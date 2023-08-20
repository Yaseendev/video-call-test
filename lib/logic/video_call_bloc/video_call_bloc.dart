import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/data/repositories/video_call_repository.dart';
import 'package:video_conf_test/utils/services/service_locator.dart';
import 'package:video_conf_test/utils/services/signalling_service.dart';

part 'video_call_event.dart';
part 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  MediaStream? localStream;

  VideoCallBloc() : super(VideoCallInitial()) {
    final VideoCallRepository repository = locator.get<VideoCallRepository>();
    on<RoomCheck>((event, emit) async {
      await repository.getUserMediaStream().then(
            (streamRes) => streamRes
                .fold((l) => emit(VideoCallError(l.message)), (r) async {
              final MediaStream stream = r;
              localStream = stream;
              emit(VideoCallInitialized(stream: stream));
              await repository.checkRoom().then(
                    (value) => value.fold(
                      (l) async {
                        if (l.message == 'No Room') {
                          emit(VideoCallCreating(localStream: stream));
                        } else {
                          emit(VideoCallError(l.message));
                        }
                      },
                      (roomId) async {
                        print('RoomId: $roomId');
                        emit(VideoCallConnecting(
                          roomId: roomId,
                          localStream: localStream!,
                        ));
                      },
                    ),
                  );
            }),
          );
    });

    on<SwitchCamera>((event, emit) async {
      if (localStream != null) {
        final res = await repository.switchCamera(localStream!);
        res.fold((l) => null, (r) => null);
      }
    });
  }
}
