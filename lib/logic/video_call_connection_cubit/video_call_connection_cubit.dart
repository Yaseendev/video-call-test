import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/data/repositories/video_call_repository.dart';

part 'video_call_connection_state.dart';

class VideoCallConnectionCubit extends Cubit<VideoCallConnectionState> {
  final VideoCallRepository repository;
  VideoCallConnectionCubit({required this.repository})
      : super(VideoCallConnectionInitial());
  RTCPeerConnection? peerConnection;
  MediaStream? remoteStream;

  void createRoom(MediaStream localStream) async {
    final connectionRes =
        await repository.establishPeerConnectionStream(localStream);
    if (connectionRes.isRight()) {
      peerConnection = connectionRes.getOrElse(() => null);
      registerPeerConnectionListeners();
      localStream.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream);
      });
    } else {
      emit(VideoCallConnectionError());
      return;
    }
    peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      repository.addCallerCandidate(candidate);
    };
    await repository.createOffer(peerConnection!);
    repository.handleCreatingRoom(
      peerConnection,
      remoteStream,
    );
  }

  void joinRoom(String roomId, MediaStream localStream) async {
    final roomResult = await repository.checkRoom(roomId);
    roomResult.fold(
      (l) => null,
      (exists) async {
        if (exists) {
          final connectionRes =
              await repository.establishPeerConnectionStream(localStream);
          if (connectionRes.isRight()) {
            peerConnection = connectionRes.getOrElse(() => null);
            registerPeerConnectionListeners();
            localStream.getTracks().forEach((track) {
              peerConnection?.addTrack(track, localStream);
            });
          } else {
            emit(VideoCallConnectionError());
            return;
          }
          peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
            if (candidate == null) {
              print('onIceCandidate: complete!');
              return;
            }
            print('onIceCandidate: ${candidate.toMap()}');
            repository.addCalleeCandidate(candidate, roomId);
          };
          peerConnection?.onTrack = (RTCTrackEvent event) {
            print('Got remote track: ${event.streams[0]}');
            event.streams[0].getTracks().forEach((track) {
              print('Add a track to the remoteStream: $track');
              remoteStream?.addTrack(track);
            });
          };

          final offerRes = await repository.getRoomOffer(roomId);
          final offer = offerRes.getOrElse(() => null);
          await peerConnection?.setRemoteDescription(
            RTCSessionDescription(offer['sdp'], offer['type']),
          );
          final answerRes = await repository.createAnswer(peerConnection!);
          final RTCSessionDescription? answer = answerRes.getOrElse(() => null);

          print('Created Answer $answer');
          if (answer != null) {
            await peerConnection!.setLocalDescription(answer);

            repository.handleJoiningRoom(
              answer,
              peerConnection,
              roomId,
            );
          }
        }
      },
    );
  }

  void endCall() async {
    peerConnection?.close();
    await repository.deleteRoom();
    remoteStream?.dispose();
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onConnectionState = (RTCPeerConnectionState rtcState) {
      print('Connection state change: $rtcState');
      if (rtcState == RTCPeerConnectionState.RTCPeerConnectionStateConnecting) {
        emit(VideoCallRemoteConnecting());
      } else if (rtcState ==
          RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        emit(VideoCallRemoteConnectionFailed());
      } else if (rtcState ==
          RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        emit(VideoCallRemoteConnected());
      }
    };

    peerConnection?.onSignalingState = (RTCSignalingState rtcState) {
      print('Signaling state change: $rtcState');
      if (rtcState == RTCSignalingState.RTCSignalingStateClosed) {
        emit(VideoCallClosed());
      } else if (rtcState ==
          RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
        emit(VideoCallConnectionInitial());
      }
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState rtcState) {
      print('ICE connection state change: $rtcState');
      if (rtcState == RTCIceGatheringState.RTCIceGatheringStateComplete) {
        emit(VideoCallConnectionCreated());
      }
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream");
      remoteStream = stream;
      emit(VideoCallRemoteStreamAdded(remoteStream: stream));
    };
  }

  @override
  Future<void> close() {
    peerConnection?.dispose();
    remoteStream?.dispose();
    return super.close();
  }
}
