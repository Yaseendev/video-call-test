import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_conf_test/logic/video_call_bloc/video_call_bloc.dart';
import 'package:video_conf_test/logic/video_call_connection_cubit/video_call_connection_cubit.dart';
import 'package:video_conf_test/signaling.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
 // Signaling signaling = Signaling();
  String? roomId;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    // signaling.onAddRemoteStream = (stream) {
    //   _remoteRenderer.srcObject = stream;
    //   setState(() {});
    // };
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
       context.read<VideoCallBloc>().add(RoomCheck());
      //signaling.openUserMedia(_localRenderer, _remoteRenderer);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<VideoCallBloc, VideoCallState>(
          listener: (context, state) async {
            if (state is VideoCallInitialized) {
              _localRenderer.srcObject = state.stream;
              _remoteRenderer.srcObject = await createLocalMediaStream('key');
              setState(() {});
            } else if (state is VideoCallCreating) {
              context
                  .read<VideoCallConnectionCubit>()
                  .createRoom(state.localStream);
            } else if (state is VideoCallConnecting) {
              context
                  .read<VideoCallConnectionCubit>()
                  .joinRoom(state.roomId, state.localStream);
            } //else if (state is VideoCallConnected) {
            //   _remoteRenderer.srcObject = state.stream;
            //   setState(() {});
            // }
          },
        ),
        BlocListener<VideoCallConnectionCubit, VideoCallConnectionState>(
          listener: (context, state) {
            if (state is VideoCallRemoteStreamAdded) {
              _remoteRenderer.srcObject = state.remoteStream;
            }
          },
        ),
      ],
      child: SafeArea(
        child: Scaffold(
          extendBody: true,
          body: SizedBox.expand(
            child: RTCVideoView(
              _remoteRenderer,
              mirror: true,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
          floatingActionButton: Container(
            width: 150,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.deepOrange,
            ),
            child: RTCVideoView(
              _localRenderer
              //  child: Text('Testing'),
              ,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
          ),
          bottomNavigationBar: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  String doom = '';
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: TextField(
                        onChanged: (value) => doom = value,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: Text('Connect'),
                        ),
                      ],
                    ),
                  ).then((value) {
                    if (value != null && value) {
                      // signaling.joinRoom(
                      //   doom.trim(),
                      //   _remoteRenderer,
                      // );
                    }
                  });
                },
                icon: Icon(Icons.label),
              ),
              IconButton(
                onPressed: () async {
                 // roomId = await signaling.createRoom(_remoteRenderer);
                  // textEditingController.text = roomId!;
                  setState(() {});
                },
                icon: Icon(Icons.kayaking),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.face),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
