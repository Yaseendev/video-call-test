part of 'video_call_bloc.dart';

abstract class VideoCallState extends Equatable {
  final bool isMute;
  final bool isSpeakerEnabled;
  VideoCallState({
    this.isMute = false,
    this.isSpeakerEnabled = true,
  });

  @override
  List<Object?> get props => [isMute];
}

class VideoCallInitial extends VideoCallState {
  @override
  List<Object?> get props => [];
}

class VideoCallConnecting extends VideoCallState {
  final String roomId;
  final MediaStream localStream;
  VideoCallConnecting({
    required this.roomId,
    required this.localStream,
  });
  @override
  List<Object?> get props => [roomId, localStream];
}

class VideoCallCreating extends VideoCallState {
  final MediaStream localStream;

  VideoCallCreating({
    required this.localStream,
  });

  @override
  List<Object?> get props => [localStream];
}

class VideoCallInitialized extends VideoCallState {
  final MediaStream stream;

  VideoCallInitialized({required this.stream});

  @override
  List<Object?> get props => [this.stream];
}

class VideoCallConnected extends VideoCallState {
  final MediaStream stream;

  VideoCallConnected({required this.stream});

  @override
  List<Object?> get props => [stream];
}

class VideoCallError extends VideoCallState {
  final String? error;
  final bool micMuted;
  final bool speakerEnabled;

  VideoCallError(
      {required this.micMuted, required this.speakerEnabled, this.error}) : super(isSpeakerEnabled: speakerEnabled, isMute: micMuted);

  @override
  List<Object?> get props => [error, micMuted, speakerEnabled];
}

class VideoCallMute extends VideoCallState {
  final bool mute;
  final bool speakerEnabled;

  VideoCallMute({required this.mute, required this.speakerEnabled})
      : super(isMute: mute, isSpeakerEnabled: speakerEnabled);

  @override
  List<Object?> get props => [mute, speakerEnabled];
}

class VideoCallSpeakerChanged extends VideoCallState {
  final bool enabled;
  final bool micMuted;

  VideoCallSpeakerChanged({required this.enabled, required this.micMuted})
      : super(isSpeakerEnabled: enabled, isMute: micMuted);

  @override
  List<Object?> get props => [enabled, micMuted];
}
