import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/logic/video_call_bloc/video_call_bloc.dart';
import 'package:video_conf_test/logic/video_call_connection_cubit/video_call_connection_cubit.dart';
import 'package:video_conf_test/signaling.dart';
import '../widgets/controlles_panel.dart';
import '../widgets/local_stream_view.dart';
import '../widgets/remote_stream_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<VideoCallBloc>().add(RoomCheck());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VideoCallBloc, VideoCallState>(
      listener: (context, state) async {
        if (state is VideoCallCreating) {
          context
              .read<VideoCallConnectionCubit>()
              .createRoom(state.localStream);
        } else if (state is VideoCallConnecting) {
          context
              .read<VideoCallConnectionCubit>()
              .joinRoom(state.roomId, state.localStream);
        } else if (state is VideoCallError) {
          //TODO: show error
        } else if (state is VideoCallEnded) {
          context.read<VideoCallConnectionCubit>().endCall();
        }
      },
      child: SafeArea(
        child: Scaffold(
            extendBody: true,
            body: SizedBox.expand(
              child: const RemoteStreamView(),
            ),
            floatingActionButton: const LocalStreamView(),
            bottomNavigationBar: const ControllesPanel(),
            ),
      ),
    );
  }
}
