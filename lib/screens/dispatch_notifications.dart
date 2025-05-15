import 'package:flutter/material.dart';
import '../classes/notification_request.dart';
import '../components/bottum_navigation_bar.dart';

class DispatchNotifications extends StatefulWidget {
  const DispatchNotifications({super.key});

  @override
  State<DispatchNotifications> createState() => _DispatchNotificationsState();
}

class _DispatchNotificationsState extends State<DispatchNotifications> {
  List<NotificationRequest> notifications = [];
  Map<String, int> departmentCounters = {};
  String keywordFilter = '';
  String letterIdSearch = '';

  String _getDeptCode(String department) {
    switch (department) {
      case 'Land':
        return 'LA';
      case 'Agriculture':
        return 'AGR';
      case 'Water':
        return 'WTR';
      default:
        return department.substring(0, 3).toUpperCase();
    }
  }

  String _getTypeCode(String type) {
    return type.toUpperCase();
  }

  String _generateLetterId(String type, String department, String date) {
    final deptCode = _getDeptCode(department);
    departmentCounters[deptCode] = (departmentCounters[deptCode] ?? 0) + 1;
    final number = departmentCounters[deptCode]!.toString().padLeft(3, '0');
    return '${_getTypeCode(type)} - $number/$deptCode/$date'.replaceAll('-', '/');
  }

  void _showAddNotificationDialog() {
    String? type;
    String? department;
    String date = '';
    String description = '';
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(24),
          content: SizedBox(
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text('NEW LETTER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: 'Internal', child: Text('Internal')),
                      DropdownMenuItem(value: 'External', child: Text('External')),
                    ],
                    onChanged: (val) => type = val,
                    validator: (val) => val == null ? 'Select type' : null,
                  ),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Department'),
                    items: const [
                      DropdownMenuItem(value: 'Land', child: Text('Land')),
                      DropdownMenuItem(value: 'Agriculture', child: Text('Agriculture')),
                      DropdownMenuItem(value: 'Water', child: Text('Water')),
                    ],
                    onChanged: (val) => department = val,
                    validator: (val) => val == null ? 'Select department' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Date (yyyy/mm/dd)'),
                    onChanged: (val) => date = val,
                    validator: (val) => val == null || val.isEmpty ? 'Enter date' : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    onChanged: (val) => description = val,
                    validator: (val) => val == null || val.isEmpty ? 'Enter description' : null,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red[200]),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green[200]),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final letterId = _generateLetterId(type!, department!, date);
                            setState(() {
                              notifications.add(NotificationRequest(
                                letterId: letterId,
                                type: type!,
                                department: department!,
                                date: date,
                                description: description,
                              ));
                            });
                            Navigator.of(context).pop();
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showNotificationDetails(NotificationRequest notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(notification.letterId, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${notification.type}'),
              Text('Department: ${notification.department}'),
              Text('Date: ${notification.date}'),
              const SizedBox(height: 8),
              Text('Description:'),
              Text(notification.description),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSidebarButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 103, 21, 158),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(
              color: Colors.white,
              width: 2,
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationRequest notification) {
    final shortDescription = notification.description.length > 60
        ? notification.description.substring(0, 60) + '... see more'
        : notification.description;
    return GestureDetector(
      onTap: () => _showNotificationDetails(notification),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.letterId,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Description: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(shortDescription)),
                ],
              ),
              Row(
                children: [
                  const Text('Department: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(notification.department),
                ],
              ),
              Row(
                children: [
                  const Text('Date: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(notification.date),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<NotificationRequest> get _filteredNotifications {
    return notifications.where((n) {
      final matchesKeyword = keywordFilter.isEmpty ||
          n.description.toLowerCase().contains(keywordFilter.toLowerCase()) ||
          n.department.toLowerCase().contains(keywordFilter.toLowerCase());
      final matchesLetterId = letterIdSearch.isEmpty ||
          n.letterId.toLowerCase().contains(letterIdSearch.toLowerCase());
      return matchesKeyword && matchesLetterId;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Row(
                children: [
                  // Sidebar
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, top: 50, right: 30),
                      child: Column(
                        children: [
                          Card(
                            color: const Color.fromARGB(255, 228, 228, 228),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Dispatch Handler Dashboard',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildSidebarButton('Dispatch Notifications', () {}),
                          const SizedBox(height: 20),
                          _buildSidebarButton('Apply Leave', () {}),
                          const Divider(),
                          Expanded(
                            child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      'Chat',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Vertical Divider
                  Container(
                    width: 2,
                    height: screenHeight,
                    color: const Color.fromARGB(255, 210, 210, 210),
                  ),
                  // Main Content
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Filter by Keywords',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (val) => setState(() => keywordFilter = val),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Search by Letter ID',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                  onChanged: (val) => setState(() => letterIdSearch = val),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: _filteredNotifications.isEmpty
                                ? const Center(child: Text('No notifications yet.'))
                                : ListView.builder(
                                    itemCount: _filteredNotifications.length,
                                    itemBuilder: (context, index) => _buildNotificationCard(_filteredNotifications[index]),
                                  ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: const Icon(Icons.add_circle, size: 36, color: Color.fromARGB(255, 103, 21, 158)),
                              onPressed: _showAddNotificationDialog,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 60,
                            child: CustomBottomNavigationBar(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Vertical Divider
                  Container(
                    width: 2,
                    height: screenHeight,
                    color: const Color.fromARGB(255, 210, 210, 210),
                  ),
                  // Right Sidebar
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Column(
                        children: [
                          Expanded(
                            child: Card(
                              color: const Color.fromARGB(255, 106, 10, 157),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'Today',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Divider(),
                          Expanded(
                            child: Card(
                              color: const Color.fromARGB(255, 114, 20, 173),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  children: [],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 