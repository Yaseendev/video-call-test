import 'package:cloud_firestore/cloud_firestore.dart';

class VideoCallDatabaseProvider {
  final FirebaseFirestore remoteDB;
  VideoCallDatabaseProvider({
    required this.remoteDB,
  });

  Future<String?> getRoomId() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await remoteDB.collection('rooms').get();
    final docs = snapshot.docs;
    if (docs.isNotEmpty) {
      return docs.first.id.toString();
    }
    return null;
  }
}
