import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoCallDatabaseProvider {
  final FirebaseFirestore remoteDB;
  final DocumentReference _roomRef;
  final CollectionReference _roomCollection;

  VideoCallDatabaseProvider({
    required this.remoteDB,
  })  : _roomCollection = remoteDB.collection('rooms'),
        _roomRef = remoteDB.collection('rooms').doc();

  Future<QuerySnapshot> get _roomSnapshot async => await _roomCollection.get();

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
    _roomRef.collection('callerCandidates').add(candidate);
  }

  void addCalleeCandidate(Map<String, dynamic> candidate, String roomId) {
    _roomCollection.doc(roomId).collection('calleeCandidates').add(candidate);
  }

  Future addToRoom(Map<String, dynamic> data) async => await _roomRef.set(data);
  Future<Map<String, dynamic>?> getRoomData(String roomId) async {
    final DocumentSnapshot roomSnapshot =
        await _roomCollection.doc(roomId).get();
    return roomSnapshot.data() as Map<String, dynamic>?;
  }

  Future<void> updateRoomData(Map<String, dynamic> data,
          [String? roomId]) async =>
      roomId == null
          ? await _roomRef.update(data)
          : await _roomCollection.doc(roomId).update(data);

  Future<void> deleteRooms() async {
    final rooms = await _roomSnapshot;
    for (var doc in rooms.docs) {
      await remoteDB.runTransaction((transaction) async {
        transaction.delete(doc.reference);
      });
    }
  }

  Stream<DocumentSnapshot<Object?>> getRoomStream() => _roomRef.snapshots();
  Stream getCalleeCandidatesStream() =>
      _roomRef.collection('calleeCandidates').snapshots();
  Stream getCallerCandidatesStream() =>
      _roomRef.collection('callerCandidates').snapshots();
}
