// services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save dispatch request
  Future<void> saveDispatchRequest(Map<String, dynamic> data) async {
    try {
      await _firestore.collection('dispatch_requests').add(data);
    } catch (e) {
      print('Error saving dispatch: $e');
      throw e;
    }
  }

  // Get all users for assignment
  Stream<QuerySnapshot> getUsers() {
    return _firestore.collection('users').snapshots();
  }

  // Get dispatch requests for current user
  Stream<QuerySnapshot> getUserDispatchRequests(String userId) {
    return _firestore
        .collection('dispatch_requests')
        .where('assignedUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // Add to your FirestoreService class
  Future<void> updateDispatchRequest(
      String documentId, Map<String, dynamic> updateData) async {
    try {
      await _firestore
          .collection('dispatch_requests')
          .doc(documentId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update dispatch: $e');
    }
  }

  // Get all dispatch requests (for admin)
  Stream<QuerySnapshot> getAllDispatchRequests() {
    return _firestore
        .collection('dispatch_requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
