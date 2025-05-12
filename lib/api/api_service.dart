import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/profile.dart';
import '../models/attendance_record.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.87.235/drivepulse';

  // --- Login Function (Live API) ---
  Future<User> login(String phone, String password) async {
    print("Attempting REAL login with Phone: $phone");

    final url = Uri.parse('$_baseUrl/api/student_login.php');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print("Login ERROR: $e");
      throw Exception("Network error: $e");
    }
  }

  // --- Get Profile (Live API) ---
  Future<Profile> getProfile(String custUid) async {
    final url = Uri.parse('$_baseUrl/api/get_profile.php?cust_uid=$custUid');
    print('Fetching profile from: $url'); // Debug print
    try {
      final response = await http.get(url);
      print('Profile Response Status: ${response.statusCode}'); // Debug print
      print('Profile Response Body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['profile'] != null) {
          // *** IMPORTANT: Ensure the map passed to fromJson is correct ***
          return Profile.fromJson(data['profile'] as Map<String, dynamic>);
        } else {
          throw Exception(data['message'] ?? 'Failed to load profile data.');
        }
      } else {
        throw Exception('Failed to load profile: Server error ${response.statusCode}');
      }
    } catch (e) {
      print('Get Profile Error: $e'); // Log detailed error
      throw Exception('Failed to load profile. Check connection or server logs.');
    }
  }





  // --- Get Attendance (Live API) ---
  Future<List<AttendanceRecord>> getAttendance(String custUid) async {
    final url = Uri.parse('$_baseUrl/api/get_attendance.php?cust_uid=$custUid');
    print('Fetching attendance from: $url'); // Debug print
    try {
      final response = await http.get(url);
      print('Attendance Response Status: ${response.statusCode}'); // Debug print
      print('Attendance Response Body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['attendance'] != null) {
          List<dynamic> recordsJson = data['attendance'];
          if (recordsJson is List) { // Ensure it's a list
            return recordsJson.map((json) => AttendanceRecord.fromJson(json as Map<String, dynamic>)).toList();
          } else {
            throw Exception('Invalid attendance data format.');
          }
        } else {
          // Handle case where status is success but attendance might be null/empty correctly
          if (data['status'] == 'success' && data['attendance'] == null) return []; // Return empty list
          throw Exception(data['message'] ?? 'Failed to load attendance data.');
        }
      } else {
        throw Exception('Failed to load attendance: Server error ${response.statusCode}');
      }
    } catch (e) {
      print('Get Attendance Error: $e'); // Log detailed error
      throw Exception('Failed to load attendance. Check connection or server logs.');
    }
  }


// --- Mark Attendance using Trainer QR (Simplified) ---
// scannedData is now the PLAIN TEXT Trainer emp_uid
  Future<String> markAttendance(String loggedInStudentUid, String scannedTrainerUid) async {
    final String attendanceScriptUrl = '${_baseUrl}/api/mark_attendance_flutter.php'; // Point to the new PHP script
    final url = Uri.parse(attendanceScriptUrl);
    print('Marking attendance via Trainer QR to: $url');
    print('Data: student_uid=${loggedInStudentUid}, trainer_uid=${scannedTrainerUid}'); // Logging plain UID now

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          'uid': loggedInStudentUid,       // Student's cust_uid
          'emp_uid': scannedTrainerUid, // The scanned PLAIN Trainer emp_uid
          // 'is_encrypted': 'true', // REMOVED - No longer sending hash
          'note': 'Attendance recorded via Flutter App QR scan',
        },
      );
      print('Mark Attendance Response Status: ${response.statusCode}');
      print('Mark Attendance Response Body: ${response.body}');

      Map<String, dynamic>? data;
      String serverMessage = "An unknown server error occurred (${response.statusCode}).";
      try { data = jsonDecode(response.body); if (data?['message'] != null) serverMessage = data!['message']; }
      catch (e) { print("Could not parse JSON response body: ${response.body}"); }

      // Check for SUCCESSFUL status codes (200 OK or 201 Created)
      // Also check the 'status' field in the JSON response from PHP
      if ((response.statusCode == 200 || response.statusCode == 201) && data?['status'] == 'success') {
        return serverMessage; // Return the success message from API
      } else {
        // Throw the specific message parsed from the JSON body or default
        throw Exception(serverMessage);
      }
    }
    on http.ClientException catch (e) { print('Mark Attendance Network Error: $e'); throw Exception('Network error. Please check connection.'); }
    catch (e) { print('Mark Attendance General Error: $e'); throw Exception(e.toString().replaceFirst('Exception: ', '')); }
  }}