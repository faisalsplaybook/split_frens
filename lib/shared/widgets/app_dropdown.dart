import 'package:flutter/material.dart';

// ==========================================
// Reusable Dropdown Field
// ==========================================
// Similar to AppTextField, this standardizes how dropdowns look across our app.
// The 'T' means this is a Generic class — it can hold Strings, Enums, or any object!
class AppDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;

  const AppDropdown({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      // DropdownButtonFormField is like DropdownButton, but with built-in
      // support for Form validation and InputDecoration styling!
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }
}
