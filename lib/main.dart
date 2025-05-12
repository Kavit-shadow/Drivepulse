// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Import screens
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/attendance_screen.dart';
import 'screens/scanner_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final storage = const FlutterSecureStorage();

  // Function to check initial login state
  Future<String> _getInitialRoute() async {
    try {
      String? custUid = await storage.read(key: 'cust_uid');
      if (custUid != null && custUid.isNotEmpty) {
        print("User already logged in: $custUid");
        return '/home'; // Already logged in
      }
    } catch (e) {
      print("Error reading from secure storage: $e");
      // Fallback to login if storage fails
    }
    print("User not logged in.");
    return '/login'; // Not logged in
  }

  @override
  Widget build(BuildContext context) {
    // Define light theme
    final ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF46abcc), // Accent blue
        secondary: Colors.lightBlueAccent,
        background: Colors.grey[100]!,
        surface: Colors.white,
        error: Colors.red.shade700,
      ),
      scaffoldBackgroundColor: Colors.grey[100],
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF46abcc), // Blue AppBar
        foregroundColor: Colors.white, // White text/icons on AppBar
        elevation: 2.0,
        titleTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF46abcc), // Button color
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          )
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[350]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color(0xFF46abcc), width: 2.0),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIconColor: const Color(0xFF46abcc), // Icon color
      ),
      cardTheme: CardTheme(
        elevation: 1.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: const Color(0xFF46abcc), // Icon color for lists
      ),
      fontFamily: 'Poppins', // Or your preferred font
    );

    return MaterialApp(
      title: 'DrivePulse Student',
      theme: lightTheme,
      // darkTheme: /* Define dark theme later if needed */,
      // themeMode: ThemeMode.light, // Force light theme for now
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<String>(
        future: _getInitialRoute(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            // Navigate based on stored state ONLY AFTER future completes
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (snapshot.data == '/home') {
                Navigator.of(context).pushReplacementNamed('/home');
              }
              // If initial route is '/login', LoginScreen will be built below
            });
            // Default to LoginScreen while deciding initial route
            return  LoginScreen();
          }
        },
      ),
      // Define routes
      routes: {
        '/login': (context) =>  LoginScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) =>  ProfileScreen(),
        '/attendance': (context) =>  AttendanceScreen(),
        '/scanner': (context) => ScannerScreen(),
      },
    );
  }
}