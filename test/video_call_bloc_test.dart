import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_conf_test/data/models/network_failure.dart';
import 'package:video_conf_test/data/repositories/video_call_repository.dart';
import 'package:video_conf_test/logic/video_call_bloc/video_call_bloc.dart';
import 'package:bloc_test/bloc_test.dart';

class MockVideoCallRepository extends Mock implements VideoCallRepository {}

class MockMediaStream extends Mock implements MediaStream {}

void main() {
  group('Video Call Bloc Testing', () {
    late VideoCallBloc videoCallBloc;
    late MockVideoCallRepository mockVideoCallRepository;
    late MockMediaStream mockMediaStream;

    setUp(() {
      mockVideoCallRepository = MockVideoCallRepository();
      videoCallBloc = VideoCallBloc(repository: mockVideoCallRepository);
      mockMediaStream = MockMediaStream();
    });
    test('Initial Test', () {
      expect(videoCallBloc.state, VideoCallInitial(micMuted: false));
    });

    blocTest<VideoCallBloc, VideoCallState>(
      'emits [VideoCallError] when RoomCheck is added and getUserMediaStream failed',
      build: () => videoCallBloc,
      setUp: () {
        when(() => mockVideoCallRepository.getUserMediaStream())
            .thenAnswer((invocation) => Future.value(Left(Failure(''))));
      },
      act: (bloc) => bloc.add(RoomCheck()),
      expect: () => <VideoCallState>[
        VideoCallError(
          error: '',
          micMuted: false,
        )
      ],
    );

    blocTest<VideoCallBloc, VideoCallState>(
      'emits [VideoCallInitialized,VideoCallCreating] when RoomCheck is added and fetchRoom returns left and no room found',
      build: () => videoCallBloc,
      setUp: () {
        when(() => mockVideoCallRepository.getUserMediaStream())
            .thenAnswer((invocation) => Future.value(Right(mockMediaStream)));
        when(() => mockVideoCallRepository.fetchRoom())
            .thenAnswer((invocation) => Future.value(Left(Failure('No Room'))));
      },
      act: (bloc) => bloc.add(RoomCheck()),
      expect: () => <VideoCallState>[
        VideoCallInitialized(
          stream: mockMediaStream,
          micMuted: false,
        ),
        VideoCallCreating(
          localStream: mockMediaStream,
          micMuted: false,
        ),
      ],
    );

    blocTest<VideoCallBloc, VideoCallState>(
      'emits [VideoCallInitialized,VideoCallError] when RoomCheck is added and fetchRoom returns left and there is an error',
      build: () => videoCallBloc,
      setUp: () {
        when(() => mockVideoCallRepository.getUserMediaStream())
            .thenAnswer((invocation) => Future.value(Right(mockMediaStream)));
        when(() => mockVideoCallRepository.fetchRoom())
            .thenAnswer((invocation) => Future.value(Left(Failure(''))));
      },
      act: (bloc) => bloc.add(RoomCheck()),
      expect: () => <VideoCallState>[
        VideoCallInitialized(
          stream: mockMediaStream,
          micMuted: false,
        ),
        VideoCallError(
          error: '',
          micMuted: false,
        ),
      ],
    );

    blocTest<VideoCallBloc, VideoCallState>(
      'emits [VideoCallInitialized,VideoCallConnecting] when RoomCheck is added and fetchRoom returns right',
      build: () => videoCallBloc,
      setUp: () {
        when(() => mockVideoCallRepository.getUserMediaStream())
            .thenAnswer((invocation) => Future.value(Right(mockMediaStream)));
        when(() => mockVideoCallRepository.fetchRoom())
            .thenAnswer((invocation) => Future.value(Right('1')));
      },
      act: (bloc) => bloc.add(RoomCheck()),
      expect: () => <VideoCallState>[
        VideoCallInitialized(
          stream: mockMediaStream,
          micMuted: false,
        ),
        VideoCallConnecting(
          roomId: '1',
          localStream: mockMediaStream,
          micMuted: false,
        ),
      ],
    );

    blocTest<VideoCallBloc, VideoCallState>(
      'emits [VideoCallEnded] when EndVideoCall is added',
      build: () => videoCallBloc,
      act: (bloc) => bloc.add(EndVideoCall()),
      expect: () => <VideoCallState>[
        VideoCallEnded(),
      ],
    );

  });
}
