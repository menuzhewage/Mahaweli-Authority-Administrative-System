import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {

  User? user = FirebaseAuth.instance.currentUser;

  static String? currentUserRole;
  static String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
  static int leaveBalance = 0;

  //logout function
  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    currentUserRole = null;
  }

  static Future<int?> getCurrentUserLeaveBlanace() async {
    

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          leaveBalance = data['leaveBalance'];
          return leaveBalance;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user leave balance: $e');
      return null;
    }
  }

  //get curruent user details from firebase
  static Future<Map<String, dynamic>?> getCurrentUserDetails() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  //get current user role
  static Future<String?> getCurrentUserRole() async {
    if (currentUserRole != null) return currentUserRole; 

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          currentUserRole = data['role'] as String?;
          return currentUserRole;
        }
      }
      return null;
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }

  

  //get user leave balance from firebase
  static Future<int?> getUserLeaveBalance() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
          return data['leaveBalance'] as int?;
        }
      }
    } catch (e) {
      print('Error fetching user leave balance: $e');
    }
    return null;
  }

  //get users with status is equal to pending
  static Future<List<Map<String, dynamic>>> getPendingUsers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('status', isEqualTo: 'pending')
          .get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching pending users: $e');
      return [];
    }
  }
}