part of 'video_call_bloc.dart';

abstract class VideoCallEvent extends Equatable{

}

class RoomCheck extends VideoCallEvent{

  @override
  List<Object> get props => [];
}

class SwitchCamera extends VideoCallEvent {
  
  @override
  List<Object> get props => [];
}