import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Import our newly created theme file
import 'core/theme/app_theme.dart';
// 2. Import our newly created router
import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

// 3. We change StatelessWidget to ConsumerWidget.
// A ConsumerWidget is a Riverpod widget that can "listen" to providers.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 4. We read our router provider here
    // ref.watch listens to the appRouterProvider and gives us the GoRouter instance.
    final goRouter = ref.watch(appRouterProvider);

    // 5. Instead of MaterialApp, we use MaterialApp.router
    // This tells Flutter that we are using an advanced routing system (go_router)
    // instead of the basic built-in one.
    return MaterialApp.router(
      title: 'Split Frens',

      // Apply our custom theme here!
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Pass the router configuration to the app
      routerConfig: goRouter,

      // Hides the "DEBUG" banner in the top right corner
      debugShowCheckedModeBanner: false,
    );
  }
}
