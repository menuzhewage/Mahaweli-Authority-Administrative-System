import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../user_service.dart';

class ApproveLeavePage extends StatefulWidget {
  const ApproveLeavePage({super.key});

  @override
  _ApproveLeavePageState createState() => _ApproveLeavePageState();
}

class _ApproveLeavePageState extends State<ApproveLeavePage> {
  final role = UserService.currentUserRole;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;

  Future<void> _getRole() async {
    UserService.getCurrentUserRole().then((role) {
      setState(() {
        UserService.currentUserRole = role;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String role = UserService.currentUserRole ?? "Unknown";
    print('Current user role: $role');

    if (!isLoading && (role != 'Administrator' || role != 'RPM')) {
      return Scaffold(
        appBar: AppBar(title: const Text("Access Denied")),
        body: const Center(
            child: Text("You are not authorized to view this page.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Leave Requests")),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
                  .collection('leave_requests')
                  .where('status', isEqualTo: 'pending')
                  .snapshots(),

          builder: (context, snapshot) {


            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              return snapshot.data!.docs.isEmpty ? 
              const Center(child: Text("No pending leave requests."))
               : ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final request = snapshot.data!.docs[index];
                  final leaveType = request['leave_type'];
                  final route = request['route_details'] ?? "N/A";
                  final vehicleNumber = request['vehicle_number'] ?? "N/A";
               
                  return role == 'RPM' ? Visibility(
                    visible:  request['job_role'] == 'Administrator' ? true: false,
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          "${request['employee_name']} - $leaveType",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Department: ${request['department']}"),
                            Text("Job Role: ${request['job_role']}"),
                            Text(
                                "From: ${request['leave_start_date']} to ${request['leave_end_date']}"),
                            if (leaveType == "Official Leave") ...[
                              Text("Route: $route"),
                              Text("Vehicle: $vehicleNumber"),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _updateLeaveRequest(request.id, "Approved");
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _updateLeaveRequest(request.id, "Rejected");
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ) : Visibility(
                    visible:  request['job_role'] == 'Administrator' ? false: true,
                    child: Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          "${request['employee_name']} - $leaveType",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Department: ${request['department']}"),
                            Text("Job Role: ${request['job_role']}"),
                            Text(
                                "From: ${request['leave_start_date']} to ${request['leave_end_date']}"),
                            if (leaveType == "Official Leave") ...[
                              Text("Route: $route"),
                              Text("Vehicle: $vehicleNumber"),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () {
                                _updateLeaveRequest(request.id, "Approved");
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                _updateLeaveRequest(request.id, "Rejected");
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                             );
            } else {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
          }),
    );
  }

  Future<void> _updateLeaveRequest(String requestId, String status) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      //fetch the leave request details
      final requestDoc = await FirebaseFirestore.instance
          .collection('leave_requests')
          .doc(requestId)
          .get();

      final requestData = requestDoc.data();
      if (requestData == null) throw Exception("Leave request not found");

      //get uid from the request data
      final String employeeId = requestData['uid'];

      await FirebaseFirestore.instance
          .collection('leave_requests')
          .doc(requestId)
          .update({
        'status': status,
        if (status == 'Approved') 'approved_by': user.uid,
        if (status == 'Rejected') 'rejected_by': user.uid,
      });

      if (status == 'Approved') {
        // Get the employee's current leave balance
        final employeeDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(employeeId)
            .get();

        if (employeeDoc.exists) {
          final currentBalance = employeeDoc['leaveBalance'] ?? 0;
          final newBalance = currentBalance - 1;

          // Update the employee's leave balance
          await FirebaseFirestore.instance
              .collection('users')
              .doc(employeeId)
              .update({'leaveBalance': newBalance});
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Leave request $status successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}
