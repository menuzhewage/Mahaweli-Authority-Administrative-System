import 'package:flutter/material.dart';

class CustomDropdownField extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? selectedValue;
  final Function(String?) onChanged;

  const CustomDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: onChanged,
        validator: (value) => value == null ? "Please select $label" : null,
      ),
    );
  }
}
