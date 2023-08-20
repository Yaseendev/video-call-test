import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/data/models/network_failure.dart';
import 'package:video_conf_test/utils/services/signalling_service.dart';
import '../providers/video_call_database_provider.dart';
import 'package:dartz/dartz.dart';

class VideoCallRepository {
  late final VideoCallDatabaseProvider databaseProvider;

  VideoCallRepository({required VideoCallDatabaseProvider databaseProvider}) {
    this.databaseProvider = databaseProvider;
  }

  Future<Either<Failure, String>> checkRoom() async {
    final String? roomId = await databaseProvider.getRoomId();
    return roomId != null ? Right(roomId)
    : Left(Failure('No Room'));
  }

  // Future<Either<Failure, String>> createRoom() async {
  //  RTCPeerConnection peerConnection = await createPeerConnection(SignallingService.configuration);

  // }
}
