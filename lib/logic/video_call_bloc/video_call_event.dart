part of 'video_call_bloc.dart';

abstract class VideoCallEvent extends Equatable {}

class RoomCheck extends VideoCallEvent {
  @override
  List<Object> get props => [];
}

class SwitchCamera extends VideoCallEvent {
  @override
  List<Object> get props => [];
}

class SwitchMicActivation extends VideoCallEvent {
  final bool mute;

  SwitchMicActivation({
    required this.mute,
  });

  @override
  List<Object> get props => [mute];
}

class EndVideoCall extends VideoCallEvent {

  EndVideoCall();

  @override
  List<Object> get props => [];
}
