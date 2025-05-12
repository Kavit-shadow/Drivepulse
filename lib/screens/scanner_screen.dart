  // lib/screens/scanner_screen.dart (Handles Login & Attendance - FINAL CORRECTED AGAIN)
  import 'package:flutter/material.dart';
  import 'package:mobile_scanner/mobile_scanner.dart';
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';
  import '../api/api_service.dart'; // Adjust path if needed
  // Import model if needed for profile fetch during login
  import '../models/profile.dart'; // Adjust path if needed

  class ScannerScreen extends StatefulWidget {
    const ScannerScreen({super.key});

    @override
    State<ScannerScreen> createState() => _ScannerScreenState();
  }

  class _ScannerScreenState extends State<ScannerScreen> {
    final ApiService _apiService = ApiService();
    final _storage = const FlutterSecureStorage();
    MobileScannerController cameraController = MobileScannerController();
    bool _isProcessing = false;
    String? _loggedInUid;
    bool _isLoginScan = false; // Flag to check if scanning for login

    @override
    void initState() {
      super.initState();
      // Get logged-in user state, but wait for arguments before deciding behavior
      _getLoggedInUid();

      // Check arguments after the first frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Check if arguments exist and are of the expected type
        final Object? argsObject = ModalRoute.of(context)?.settings.arguments;
        final Map<String, dynamic>? args = argsObject is Map<String, dynamic> ? argsObject : null;

        if (args != null && args['isLoginScan'] == true) {
          if (!_isLoginScan) { // Update only if state changes
            setState(() { _isLoginScan = true; });
            print("Scanner screen initialized for LOGIN scan.");
          }
        } else {
          if (_isLoginScan) { // Update only if state changes
            setState(() { _isLoginScan = false; });
          }
          print("Scanner screen initialized for ATTENDANCE scan.");
          // Verify login only if required for attendance
          // Moved check into _foundBarcode for attendance mode
        }
      });
    }


    Future<void> _getLoggedInUid() async {
      try {
        _loggedInUid = await _storage.read(key: 'cust_uid');
        print("Retrieved loggedInUid: $_loggedInUid");
      } catch (e) {
        print("Error reading secure storage: $e");
        _loggedInUid = null; // Ensure it's null on error
      }
    }

    void _foundBarcode(BarcodeCapture capture) {
      print("Barcode detected. Processing: $_isProcessing, IsLogin: $_isLoginScan, LoggedInUID: $_loggedInUid");
      // Check if processing OR if it's an attendance scan AND user isn't logged in
      if (_isProcessing || (!_isLoginScan && _loggedInUid == null)) {
        print("Scan ignored due to state.");
        // Show error only if trying attendance scan when logged out
        if (!_isLoginScan && _loggedInUid == null && mounted) {
          _showResultDialog('Error', 'You must be logged in to mark attendance.', true, restartCamera: false, popOnClose: true);
        }
        return;
      }

      final List<Barcode> barcodes = capture.barcodes;
      if (barcodes.isNotEmpty) {
        final String? scannedData = barcodes.first.rawValue;

        if (scannedData != null && scannedData.isNotEmpty) {
          print('QR Scanned Raw Data: $scannedData');
          setState(() { _isProcessing = true; });
          try { cameraController.stop(); print("Camera stopped for processing."); }
          catch (e) { print("Error stopping camera: $e"); }

          // *** THIS IS THE CORRECTED LOGIC ***
          if (_isLoginScan) {
            _processLoginScan(scannedData); // Call login function
          } else {
            _markAttendance(scannedData); // Call attendance function
          }
          // *** END CORRECTION ***

        } else { print("Scanned data is null or empty."); setState(() { _isProcessing = false; }); }
      } else { print("No barcodes found in capture."); setState(() { _isProcessing = false; }); }
    }

    // --- Function to Handle QR Login Scan ---
    Future<void> _processLoginScan(String scannedData) async {
      // Assume scannedData directly contains the cust_uid
      final String custUid = scannedData.trim();
      print("Processing LOGIN scan for UID: $custUid");

      bool isDialogShowing = true;
      showDialog( context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator()) ).then((_) => isDialogShowing = false);

      try {
        if (custUid.isEmpty) throw Exception('Invalid QR code: UID is empty.');

        // --- Fetch Profile to get Name (Recommended) ---
        String name = "User"; // Default name
        try {
          print('Fetching profile for name...');
          final profile = await _apiService.getProfile(custUid); // Call API
          name = profile.name ?? "User";
          print('Profile fetched successfully during login. Name: $name');
        } catch (e) {
          print("Warning: Failed to fetch profile details during QR login: $e");
          name = "User ($custUid)";
          if (mounted && isDialogShowing) { Navigator.of(context).pop(); isDialogShowing = false; }
          _showResultDialog('Warning', 'Logged in, but failed to fetch profile name.', false, restartCamera: false);
          await Future.delayed(const Duration(seconds: 2));
        }

        // Store credentials securely
        print("Storing credentials: UID=$custUid, Name=$name");
        await _storage.write(key: 'cust_uid', value: custUid);
        await _storage.write(key: 'user_name', value: name);

        if(mounted && isDialogShowing) { Navigator.of(context).pop(); isDialogShowing = false;}

        if (mounted) {
          print("Login successful via QR, navigating home.");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if(mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          });
        }

      } catch (e) {
        if(mounted && isDialogShowing) { Navigator.of(context).pop(); isDialogShowing = false; }
        _showResultDialog('Login Failed', e.toString().replaceFirst('Exception: ', ''), true, restartCamera: true);
        if (mounted) setState(() { _isProcessing = false; });
      }
    }


    // --- Mark Attendance (Requires user to be logged in, scans Trainer QR URL) ---
    // --- Mark Attendance (Simplified - takes PLAIN trainer UID) ---
    // Input is now the PLAIN TEXT Trainer EMP_UID scanned from the QR code
    Future<void> _markAttendance(String scannedTrainerUid) async {
      print("Processing ATTENDANCE scan for Trainer UID: $scannedTrainerUid by Student: $_loggedInUid");
      if (_loggedInUid == null) {
        _showResultDialog('Error', 'Cannot mark attendance. User not logged in.', true, restartCamera: false, popOnClose: true);
        setState(() { _isProcessing = false; });
        return;
      }

      // --- NO URL PARSING NEEDED ---
      String trainerEmpUid = scannedTrainerUid.trim(); // Use the scanned data directly
      if (trainerEmpUid.isEmpty) {
        _showResultDialog('Scan Error', 'Invalid Trainer QR code format (empty).', true, restartCamera: true);
        setState(() { _isProcessing = false; });
        return;
      }
      print("Using Trainer EMP_UID: $trainerEmpUid");
      // --- End NO URL PARSING NEEDED ---


      bool isDialogShowing = true;
      // Ensure context is valid before showing dialog
      if (!mounted) return;
      showDialog( context: context, barrierDismissible: false, builder: (context) => const Center(child: CircularProgressIndicator())).then((_) => isDialogShowing = false);

      try {
        // Call API Service using student UID and the scanned plain Trainer UID
        // Ensure ApiService method name is 'markAttendance' and it calls the correct PHP script
        String resultMessage = await _apiService.markAttendance(_loggedInUid!, trainerEmpUid); // Pass plain UID

        if (mounted && isDialogShowing) Navigator.of(context).pop(); // Close loading dialog
        if (mounted) _showResultDialog('Success', resultMessage, false, restartCamera: true); // Show success

      } catch (e) {
        if (mounted && isDialogShowing) Navigator.of(context).pop(); // Close loading dialog
        if (mounted) _showResultDialog('Error', e.toString().replaceFirst('Exception: ', ''), true, restartCamera: true); // Show error
      }
      // Note: _isProcessing reset happens in the dialog's OK button logic in _showResultDialog
    }

    // --- Show Result Dialog ---
    void _showResultDialog(String title, String message, bool isError, {bool restartCamera = true, bool popOnClose = false}) {
      if (!mounted) return;
      print("Showing result dialog: Title=$title, IsError=$isError, Restart=$restartCamera, Pop=$popOnClose");

      try { cameraController.stop(); print("Camera stopped before showing dialog."); }
      catch (e) { print("Error stopping camera: $e"); }

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(/* ... */
            children: [
              Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: isError ? Colors.red : Colors.green),
              const SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog first
                if (mounted) {
                  setState(() { _isProcessing = false; });
                  print("Processing flag reset.");
                  if (popOnClose) {
                    Navigator.of(context).pop(); // Pop the scanner screen
                  } else if (restartCamera) {
                    try {
                      print("Attempting to restart camera...");
                      cameraController.start();
                      print("Camera restart initiated.");
                    } catch (e) {
                      print("Error restarting camera: $e");
                      if(mounted) _showResultDialog("Camera Error", "Failed to restart camera.", true, restartCamera: false);
                    }
                  }
                }
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
    }

    @override
    void dispose() {
      print("Disposing ScannerScreen and CameraController.");
      cameraController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      final mediaSize = MediaQuery.of(context).size;
      print("Building ScannerScreen. IsLoginScan: $_isLoginScan");

      return Scaffold(
        appBar: AppBar(
          title: Row( /* ... Title with logo ... */
            children: [
              Image.asset('assets/images/logo.png', height: 30),
              const SizedBox(width: 10),
              Text(_isLoginScan ? 'Scan Login QR' : 'Scan Attendance QR'),
            ],
          ),
          actions: const [],
        ),
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: [
            MobileScanner(
              controller: cameraController,
              onDetect: _foundBarcode,
              errorBuilder: (context, error, child) { /* ... */
                print("MobileScanner Error Builder: $error");
                return Center(child: Text('Camera Error...', style: TextStyle(color: Colors.red)));
              },
              fit: BoxFit.cover,
            ),
            // Viewfinder overlay
            Container( /* ... Viewfinder ... */
              width: mediaSize.width * 0.7,
              height: mediaSize.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: _isProcessing ? Colors.grey.shade600 : Colors.greenAccent, width: _isProcessing ? 2 : 4),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            // Instruction Text
            Positioned( /* ... Instruction ... */
              bottom: 50,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.8), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  _isLoginScan ? 'Scan Login QR from Admin Panel' : 'Align Trainer QR code in frame',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            // Loading indicator overlay
            if (_isProcessing)
              Positioned.fill( /* ... Loading Indicator ... */
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
        // No Floating Action Button
      );
    }
  }