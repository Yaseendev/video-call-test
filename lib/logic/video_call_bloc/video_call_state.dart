part of 'video_call_bloc.dart';

abstract class VideoCallState extends Equatable {}

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

  VideoCallError([this.error]);

  @override
  List<Object?> get props => [error];
}
