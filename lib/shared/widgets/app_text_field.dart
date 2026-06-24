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
  final String? prefixText;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.prefixIcon,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    // TextFormField is the standard Flutter widget for forms because
    // it automatically connects to the surrounding Form widget for validation.
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8), // textSubtitle
              ),
            ),
            const SizedBox(height: 8),
          ],
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
            // The decoration determines how the field looks
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
              prefixText: prefixText,
            ),
          ),
        ],
      ),
    );
  }
}
