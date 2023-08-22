import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_conf_test/data/models/network_failure.dart';
import 'package:video_conf_test/data/repositories/video_call_repository.dart';
import 'package:video_conf_test/logic/remote_renderer_bloc/remote_renderer_bloc.dart';

class MockVideoCallRepository extends Mock implements VideoCallRepository {}

class MockMediaStream extends Mock implements MediaStream {}

class MockRTCVideoRenderer extends Mock implements RTCVideoRenderer {}

void main() {
  group('Remote Renderer Bloc Tests', () {
    late RemoteRendererBloc remoteRendererBloc;
    late MockRTCVideoRenderer mockRTCVideoRenderer;
    late MockVideoCallRepository mockVideoCallRepository;
    late MockMediaStream mockMediaStream;

    setUp(() {
      mockVideoCallRepository = MockVideoCallRepository();
      mockRTCVideoRenderer = MockRTCVideoRenderer();
      mockMediaStream = MockMediaStream();
      remoteRendererBloc = RemoteRendererBloc(
        repository: mockVideoCallRepository,
        rtcVideoRenderer: mockRTCVideoRenderer,
      );
    });

    test('Initial Test', () {
      expect(remoteRendererBloc.state,
          RemoteRendererInitial(mockRTCVideoRenderer));
    });

    blocTest<RemoteRendererBloc, RemoteRendererState>(
      'emits [RemoteRendererInitialized] when InitRemoteRenderer is added',
      build: () => remoteRendererBloc,
      setUp: () {
        when(() => mockRTCVideoRenderer.initialize())
            .thenAnswer((invocation) => Future.value());
      },
      act: (bloc) => bloc.add(InitRemoteRenderer()),
      expect: () => <RemoteRendererState>[
        RemoteRendererInitialized(mockRTCVideoRenderer),
      ],
    );

    blocTest<RemoteRendererBloc, RemoteRendererState>(
      'emits [RemoteRendererStreamAdded] when AddRemoteStream is added',
      build: () => remoteRendererBloc,
      act: (bloc) => bloc.add(AddRemoteStream(mockMediaStream)),
      expect: () => <RemoteRendererState>[
        RemoteRendererStreamAdded(mockRTCVideoRenderer),
      ],
    );

    blocTest<RemoteRendererBloc, RemoteRendererState>(
      'emits [RemoteRendererSettingsChanged] when ToggleRemoteRendererSpeaker is added',
      build: () => remoteRendererBloc,
      act: (bloc) => bloc.add(ToggleRemoteRendererSpeaker()),
      expect: () => <RemoteRendererState>[
        RemoteRendererSettingsChanged(mockRTCVideoRenderer),
      ],
    );

    blocTest<RemoteRendererBloc, RemoteRendererState>(
      'emits [RemoteRendererError] when StopRomteVideo is added and deactivateVideoRender returns left',
      build: () => remoteRendererBloc,
      setUp: () {
        when(() => mockVideoCallRepository
                .deactivateVideoRender(mockRTCVideoRenderer))
            .thenAnswer((invocation) => Future.value(Left(Failure('message'))));
      },
      act: (bloc) => bloc.add(StopRomteVideo()),
      expect: () => <RemoteRendererState>[
        RemoteRendererError(mockRTCVideoRenderer, 'message'),
      ],
    );

    blocTest<RemoteRendererBloc, RemoteRendererState>(
      'emits [RemoteRendererStopped] when StopRomteVideo is added and deactivateVideoRender returns right',
      build: () => remoteRendererBloc,
      setUp: () {
        when(() => mockVideoCallRepository
                .deactivateVideoRender(mockRTCVideoRenderer))
            .thenAnswer(
                (invocation) => Future.value(Right(mockRTCVideoRenderer)));
      },
      act: (bloc) => bloc.add(StopRomteVideo()),
      expect: () => <RemoteRendererState>[
        RemoteRendererStopped(mockRTCVideoRenderer),
      ],
    );
  });
}
