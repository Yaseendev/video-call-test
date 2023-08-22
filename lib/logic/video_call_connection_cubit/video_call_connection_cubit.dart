import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/data/repositories/video_call_repository.dart';
import 'package:video_conf_test/utils/services/service_locator.dart';
import 'package:video_conf_test/utils/services/signalling_service.dart';

part 'video_call_connection_state.dart';

class VideoCallConnectionCubit extends Cubit<VideoCallConnectionState> {
  VideoCallConnectionCubit() : super(VideoCallConnectionInitial());
  final VideoCallRepository repository = locator.get<VideoCallRepository>();
  RTCPeerConnection? peerConnection;
  MediaStream? remoteStream;

  void createRoom(MediaStream localStream) async {
    final connectionRes =
        await repository.establishPeerConnectionStream(localStream);
    if (connectionRes.isRight()) {
      peerConnection = connectionRes.getOrElse(() => null);
    } else {
      emit(VideoCallConnectionError());
      return;
    }
    registerPeerConnectionListeners();
    repository.createRoom(
      peerConnection,
      remoteStream,
    );
  }

  void joinRoom(String roomId, MediaStream localStream) async {
    repository.joinRoom(
      roomId,
      localStream,
      peerConnection,
      (){
        registerPeerConnectionListeners();
      },
      remoteStream,
    );
  }

  void endCall() async {
    peerConnection?.close();
    var db = FirebaseFirestore.instance;
    var roomRef = await db.collection('rooms').get();
    for (var doc in roomRef.docs) {
      await db.runTransaction((transaction) async {
        transaction.delete(doc.reference);
      });
    }
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
