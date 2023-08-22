import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/utils/services/webrtc_service.dart';

class WebRTCProvider {
  Future<MediaStream> getUserMediaStream() async {
    return await WebRTCService.getUserMediaStream();
  }

  Future<RTCVideoRenderer> deactivateVideoRender(
      RTCVideoRenderer videoRenderer) async {
    return await WebRTCService.deactivateVideoRender(videoRenderer);
  }

  Future<bool> switchCamera(MediaStream mediaStream) async {
    return await WebRTCService.switchCamera(mediaStream);
  }

  bool toggleMic(MediaStream mediaStream, bool mute) {
    return WebRTCService.toggleMicActivation(mediaStream, mute);
  }

  Future<RTCPeerConnection> createPeerConnectionStream(
    MediaStream mediaStream) async {
    return await WebRTCService.createPeerConnectionStream(
      mediaStream,
    );
  }

  Future<RTCSessionDescription> createOffer(
      RTCPeerConnection peerConnection) async {
    return await WebRTCService.createOffer(peerConnection);
  }

  Future<RTCSessionDescription> createAnswer(
      RTCPeerConnection peerConnection) async {
    return await WebRTCService.createAnswer(peerConnection);
  }
}
