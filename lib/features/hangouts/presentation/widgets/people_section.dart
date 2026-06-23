import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/hangout_model.dart';
import '../../data/models/person_model.dart';
import '../providers/person_provider.dart';

// ==========================================
// People Section Widget
// ==========================================
// Displays the participants header and a horizontal scrollable list of
// avatar circles, or an empty state CTA if no people have been added.
class PeopleSection extends ConsumerWidget {
  final HangoutModel hangout;

  const PeopleSection({super.key, required this.hangout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPeople = ref.watch(personsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Participants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '${hangout.participantIds.length} people',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (hangout.participantIds.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.people_alt_outlined, color: Colors.grey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Add friends to start splitting.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.push('/hangout/${hangout.id}/add-people'),
                    child: const Text('Add Now'),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hangout.participantIds.length,
              itemBuilder: (context, index) {
                final personId = hangout.participantIds[index];
                final person = allPeople.firstWhere(
                  (p) => p.id == personId,
                  orElse: () => PersonModel(id: personId, name: '?'),
                );

                final initials = person.name.isNotEmpty
                    ? person.name.substring(0, 1).toUpperCase()
                    : '?';

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
