import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeaveApplicationForm extends StatefulWidget {
  const LeaveApplicationForm({super.key});

  @override
  _LeaveApplicationFormState createState() => _LeaveApplicationFormState();
}

class _LeaveApplicationFormState extends State<LeaveApplicationForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _numDaysController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _workplaceController = TextEditingController();
  final TextEditingController _workController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _vehicleController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedDesignation;
  String? _selectedLeaveType;

  final List<String> _departments = [
    'Admin',
    'Accounts',
    'Agriculture',
    'Land',
    'Transportation',
    'Technical Services'
  ];
  final List<String> _designations = [
    'Manager',
    'Team Lead',
    'Developer',
    'Analyst'
  ];
  final List<String> _leaveTypes = [
    'Formal Leave',
    'Casual Leave',
    'Sick Leave',
    'Without Payment Leave (normal)',
    'Without Payment Leave (approved)',
    'Maternity Leave (with payment)',
    'Maternity Leave (without payment)',
    'Maternity Leave (with half payment)',
    'Other Leaves',
    'Special Leave'
  ];

  bool _isFormalLeave = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    _returnDateController.dispose();
    _numDaysController.dispose();
    _reasonController.dispose();
    _workplaceController.dispose();
    _workController.dispose();
    _routeController.dispose();
    _vehicleController.dispose();
    super.dispose();
  }

  void _updateNumberOfDays() {
    if (_startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty) {
      DateTime startDate =
          DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      DateTime endDate =
          DateFormat('yyyy-MM-dd').parse(_endDateController.text);

      int numDays = 0;

      // Loop through all the dates between start and end date
      for (DateTime date = startDate;
          date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
          date = date.add(Duration(days: 1))) {
        // Count the day if it's not Saturday or Sunday
        if (date.weekday != DateTime.saturday &&
            date.weekday != DateTime.sunday) {
          numDays++;
        }
      }

      setState(() {
        _numDaysController.text = numDays.toString();
      });
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      _updateNumberOfDays();
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitted = true;
      });

      // Simulate submission success
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Submission Complete'),
            content: Text(
                'Leave submission is complete and now it is under progress. You will receive a notification on its status.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 13, 14),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading
                  Center(
                    child: Text(
                      'Leave Application Form',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(255, 10, 10, 10)),
                    ),
                  ),
                  SizedBox(height: 20),

                  // EMP-ID
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'EMP-ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your EMP-ID';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),

                  // Employee Name
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Employee Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),

                  // Department
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: _selectedDepartment,
                    items: _departments.map((dept) {
                      return DropdownMenuItem(value: dept, child: Text(dept));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDepartment = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a department' : null,
                  ),
                  SizedBox(height: 12),

                  // Designation
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Designation',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: _selectedDesignation,
                    items: _designations.map((des) {
                      return DropdownMenuItem(value: des, child: Text(des));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDesignation = value;
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a designation' : null,
                  ),
                  SizedBox(height: 12),

                  // Leave Type
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Leave Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    value: _selectedLeaveType,
                    items: _leaveTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLeaveType = value;
                        _isFormalLeave = value == 'Formal Leave';
                      });
                    },
                    validator: (value) =>
                        value == null ? 'Please select a leave type' : null,
                  ),
                  SizedBox(height: 12),

                  // Common Fields
                  TextFormField(
                    controller: _startDateController,
                    decoration: InputDecoration(
                      labelText: 'Leave Starting Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, _startDateController),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a starting date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),

                  TextFormField(
                    controller: _endDateController,
                    decoration: InputDecoration(
                      labelText: 'Leave Ending Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context, _endDateController),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an ending date';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12),

                  // Total Days
                  TextFormField(
                    controller: _numDaysController,
                    decoration: InputDecoration(
                      labelText: 'Total Days',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    readOnly: true,
                  ),
                  SizedBox(height: 12),

                  // Formal leave reason (if applicable)
                  if (_isFormalLeave)
                    TextFormField(
                      controller: _reasonController,
                      decoration: InputDecoration(
                        labelText: 'Reason for Formal Leave',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  SizedBox(height: 12),

                  // Workplace and travel details
                  if (_isFormalLeave) ...[
                    TextFormField(
                      controller: _workplaceController,
                      decoration: InputDecoration(
                        labelText: 'Workplace During Leave',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _workController,
                      decoration: InputDecoration(
                        labelText: 'Work to be Done During Leave',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _routeController,
                      decoration: InputDecoration(
                        labelText: 'Route of Travel (if applicable)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _vehicleController,
                      decoration: InputDecoration(
                        labelText: 'Vehicle to be Used (if applicable)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],

                  // Submit Button
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: _isSubmitted
                        ? Text('Leave Application Submitted')
                        : Text('Submit Leave Application'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: LeaveApplicationForm()));
