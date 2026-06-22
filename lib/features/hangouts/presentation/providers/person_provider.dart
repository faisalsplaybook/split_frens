import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/person_model.dart';
import '../../data/services/local_storage_service.dart';
import 'hangout_provider.dart';
import 'expense_provider.dart';

class PersonsNotifier extends Notifier<List<PersonModel>> {
  @override
  List<PersonModel> build() {
    return LocalStorageService.loadPersons();
  }

  void _save() {
    LocalStorageService.saveAllData(
      hangouts: ref.read(hangoutsProvider),
      persons: state,
      expenses: ref.read(expensesProvider),
    );
  }

  /// Adds a new person to our global list
  void addPerson(PersonModel person) {
    // Check for duplicates first!
    final isDuplicate = state.any(
      (p) => p.name.toLowerCase() == person.name.toLowerCase(),
    );
    
    if (isDuplicate) {
      throw Exception('A person with this name already exists.');
    }
    
    state = [...state, person];
    _save();
  }

  /// Finds a person by their ID
  PersonModel? getPersonById(String id) {
    try {
      return state.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Updates an existing person (like changing their contact info)
  void updatePerson(PersonModel updatedPerson) {
    state = state.map((p) {
      if (p.id == updatedPerson.id) {
        return updatedPerson;
      }
      return p;
    }).toList();
    _save();
  }

  /// Removes a person completely from the app
  void deletePerson(String id) {
    state = state.where((p) => p.id != id).toList();
    _save();
  }
}

final personsProvider = NotifierProvider<PersonsNotifier, List<PersonModel>>(() {
  return PersonsNotifier();
});
