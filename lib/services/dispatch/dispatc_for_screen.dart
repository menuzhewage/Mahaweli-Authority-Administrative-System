// screens/dispatch_form_screen.dart
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../firestore_service.dart';

class DispatchFormScreen extends StatefulWidget {
  const DispatchFormScreen({super.key});

  @override
  _DispatchFormScreenState createState() => _DispatchFormScreenState();
}

class _DispatchFormScreenState extends State<DispatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedUserId;
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  bool _usersLoaded = false;

  @override
  void initState() {
    super.initState();
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _loadUsers(); // Load users automatically when screen initializes
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _loadUsers() async {
    if (_usersLoaded) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isNotEqualTo: 'admin') // Optional: filter if needed
          .get();
          
      setState(() {
        _users = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'],
            'email': doc['email'],
          };
        }).toList();
        _usersLoaded = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an employee')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final firestoreService = Provider.of<FirestoreService>(context, listen: false);
      
      // Find the selected user
      final selectedUser = _users.firstWhere(
        (user) => user['id'] == _selectedUserId,
        orElse: () => {'name': 'Unknown User'}
      );
      
      final dispatchData = {
        'subject': _subjectController.text,
        'referenceNumber': _referenceController.text,
        'description': _descriptionController.text,
        'dispatchDate': _dateController.text,
        'assignedUserId': _selectedUserId,
        'assignedUserName': selectedUser['name'],
        'createdAt': Timestamp.now(),
        'status': 'pending',
      };

      await firestoreService.saveDispatchRequest(dispatchData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dispatch letter saved successfully!')),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving dispatch: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Dispatch Letter', 
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _subjectController,
                label: 'Subject',
                icon: Iconsax.document,
                validator: (value) => value!.isEmpty ? 'Please enter subject' : null,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _referenceController,
                label: 'Reference Number',
                icon: Iconsax.tag,
                validator: (value) => value!.isEmpty ? 'Please enter reference number' : null,
              ),
              const SizedBox(height: 20),
              _buildDateField(context),
              const SizedBox(height: 20),
              _buildUserDropdown(),
              const SizedBox(height: 20),
              _buildDescriptionField(),
              const SizedBox(height: 30),
              _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text('Save Dispatch', 
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: validator,
    );
  }

  Widget _buildDateField(BuildContext context) {
    return TextFormField(
      controller: _dateController,
      decoration: InputDecoration(
        labelText: 'Dispatch Date',
        prefixIcon: const Icon(Iconsax.calendar, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: const Icon(Iconsax.calendar_1, size: 20),
          onPressed: () => _selectDate(context),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      readOnly: true,
      validator: (value) => value!.isEmpty ? 'Please select date' : null,
    );
  }

  Widget _buildUserDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Assign to Employee', 
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        if (_isLoading && !_usersLoaded)
          const Center(child: CircularProgressIndicator())
        else if (_users.isEmpty)
          OutlinedButton(
            onPressed: _loadUsers,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('No employees available', style: TextStyle(color: Colors.grey)),
                Icon(Iconsax.user, size: 20, color: Colors.grey),
              ],
            ),
          )
        else
          DropdownButtonFormField<String>(
            value: _selectedUserId,
            items: _users.map<DropdownMenuItem<String>>((user) {
              return DropdownMenuItem<String>(
                value: user['id'] as String,
                child: Text('${user['name']} (${user['email']})'),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedUserId = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Iconsax.user, size: 20),
            ),
            validator: (value) => value == null ? 'Please select an employee' : null,
            borderRadius: BorderRadius.circular(12),
            isExpanded: true,
            hint: const Text('Select an employee'),
          ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        labelText: 'Description',
        alignLabelWithHint: true,
        prefixIcon: const Icon(Iconsax.note, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) => value!.isEmpty ? 'Please enter description' : null,
    );
  }
}