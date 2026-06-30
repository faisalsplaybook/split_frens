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

class CreateHangoutScreen extends ConsumerStatefulWidget {
  const CreateHangoutScreen({super.key});

  @override
  ConsumerState<CreateHangoutScreen> createState() =>
      _CreateHangoutScreenState();
}

class _CreateHangoutScreenState extends ConsumerState<CreateHangoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedType = 'Hangout';

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newId = const Uuid().v4();

      final newHangout = HangoutModel(
        id: newId,
        title: _nameController.text.trim(),
        startDate: DateTime.now(),
        participantIds: [],
        expenseIds: [],
        defaultCurrency: SettingsService.getDefaultCurrency(),
      );

      // ref.read, not ref.watch: this runs inside an event handler, not build().
      ref.read(hangoutsProvider.notifier).createHangout(newHangout);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Hangout created!')));

      // pushReplacement so back-button from the detail screen returns to
      // Home, not to this now-submitted form.
      context.pushReplacement('/hangout/$newId');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Hangout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Hangout Name',
                hint: 'e.g., Weekend Getaway',
                controller: _nameController,
                validator: AppValidators.validateHangoutName,
              ),
              AppTextField(
                label: 'Note (Optional)',
                hint: 'Any details to remember?',
                controller: _noteController,
                maxLines: 3,
              ),
              AppDropdown<String>(
                label: 'Type',
                value: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'Hangout', child: Text('Hangout')),
                  DropdownMenuItem(value: 'Trip', child: Text('Trip')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedType = value;
                    });
                  }
                },
              ),

              // Travel Mode toggle / Base Currency dropdown removed:
              // currency conversion is handled per-expense in AddExpensesScreen.
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
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
