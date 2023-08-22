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

  VideoCallBloc() : super(VideoCallInitial(micMuted: false)) {
    final VideoCallRepository repository = locator.get<VideoCallRepository>();
    on<RoomCheck>((event, emit) async {
      await repository.getUserMediaStream().then(
            (streamRes) => streamRes.fold(
                (l) => emit(VideoCallError(
                      error: l.message,
                      micMuted: state.isMute,
                    )), (r) async {
              final MediaStream stream = r;
              localStream = stream;
              emit(VideoCallInitialized(
                stream: stream,
                micMuted: state.isMute,
              ));
              await repository.fetchRoom().then(
                    (value) => value.fold(
                      (l) async {
                        if (l.message == 'No Room') {
                          emit(VideoCallCreating(
                            localStream: stream,
                            micMuted: state.isMute,
                          ));
                        } else {
                          emit(VideoCallError(
                            error: l.message,
                            micMuted: state.isMute,
                          ));
                        }
                      },
                      (roomId) async {
                        print('RoomId: $roomId');
                        emit(VideoCallConnecting(
                          roomId: roomId,
                          localStream: localStream!,
                          micMuted: state.isMute,
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
        res.fold(
            (l) => emit(VideoCallError(
                  error: l.message,
                  micMuted: state.isMute,
                )),
            (r) => null);
      }
    });

    on<SwitchMicActivation>((event, emit) async {
      if (localStream != null) {
        final res = await repository.toggleMicMute(localStream!, event.mute);
        res.fold(
            (l) => emit(VideoCallError(
                  error: l.message,
                  micMuted: state.isMute,
                )),
            (r) => emit(VideoCallMute(
                  mute: event.mute,
                )));
      }
    });

    on<EndVideoCall>((event, emit) {
      emit(VideoCallEnded());
    });
  }
}
