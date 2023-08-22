part of 'local_renderer_bloc.dart';

abstract class LocalRendererEvent extends Equatable {
  const LocalRendererEvent();

  @override
  List<Object> get props => [];
}

class InitLocalRenderer extends LocalRendererEvent {
  final MediaStream stream;
  InitLocalRenderer({
    required this.stream,
  });
  @override
  List<Object> get props => [stream];
}

class CloseLocalVideo extends LocalRendererEvent {

  @override
  List<Object> get props => [];
}
