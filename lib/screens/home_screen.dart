// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'attendance_screen.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = const FlutterSecureStorage();
  String _userName = 'User'; // Default name

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    String? name = await _storage.read(key: 'user_name');
    if (name != null && mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  Future<void> _logout() async {
    bool? logoutConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (logoutConfirmed == true && mounted) {
      await _storage.delete(key: 'cust_uid');
      await _storage.delete(key: 'user_name');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Widget _buildDashboardButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 28),
      label: Text(label),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),
        ],
      ),
      drawer: SizedBox(
        width: 235, // Set your custom width here
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(color: theme.colorScheme.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: 65,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome, $_userName',
                      style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'DrivePulse Student',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('View Profile'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Scan for Attendance'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.checklist_rtl),
                title: const Text('View Attendance'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceScreen()));
                },
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.error),
                title: Text('Logout', style: TextStyle(color: theme.colorScheme.error)),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✅ LOGO AT TOP
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                height: 80, // You can adjust this
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Welcome Back, $_userName!',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            GridView.count(
              crossAxisCount: 1,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 20,
              childAspectRatio: 3.5,
              children: <Widget>[
                _buildDashboardButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan for Attendance',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
                  },
                  color: theme.colorScheme.primary,
                ),
                _buildDashboardButton(
                  icon: Icons.checklist_rtl,
                  label: 'View Attendance',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceScreen()));
                  },
                  color: Colors.green.shade600,
                ),
                _buildDashboardButton(
                  icon: Icons.person_outline,
                  label: 'View Profile',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                  },
                  color: Colors.orange.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}