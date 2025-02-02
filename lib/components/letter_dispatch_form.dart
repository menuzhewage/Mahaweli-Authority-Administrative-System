import 'package:flutter/material.dart';

class LetterDispatchForm extends StatefulWidget {
  @override
  _LetterDispatchFormState createState() => _LetterDispatchFormState();
}

class _LetterDispatchFormState extends State<LetterDispatchForm> {
  final _formKey = GlobalKey<FormState>();

  String? _letterId;
  String? _letterType;
  String? _department;
  DateTime? _receivedDate;
  String? _receiver;
  String? _reason;
  String? _category;
  String? _assignee;
  String? _priority;
  String? _needForReply;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 13, 14),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Header: Letter Dispatch Form
              Text(
                'Letter Dispatch Form',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              // Letter ID Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Letter ID',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _letterId = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Letter ID';
                  }
                  return null;
                },
              ),
              SizedBox(height: 17),

              // Letter Type Field (Normal, Registered)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Letter Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Normal',
                  'Registered',
                ]
                    .map((letterType) => DropdownMenuItem(
                          value: letterType,
                          child: Text(letterType),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _letterType = value),
                onSaved: (value) => _letterType = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a Letter Type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Department Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'ADM (Admin)',
                  'ACCT (Account)',
                  'TS (Technical Services)',
                  'LA (Land)',
                  'TRA (Transport)',
                  'AGR (Agriculture)',
                  'IDO (Development)'
                ]
                    .map((department) => DropdownMenuItem(
                          value: department,
                          child: Text(department),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _department = value),
                onSaved: (value) => _department = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a Department';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Received Date Field
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Received Date',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: _receivedDate != null
                      ? '${_receivedDate!.toLocal()}'.split(' ')[0]
                      : '',
                ),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _receivedDate = pickedDate;
                    });
                  }
                },
                validator: (value) {
                  if (_receivedDate == null) {
                    return 'Please select a received date';
                  }
                  return null;
                },
                onSaved: (value) => _receivedDate = _receivedDate,
              ),
              SizedBox(height: 16),

              // Receiver Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Receiver',
                  border: OutlineInputBorder(),
                ),
                items: ['Receiver 1', 'Receiver 2', 'Receiver 3']
                    .map((receiver) => DropdownMenuItem(
                          value: receiver,
                          child: Text(receiver),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _receiver = value),
                onSaved: (value) => _receiver = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a receiver';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Reason Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                items: ['Reason 1', 'Reason 2', 'Reason 3']
                    .map((reason) => DropdownMenuItem(
                          value: reason,
                          child: Text(reason),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _reason = value),
                onSaved: (value) => _reason = value,
              ),
              SizedBox(height: 16),

              // Category Field (Internal, External)
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Internal',
                  'External',
                ]
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
                onSaved: (value) => _category = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a Category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Assignee Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Assignee',
                  border: OutlineInputBorder(),
                ),
                items: ['Assignee 1', 'Assignee 2', 'Assignee 3']
                    .map((assignee) => DropdownMenuItem(
                          value: assignee,
                          child: Text(assignee),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _assignee = value),
                onSaved: (value) => _assignee = value,
              ),
              SizedBox(height: 16),

              // Priority Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: ['High', 'Moderate', 'Low']
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _priority = value),
                onSaved: (value) => _priority = value,
              ),
              SizedBox(height: 16),

              // Need for Reply Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Need for Reply',
                  border: OutlineInputBorder(),
                ),
                items: ['Yes', 'No']
                    .map((reply) => DropdownMenuItem(
                          value: reply,
                          child: Text(reply),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _needForReply = value),
                onSaved: (value) => _needForReply = value,
              ),
              SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Handle form submission here
                    print('Letter ID: $_letterId');
                    print('Letter Type: $_letterType');
                    print('Department: $_department');
                    print('Received Date: $_receivedDate');
                    print('Receiver: $_receiver');
                    print('Reason: $_reason');
                    print('Category: $_category');
                    print('Assignee: $_assignee');
                    print('Priority: $_priority');
                    print('Need for Reply: $_needForReply');
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: LetterDispatchForm()));
