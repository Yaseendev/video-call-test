import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/utils/constants.dart';

class WebRTCService {
  static Future<MediaStream> getUserMediaStream() async {
    final mediaConstraints = <String, dynamic>{
      'video': true,
      'audio': true,
    };

    try {
      return navigator.mediaDevices.getUserMedia(mediaConstraints);
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<bool> switchCamera(MediaStream mediaStream) async {
    final videoTrack = mediaStream.getVideoTracks().first;
    try {
      if (kIsWeb) {
        final cameraDevices = await Helper.cameras;
        return await Helper.switchCamera(
          videoTrack,
          cameraDevices.first.deviceId,
          mediaStream,
        );
      } else {
        return await Helper.switchCamera(videoTrack);
      }
    } catch (e) {
      throw e.toString();
    }
  }

  static bool toggleMicActivation(
      MediaStream mediaStream, bool micActivationStatus) {
    final MediaStreamTrack audioTrack = mediaStream.getAudioTracks().first;
    audioTrack.enableSpeakerphone(!micActivationStatus);
    //setMicrophoneMute(!micActivationStatus);
    return !micActivationStatus;
  }

  static Future<RTCPeerConnection> createPeerConnectionStream(
    MediaStream mediaStream) async {
    final iceServers = ServerConfig.servers;

    final configuration = ServerConfig.configuration;
    final peerConnection =
        await createPeerConnection(iceServers, configuration);
    await peerConnection.addStream(mediaStream);

    return peerConnection;
  }
}
