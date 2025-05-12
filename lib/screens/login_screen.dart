// lib/screens/login_screen.dart (QR Login Version)
import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Access theme data

    return Scaffold(
      backgroundColor: Colors.grey[100], // Light background
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- LOGO ---
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Image.asset(
                  'assets/images/logo.png', // Your logo path
                  height: 100, // Adjust size
                ),
              ),
              // --- END LOGO ---

              Text(
                'DrivePulse Student Portal',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15.0),

              // --- Login Button ---
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Login with QR Scan'),
                style: ElevatedButton.styleFrom( // Use theme button style
                  // backgroundColor: theme.colorScheme.primary, // Already set by theme
                  // foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  // shape: RoundedRectangleBorder( ... ) // Already set by theme
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // Navigate to the Scanner screen specifically for login
                  Navigator.pushNamed(context, '/scanner', arguments: {'isLoginScan': true});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}