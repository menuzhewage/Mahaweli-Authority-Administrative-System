import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/leave_application.dart';

class LeaveRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitLeaveRequest(LeaveApplication application) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    await _firestore.collection('leave_requests').add(
      {
        ...application.toMap(),
        'user_email': user.email,
        'timestamp': FieldValue.serverTimestamp(),
        'uid': user.uid,
      },
    );
  }
}