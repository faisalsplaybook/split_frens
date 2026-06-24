import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// ==========================================
// 1. Imports
// ==========================================
// We must import all the screens we want our router to know about.
// Notice how they are cleanly separated by feature folders!
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../screens/home_screen.dart';

// Hangouts Feature Screens
import '../../features/hangouts/presentation/screens/create_hangout_screen.dart';
import '../../features/hangouts/presentation/screens/hangout_detail_screen.dart';
import '../../features/hangouts/presentation/screens/add_people_screen.dart';
import '../../features/hangouts/presentation/screens/add_expenses_screen.dart';
import '../../features/hangouts/presentation/screens/expense_detail_screen.dart';
import '../../features/hangouts/presentation/screens/split_results_screen.dart';
import '../../features/hangouts/presentation/screens/settlements_screen.dart';
// Currency Feature Screens
import '../../features/currency/presentation/screens/currency_converter_screen.dart';

// Settings Feature Screens
import '../../features/settings/presentation/screens/settings_screen.dart';

// ==========================================
// 2. Defining the Router Provider
// ==========================================
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',

    // ==========================================
    // 3. Defining the Routes
    // ==========================================
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),

      GoRoute(
        path: '/create-hangout',
        // Now using our real CreateHangoutScreen!
        builder: (context, state) => const CreateHangoutScreen(),
      ),

      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Dynamic Routes passing 'hangoutId' downwards
      GoRoute(
        path: '/hangout/:hangoutId',
        builder: (context, state) {
          final hangoutId = state.pathParameters['hangoutId']!;
          return HangoutDetailScreen(hangoutId: hangoutId);
        },
      ),

      GoRoute(
        path: '/hangout/:hangoutId/add-people',
        builder: (context, state) {
          final hangoutId = state.pathParameters['hangoutId']!;
          return AddPeopleScreen(hangoutId: hangoutId);
        },
      ),

      GoRoute(
        path: '/hangout/:hangoutId/add-expense',
        builder: (context, state) {
          final hangoutId = state.pathParameters['hangoutId']!;
          return AddExpensesScreen(hangoutId: hangoutId);
        },
      ),

      GoRoute(
        path: '/hangout/:hangoutId/expense/:expenseId',
        builder: (context, state) {
          final hangoutId = state.pathParameters['hangoutId']!;
          final expenseId = state.pathParameters['expenseId']!;
          return ExpenseDetailScreen(
            hangoutId: hangoutId,
            expenseId: expenseId,
          );
        },
      ),

      GoRoute(
        path: '/hangout/:hangoutId/results',
        builder: (context, state) {
          final hangoutId = state.pathParameters['hangoutId']!;
          return SplitResultsScreen(hangoutId: hangoutId);
        },
      ),

      GoRoute(
        path: '/hangout/:hangoutId/settlements',
        builder: (context, state) {
          final hangoutId = state.pathParameters['hangoutId']!;
          return SettlementsScreen(hangoutId: hangoutId);
        },
      ),

      GoRoute(
        path: '/hangout/:hangoutId/currency-converter',
        builder: (context, state) {
          final hangoutId = state.pathParameters['hangoutId']!;
          return CurrencyConverterScreen(hangoutId: hangoutId);
        },
      ),
    ],
  );
});
