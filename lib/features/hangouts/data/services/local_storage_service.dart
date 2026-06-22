import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/expense_model.dart';
import '../models/hangout_model.dart';
import '../models/person_model.dart';

// ==========================================
// LocalStorageService
// ==========================================
// Single source of truth for all Hive read/write operations.
// Stores all three lists (Hangouts, Persons, Expenses) under separate
// keys so that our normalized, ID-linked architecture is fully preserved.
class LocalStorageService {
  static const String _boxName = 'split_frens_box';
  static const String _hangoutsKey = 'hangouts';
  static const String _personsKey = 'persons';
  static const String _expensesKey = 'expenses';

  static late Box _box;

  // ==========================================
  // init: Must be called once in main() before runApp
  // ==========================================
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // ==========================================
  // Save: Serializes all three lists to JSON and writes them to Hive
  // ==========================================
  static Future<void> saveAllData({
    required List<HangoutModel> hangouts,
    required List<PersonModel> persons,
    required List<ExpenseModel> expenses,
  }) async {
    await _box.put(
      _hangoutsKey,
      jsonEncode(hangouts.map((h) => h.toJson()).toList()),
    );
    await _box.put(
      _personsKey,
      jsonEncode(persons.map((p) => p.toJson()).toList()),
    );
    await _box.put(
      _expensesKey,
      jsonEncode(expenses.map((e) => e.toJson()).toList()),
    );
  }

  // ==========================================
  // Load: Reads JSON strings and deserializes into model objects
  // Returns empty list if no data is stored yet (first launch)
  // ==========================================
  static List<HangoutModel> loadHangouts() {
    final raw = _box.get(_hangoutsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw as String) as List;
    return list
        .map((json) => HangoutModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static List<PersonModel> loadPersons() {
    final raw = _box.get(_personsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw as String) as List;
    return list
        .map((json) => PersonModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static List<ExpenseModel> loadExpenses() {
    final raw = _box.get(_expensesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw as String) as List;
    return list
        .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ==========================================
  // Clear: Wipes the entire box
  // ==========================================
  static Future<void> clearAllData() async {
    await _box.clear();
  }
}
