import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/utils/services/webrtc_service.dart';

class WebRTCProvider {
   Future<MediaStream> getUserMediaStream() async {
    return await WebRTCService.getUserMediaStream();
  }

    Future<bool> switchCamera(MediaStream mediaStream) async {
    return await WebRTCService.switchCamera(mediaStream);
  }

    bool toggleMic(MediaStream mediaStream, bool mute) {
    return WebRTCService.toggleMicActivation(mediaStream, mute);
  }
}