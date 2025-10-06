import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ComplainManagement extends StatefulWidget {
  const ComplainManagement({super.key});

  @override
  State<ComplainManagement> createState() => _ComplainManagementState();
}

class _ComplainManagementState extends State<ComplainManagement> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const RegisterComplain(),
    const ViewComplains(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Complain Management',
          style: TextStyle(color: Color(0xFF634682)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF634682)),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.add_square),
            label: 'Register Complain',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.document),
            label: 'View Complains',
          ),
        ],
      ),
    );
  }
}

class RegisterComplain extends StatefulWidget {
  const RegisterComplain({super.key});

  @override
  State<RegisterComplain> createState() => _RegisterComplainState();
}

class _RegisterComplainState extends State<RegisterComplain> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _complainDetailsController =
      TextEditingController();
  final TextEditingController _assignedToController = TextEditingController();

  String _selectedCategory = 'agriculture';
  String _selectedEmployee = '';
  List<Map<String, dynamic>> _employees = [];
  bool _isExistingComplaint = false;
  int _sameProblemCount = 0;
  List<String> _previousComplaintIds = [];

  final List<String> _categories = [
    'agriculture',
    'financial',
    'irrigation',
    'land',
    'housing',
    'infrastructure',
    'other'
  ];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _dateController.text = _formatDate(DateTime.now());
  }

  Future<void> _loadEmployees() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      setState(() {
        _employees = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['name'],
            'email': doc['email'],
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading employees: $e')),
      );
    }
  }

  Future<void> _checkExistingComplaint() async {
    if (_idController.text.isEmpty || _complainDetailsController.text.isEmpty)
      return;

    try {
      final currentDetails =
          _complainDetailsController.text.toLowerCase().trim();

      final querySnapshot = await FirebaseFirestore.instance
          .collection('complains')
          .where('complainerId', isEqualTo: _idController.text)
          .get();

      int sameProblemCount = 0;
      List<String> previousComplaintIds = [];

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final existingDetails = data['details'] as String? ?? '';

        // Simple comparison - if the complaint details are very similar, consider it the same problem
        if (existingDetails.toLowerCase().trim() == currentDetails) {
          sameProblemCount++;
          previousComplaintIds.add(doc.id);
        }
      }

      setState(() {
        _sameProblemCount = sameProblemCount;
        _isExistingComplaint = sameProblemCount > 0;
        _previousComplaintIds = previousComplaintIds;
      });
    } catch (e) {
      print('Error checking existing complaint: $e');
    }
  }

  String _getPriority() {
    if (_sameProblemCount >= 2) return 'red';
    if (_sameProblemCount >= 1) return 'orange';
    return 'green';
  }

  Future<void> _updateExistingComplaintPriorities() async {
    if (_previousComplaintIds.isEmpty) return;

    try {
      final newPriority = _getPriority();

      // Update all previous complaints about the same problem
      for (final complaintId in _previousComplaintIds) {
        await FirebaseFirestore.instance
            .collection('complains')
            .doc(complaintId)
            .update({
          'priority': newPriority,
          'updatedAt': Timestamp.now(),
        });
      }

      print(
          'Updated ${_previousComplaintIds.length} previous complaints to $newPriority priority');
    } catch (e) {
      print('Error updating existing complaint priorities: $e');
    }
  }

  Future<void> _submitComplain() async {
    if (_formKey.currentState!.validate()) {
      try {
        final priority = _getPriority();

        // First update existing complaints if this is a repeat problem
        if (_isExistingComplaint) {
          await _updateExistingComplaintPriorities();
        }

        // Then add the new complaint
        await FirebaseFirestore.instance.collection('complains').add({
          'complainerId': _idController.text,
          'complainerName': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'category': _selectedCategory,
          'details': _complainDetailsController.text,
          'assignedTo': _selectedEmployee,
          'assignedToName': _assignedToController.text,
          'priority': priority,
          'status': 'pending',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Complain registered successfully! ${_isExistingComplaint ? 'Previous complaints updated.' : ''}')),
        );

        _formKey.currentState!.reset();
        setState(() {
          _isExistingComplaint = false;
          _sameProblemCount = 0;
          _previousComplaintIds = [];
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering complain: $e')),
        );
      }
    }
  }

  // Add this to your state class
  final TextEditingController _dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != DateTime.now()) {
      _dateController.text = _formatDate(picked);
    }
  }

  String _formatDate(DateTime date) {
    // return '${date.day}/${date.month}/${date.year}';
    // Or use this for a more formatted date:
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isExistingComplaint)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _sameProblemCount >= 2
                      ? Colors.red.withOpacity(0.2)
                      : _sameProblemCount >= 1
                          ? Colors.orange.withOpacity(0.2)
                          : Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      color: _sameProblemCount >= 2
                          ? Colors.red
                          : _sameProblemCount >= 1
                              ? Colors.orange
                              : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This person has reported this same problem $_sameProblemCount time(s) before - ${_getPriority().toUpperCase()} priority',
                        style: TextStyle(
                          color: _sameProblemCount >= 2
                              ? Colors.red
                              : _sameProblemCount >= 1
                                  ? Colors.orange
                                  : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Complainer ID',
                prefixIcon: Icon(Iconsax.card),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _checkExistingComplaint(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter complainer ID';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Iconsax.user),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter complainer name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Iconsax.call),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                prefixIcon: Icon(Iconsax.location),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Iconsax.category),
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child:
                      Text(category[0].toUpperCase() + category.substring(1)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            //get current date or select a date
            TextFormField(
              controller: _dateController,
              readOnly:
                  true, // Makes the field non-editable, forcing use of date picker
              decoration: const InputDecoration(
                labelText: 'Date',
                prefixIcon: Icon(Iconsax.calendar),
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.arrow_drop_down),
              ),
              onTap: () => _selectDate(context),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a date';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 16,
            ),
            TextFormField(
              controller: _complainDetailsController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Complain Details',
                prefixIcon: Icon(Iconsax.document),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _checkExistingComplaint(),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter complain details';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _assignedToController,
              decoration: InputDecoration(
                labelText: 'Assign To',
                prefixIcon: const Icon(Iconsax.user_tag),
                border: const OutlineInputBorder(),
                suffixIcon: PopupMenuButton<String>(
                  icon: const Icon(Iconsax.search_status),
                  onSelected: (String value) {
                    final employee = _employees.firstWhere(
                      (emp) => emp['id'] == value,
                      orElse: () => {},
                    );

                    if (employee.isNotEmpty) {
                      setState(() {
                        _selectedEmployee = value;
                        _assignedToController.text = employee['name'];
                      });
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return _employees.map<PopupMenuItem<String>>((employee) {
                      return PopupMenuItem<String>(
                        value: employee['id'],
                        child: Text(employee['name']),
                      );
                    }).toList();
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an employee';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF634682),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submitComplain,
                child: const Text(
                  'Register Complain',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewComplains extends StatefulWidget {
  const ViewComplains({super.key});

  @override
  State<ViewComplains> createState() => _ViewComplainsState();
}

class _ViewComplainsState extends State<ViewComplains> {
  String _searchQuery = '';
  String _selectedCategory = 'all';
  String _selectedStatus = 'all';
  final List<String> _categories = [
    'all',
    'agriculture',
    'financial',
    'irrigation',
    'land',
    'housing',
    'infrastructure',
    'other'
  ];
  final List<String> _statuses = ['all', 'pending', 'in-progress', 'resolved'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Search by Complainer ID',
                  prefixIcon: const Icon(Iconsax.search_normal),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Iconsax.close_circle),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category[0].toUpperCase() +
                              category.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: _statuses.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                              status[0].toUpperCase() + status.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('complains')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final complains = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final matchesSearch = _searchQuery.isEmpty ||
                    data['complainerId'].toString().contains(_searchQuery);
                final matchesCategory = _selectedCategory == 'all' ||
                    data['category'] == _selectedCategory;
                final matchesStatus = _selectedStatus == 'all' ||
                    data['status'] == _selectedStatus;

                return matchesSearch && matchesCategory && matchesStatus;
              }).toList();

              if (complains.isEmpty) {
                return const Center(
                  child: Text('No complains found'),
                );
              }

              return ListView.builder(
                itemCount: complains.length,
                itemBuilder: (context, index) {
                  final complain = complains[index];
                  final data = complain.data() as Map<String, dynamic>;

                  Color priorityColor;
                  switch (data['priority']) {
                    case 'red':
                      priorityColor = Colors.red;
                      break;
                    case 'orange':
                      priorityColor = Colors.orange;
                      break;
                    default:
                      priorityColor = Colors.green;
                  }

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: Container(
                        width: 10,
                        decoration: BoxDecoration(
                          color: priorityColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      title: Text('Complainer: ${data['complainerName']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID: ${data['complainerId']}'),
                          Text('Category: ${data['category']}'),
                          Text('Status: ${data['status']}'),
                          Text('Priority: ${data['priority']}'),
                          Text('Assigned to: ${data['assignedToName']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Iconsax.more),
                        onPressed: () {
                          _showComplainDetails(context, complain);
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showComplainDetails(
      BuildContext context, QueryDocumentSnapshot complain) {
    final data = complain.data() as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Complain Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Complainer ID', data['complainerId']),
                _detailRow('Name', data['complainerName']),
                _detailRow('Phone', data['phone']),
                _detailRow('Address', data['address']),
                _detailRow('Category', data['category']),
                _detailRow('Details', data['details']),
                _detailRow('Assigned To', data['assignedToName']),
                _detailRow('Priority', data['priority']),
                _detailRow('Status', data['status']),
                _detailRow('Created',
                    (data['createdAt'] as Timestamp).toDate().toString()),
              ],
            ),
          ),
          actions: [
            if (data['status'] != 'resolved') ...[
              TextButton(
                onPressed: () {
                  _updateComplainStatus(context, complain);
                },
                child: const Text('Update Status'),
              ),
              TextButton(
                onPressed: () {
                  _updateComplainPriority(context, complain);
                },
                child: const Text('Update Priority'),
              ),
            ],
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _updateComplainStatus(
      BuildContext context, QueryDocumentSnapshot complain) {
    final data = complain.data() as Map<String, dynamic>;
    final TextEditingController solutionController = TextEditingController();
    String selectedStatus = data['status'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Complain Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                value: selectedStatus,
                items: ['pending', 'in-progress', 'resolved'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status[0].toUpperCase() + status.substring(1)),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedStatus = value!;
                },
              ),
              if (selectedStatus == 'resolved')
                TextField(
                  controller: solutionController,
                  decoration: const InputDecoration(
                    labelText: 'Solution Details',
                  ),
                  maxLines: 3,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final updateData = {
                    'status': selectedStatus,
                    'updatedAt': Timestamp.now(),
                  };

                  if (selectedStatus == 'resolved' &&
                      solutionController.text.isNotEmpty) {
                    updateData['solution'] = solutionController.text;
                  }

                  await complain.reference.update(updateData);

                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Also close the details dialog

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Complain status updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating status: $e')),
                  );
                }
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _updateComplainPriority(
      BuildContext context, QueryDocumentSnapshot complain) {
    final data = complain.data() as Map<String, dynamic>;
    String selectedPriority = data['priority'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Complain Priority'),
          content: DropdownButtonFormField(
            value: selectedPriority,
            items: ['green', 'orange', 'red'].map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text(priority[0].toUpperCase() + priority.substring(1)),
              );
            }).toList(),
            onChanged: (value) {
              selectedPriority = value!;
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await complain.reference.update({
                    'priority': selectedPriority,
                    'updatedAt': Timestamp.now(),
                  });

                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Also close the details dialog

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Complain priority updated successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating priority: $e')),
                  );
                }
              },
              child: const Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
