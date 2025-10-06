  class LeaveApplication {
    final String employeeName;
    final String department;
    final String jobRole;
    final DateTime leaveStartDate;
    final DateTime leaveEndDate;
    final DateTime returnDate;
    final String leaveType;
    final String? workingPlace;
    final String? purposeOfVisit;
    final String? routeDetails;
    final String? vehicleNumber;
    final String status;

    LeaveApplication({
      required this.status,
      required this.employeeName,
      required this.department,
      required this.jobRole,
      required this.leaveStartDate,
      required this.leaveEndDate,
      required this.returnDate,
      required this.leaveType,
      this.workingPlace,
      this.purposeOfVisit,
      this.routeDetails,
      this.vehicleNumber,
    });

    Map<String, dynamic> toMap() {
      return {
        'status': status,
        'employee_name': employeeName,
        'department': department,
        'job_role': jobRole,
        'leave_start_date': leaveStartDate.toIso8601String(),
        'leave_end_date': leaveEndDate.toIso8601String(),
        'return_date': returnDate.toIso8601String(),
        'leave_type': leaveType,
        'working_place': workingPlace,
        'purpose_of_visit': purposeOfVisit,
        'route_details': routeDetails,
        'vehicle_number': vehicleNumber,
      };
    }
  }
