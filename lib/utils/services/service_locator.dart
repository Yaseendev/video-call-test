import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:video_conf_test/data/providers/video_call_database_provider.dart';
import 'package:video_conf_test/data/repositories/video_call_repository.dart';

final locator = GetIt.instance;

Future locatorsSetup() async {
  locator.registerLazySingleton<VideoCallDatabaseProvider>(() => VideoCallDatabaseProvider(remoteDB: FirebaseFirestore.instance));
  locator.registerLazySingleton<VideoCallRepository>(() => VideoCallRepository(databaseProvider: locator.get<VideoCallDatabaseProvider>()));
}
