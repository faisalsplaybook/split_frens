import '../models/expense_model.dart';
import '../models/hangout_model.dart';
import '../models/person_model.dart';
import '../models/split_type.dart';

/// This class holds our dummy data for testing the UI before we connect a real database.
/// We use 'static final' so we can access these lists anywhere in the app
/// simply by calling DummyData.allPeople, without having to create an object of DummyData.
class DummyData {
  // ==========================================
  // 1. Create the People (Friends)
  // ==========================================
  static final PersonModel faisal = PersonModel(id: 'p1', name: 'Faisal');
  static final PersonModel rafi = PersonModel(id: 'p2', name: 'Rafi');
  static final PersonModel nabil = PersonModel(id: 'p3', name: 'Nabil');

  static final List<PersonModel> allPeople = [faisal, rafi, nabil];

  // ==========================================
  // 2. Create the Expenses
  // ==========================================
  static final ExpenseModel kacchiExpense = ExpenseModel(
    id: 'e1',
    title: 'Kacchi',
    amount: 1200.0, // 1200 BDT
    date: DateTime(2026, 6, 7),
    paidById: faisal.id, // Faisal paid for this
    splitType: SplitType.equal, // Assuming they split the Kacchi equally
    participantIds: [faisal.id, rafi.id, nabil.id], // All 3 participated
  );

  static final ExpenseModel cokeExpense = ExpenseModel(
    id: 'e2',
    title: 'Coke',
    amount: 180.0, // 180 BDT
    date: DateTime(2026, 6, 7),
    paidById: rafi.id, // Rafi paid for this
    splitType: SplitType.equal, // Assuming they split the Coke equally
    participantIds: [faisal.id, rafi.id, nabil.id], // All 3 participated
  );

  static final List<ExpenseModel> allExpenses = [kacchiExpense, cokeExpense];

  // ==========================================
  // 3. Create the Hangout (The Event)
  // ==========================================
  static final HangoutModel fridayKacchiNight = HangoutModel(
    id: 'h1',
    title: 'Friday Kacchi Night',
    startDate: DateTime.now(),
    // Everyone who attended the hangout
    participantIds: [faisal.id, rafi.id, nabil.id],
    // All expenses linked to this hangout
    expenseIds: [kacchiExpense.id, cokeExpense.id],
  );

  static final List<HangoutModel> allHangouts = [fridayKacchiNight];
}
