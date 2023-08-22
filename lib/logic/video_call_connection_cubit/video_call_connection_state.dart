part of 'video_call_connection_cubit.dart';

class VideoCallConnectionState extends Equatable {
  const VideoCallConnectionState();

  @override
  List<Object?> get props => [];
}

class VideoCallConnectionInitial extends VideoCallConnectionState {}

class VideoCallRemoteStreamAdded extends VideoCallConnectionState {
  final MediaStream remoteStream;
  VideoCallRemoteStreamAdded({
    required this.remoteStream,
  });

  @override
  List<Object> get props => [remoteStream];  
}

class VideoCallConnectionCreated extends VideoCallConnectionState {}
class VideoCallRemoteConnecting extends VideoCallConnectionState {}
class VideoCallRemoteConnected extends VideoCallConnectionState {}
class VideoCallRemoteConnectionFailed extends VideoCallConnectionState {}
class VideoCallClosed extends VideoCallConnectionState {}

class VideoCallConnectionError extends VideoCallConnectionState {
  final String? msg;
  const VideoCallConnectionError([this.msg]);

  @override
  List<Object?> get props => [msg];
}