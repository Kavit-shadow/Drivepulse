// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/api_service.dart'; // Adjust path
import '../models/profile.dart'; // Adjust path

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  final _storage = FlutterSecureStorage();
  Future<Profile>? _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      String? custUid = await _storage.read(key: 'cust_uid');
      if (custUid != null && custUid.isNotEmpty) {
        print('Loaded cust_uid from storage: $custUid');
        setState(() {
          _profileFuture = _apiService.getProfile(custUid);
        });
      } else {
        setState(() {
          _profileFuture = Future.error('User not logged in.');
        });
      }
    } catch (e) {
      setState(() {
        _profileFuture = Future.error('Failed to load user data.');
      });
    }
  }

  // Updated Column-style Info Row
  Widget _buildInfoRow(String label, String? value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value ?? '-',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(height: 20, thickness: 1),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<Profile>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Error loading profile: ${snapshot.error}',
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          } else if (snapshot.hasData) {
            final profile = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCard(
                  title: 'Personal Information',
                  children: [
                    _buildInfoRow('Name', profile.name),
                    _buildInfoRow('Customer ID', profile.custUid),
                    _buildInfoRow('Email', profile.email),
                    _buildInfoRow('Phone', profile.phone),
                    _buildInfoRow('Address', profile.address),
                  ],
                ),
                _buildCard(
                  title: 'Training Details',
                  children: [
                    _buildInfoRow('Vehicle', profile.vehicle),
                    _buildInfoRow('Duration', '${profile.days ?? '-'} Days'),
                    _buildInfoRow('Time Slot', profile.timeslot),
                    _buildInfoRow('Training Start', profile.trainingStartDate),
                    _buildInfoRow('Training End', profile.trainingEndDate),
                    _buildInfoRow('RTO Work', profile.rtoWork),
                  ],
                ),
                _buildCard(
                  title: 'Trainer Information',
                  children: [
                    _buildInfoRow('Trainer Name', profile.trainerName),
                    _buildInfoRow('Trainer Phone', profile.trainerPhone),
                  ],
                ),
                _buildCard(
                  title: 'Payment Information',
                  children: [
                    _buildInfoRow('Total Amount', profile.totalAmount),
                    _buildInfoRow('Amount Paid', profile.paidAmount, valueColor: Colors.green.shade700),
                    _buildInfoRow('Amount Due', profile.dueAmount, valueColor: Colors.red.shade700),
                    _buildInfoRow('Payment Method', profile.paymentMethod),
                    _buildInfoRow('Registration Date', profile.registrationDate),
                  ],
                ),
                _buildCard(
                  title: 'Other Information',
                  children: [
                    _buildInfoRow('Form Filled By', profile.formFiller),
                    _buildInfoRow('App Access', profile.isAppUser == true ? 'Enabled' : 'Not Setup'),
                  ],
                ),
              ],
            );
          } else {
            return const Center(child: Text('No profile data found.'));
          }
        },
      ),
    );
  }
}
