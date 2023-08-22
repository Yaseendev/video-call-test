import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/data/repositories/video_call_repository.dart';
import 'package:video_conf_test/logic/remote_renderer_bloc/remote_renderer_bloc.dart';
import 'package:video_conf_test/logic/video_call_bloc/video_call_bloc.dart';
import 'package:video_conf_test/logic/video_call_connection_cubit/video_call_connection_cubit.dart';
import 'package:video_conf_test/utils/services/service_locator.dart';
import 'stream_error_view.dart';
import 'stream_placeholder.dart';

class RemoteStreamView extends StatefulWidget {
  const RemoteStreamView({super.key});

  @override
  State<RemoteStreamView> createState() => _RemoteStreamViewState();
}

class _RemoteStreamViewState extends State<RemoteStreamView> {
  final RemoteRendererBloc _rendererBloc = RemoteRendererBloc(
    repository: locator.get<VideoCallRepository>(),
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoCallBloc, VideoCallState>(
      listener: (context, state) async {
        if (state is VideoCallInitialized) {
          _rendererBloc.add(InitRemoteRenderer());
        } else if (state is VideoCallEnded) {
          _rendererBloc.add(StopRomteVideo());
        }
      },
      child: BlocConsumer<VideoCallConnectionCubit, VideoCallConnectionState>(
        listener: (context, state) {
          if (state is VideoCallRemoteStreamAdded) {
            _rendererBloc.add(AddRemoteStream(state.remoteStream));
          }
        },
        buildWhen: (previous, current) =>
            current is! VideoCallRemoteStreamAdded,
        builder: (context, state) {
          if (state is VideoCallRemoteConnecting) {
            return StreamPlaceholder(label: 'Connecting');
          } else if (state is VideoCallRemoteConnectionFailed) {
            return StreamErrorView(label: 'Connection Failed');
          } else if (state is VideoCallConnectionCreated) {
            return StreamPlaceholder(label: 'Waiting for others to join');
          } else if (state is VideoCallRemoteConnected) {
            return BlocBuilder<RemoteRendererBloc, RemoteRendererState>(
              bloc: _rendererBloc,
              builder: (context, rendererState) {
                return Stack(
                  children: [
                    RTCVideoView(
                      rendererState.remoteRenderer,
                      objectFit:
                          RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      placeholderBuilder: (context) => StreamPlaceholder(
                        label: 'Loading',
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            _rendererBloc.add(ToggleRemoteRendererSpeaker());
                          },
                          style: ElevatedButton.styleFrom(
                            shape: CircleBorder(),
                            backgroundColor: Colors.grey.withOpacity(.9),
                            padding: EdgeInsets.all(10),
                          ),
                          child: Icon(
                            rendererState.remoteRenderer.muted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else if (state is VideoCallClosed) {
            return Center(
              child: Text('Call Ended',
              style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
              ),
            );
          }
          return StreamPlaceholder(label: 'Initializing');
        },
      ),
    );
  }
}
