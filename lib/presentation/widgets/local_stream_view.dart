import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/logic/local_renderer_bloc/local_renderer_bloc.dart';
import 'package:video_conf_test/logic/video_call_bloc/video_call_bloc.dart';

class LocalStreamView extends StatefulWidget {
  const LocalStreamView({
    super.key,
  });

  @override
  State<LocalStreamView> createState() => _LocalStreamViewState();
}

class _LocalStreamViewState extends State<LocalStreamView> {
  final LocalRendererBloc _localRendererBloc = LocalRendererBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoCallBloc, VideoCallState>(
      listener: (context, state) {
        if (state is VideoCallInitialized) {
          _localRendererBloc.add(InitLocalRenderer(stream: state.stream));
        } else if (state is VideoCallEnded) {
          _localRendererBloc.add(CloseLocalVideo());
        }
      },
      child: BlocBuilder<LocalRendererBloc, LocalRendererState>(
        bloc: _localRendererBloc,
        builder: (context, state) {
          return Container(
            width: MediaQuery.of(context).size.width * .35,
            height: MediaQuery.of(context).size.height * .3,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: RTCVideoView(
                state.localRenderer,
                mirror: true,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    //_localRenderer.dispose();
    super.dispose();
  }
}
