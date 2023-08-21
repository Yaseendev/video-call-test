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

class SwitchSpeakerActivation extends VideoCallEvent {
  final bool enabled;

  SwitchSpeakerActivation({
    required this.enabled,
  });

  @override
  List<Object> get props => [enabled];
}
