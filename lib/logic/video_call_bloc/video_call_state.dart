part of 'video_call_bloc.dart';

abstract class VideoCallState extends Equatable {
  final bool isMute;
  VideoCallState({
    required this.isMute,
  });

  @override
  List<Object?> get props => [isMute];
}

class VideoCallInitial extends VideoCallState {
  final bool micMuted;

  VideoCallInitial({
    required this.micMuted,
  }) : super( isMute: micMuted);

  @override
  List<Object?> get props => [micMuted];
}

class VideoCallConnecting extends VideoCallState {
  final String roomId;
  final MediaStream localStream;
  final bool micMuted;

  VideoCallConnecting({
    required this.roomId,
    required this.localStream,
    required this.micMuted,
  }) : super( isMute: micMuted);

  @override
  List<Object?> get props => [roomId, localStream, micMuted];
}

class VideoCallCreating extends VideoCallState {
  final MediaStream localStream;
  final bool micMuted;

  VideoCallCreating({
    required this.localStream,
    required this.micMuted,
  }) : super(isMute: micMuted);

  @override
  List<Object?> get props => [localStream, micMuted];
}

class VideoCallInitialized extends VideoCallState {
  final MediaStream stream;
  final bool micMuted;

  VideoCallInitialized({
    required this.stream,
    required this.micMuted,
  }) : super( isMute: micMuted);

  @override
  List<Object?> get props => [stream, micMuted];
}

class VideoCallConnected extends VideoCallState {
  final MediaStream stream;
  final bool micMuted;

  VideoCallConnected({
    required this.stream,
    required this.micMuted,
  }) : super(isMute: micMuted);

  @override
  List<Object?> get props => [stream, micMuted];
}

class VideoCallError extends VideoCallState {
  final String? error;
  final bool micMuted;

  VideoCallError(
      {required this.micMuted, this.error})
      : super( isMute: micMuted);

  @override
  List<Object?> get props => [error, micMuted];
}

class VideoCallMute extends VideoCallState {
  final bool mute;

  VideoCallMute({required this.mute})
      : super(isMute: mute);

  @override
  List<Object?> get props => [mute];
}

class VideoCallEnded extends VideoCallState {

  VideoCallEnded() : super(isMute: false);

  @override
  List<Object?> get props => [];
}
