import 'package:flutter/material.dart';
// Import go_router so we can use context.go() for navigation.
// This is the ONLY navigation system we should be using in this app.
import 'package:go_router/go_router.dart';

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

    // 3. Navigate to the Home screen using go_router's context.go().
    //
    // IMPORTANT: We use context.go('/') NOT context.push('/').
    // The difference is crucial:
    //   - context.push() ADDS '/' on top of '/splash', so back button returns to splash.
    //   - context.go() REPLACES the entire stack with '/', so there is no way to go back.
    // This is exactly what we want for a splash screen!
    context.go('/');
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
