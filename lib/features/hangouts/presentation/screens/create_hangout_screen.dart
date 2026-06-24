import 'package:flutter/material.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_dropdown.dart';
import '../../../../core/utils/validators.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/hangout_model.dart';
import '../providers/hangout_provider.dart';
import '../../../settings/data/services/settings_service.dart';

// ==========================================
// Create Hangout Screen
// ==========================================
// We changed this to a StatefulWidget because we need to remember the state
// of our form (what the user typed, if travel mode is toggled on, etc).
// We changed this to a ConsumerStatefulWidget because we need to remember the state
// of our form AND we need access to Riverpod providers!
class CreateHangoutScreen extends ConsumerStatefulWidget {
  const CreateHangoutScreen({super.key});

  @override
  ConsumerState<CreateHangoutScreen> createState() => _CreateHangoutScreenState();
}

class _CreateHangoutScreenState extends ConsumerState<CreateHangoutScreen> {
  // 1. The Form Key
  // This is a unique key that identifies our form. We use it later to trigger
  // the validation check when the user presses 'Save'.
  final _formKey = GlobalKey<FormState>();

  // 2. Controllers
  // Controllers allow us to read the text the user has typed into the TextFields.
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();

  // 3. State Variables
  // Variables to hold the dropdown and toggle selections
  String _selectedType = 'Hangout';

  @override
  void dispose() {
    // Always dispose controllers when the screen is destroyed to free up memory!
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // This function is called when the user presses the 'Create' button
  void _submitForm() {
    // _formKey.currentState!.validate() goes through every field in our Form
    // and runs the validator functions we gave them.
    if (_formKey.currentState!.validate()) {
      // If validate() returns true, all fields passed!

      // 1. Create a unique ID for our new hangout using the uuid package
      final newId = const Uuid().v4();

      // 2. Create the Hangout object
      final newHangout = HangoutModel(
        id: newId,
        title: _nameController.text.trim(),
        startDate: DateTime.now(), // For now, we just use today's date
        // As requested for Day 4: keep people and expenses empty!
        participantIds: [],
        expenseIds: [],
        defaultCurrency: SettingsService.getDefaultCurrency(),
      );

      // 3. Add it to our central state (Riverpod) instead of the local DummyData list!
      // We use ref.read instead of ref.watch because we are inside a button press (an event), 
      // not inside the build() method.
      ref.read(hangoutsProvider.notifier).createHangout(newHangout);

      // 4. Show visual feedback to the user
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hangout created!')));

      // 5. Navigate to the new Hangout's Detail Screen.
      // We use pushReplacement so that if the user hits the back button,
      // it takes them to the Home screen, NOT back to this form!
      context.pushReplacement('/hangout/$newId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Hangout')),
      // We use SingleChildScrollView so the screen can scroll if the keyboard pops up
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // The Form widget wraps all our inputs and links them to the _formKey
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. Hangout Name (Required)
              // ==========================================
              AppTextField(
                label: 'Hangout Name',
                hint: 'e.g., Weekend Getaway',
                controller: _nameController,
                // We use our custom validator here!
                validator: AppValidators.validateHangoutName,
              ),

              // ==========================================
              // 2. Optional Note
              // ==========================================
              AppTextField(
                label: 'Note (Optional)',
                hint: 'Any details to remember?',
                controller: _noteController,
                maxLines: 3, // Makes the box bigger for longer text
                // No validator needed since it's optional
              ),

              // ==========================================
              // 3. Type Dropdown
              // ==========================================
              AppDropdown<String>(
                label: 'Type',
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'Hangout', child: Text('Hangout')),
                  DropdownMenuItem(value: 'Trip', child: Text('Trip')),
                ],
                onChanged: (value) {
                  // setState tells Flutter to redraw the screen with the new value
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),

              // Removed Travel Mode toggle and conditional Base Currency dropdown
              // because currency conversion is handled per-expense in AddExpensesScreen.

              const SizedBox(height: 32),

              // ==========================================
              // 6. Submit Button
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 50, // Making the button nicely sized
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Create', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
