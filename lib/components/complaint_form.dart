import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const ComplaintForm());
}

class ComplaintForm extends StatelessWidget {
  const ComplaintForm({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal, // Set primaryColor directly
        scaffoldBackgroundColor: Colors.grey[100],
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: ComplaintFormScreen(),
    );
  }
}

class ComplaintFormScreen extends StatefulWidget {
  const ComplaintFormScreen({super.key});

  @override
  _ComplaintFormScreenState createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController complaintIdController = TextEditingController();
  final TextEditingController nicController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController relatedFieldController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  String? priority;
  String? status;
  String? occurrence;
  String? relatedField;

  final List<String> priorityOptions = ['High', 'Moderate', 'Low'];
  final List<String> statusOptions = [
    'Completed',
    'In Progress',
    'To Be Started'
  ];
  final List<String> occurrenceOptions = ['First', 'Second', 'Third'];
  final List<String> relatedFieldOptions = [
    'ADM(ADMIN)',
    'ACCT(Account)',
    'TS(Technical services)',
    'LA(Land)',
    'TRA(Transport)',
    'AGR(Agriculture)',
    'IDO(Development)'
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Form Submitted'),
          content:
              const Text('Your complaint has been successfully submitted.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Complaint Form',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(complaintIdController, 'Complaint ID'),
              _buildTextField(nicController, 'Beneficiary NIC'),
              _buildTextField(nameController, 'Beneficiary Name'),
              _buildTextField(addressController, 'Beneficiary Address'),
              _buildTextField(subjectController, 'Subject'),
              _buildDropdownField(
                  'Related Field',
                  relatedFieldOptions,
                  (value) => setState(() => relatedField = value),
                  relatedField),
              _buildDropdownField('Priority', priorityOptions,
                  (value) => setState(() => priority = value), priority),
              _buildDropdownField('Status', statusOptions,
                  (value) => setState(() => status = value), status),
              _buildDropdownField('Occurrence', occurrenceOptions,
                  (value) => setState(() => occurrence = value), occurrence),
              _buildDateField(),
              const SizedBox(height: 24.0),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 15.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: const Text('Submit', style: TextStyle(fontSize: 18.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        validator: (value) => value!.isEmpty ? '$label is required' : null,
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options,
      Function(String?) onChanged, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: options
            .map((option) =>
                DropdownMenuItem(value: option, child: Text(option)))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? '$label is required' : null,
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: dateController,
        decoration: InputDecoration(
          labelText: 'Submission Date',
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ),
        readOnly: true,
        validator: (value) =>
            value!.isEmpty ? 'Submission Date is required' : null,
      ),
    );
  }
}
