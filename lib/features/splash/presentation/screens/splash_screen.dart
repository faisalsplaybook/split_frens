import 'package:flutter/material.dart';
// We import the HomeScreen so we can navigate to it.
// We use relative paths to go up a few folders to reach lib/screens/
import '../../../../screens/home_screen.dart';

/// The splash screen is the first screen the user sees when opening the app.
/// We make it a StatefulWidget because we need to run some code (a delay) as soon as it loads.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // initState is called exactly once when the screen is first created.
  @override
  void initState() {
    super.initState();
    // Start our delayed navigation process as soon as the screen loads
    _navigateToHome();
  }

  /// A method that waits for a few seconds, then navigates to the home screen.
  Future<void> _navigateToHome() async {
    // 1. Wait for 2.5 seconds.
    // In the future, instead of a simple delay, we'll wait for local data to load here.
    await Future.delayed(const Duration(milliseconds: 2500));

    // 2. Check if the widget is still 'mounted' (still on screen).
    // It's a standard Flutter safety check after doing anything asynchronous (like waiting).
    if (!mounted) return;

    // 3. Navigate to the HomeScreen.
    // We use pushReplacement instead of just push.
    // This replaces the splash screen in the navigation stack so that if the user
    // presses the Android back button on the Home Screen, it closes the app
    // instead of taking them back to the splash screen.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use Center to push everything into the exact middle of the screen.
      body: Center(
        child: Column(
          // mainAxisAlignment centers the children vertically within the Column.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Name
            Text(
              'SplitFrens',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Theme.of(
                  context,
                ).colorScheme.primary, // Using our primary theme color
              ),
            ),

            const SizedBox(height: 8), // Small vertical space
            // Tagline
            Text(
              'Split trips. Settle fast.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                letterSpacing: 0.5, // Adds a tiny bit of space between letters
              ),
            ),

            const SizedBox(
              height: 48,
            ), // A larger gap before the loading spinner
            // Small loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
