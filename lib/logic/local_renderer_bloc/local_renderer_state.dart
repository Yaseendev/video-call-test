part of 'local_renderer_bloc.dart';

abstract class LocalRendererState extends Equatable {
  final RTCVideoRenderer localRenderer;
  const LocalRendererState(this.localRenderer);

  @override
  List<Object?> get props => [localRenderer];
}

class LocalRendererInitial extends LocalRendererState {
  LocalRendererInitial(super.localRenderer);
}

class LocalRendererClosed extends LocalRendererState {
  LocalRendererClosed(super.localRenderer);
}

class LocalRendererError extends LocalRendererState {
  final String? msg;
  LocalRendererError(super.localRenderer, [this.msg]);

  @override
  List<Object?> get props => [msg];
}
