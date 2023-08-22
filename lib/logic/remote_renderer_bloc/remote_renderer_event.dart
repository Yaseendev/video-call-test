part of 'remote_renderer_bloc.dart';

abstract class RemoteRendererEvent extends Equatable {
  const RemoteRendererEvent();

  @override
  List<Object> get props => [];
}

class InitRemoteRenderer extends RemoteRendererEvent {}

class AddRemoteStream extends RemoteRendererEvent {
  final MediaStream remoteStream;

  const AddRemoteStream(this.remoteStream);

  @override
  List<Object> get props => [remoteStream];
}

class ToggleRemoteRendererSpeaker extends RemoteRendererEvent {}

class StopRomteVideo extends RemoteRendererEvent {

  @override
  List<Object> get props => [];
}

class ResetRemoteRenderer extends RemoteRendererEvent {

  @override
  List<Object> get props => [];
}