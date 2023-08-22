import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/data/repositories/video_call_repository.dart';

part 'local_renderer_event.dart';
part 'local_renderer_state.dart';

class LocalRendererBloc extends Bloc<LocalRendererEvent, LocalRendererState> {
    final VideoCallRepository repository;
  LocalRendererBloc({
    required this.repository,
    RTCVideoRenderer? rtcVideoRenderer,
  }) : super(LocalRendererInitial(rtcVideoRenderer ?? RTCVideoRenderer())) {
    on<InitLocalRenderer>((event, emit) async {
      final RTCVideoRenderer renderer = RTCVideoRenderer();
      await renderer.initialize();
      emit(LocalRendererInitial(renderer..srcObject = event.stream));
    });
    on<CloseLocalVideo>((event, emit) async {
     final result =  await repository.deactivateVideoRender(state.localRenderer);
           result.fold(
              (l) => emit(LocalRendererError(state.localRenderer, l.message)),
              (r) => emit(LocalRendererClosed(r)));
    });
  }
}
