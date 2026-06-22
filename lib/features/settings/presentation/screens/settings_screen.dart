import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../hangouts/data/repositories/hangout_repository.dart';
import '../../../hangouts/presentation/providers/expense_provider.dart';
import '../../../hangouts/presentation/providers/hangout_provider.dart';
import '../../../hangouts/presentation/providers/person_provider.dart';
import '../../data/services/settings_service.dart';

// ==========================================
// Settings Screen
// ==========================================
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late String _currentCurrency;

  @override
  void initState() {
    super.initState();
    _currentCurrency = SettingsService.getDefaultCurrency();
  }

  void _updateCurrency(String newCurrency) async {
    final currency = newCurrency.trim().toUpperCase();
    if (currency.isNotEmpty) {
      await SettingsService.setDefaultCurrency(currency);
      setState(() {
        _currentCurrency = currency;
      });
    }
  }

  void _showCurrencyDialog() {
    final controller = TextEditingController(text: _currentCurrency);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Default Currency'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Currency Code',
              hintText: 'USD, EUR, GBP...',
            ),
            textCapitalization: TextCapitalization.characters,
            maxLength: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                _updateCurrency(controller.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete all data?'),
          content: const Text('Are you sure? This will delete all saved hangouts.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () async {
                // 1. Wipe the database
                await HangoutRepository().clearAll();

                // 2. Clear all providers in memory (which will auto-save empty lists)
                ref.read(hangoutsProvider.notifier).clearAllHangouts();
                
                // We don't explicitly have clearAll on persons/expenses yet, 
                // but wiping hangouts is the core structure. 
                // To be completely clean, let's force a reload.
                // In Riverpod, we can invalidate to force them to re-run their build().
                ref.invalidate(hangoutsProvider);
                ref.invalidate(personsProvider);
                ref.invalidate(expensesProvider);

                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All local data cleared.')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Default currency'),
            subtitle: Text(_currentCurrency),
            onTap: _showCurrencyDialog,
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About SplitFrens'),
            subtitle: Text('Version 1.0.0'),
          ),
          const Divider(),
          ListTile(
            leading: Icon(
              Icons.delete_forever,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(
              'Clear all local data',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _showClearDataDialog,
          ),
        ],
      ),
    );
  }
}
