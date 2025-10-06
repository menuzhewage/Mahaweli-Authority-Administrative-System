import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    JoinQueueScreen(),
    TicketScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mahaweli Queue Optimizer'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.scan),
            label: 'Join Queue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.ticket),
            label: 'My Ticket',
          ),
        ],
      ),
    );
  }
}

class JoinQueueScreen extends StatefulWidget {
  @override
  _JoinQueueScreenState createState() => _JoinQueueScreenState();
}

class _JoinQueueScreenState extends State<JoinQueueScreen> {
  String? _selectedCounter;
  String? _selectedService;
  String? _phoneNumber;
  String? _email;
  bool _isElderly = false;
  bool _hasAppointment = false;
  List<Map<String, dynamic>> _counters = [];
  List<Map<String, dynamic>> _services = [];

  @override
  void initState() {
    super.initState();
    _loadCountersAndServices();
  }

  Future<void> _loadCountersAndServices() async {
    // Load counters from Firebase
    final countersSnapshot = await FirebaseFirestore.instance.collection('counters').get();
    final servicesSnapshot = await FirebaseFirestore.instance.collection('services').get();
    
    setState(() {
      _counters = countersSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      _services = servicesSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> _joinQueue() async {
    if (_selectedCounter == null || _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a counter and service')),
      );
      return;
    }

    try {
      // Get the selected service to calculate base priority
      final selectedService = _services.firstWhere((service) => service['id'] == _selectedService);
      final basePriority = selectedService['basePriority'] ?? 0;
      
      // Calculate priority based on service and special flags
      int calculatedPriority = basePriority;
      if (_isElderly) calculatedPriority += 10;
      if (_hasAppointment) calculatedPriority += 15;
      
      // Create queue entry
      final queueEntry = {
        'counterId': _selectedCounter,
        'counterName': _counters.firstWhere((counter) => counter['id'] == _selectedCounter)['name'],
        'serviceId': _selectedService,
        'serviceName': _services.firstWhere((service) => service['id'] == _selectedService)['name'],
        'phoneNumber': _phoneNumber,
        'email': _email,
        'isElderly': _isElderly,
        'hasAppointment': _hasAppointment,
        'priority': calculatedPriority,
        'status': 'waiting',
        'joinedAt': Timestamp.now(),
        'estimatedWaitTime': 15, 
      };

      // Add to Firebase
      final docRef = await FirebaseFirestore.instance.collection('queue').add(queueEntry);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully joined the queue! Your ticket ID: ${docRef.id}')),
      );

      // Reset form
      setState(() {
        _selectedCounter = null;
        _selectedService = null;
        _phoneNumber = null;
        _email = null;
        _isElderly = false;
        _hasAppointment = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining queue: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Join Queue',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCounter,
                    decoration: InputDecoration(
                      labelText: 'Select Counter',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Iconsax.location),
                    ),
                    items: _counters.map((counter) {
                      return DropdownMenuItem<String>(
                        value: counter['id'],
                        child: Text(counter['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCounter = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedService,
                    decoration: InputDecoration(
                      labelText: 'Select Service',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Iconsax.document),
                    ),
                    items: _services.map((service) {
                      return DropdownMenuItem<String>(
                        value: service['id'],
                        child: Text(service['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedService = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Phone Number (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Iconsax.call),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _phoneNumber = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Iconsax.sms),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _email = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  CheckboxListTile(
                    title: Text('Elderly/Disabled'),
                    value: _isElderly,
                    onChanged: (value) {
                      setState(() {
                        _isElderly = value ?? false;
                      });
                    },
                    secondary: Icon(Iconsax.user),
                  ),
                  CheckboxListTile(
                    title: Text('I have an appointment'),
                    value: _hasAppointment,
                    onChanged: (value) {
                      setState(() {
                        _hasAppointment = value ?? false;
                      });
                    },
                    secondary: Icon(Iconsax.calendar),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _joinQueue,
                    child: Text('Join Queue', style: TextStyle(
                      color: Colors.white,
                    ),),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          //display ticket id after joining queue
          Text(
            'After joining the queue, you will receive a ticket ID. Use this ID to check your ticket status in the "My Ticket" section.',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class TicketScreen extends StatefulWidget {
  @override
  _TicketScreenState createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final TextEditingController _ticketIdController = TextEditingController();
  Map<String, dynamic>? _ticketData;
  int _positionInQueue = 0;

  Future<void> _loadTicket() async {
    final ticketId = _ticketIdController.text.trim();
    if (ticketId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a ticket ID')),
      );
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('queue').doc(ticketId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _ticketData = data;
        });
        
        // Calculate position in queue
        await _calculatePosition(ticketId, data['counterId']);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ticket not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading ticket: $e')),
      );
    }
  }

  Future<void> _calculatePosition(String ticketId, String counterId) async {
    try {
      // Get all waiting tickets for the same counter, ordered by priority and join time
      final waitingTickets = await FirebaseFirestore.instance
          .collection('queue')
          .where('counterId', isEqualTo: counterId)
          .where('status', isEqualTo: 'waiting')
          .orderBy('priority', descending: true)
          .orderBy('joinedAt')
          .get();

      int position = 1;
      for (var doc in waitingTickets.docs) {
        if (doc.id == ticketId) {
          break;
        }
        position++;
      }

      setState(() {
        _positionInQueue = position;
      });
    } catch (e) {
      print('Error calculating position: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'My Ticket',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _ticketIdController,
                    decoration: InputDecoration(
                      labelText: 'Enter Ticket ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Iconsax.ticket),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadTicket,
                    child: Text('Load Ticket'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          if (_ticketData != null) _buildTicketCard(),
        ],
      ),
    );
  }

  Widget _buildTicketCard() {
    final joinedAt = (_ticketData!['joinedAt'] as Timestamp).toDate();
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(joinedAt);
    
    return Card(
      elevation: 4,
      color: Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'MAHAWELI AUTHORITY',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Queue Ticket',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            Divider(thickness: 2),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ticket ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_ticketIdController.text.substring(0, 8)),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Counter:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_ticketData!['counterName'] ?? 'N/A'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Service:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_ticketData!['serviceName'] ?? 'N/A'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Joined at:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(formattedDate),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status:', style: TextStyle(fontWeight: FontWeight.bold)),
                Chip(
                  label: Text(
                    _ticketData!['status']?.toUpperCase() ?? 'N/A',
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: _getStatusColor(_ticketData!['status']),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Position in queue:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('$_positionInQueue', style: TextStyle(fontSize: 18)),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Please be ready when your number is called',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'waiting':
        return Colors.orange;
      case 'serving':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}

class StaffDashboardScreen extends StatefulWidget {
  @override
  _StaffDashboardScreenState createState() => _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends State<StaffDashboardScreen> {
  String? _selectedCounter;
  List<Map<String, dynamic>> _counters = [];
  List<Map<String, dynamic>> _queue = [];

  @override
  void initState() {
    super.initState();
    _loadCounters();
  }

  Future<void> _loadCounters() async {
    final countersSnapshot = await FirebaseFirestore.instance.collection('counters').get();
    setState(() {
      _counters = countersSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
      if (_counters.isNotEmpty) {
        _selectedCounter = _counters.first['id'];
        _loadQueue();
      }
    });
  }

  Future<void> _loadQueue() async {
    if (_selectedCounter == null) return;

    final queueSnapshot = await FirebaseFirestore.instance
        .collection('queue')
        .where('counterId', isEqualTo: _selectedCounter)
        .where('status', isEqualTo: 'waiting')
        .orderBy('priority', descending: true)
        .orderBy('joinedAt')
        .get();

    setState(() {
      _queue = queueSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> _callNext() async {
    if (_queue.isEmpty) return;

    final nextTicket = _queue.first;
    await FirebaseFirestore.instance.collection('queue').doc(nextTicket['id']).update({
      'status': 'serving',
      'calledAt': Timestamp.now(),
    });

    _loadQueue();
  }

  Future<void> _serveTicket(String ticketId) async {
    await FirebaseFirestore.instance.collection('queue').doc(ticketId).update({
      'status': 'completed',
      'servedAt': Timestamp.now(),
    });

    _loadQueue();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Staff Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedCounter,
                    decoration: InputDecoration(
                      labelText: 'Select Counter',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Iconsax.location),
                    ),
                    items: _counters.map((counter) {
                      return DropdownMenuItem<String>(
                        value: counter['id'],
                        child: Text(counter['name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCounter = value;
                        _loadQueue();
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _callNext,
                          child: Text('Call Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Current Queue',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          if (_queue.isEmpty)
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No customers in queue'),
              ),
            )
          else
            ..._queue.map((ticket) => _buildQueueItem(ticket)).toList(),
        ],
      ),
    );
  }

  Widget _buildQueueItem(Map<String, dynamic> ticket) {
    final joinedAt = (ticket['joinedAt'] as Timestamp).toDate();
    final formattedTime = DateFormat('HH:mm').format(joinedAt);
    
    return Card(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(Iconsax.user, color: Colors.green),
        title: Text('Ticket #${ticket['id'].substring(0, 8)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Priority: ${ticket['priority']}'),
            Text('Joined at: $formattedTime'),
            if (ticket['isElderly'] == true) Text('Elderly/Disabled', style: TextStyle(color: Colors.blue)),
            if (ticket['hasAppointment'] == true) Text('Appointment', style: TextStyle(color: Colors.green)),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _serveTicket(ticket['id']),
          child: Text('Serve'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
          ),
        ),
      ),
    );
  }
}
