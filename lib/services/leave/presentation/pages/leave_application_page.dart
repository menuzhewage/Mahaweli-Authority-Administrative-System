import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../user_service.dart';
import '../data/model/leave_application.dart';
import '../data/model/leave_service.dart';
import '../data/repositories/leave_repository.dart';

class LeaveApplicationForm extends StatefulWidget {
  const LeaveApplicationForm({super.key});

  @override
  _LeaveApplicationFormState createState() => _LeaveApplicationFormState();
}

class _LeaveApplicationFormState extends State<LeaveApplicationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _employeeNameController = TextEditingController();
  final TextEditingController _jobRoleController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();
  final TextEditingController _workingPlaceController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _vehicleNumberController = TextEditingController();

  String? _selectedDepartment;
  String? _selectedLeaveType;
  bool _isSubmitting = false;

  

  final List<String> _departments = [
    'Administration',
    'Account',
    'Land',
    'Agri',
    'Technical',
    'Development',
    'Transport'
  ];

  final List<String> _leaveTypes = [
    'සාමාන්‍ය නිවාඩු',
    'දවසකින් කොටසක් සදහා නිවාඩු',
    'අනියම් නිවාඩු',
    'අසනීප නිවාඩු',
    'හිලවු නිවාඩු',
    'විවේක නිවාඩු',
    'හදිසි අනතුරු නිවාඩු හා විශේෂ අසනීප නිවාඩු',
    'ඉකුත් නිවාඩු',
    'විශ්‍රාම පූර්ව නිවාඩු',
    'විශේෂ නිවාඩු',
    'රාජකාරි නිවාඩු',
    'සම්පූර්න වැටුප් සහිත අද්‍යයන නිවාඩු',
    'වැටුප් රහිත මෙරට අද්‍යයන නිවාඩු',
    'විදේශ අද්‍යයන සහ/හෝ රැකියා සදහා වැටුප් රහිත නිවාඩු',
    'ඉපැයූ නිවාඩු',
    'ප්‍රසූති නිවාඩු',
    'රජයේ විභාග වලට පෙනී සිටීම සදහා නිවාඩු',
    'අනිවාර්‍ය නිවාඩු',
    'අඩ වැටුප් නිවාඩු',
    'වැටුප් රහිත නිවාඩු',
    'දිවයිනෙන් බැහැර ගත කරන නිවාඩු',
    'ගුරුවරුන් සදහා නිවාඩු',
  ];

  Map<String, dynamic>? _userDetails;

  

  final LeaveRepository _leaveRepository = LeaveRepository();

  // Helper function to parse date from controller text
  DateTime? _parseDate(TextEditingController controller) {
    if (controller.text.isEmpty) return null;
    try {
      return DateTime.parse(controller.text);
    } catch (e) {
      return null;
    }
  }

  // Validation function for date fields
  String? _validateDate(String? value, String fieldName, {DateTime? minDate, DateTime? maxDate}) {
    if (value == null || value.isEmpty) {
      return 'Please select a $fieldName';
    }
    
    try {
      final selectedDate = DateTime.parse(value);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      // Check if date is in the past
      if (minDate != null && selectedDate.isBefore(minDate)) {
        return '$fieldName cannot be in the past';
      }
      
      // Check if date is beyond max date
      if (maxDate != null && selectedDate.isAfter(maxDate)) {
        return '$fieldName cannot be beyond ${maxDate.toLocal().toString().split(' ')[0]}';
      }
      
      return null;
    } catch (e) {
      return 'Invalid date format';
    }
  }

  // Custom validation for return date (must be after end date)
  String? _validateReturnDate(String? value) {
    final endDate = _parseDate(_endDateController);
    if (endDate == null) return null;
    
    final returnDate = _parseDate(_returnDateController);
    if (returnDate == null) return null;
    
    if (!returnDate.isAfter(endDate)) {
      return 'Return date must be after leave end date';
    }
    
    return null;
  }

  // Custom validation for end date (must be after or equal to start date)
  String? _validateEndDate(String? value) {
    final startDate = _parseDate(_startDateController);
    if (startDate == null) return null;
    
    final endDate = _parseDate(_endDateController);
    if (endDate == null) return null;
    
    if (endDate.isBefore(startDate)) {
      return 'End date cannot be before start date';
    }
    
    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchUserDetails();
  }

  // Fetch user details (e.g., name) from a user service or Firebase
  Future<void> _fetchUserDetails() async {
    _userDetails = await UserService.getCurrentUserDetails();
    if (_userDetails != null) {
      setState(() {
        _employeeNameController.text = _userDetails!['name'] ?? '';
        _jobRoleController.text = _userDetails!['role'] ?? '';
        _selectedDepartment = _userDetails!['department'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Iconsax.backward,
                          size: 32,
                          color: Color(0xFF634682),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Leave Application Form',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF634682),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildTextField("Employee Name", _employeeNameController, Iconsax.user),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    "Department", 
                    _departments, 
                    _selectedDepartment, 
                    (value) => setState(() => _selectedDepartment = value),
                    Iconsax.building
                  ),
                  const SizedBox(height: 16),
                  _buildTextField("Job Role", _jobRoleController, Iconsax.briefcase),
                  const SizedBox(height: 16),
                  _buildDateField(
                    "Leave Start Date", 
                    _startDateController,
                    (value) => _validateDate(value, "Start Date", minDate: DateTime.now()),
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    "Leave End Date", 
                    _endDateController,
                    (value) {
                      final basicValidation = _validateDate(value, "End Date", minDate: DateTime.now());
                      if (basicValidation != null) return basicValidation;
                      return _validateEndDate(value);
                    },
                    minDate: _parseDate(_startDateController) ?? DateTime.now(),
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    "Date of Return to Work", 
                    _returnDateController,
                    (value) {
                      final basicValidation = _validateDate(value, "Return Date", minDate: DateTime.now());
                      if (basicValidation != null) return basicValidation;
                      return _validateReturnDate(value);
                    },
                    minDate: _parseDate(_endDateController) ?? DateTime.now(),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    "Type of Leave", 
                    _leaveTypes, 
                    _selectedLeaveType, 
                    (value) => setState(() => _selectedLeaveType = value),
                    Iconsax.calendar
                  ),
                  if (_selectedLeaveType == "විශේෂ නිවාඩු" || _selectedLeaveType == "රාජකාරි නිවාඩු") ...[
                    const SizedBox(height: 16),
                    _buildTextField("Working Place", _workingPlaceController, Iconsax.location),
                    const SizedBox(height: 16),
                    _buildTextField("Purpose of Visit", _reasonController, Iconsax.note_text),
                    const SizedBox(height: 16),
                    _buildTextField("Route Details", _routeController, Iconsax.route_square),
                    const SizedBox(height: 16),
                    _buildTextField("Vehicle Number", _vehicleNumberController, Iconsax.car),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF634682),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Submit Leave Request',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      bool canApply = await LeaveService().canApplyForLeave(
        _selectedLeaveType!,
        DateTime.parse(_startDateController.text),
        DateTime.parse(_endDateController.text),
      );

      if (canApply) {
        await _submitLeaveRequest();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Not enough leave balance")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _submitLeaveRequest() async {
    final leaveStartDate = DateTime.parse(_startDateController.text);
    final leaveEndDate = DateTime.parse(_endDateController.text);
    final returnDate = DateTime.parse(_returnDateController.text);

    final application = LeaveApplication(
      status: "pending",
      employeeName: _employeeNameController.text,
      department: _selectedDepartment!,
      jobRole: _jobRoleController.text,
      leaveStartDate: leaveStartDate,
      leaveEndDate: leaveEndDate,
      returnDate: returnDate,
      leaveType: _selectedLeaveType!,
      workingPlace: _selectedLeaveType == "Special Leave"
          ? _workingPlaceController.text
          : null,
      purposeOfVisit: _selectedLeaveType == "Special Leave"
          ? _reasonController.text
          : null,
      routeDetails:
          _selectedLeaveType == "Special Leave" ? _routeController.text : null,
      vehicleNumber: _selectedLeaveType == "Special Leave"
          ? _vehicleNumberController.text
          : null,
    );

    try {
      await _leaveRepository.submitLeaveRequest(application);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Leave request submitted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting request: $e")),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
          style: GoogleFonts.poppins(),
          validator: (value) => value!.isEmpty ? "This field is required" : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: GoogleFonts.poppins(),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            hintText: 'Select $label',
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 0,
            ),
          ),
          onChanged: (String? newValue) {
            onChanged(newValue);
            setState(() {});
          },
          validator: (value) => value == null ? "Please select $label" : null,
          style: GoogleFonts.poppins(color: Colors.black),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Iconsax.arrow_down_1, size: 20),
          isExpanded: true,
          elevation: 2,
          menuMaxHeight: 300,
        ),
      ],
    );
  }

  Widget _buildDateField(
    String label, 
    TextEditingController controller, 
    String? Function(String?)? validator, {
    DateTime? minDate,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Select $label',
            prefixIcon: const Icon(Iconsax.calendar, size: 20),
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 16,
            ),
          ),
          style: GoogleFonts.poppins(),
          validator: validator,
          onTap: () async {
            // Set the initial date to the minimum date or today
            final initialDate = minDate ?? DateTime.now();
            
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: minDate ?? DateTime.now(),
              lastDate: DateTime(2101),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: Color(0xFF634682),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF634682),
                      ),
                    ),
                  ),
                  child: child!,
                );
              },
            );
            
            if (pickedDate != null) {
              setState(() {
                controller.text = pickedDate.toLocal().toString().split(' ')[0];
              });
              
              // Trigger validation after date selection
              _formKey.currentState!.validate();
            }
          },
        ),
      ],
    );
  }
}

