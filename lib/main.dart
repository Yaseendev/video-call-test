import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_conf_test/logic/video_call_bloc/video_call_bloc.dart';
import 'package:video_conf_test/logic/video_call_connection_cubit/video_call_connection_cubit.dart';
import 'package:video_conf_test/presentation/screens/call_screen.dart';
import 'package:video_conf_test/utils/services/service_locator.dart';
import 'data/repositories/video_call_repository.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await locatorsSetup();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<VideoCallBloc>(
          create: (context) => VideoCallBloc(
            repository: locator.get<VideoCallRepository>(),
          ),
        ),
        BlocProvider<VideoCallConnectionCubit>(
          create: (context) => VideoCallConnectionCubit(
            repository: locator.get<VideoCallRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const CallScreen(),
      ),
    );
  }
}
