import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_conf_test/logic/video_call_bloc/video_call_bloc.dart';

class ControllesPanel extends StatelessWidget {
  const ControllesPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoCallBloc, VideoCallState>(
      builder: (context, state) {
        if (state is! VideoCallInitial) {
          if (state is VideoCallEnded) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<VideoCallBloc>().add(RoomCheck());
                      },
                      label: const Text('Call Again'),
                      icon: const Icon(Icons.call_rounded),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      context
                          .read<VideoCallBloc>()
                          .add(SwitchMicActivation(mute: !state.isMute));
                    },
                    icon: Icon(
                      state.isMute ? Icons.mic_off_rounded : Icons.mic_rounded,
                      size: 30,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VideoCallBloc>().add(EndVideoCall());
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.all(10),
                    ),
                    child: Icon(
                      Icons.call_end_rounded,
                      size: 30,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<VideoCallBloc>().add(SwitchCamera());
                    },
                    icon: Icon(
                      Icons.cameraswitch_rounded,
                      size: 30,
                    ),
                  ),
                ],
              ),
            );
        }
        return Container();
      },
    );
  }
}
