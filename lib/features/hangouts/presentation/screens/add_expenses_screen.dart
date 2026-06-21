import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../models/expense_model.dart';
import '../../../../models/split_type.dart';
import '../providers/hangout_provider.dart';
import '../providers/person_provider.dart';
import '../providers/expense_provider.dart';

// ==========================================
// Add Expenses Screen
// ==========================================
class AddExpensesScreen extends ConsumerStatefulWidget {
  final String hangoutId;

  const AddExpensesScreen({super.key, required this.hangoutId});

  @override
  ConsumerState<AddExpensesScreen> createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends ConsumerState<AddExpensesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _selectedPayerId;
  final Set<String> _selectedParticipantIds = {};

  // For Phase 1 travel mode / currency
  bool _isTravelMode = false;
  final _currencyController = TextEditingController();
  final _convertedAmountController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _currencyController.dispose();
    _convertedAmountController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      if (_selectedPayerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select who paid.')),
        );
        return;
      }

      if (_selectedParticipantIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one participant.'),
          ),
        );
        return;
      }

      final amount = double.parse(_amountController.text.trim());

      final newExpense = ExpenseModel(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: amount,
        date: DateTime.now(),
        paidById: _selectedPayerId!,
        splitType: SplitType.equal, // Phase 1 assumes equal split
        participantIds: _selectedParticipantIds.toList(),
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
        currency: _isTravelMode ? _currencyController.text.trim() : null,
        convertedAmount:
            _isTravelMode && _convertedAmountController.text.trim().isNotEmpty
            ? double.tryParse(_convertedAmountController.text.trim())
            : null,
      );

      // 1. Add to global expenses provider
      ref.read(expensesProvider.notifier).addExpense(newExpense);

      // 2. Add reference to the hangout
      ref
          .read(hangoutsProvider.notifier)
          .addExpense(widget.hangoutId, newExpense.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully!')),
      );

      // Go back to detail screen
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/hangout/${widget.hangoutId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hangout = ref
        .watch(hangoutsProvider)
        .firstWhere((h) => h.id == widget.hangoutId);
    final allPeople = ref.watch(personsProvider);

    // Get the actual PersonModel objects for the participants in this hangout
    final hangoutPeople = hangout.participantIds
        .map((id) => allPeople.firstWhere((p) => p.id == id))
        .toList();

    // ==========================================
    // UX Guard: Less than 2 people
    // ==========================================
    if (hangoutPeople.length < 2) {
      return Scaffold(
        appBar: AppBar(title: const Text('Add Expense')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_add, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Add at least 2 friends before adding expenses.',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.push('/hangout/${widget.hangoutId}/add-people'),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Friends'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Initialize all participants as selected by default if empty
    if (_selectedParticipantIds.isEmpty && _titleController.text.isEmpty) {
      _selectedParticipantIds.addAll(hangout.participantIds);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 1. Title & Amount
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      controller: _titleController,
                      label: 'Expense Title',
                      hint: 'e.g. Dinner, Taxi, Tickets',
                      prefixIcon: Icons.receipt,
                      validator: (value) =>
                          AppValidators.validateRequiredText(value, 'Title'),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _amountController,
                      label: 'Amount',
                      hint: '0.00',
                      prefixIcon: Icons.attach_money,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: AppValidators.validateAmount,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Travel Mode / Currency
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Foreign Currency (Travel Mode)'),
                      value: _isTravelMode,
                      onChanged: (val) => setState(() => _isTravelMode = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_isTravelMode) ...[
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _currencyController,
                        label: 'Currency',
                        hint: 'e.g. EUR, THB, JPY',
                        prefixIcon: Icons.public,
                        validator: (value) => AppValidators.validateCurrency(
                          value,
                          _isTravelMode,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _convertedAmountController,
                        label: 'Converted Amount (Optional)',
                        hint: '0.00',
                        prefixIcon: Icons.currency_exchange,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 3. Payer & Participants
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Who paid?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payment),
                      ),
                      hint: const Text('Select Payer'),
                      initialValue: _selectedPayerId,
                      items: hangoutPeople.map((person) {
                        return DropdownMenuItem(
                          value: person.id,
                          child: Text(person.name),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedPayerId = val;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Payer is required' : null,
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'For whom?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Split Type: Equal',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Select All Checkbox
                    CheckboxListTile(
                      title: const Text('Select All', style: TextStyle(fontWeight: FontWeight.bold)),
                      value: _selectedParticipantIds.length == hangoutPeople.length,
                      onChanged: (selected) {
                        setState(() {
                          if (selected == true) {
                            _selectedParticipantIds.addAll(hangoutPeople.map((p) => p.id));
                          } else {
                            _selectedParticipantIds.clear();
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: Theme.of(context).colorScheme.primary,
                    ),
                    const Divider(),

                    ...hangoutPeople.map((person) {
                      return CheckboxListTile(
                        title: Text(person.name),
                        value: _selectedParticipantIds.contains(person.id),
                        onChanged: (selected) {
                          setState(() {
                            if (selected == true) {
                              _selectedParticipantIds.add(person.id);
                            } else {
                              _selectedParticipantIds.remove(person.id);
                            }
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Note
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AppTextField(
                  controller: _noteController,
                  label: 'Note (Optional)',
                  hint: 'Any extra details?',
                  prefixIcon: Icons.notes,
                  maxLines: 3,
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _saveExpense,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Save Expense'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
