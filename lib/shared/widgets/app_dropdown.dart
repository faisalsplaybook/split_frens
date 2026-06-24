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
          DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            decoration: const InputDecoration(
              // No labelText here, since it's displayed above
            ),
          ),
        ],
      ),
    );
  }
}
