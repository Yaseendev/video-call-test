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

  Future<Either<Failure, String>> checkRoom() async {
    final String? roomId = await databaseProvider.getRoomId();
    return roomId != null ? Right(roomId) : Left(Failure('No Room'));
  }

  Future<Either<Failure, MediaStream>> getUserMediaStream() async {
    try {
      final MediaStream mediaStream = await webRTCProvider.getUserMediaStream();
      return Right(mediaStream);
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

  // Future<Either<Failure, String>> createRoom() async {
  //  RTCPeerConnection peerConnection = await createPeerConnection(SignallingService.configuration);

  // }
}
