import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../user_service.dart';

class LeaveService {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<bool> canApplyForLeave(String leaveType, DateTime startDate, DateTime endDate) async {
    
    int leaveBalance = await UserService.getUserLeaveBalance() ?? 0;

    if ( leaveBalance > 0 ){
      return true;
    } else {
      return false;
    }
    print("leave balance: $leaveBalance");
  }
}