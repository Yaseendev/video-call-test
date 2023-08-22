import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/data/models/network_failure.dart';
import 'package:video_conf_test/data/providers/webrtc_provider.dart';
import 'package:video_conf_test/utils/services/signalling_service.dart';
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

  Future<void> createRoom(
    RTCPeerConnection? peerConnection,
    MediaStream? remoteStream,
  ) async {
    // var callerCandidatesCollection = docRef.collection('callerCandidates');
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      //FIXME
      print('Got candidate: ${candidate.toMap()}');
      databaseProvider.addCallerCandidates(candidate.toMap());
      //callerCandidatesCollection.add(candidate.toMap());
    };

    final RTCSessionDescription offer =
        await webRTCProvider.createOffer(peerConnection!);
    await peerConnection.setLocalDescription(offer);
    print('Created offer: $offer');
    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};
    await databaseProvider.addToRoom(roomWithOffer);

    peerConnection.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };

    // Listening for remote session description below
    databaseProvider.getRoomStream().listen((snapshot) async {
      print('Got updated room: ${snapshot.data()}');

      Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
      if (data?['answer'] != null) {
        var answer = RTCSessionDescription(
          data?['answer']['sdp'],
          data?['answer']['type'],
        );

        print("Someone tried to connect");
        await peerConnection.setRemoteDescription(answer);
      }
    });

    // Listen for remote Ice candidates below
    databaseProvider.getCalleeCandidatesStream().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          peerConnection.addCandidate(
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

  Future<void> joinRoom(
      // RTCPeerConnection? peerConnection,
      // MediaStream? remoteStream,
      String roomId,
      MediaStream localStream,
      RTCPeerConnection? peerConnection,
      Function s,
      MediaStream? remoteStream) async {
     DocumentReference roomRef =databaseProvider.remoteDB.collection('rooms').doc('$roomId');
     var roomSnapshot = await roomRef.get();
    // print('Got room ${roomSnapshot.exists}');

    // if (roomSnapshot.exists) {
    //   //print('Create PeerConnection with configuration: $configuration');
    //   peerConnection =
    //       await createPeerConnection(SignallingService.configuration);
    //   s();

    //   localStream.getTracks().forEach((track) {
    //     peerConnection?.addTrack(track, localStream);
    //   });

      // Code for collecting ICE candidates below
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) {
        if (candidate == null) {
          print('onIceCandidate: complete!');
          return;
        }
        print('onIceCandidate: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap());
      };
      // Code for collecting ICE candidate above

      peerConnection?.onTrack = (RTCTrackEvent event) {
        print('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          print('Add a track to the remoteStream: $track');
          remoteStream?.addTrack(track);
        });
      };

      // Code for creating SDP answer below
      var data = roomSnapshot.data() as Map<String, dynamic>;
      print('Got offer $data');
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peerConnection!.createAnswer();
      print('Created Answer $answer');

      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await roomRef.update(roomWithAnswer);
      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          var data = document.doc.data();
          print(data);
          print('Got new remote ICE candidate: $data');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data?['candidate'],
              data?['sdpMid'],
              data?['sdpMLineIndex'],
            ),
          );
        });
      });
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
