import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/logic/video_call_bloc/video_call_bloc.dart';
import 'package:video_conf_test/logic/video_call_connection_cubit/video_call_connection_cubit.dart';
import 'stream_error_view.dart';
import 'stream_placeholder.dart';

class RemoteStreamView extends StatefulWidget {
  const RemoteStreamView({super.key});

  @override
  State<RemoteStreamView> createState() => _RemoteStreamViewState();
}

class _RemoteStreamViewState extends State<RemoteStreamView> {
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    _remoteRenderer.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoCallBloc, VideoCallState>(
      listener: (context, state) async {
        if (state is VideoCallInitialized) {
          _remoteRenderer.srcObject = await createLocalMediaStream('key');
          setState(() {});
        }
      },
      child: BlocConsumer<VideoCallConnectionCubit, VideoCallConnectionState>(
        listener: (context, state) {
          if (state is VideoCallRemoteStreamAdded) {
            _remoteRenderer.srcObject = state.remoteStream;
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
            return Stack(
              children: [
                RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  placeholderBuilder: (context) => StreamPlaceholder(
                    label: 'Initialzing',
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Colors.grey.withOpacity(.9),
                        padding: EdgeInsets.all(10),
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return StreamPlaceholder(label: 'Initialzing');
        },
      ),
    );
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    super.dispose();
  }
}
