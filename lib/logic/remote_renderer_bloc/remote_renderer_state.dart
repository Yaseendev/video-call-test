part of 'remote_renderer_bloc.dart';

abstract class RemoteRendererState extends Equatable {
  final RTCVideoRenderer remoteRenderer;
  const RemoteRendererState(this.remoteRenderer);
  
  @override
  List<Object?> get props => [remoteRenderer];
}

class RemoteRendererInitial extends RemoteRendererState {
  RemoteRendererInitial(super.remoteRenderer);
}

class RemoteRendererInitialized extends RemoteRendererState {
  RemoteRendererInitialized(super.remoteRenderer);
}

class RemoteRendererStreamAdded extends RemoteRendererState {
  RemoteRendererStreamAdded(super.remoteRenderer);
}

class RemoteRendererSettingsChanged extends RemoteRendererState {
  RemoteRendererSettingsChanged(super.remoteRenderer);
}

class RemoteRendererStopped extends RemoteRendererState {
  RemoteRendererStopped(super.remoteRenderer);
}

class RemoteRendererError extends RemoteRendererState {
  final String? msg;
  RemoteRendererError(super.remoteRenderer, [this.msg]);

  @override
  List<Object?> get props => [msg];
}