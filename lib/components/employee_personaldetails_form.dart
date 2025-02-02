import 'package:flutter/material.dart';

class AddEmployeeForm extends StatelessWidget {
  const AddEmployeeForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 13, 13, 14),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add the heading for Employee Registration Form
            const Text(
              'Employee Registration Form',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Registration Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextField('Email Address', TextInputType.emailAddress),
            _buildDropdownField(
                'Department', ['HR', 'IT', 'Finance', 'Marketing']),
            _buildDropdownField(
                'Designation', ['Manager', 'Engineer', 'Analyst', 'Clerk']),
            _buildTextField('EMP-ID', TextInputType.text),
            const SizedBox(height: 20),
            const Text(
              'Personal Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildTextField('EPF-NO', TextInputType.text),
            _buildTextField('Full Name', TextInputType.text),
            _buildTextField('Name with Initials', TextInputType.text),
            _buildTextField('Resident Address', TextInputType.text),
            _buildTextField('Telephone', TextInputType.phone),
            _buildDateField(context, 'Birthdate'),
            _buildTextField('NIC', TextInputType.text),
            _buildDropdownField('Gender', ['Male', 'Female']),
            _buildDropdownField('Marital Status', ['Married', 'Single']),
            _buildDateField(context, 'Pension Date'),
            _buildTextField(
                'First Appointment Designation', TextInputType.text),
            _buildTextField('First Appointment Grade', TextInputType.text),
            _buildDateField(context, 'First Appointment Date'),
            _buildDateField(context, 'Date of Service Establishment'),
            _buildTextField('Current Designation', TextInputType.text),
            _buildTextField('Current Designation Grade', TextInputType.text),
            _buildDateField(context, 'Date Appointed to Current Designation'),
            _buildDropdownField(
                'Service Category', ['Permanent', 'Temporary', 'Contract']),
            _buildDropdownField(
                'Salary Category', ['Grade A', 'Grade B', 'Grade C']),
            _buildTextField('Salary Scale', TextInputType.text),
            _buildTextField('Current Basic Salary', TextInputType.number),
            _buildDateField(context, 'Salary Increment Date'),
            _buildDateField(context, 'Date Appointed to System D'),
            _buildTextField('Current Working Place', TextInputType.text),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle form submission logic here
                },
                child: const Text('Register Employee'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextInputType inputType) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> options) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items: options.map((option) {
          return DropdownMenuItem(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label) {
    TextEditingController dateController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: dateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            dateController.text =
                "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          }
        },
      ),
    );
  }
}

void main() => runApp(const MaterialApp(home: AddEmployeeForm()));
