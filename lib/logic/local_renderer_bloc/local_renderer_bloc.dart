import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/data/repositories/video_call_repository.dart';
import 'package:video_conf_test/utils/services/service_locator.dart';

part 'local_renderer_event.dart';
part 'local_renderer_state.dart';

class LocalRendererBloc extends Bloc<LocalRendererEvent, LocalRendererState> {
  LocalRendererBloc() : super(LocalRendererInitial(RTCVideoRenderer())) {
    final VideoCallRepository repository = locator.get<VideoCallRepository>();
    on<InitLocalRenderer>((event, emit) async {
      final RTCVideoRenderer renderer = RTCVideoRenderer();
      await renderer.initialize();
      emit(LocalRendererInitial(renderer..srcObject = event.stream));
    });
    on<CloseLocalVideo>((event, emit) async {
      await repository.deactivateVideoRender(state.localRenderer).then(
          (result) => result.fold(
              (l) => emit(LocalRendererError(state.localRenderer, l.message)),
              (r) => emit(LocalRendererClosed(r))));
    });
  }
}
