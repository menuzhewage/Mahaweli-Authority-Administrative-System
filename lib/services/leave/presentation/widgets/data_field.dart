import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const DateFieldWidget({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
          }
        },
        validator: (value) => value!.isEmpty ? "Please select a date" : null,
      ),
    );
  }
}
