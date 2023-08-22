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

  static Future<RTCVideoRenderer> deactivateVideoRender(
      RTCVideoRenderer videoRenderer) async {
    final List<MediaStreamTrack> tracks = videoRenderer.srcObject!.getTracks();
    tracks.forEach((track) {
      track.stop();
    });
    await videoRenderer.srcObject?.dispose();
    videoRenderer.srcObject = null;
    await videoRenderer.dispose();
    return videoRenderer;
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

  // static bool toggleMicActivation(
  //     MediaStream mediaStream, bool micActivationStatus) {
  //   final MediaStreamTrack audioTrack = mediaStream.getAudioTracks().first;
  //   audioTrack.enableSpeakerphone(!micActivationStatus);
  //   //setMicrophoneMute(!micActivationStatus);
  //   return !micActivationStatus;
  // }

  static bool toggleMicActivation(
      MediaStream mediaStream, bool micActivationStatus) {
    final audioTrack = mediaStream.getAudioTracks().first;
    try {
      Helper.setMicrophoneMute(
        micActivationStatus,
        audioTrack,
      );
      return true;
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<RTCPeerConnection> createPeerConnectionStream(
      MediaStream mediaStream) async {
    final iceServers = ServerConfig.servers;

    final configuration = ServerConfig.configuration;
    final peerConnection =
        await createPeerConnection(iceServers, configuration);
    await peerConnection.addStream(mediaStream);
    mediaStream.getTracks().forEach((track) {
      peerConnection.addTrack(track, mediaStream);
    });
    return peerConnection;
  }

    static Future<RTCSessionDescription> createOffer(
      RTCPeerConnection peerConnection) async {
    final offerSdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': <dynamic>[],
    };
    try {
      return await peerConnection.createOffer(offerSdpConstraints);
    } catch (e) {
      throw e.toString();
    }
  }
}
