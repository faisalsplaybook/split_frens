import 'package:flutter/material.dart';

// ==========================================
// Reusable Text Field
// ==========================================
// Creating our own custom Text Field means we don't have to rewrite 
// the styling (like borders, padding, hints) every single time we need an input!
class AppTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  // This takes a function that returns a String? (the error message)
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;
  final IconData? prefixIcon;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // TextFormField is the standard Flutter widget for forms because
    // it automatically connects to the surrounding Form widget for validation.
    return Padding(
      // We add some bottom padding so multiple fields don't squish together
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        // The decoration determines how the field looks
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          // We use an OutlineInputBorder to give it a modern box look
          border: const OutlineInputBorder(),
          // filled: true and fillColor gives it a subtle background color
          filled: true,
          fillColor: Colors.grey.shade50,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        ),
      ),
    );
  }
}
