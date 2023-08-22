import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class VideoCallDatabaseProvider {
  final FirebaseFirestore remoteDB;
  VideoCallDatabaseProvider({
    required this.remoteDB,
  });

  CollectionReference get _roomCollection => remoteDB.collection('rooms');
  DocumentReference get _roomRef => _roomCollection.doc();
  Future<QuerySnapshot> get _roomSnapshot async => await _roomCollection.get();
  CollectionReference get _callerCandidatesCollection =>
      _roomRef.collection('callerCandidates');
  CollectionReference get _calleeCandidatesCollection =>
      _roomRef.collection('calleeCandidates');

  Future<String?> getRoomId() async {
    final QuerySnapshot snapshot = await _roomSnapshot;
    final docs = snapshot.docs;
    if (docs.isNotEmpty) {
      return docs.first.id.toString();
    }
    return null;
  }

  Future<bool> checkRoomId(String roomId) async {
    try {
      final roomSnapshot = await _roomCollection.doc(roomId).get();
      return roomSnapshot.exists;
    } catch (e) {
      throw e;
    }
  }

  void addCallerCandidates(Map<String, dynamic> candidate) {
    _callerCandidatesCollection.add(candidate);
  }

  Future addToRoom(Map<String, dynamic> data) async => await _roomRef.set(data);

  Stream<DocumentSnapshot<Object?>> getRoomStream() => _roomRef.snapshots();
  Stream getCalleeCandidatesStream() => _calleeCandidatesCollection.snapshots();
}
