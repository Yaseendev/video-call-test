import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/data/repositories/video_call_repository.dart';

part 'remote_renderer_event.dart';
part 'remote_renderer_state.dart';

class RemoteRendererBloc
    extends Bloc<RemoteRendererEvent, RemoteRendererState> {
    final VideoCallRepository repository;
  RemoteRendererBloc({
    required this.repository,
    RTCVideoRenderer? rtcVideoRenderer,
  })
      : super(RemoteRendererInitial(
        rtcVideoRenderer ??  RTCVideoRenderer(),
        )) {
    on<InitRemoteRenderer>((event, emit) async {
      final RTCVideoRenderer renderer = RTCVideoRenderer();
      await renderer.initialize();
      emit(RemoteRendererInitialized(renderer
        ..srcObject = await createLocalMediaStream('key')));
    });

    on<AddRemoteStream>((event, emit) {
      emit(RemoteRendererStreamAdded(
          state.remoteRenderer..srcObject = event.remoteStream));
    });

    on<ToggleRemoteRendererSpeaker>((event, emit) {
      emit(RemoteRendererSettingsChanged(
          state.remoteRenderer..muted = !state.remoteRenderer.muted));
    });

    on<StopRomteVideo>((event, emit) async {
      await repository.deactivateVideoRender(state.remoteRenderer).then(
          (result) => result.fold(
              (l) => emit(RemoteRendererError(state.remoteRenderer, l.message)),
              (r) => emit(RemoteRendererStopped(r))));
    });
  }
}
