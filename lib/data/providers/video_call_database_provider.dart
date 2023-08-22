import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class VideoCallDatabaseProvider {
  final FirebaseFirestore remoteDB;
  VideoCallDatabaseProvider({
    required this.remoteDB,
  });

  DocumentReference get _roomRef => remoteDB.collection('rooms').doc();
  Future<QuerySnapshot<Map<String, dynamic>>> get _roomSnapshot async =>
      await remoteDB.collection('rooms').get();
  CollectionReference get _callerCandidatesCollection =>
      _roomRef.collection('callerCandidates');
  CollectionReference get _calleeCandidatesCollection =>
      _roomRef.collection('calleeCandidates');

  Future<String?> getRoomId() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _roomSnapshot;
    final docs = snapshot.docs;
    if (docs.isNotEmpty) {
      return docs.first.id.toString();
    }
    return null;
  }

  void addCallerCandidates(Map<String, dynamic> candidate) {
    _callerCandidatesCollection.add(candidate);
  }

  Future addToRoom(Map<String, dynamic> data) async => await _roomRef.set(data);

  Stream<DocumentSnapshot<Object?>> getRoomStream() => _roomRef.snapshots(); 
  Stream getCalleeCandidatesStream() => _calleeCandidatesCollection.snapshots(); 
}
