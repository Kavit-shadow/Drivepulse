import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // <-- added for datetime formatting
import '../api/api_service.dart'; // Adjust path
import '../models/attendance_record.dart'; // Adjust path

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final ApiService _apiService = ApiService();
  final _storage = const FlutterSecureStorage();
  Future<List<AttendanceRecord>>? _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    if (!mounted) return;
    setState(() {
      _attendanceFuture = null;
    });
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    try {
      String? custUid = await _storage.read(key: 'cust_uid');
      if (custUid != null && custUid.isNotEmpty) {
        if (mounted) {
          setState(() {
            _attendanceFuture = _apiService.getAttendance(custUid);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _attendanceFuture = Future.error('User not logged in.');
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _attendanceFuture = Future.error('Failed to get login details.');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Attendance History'),
          ],
        ),
        elevation: 1.0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadAttendanceData,
        child: FutureBuilder<List<AttendanceRecord>>(
          future: _attendanceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && _attendanceFuture != null) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error.toString());
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final records = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return Card(
                    elevation: 1.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: Icon(
                        Icons.calendar_today_outlined,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                      title: Text(
                        _formatDateTime(record.displayDatetime ?? record.date),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (record.trainerName?.isNotEmpty ?? false)
                              Text(
                                'Trainer: ${record.trainerName}',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                              ),
                            if (record.vehicleName?.isNotEmpty ?? false)
                              Text(
                                'Vehicle: ${record.vehicleName}',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                              ),
                          ].where((w) => w.data != null && w.data!.isNotEmpty).toList(),
                        ),
                      ),
                      dense: true,
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(height: 0),
              );
            } else {
              return _buildEmptyStateWidget();
            }
          },
        ),
      ),
    );
  }

  // Format datetime string to show both date and time
  String _formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy • hh:mm a').format(dt); // e.g., 30 Apr 2024 • 10:45 AM
    } catch (e) {
      return raw;
    }
  }

  Widget _buildErrorWidget(String errorMsg) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 60, color: theme.colorScheme.error),
            const SizedBox(height: 15),
            Text(
              'Error loading attendance:\n${errorMsg.replaceFirst('Exception: ', '')}',
              style: TextStyle(fontSize: 16, color: theme.colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _loadAttendanceData,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_toggle_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 15),
            const Text(
              'No attendance records found yet.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              onPressed: _loadAttendanceData,
            )
          ],
        ),
      ),
    );
  }
}
