
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/message.dart';

class ChatServices extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUsersStreamExcludedBlocked() {
    final currentUser = _auth.currentUser;

    return _firestore
        .collection("users")
        .doc(currentUser!.uid)
        .collection("BlockedUsers")
        .snapshots()
        .asyncMap((snapshot) async {
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      final usersSnapshot = await _firestore.collection("users").get();

      return usersSnapshot.docs
          .where((doc) =>
              doc.data()["email"] != currentUser.email &&
              !blockedUserIds.contains(doc.id))
          .map((doc) => doc.data())
          .toList();
    });
  }

  Future<void> sendMessage(String recieverID, String message) async {
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      recieverID: recieverID,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserID, recieverID];
    ids.sort();

    String chatRoomID = ids.join('_');

    await _firestore
        .collection("Chat_rooms")
        .doc(chatRoomID)
        .collection("Messages")
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();

    String chatRoomID = ids.join('_');

    return _firestore
        .collection("Chat_rooms")
        .doc(chatRoomID)
        .collection("Messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> reportUser(String messageID, String userID) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageID': messageID,
      'messageOwnerID': userID,
      'timestamp': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('Reports').add(report);
  }

  Future<void> blockUser(String userID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userID)
        .set({});

    notifyListeners();
  }

  Future<void> unblockUser(String blockedUserID) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(blockedUserID)
        .delete();
  }

  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userID) {
    return _firestore
        .collection('users')
        .doc(userID)
        .collection("BlockedUsers")
        .snapshots()
        .asyncMap((snapshot) async {
      final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

      final userDocs = await Future.wait(blockedUserIds
          .map((id) => _firestore.collection('users').doc(id).get()));

      return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    });
  }

  String formatTimestamp(data) {
    DateTime dateTime = (data as Timestamp).toDate();
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
  }
}
