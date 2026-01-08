import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/data_sync_service.dart';
import 'package:http/http.dart' as http;

class DebugConnectionScreen extends StatefulWidget {
  const DebugConnectionScreen({Key? key}) : super(key: key);

  @override
  State<DebugConnectionScreen> createState() => _DebugConnectionScreenState();
}

class _DebugConnectionScreenState extends State<DebugConnectionScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _log = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _urlController.text = ApiService.baseUrl;
  }

  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _log = '[$timestamp] $message\n$_log';
    });
    debugPrint('[DEBUG] $message');
  }

  Future<void> _updateBaseUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    await ApiService.setBaseUrl(url);
    _addLog('Base URL updated to: $url');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Base URL Updated')),
    );
  }

  Future<void> _testContactSync() async {
    setState(() {
      _isLoading = true;
      _log = '';
    });
    _addLog('=== TESTING CONTACT SYNC ===');

    try {
      final result = await DataSyncService.syncContacts();
      _addLog(result);
    } catch (e) {
      _addLog('✗ Sync failed: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testBackendConnection() async {
    setState(() {
      _isLoading = true;
      _log = '';
    });

    _addLog('=== TESTING BACKEND CONNECTION ===');
    _addLog('Base URL: ${ApiService.baseUrl}');

    try {
      // Test 1: Root endpoint
      _addLog('Test 1: Checking root endpoint /');
      final response1 = await http.get(Uri.parse('${ApiService.baseUrl}/'));
      _addLog('Response: ${response1.statusCode}');
      if (response1.statusCode == 200) {
        _addLog('✓ Backend is reachable!');
      } else {
        _addLog('✗ Unexpected status code');
      }
    } catch (e) {
      _addLog('✗ ERROR: Cannot reach backend!');
      _addLog('Error: $e');
      _addLog('');
      _addLog('SOLUTION:');
      _addLog('1. Check if backend is running');
      _addLog('2. Ensure IP is correct in Base URL above');
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Test 2: Register device
      _addLog('');
      _addLog('Test 2: Registering device');
      await ApiService.registerDevice();
      _addLog('✓ Device registration successful');
    } catch (e) {
      _addLog('✗ Device registration failed: $e');
    }

    try {
      // Test 3: Check device status
      _addLog('');
      _addLog('Test 3: Check device status');
      final status = await ApiService.getDeviceStatus();
      _addLog('Device status: $status');
      _addLog('✓ Status check successful');
    } catch (e) {
      _addLog('✗ Status check failed: $e');
    }

    try {
      // Test 4: Update profile (test endpoint)
      _addLog('');
      _addLog('Test 4: Testing update profile endpoint');
      final error = await ApiService.updateProfile(
        name: 'Test User',
        nik: '1234567890123456',
        phone: '081234567890',
      );

      if (error == null) {
        _addLog('✓ Profile update successful!');
        _addLog('');
        _addLog('=== ALL TESTS PASSED ===');
        _addLog('Backend connection is WORKING!');
      } else {
        _addLog('✗ Profile update failed: $error');
      }
    } catch (e) {
      _addLog('✗ Profile update error: $e');
    }

    setState(() => _isLoading = false);
  }

  Future<void> _testFormSubmission() async {
    setState(() {
      _isLoading = true;
      _log = '';
    });

    _addLog('=== TESTING FORM SUBMISSION ===');

    try {
      _addLog('Simulating form submission...');
      _addLog('NIK: 1234567890123456');
      _addLog('Phone: 081234567890');
      _addLog('Name: Test User');
      _addLog('');

      final error = await ApiService.updateProfile(
        name: 'Test User',
        nik: '1234567890123456',
        phone: '081234567890',
        address: 'Test Address',
        emergencyContact: '081234567891',
      );

      if (error == null) {
        _addLog('✓ Form submission SUCCESSFUL!');
        _addLog('');
        _addLog('The form CAN be submitted.');
        _addLog('Issue might be in EKYC screen.');
      } else {
        _addLog('✗ Form submission FAILED');
        _addLog('Error: $error');
      }
    } catch (e) {
      _addLog('✗ Exception during submission: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Connection'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Base URL Configuration
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'API Base URL',
                      hintText: 'http://192.168.x.x:3000',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _updateBaseUrl,
                  child: const Text('Update'),
                ),
              ],
            ),
          ),

          // Test Buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.orange[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testBackendConnection,
                  icon: const Icon(Icons.cloud),
                  label: const Text('Test Backend Connection'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testFormSubmission,
                        icon: const Icon(Icons.send),
                        label: const Text('Test Form'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _testContactSync,
                        icon: const Icon(Icons.contacts),
                        label: const Text('Sync Contacts'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Info Card
          Card(
            margin: const EdgeInsets.all(16),
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      const Text(
                        'Troubleshooting Steps:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Update Base URL to your PC IP'),
                  const Text('2. Test backend connection first'),
                  const Text('3. Test Contact Sync'),
                  const Text('4. Check logs below for errors'),
                ],
              ),
            ),
          ),

          // Log Container
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _log.isEmpty ? 'Press a test button to start...' : _log,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.amber[100],
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Testing...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
