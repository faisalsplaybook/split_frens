import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../models/person_model.dart';
import '../providers/hangout_provider.dart';
import '../providers/person_provider.dart';
import '../providers/expense_provider.dart';

// ==========================================
// Add People Screen
// ==========================================
// Used to add friends/participants to a specific hangout.
class AddPeopleScreen extends ConsumerStatefulWidget {
  final String hangoutId;

  const AddPeopleScreen({super.key, required this.hangoutId});

  @override
  ConsumerState<AddPeopleScreen> createState() => _AddPeopleScreenState();
}

class _AddPeopleScreenState extends ConsumerState<AddPeopleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _addPerson() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final contactInfo = _contactController.text.trim();

      // Check if person already exists globally (to block duplicates)
      final allPeople = ref.read(personsProvider);
      final isDuplicate = allPeople.any((p) => p.name.toLowerCase() == name.toLowerCase());

      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A person with this name already exists!')),
        );
        return;
      }

      // 1. Create the new person
      final newPerson = PersonModel(
        id: const Uuid().v4(),
        name: name,
        contactInfo: contactInfo.isNotEmpty ? contactInfo : null,
      );

      // 2. Add to global persons list
      ref.read(personsProvider.notifier).addPerson(newPerson);

      // 3. Add to this specific hangout
      ref.read(hangoutsProvider.notifier).addPerson(widget.hangoutId, newPerson.id);

      // 4. Clear the form
      _nameController.clear();
      _contactController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Person added!')),
      );
    }
  }

  void _removePerson(String personId) {
    // 1. Check if the person is part of any expense in this hangout
    final hangout = ref.read(hangoutsProvider).firstWhere((h) => h.id == widget.hangoutId);
    final allExpenses = ref.read(expensesProvider);
    
    // Get only the expenses that belong to this hangout
    final hangoutExpenses = allExpenses.where((e) => hangout.expenseIds.contains(e.id)).toList();
    
    // Check if the person is involved in any of these expenses
    final isInvolved = hangoutExpenses.any(
      (e) => e.paidById == personId || e.participantIds.contains(personId),
    );

    if (isInvolved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This person is already part of an expense.')),
      );
      return;
    }

    ref.read(hangoutsProvider.notifier).removePerson(widget.hangoutId, personId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Person removed from hangout')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Watch the current hangout to get its participant IDs
    final hangout = ref.watch(hangoutsProvider).firstWhere((h) => h.id == widget.hangoutId);
    
    // 2. Watch all people to find the actual PersonModel for each ID
    final allPeople = ref.watch(personsProvider);
    
    // 3. Get the full models for the participants in this hangout
    final participants = hangout.participantIds
        .map((id) => allPeople.firstWhere((p) => p.id == id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add People'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ==========================================
            // Add Person Form
            // ==========================================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Add a Friend',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      
                      AppTextField(
                        controller: _nameController,
                        label: 'Name',
                        hint: 'e.g. John Doe',
                        prefixIcon: Icons.person,
                        validator: (value) => AppValidators.validateRequiredText(value, 'Name'),
                      ),
                      const SizedBox(height: 16),
                      
                      AppTextField(
                        controller: _contactController,
                        label: 'Contact Info (Optional)',
                        hint: 'e.g. john@email.com or 555-1234',
                        prefixIcon: Icons.contact_mail,
                      ),
                      const SizedBox(height: 16),
                      
                      ElevatedButton.icon(
                        onPressed: _addPerson,
                        icon: const Icon(Icons.add),
                        label: const Text('Add to Hangout'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ==========================================
            // Added People List
            // ==========================================
            const Text(
              'Added Participants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: participants.isEmpty
                  ? const Center(
                      child: Text(
                        'No people added yet.\\nUse the form above to add friends!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: participants.length,
                      itemBuilder: (context, index) {
                        final person = participants[index];
                        // Auto-generate initials for the avatar
                        final initials = person.name.isNotEmpty 
                            ? person.name.substring(0, 1).toUpperCase() 
                            : '?';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(person.name),
                            subtitle: person.contactInfo != null 
                                ? Text(person.contactInfo!) 
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                              onPressed: () => _removePerson(person.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
