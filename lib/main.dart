import 'package:flutter/material.dart';
// 1. Import our newly created theme file
import 'core/theme/app_theme.dart';
// Import our new home screen
import 'screens/home_screen.dart';

void main() {
  // runApp is the starting point of any Flutter app.
  // It takes a widget (MyApp) and makes it the root of the widget tree.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp is a wrapper that provides many built-in Material Design features
    // like navigation, themes, and localization.
    return MaterialApp(
      title: 'Split Frens',
      // 2. Apply our custom theme here!
      // Now, instead of the default Flutter theme, the app will use
      // all the colors and shapes we defined in AppTheme.lightTheme.
      theme: AppTheme.lightTheme,

      // We removed the default MyHomePage and replaced it with our custom HomeScreen
      home: const HomeScreen(),

      // Hides the "DEBUG" banner in the top right corner
      debugShowCheckedModeBanner: false,
    );
  }
}
