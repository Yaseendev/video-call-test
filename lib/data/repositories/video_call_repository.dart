import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/data/models/network_failure.dart';
import 'package:video_conf_test/data/providers/webrtc_provider.dart';
import '../providers/video_call_database_provider.dart';
import 'package:dartz/dartz.dart';

class VideoCallRepository {
  late final VideoCallDatabaseProvider databaseProvider;
  late final WebRTCProvider webRTCProvider;

  VideoCallRepository(
      {required VideoCallDatabaseProvider databaseProvider,
      required WebRTCProvider webRTCProvider}) {
    this.databaseProvider = databaseProvider;
    this.webRTCProvider = webRTCProvider;
  }

  Future<Either<Failure, String>> fetchRoom() async {
    final String? roomId = await databaseProvider.getRoomId();
    return roomId != null ? Right(roomId) : Left(Failure('No Room'));
  }

  Future<Either<Failure, bool>> checkRoom(String roomId) async {
    try {
      return Right(await databaseProvider.checkRoomId(roomId));
    } catch (e) {}
    return Left(Failure('No Room'));
  }

  Future<void> handleCreatingRoom(
    RTCPeerConnection? peerConnection,
    MediaStream? remoteStream,
  ) async {
    peerConnection?.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };

    /// Listening for remote session description
    databaseProvider.getRoomStream().listen((snapshot) async {
      print('Got updated room: ${snapshot.data()}');

      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data?['answer'] != null) {
        var answer = RTCSessionDescription(
          data?['answer']['sdp'],
          data?['answer']['type'],
        );

        print("Someone tried to connect");
        await peerConnection?.setRemoteDescription(answer);
      }
    });

    /// Listen for remote Ice candidates below
    databaseProvider.getCalleeCandidatesStream().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          peerConnection?.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    });
  }

  Future<void> handleJoiningRoom(
    RTCSessionDescription answer,
    RTCPeerConnection? peerConnection,
    String roomId,
  ) async {
    final Map<String, dynamic> roomWithAnswer = {
      'answer': {'type': answer.type, 'sdp': answer.sdp}
    };
    await databaseProvider.updateRoomData(roomWithAnswer, roomId);

    /// Listening for remote ICE candidates
    databaseProvider.getCallerCandidatesStream().listen((snapshot) {
      snapshot.docChanges.forEach((document) {
        var data = document.doc.data() as Map<String, dynamic>;
        print(data);
        print('Got new remote ICE candidate: $data');
        peerConnection?.addCandidate(
          RTCIceCandidate(
            data['candidate'],
            data['sdpMid'],
            data['sdpMLineIndex'],
          ),
        );
      });
    });
  }

  Future<Either<Failure, dynamic>> getRoomOffer(String roomId) async {
    try {
      final data = await databaseProvider.getRoomData(roomId);
      print('Got offer $data');
      return Right(data?['offer']);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> deleteRoom() async {
    try {
      await databaseProvider.deleteRooms();
      return Right(true);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, RTCSessionDescription?>> createAnswer(RTCPeerConnection peerConnection) async {
    try {
      return Right(await webRTCProvider.createAnswer(peerConnection));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  void addCallerCandidate(RTCIceCandidate candidate) {
    databaseProvider.addCallerCandidates(candidate.toMap());
  }

  void addCalleeCandidate(RTCIceCandidate candidate, String roomId) {
    databaseProvider.addCalleeCandidate(candidate.toMap(), roomId);
  }

  Future<void> createOffer(RTCPeerConnection peerConnection) async {
    try {
      final RTCSessionDescription offer =
          await webRTCProvider.createOffer(peerConnection);
      await peerConnection.setLocalDescription(offer);
      print('Created offer: $offer');
      final Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};
      await databaseProvider.addToRoom(roomWithOffer);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<Either<Failure, MediaStream>> getUserMediaStream() async {
    try {
      final MediaStream mediaStream = await webRTCProvider.getUserMediaStream();
      return Right(mediaStream);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, RTCVideoRenderer>> deactivateVideoRender(
      RTCVideoRenderer videoRenderer) async {
    try {
      return Right(await webRTCProvider.deactivateVideoRender(videoRenderer));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> switchCamera(MediaStream mediaStream) async {
    try {
      return Right(await webRTCProvider.switchCamera(mediaStream));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, bool>> toggleMicMute(
      MediaStream mediaStream, bool mute) async {
    try {
      return Right(webRTCProvider.toggleMic(mediaStream, mute));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, RTCPeerConnection?>> establishPeerConnectionStream(
      MediaStream mediaStream) async {
    try {
      return Right(
          await webRTCProvider.createPeerConnectionStream(mediaStream));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
