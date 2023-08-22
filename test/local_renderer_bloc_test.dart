import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_conf_test/data/models/network_failure.dart';
import 'package:video_conf_test/data/repositories/video_call_repository.dart';
import 'package:video_conf_test/logic/local_renderer_bloc/local_renderer_bloc.dart';

class MockVideoCallRepository extends Mock implements VideoCallRepository {}
class MockMediaStream extends Mock implements MediaStream {}
class MockRTCVideoRenderer extends Mock implements RTCVideoRenderer {}

void main() {
  group('Local Renderer Bloc Tests', () {
    late LocalRendererBloc localRendererBloc;
    late MockRTCVideoRenderer mockRTCVideoRenderer;
    late MockVideoCallRepository mockVideoCallRepository;
    late MockMediaStream mockMediaStream;

    setUp(() {
      mockVideoCallRepository = MockVideoCallRepository();
      mockRTCVideoRenderer = MockRTCVideoRenderer();
      mockMediaStream = MockMediaStream();
      localRendererBloc = LocalRendererBloc(repository: mockVideoCallRepository,
      rtcVideoRenderer: mockRTCVideoRenderer,
      );
    });

    test('Initial Test', () {
      expect(localRendererBloc.state, LocalRendererInitial(mockRTCVideoRenderer));
    });

      blocTest<LocalRendererBloc, LocalRendererState>(
      'emits [LocalRendererInitial] when InitLocalRenderer is added',
      build: () => localRendererBloc,
      setUp: () {
        when(() => mockRTCVideoRenderer.initialize())
            .thenAnswer((invocation) => Future.value());
      },
      act: (bloc) => bloc.add(InitLocalRenderer(stream: mockMediaStream)),
      expect: () => <LocalRendererState>[
        LocalRendererInitial(mockRTCVideoRenderer),
      ],
    );

      blocTest<LocalRendererBloc, LocalRendererState>(
      'emits [LocalRendererError] when CloseLocalVideo is added and deactivateVideoRender returns left',
      build: () => localRendererBloc,
      setUp: () {
        when(() => mockVideoCallRepository.deactivateVideoRender(mockRTCVideoRenderer))
            .thenAnswer((invocation) => Future.value(Left( Failure('') )));
      },
      act: (bloc) => bloc.add(CloseLocalVideo()),
      expect: () => <LocalRendererState>[
        LocalRendererError(mockRTCVideoRenderer),
      ],
    );

      blocTest<LocalRendererBloc, LocalRendererState>(
      'emits [LocalRendererClosed] when CloseLocalVideo is added and deactivateVideoRender returns right',
      build: () => localRendererBloc,
      setUp: () {
        when(() => mockVideoCallRepository.deactivateVideoRender(mockRTCVideoRenderer))
            .thenAnswer((invocation) => Future.value(Right(mockRTCVideoRenderer)));
      },
      act: (bloc) => bloc.add(CloseLocalVideo()),
      expect: () => <LocalRendererState>[
        LocalRendererClosed(mockRTCVideoRenderer),
      ],
    );

  });
}
