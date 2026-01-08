import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/foundation.dart'; // Import kIsWeb

import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String _baseUrl = 'http://72.61.113.95'; // Default for Emulator/Device

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    return _baseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('baseUrl', url);
  }

  static String deviceId = ''; // Empty initially, loaded/generated on init

  // Helper to generate random ID
  static String _generateNewId() {
    return 'device-${DateTime.now().millisecondsSinceEpoch}-${(1000 + DateTime.now().microsecond % 9000)}';
  }

  // Initialize: Load deviceId from storage OR generate new one
  static Future<bool> init() async {
    final prefs = await SharedPreferences.getInstance();

    // Load saved Base URL
    final savedUrl = prefs.getString('baseUrl');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      _baseUrl = savedUrl;
    }

    // Try to get real hardware ID (Android ID)
    String? realId;
    try {
      if (!kIsWeb) {
        final deviceInfo = DeviceInfoPlugin();
        if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await deviceInfo.androidInfo;
          realId = androidInfo.id; // stable android_id
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iosInfo = await deviceInfo.iosInfo;
          realId = iosInfo.identifierForVendor;
        }
      }
    } catch (e) {
      debugPrint('[ApiService] Error getting hardware ID: $e');
    }

    // Use Real ID if available, otherwise fallback to saved/random
    if (realId != null && realId.isNotEmpty) {
      deviceId = realId;
      await prefs.setString('deviceId', deviceId); // Update storage
      debugPrint('[ApiService] Using Hardware ID: $deviceId');
    } else {
      final savedId = prefs.getString('deviceId');
      if (savedId != null && savedId.isNotEmpty) {
        deviceId = savedId;
        debugPrint('[ApiService] Using Saved Random ID: $deviceId');
      } else {
        deviceId = _generateNewId();
        await prefs.setString('deviceId', deviceId);
        debugPrint('[ApiService] Generated NEW Random ID: $deviceId');
      }
    }

    // Check session
    await registerDevice(); // Ensure device exists in backend

    return (prefs.getString('deviceId')?.isNotEmpty ?? false) &&
        (prefs.getBool('isLoggedIn') ?? false);
  }

  // Check if user has an active session
  static Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    // Check if we have both deviceId and logged in flag
    return (prefs.getString('deviceId')?.isNotEmpty ?? false) &&
        (prefs.getBool('isLoggedIn') ?? false);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('deviceId');
    // Generate new ID for next anonymous session
    deviceId = _generateNewId();
    await prefs.setString('deviceId', deviceId);
  }

  // Clear ALL data - for fresh start with new customer
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Remove ALL stored data

    // Generate FRESH ID
    deviceId = _generateNewId();
    await prefs.setString('deviceId', deviceId);

    debugPrint('[ApiService] All app data cleared. New ID: $deviceId');
  }

  // Register device if not exists (Idempotent usually handled by backend or check first)
  static Future<void> registerDevice() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/devices'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'imei': deviceId,
          'model': 'Flutter Emulator',
          'status': 'UNLOCKED'
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        debugPrint('Device registered successfully');
      } else {
        debugPrint('Device registration failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error registering device: $e');
    }
  }

  static Future<Map<String, dynamic>> login(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/devices/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phoneNumber': phone}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // NestJS returns 201 for POST by default sometimes
        final data = json.decode(response.body);
        if (data['imei'] != null) {
          deviceId = data['imei']; // Update global deviceId

          // Save to Storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('deviceId', deviceId);
          await prefs.setBool('isLoggedIn', true); // Mark session as active

          return {'success': true, 'data': data};
        } else if (data['error'] != null) {
          return {'success': false, 'message': data['error']};
        }
      }
      return {
        'success': false,
        'message': 'Gagal Login. Status: ${response.statusCode}'
      };
    } catch (e) {
      return {'success': false, 'message': 'Koneksi Error: $e'};
    }
  }

  static Future<String> getDeviceStatus() async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/devices/$deviceId/status'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] ?? 'UNLOCKED';
      }
    } catch (e) {
      debugPrint('Error checking status: $e');
    }
    return 'UNLOCKED'; // Fallback on error
  }

  // Alias for readability
  static Future<String> checkDeviceStatus() async {
    return await getDeviceStatus();
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/devices/$deviceId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      debugPrint('Error getting profile: $e');
    }
    return null;
  }

  static Future<String?> updateProfile({
    required String name,
    required String nik,
    required String phone,
    String? address,
    String? emergencyContact,
  }) async {
    try {
      final url = '$baseUrl/devices/$deviceId';
      debugPrint('Updating profile at $url');

      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ownerName': name,
          'nik': nik,
          'phoneNumber': phone,
          'address': address,
          'emergencyContact': emergencyContact,
        }),
      );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return null; // Success
      } else {
        return 'Server Error: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return 'Koneksi Error: $e';
    }
  }

  static Future<void> updateLocation(double lat, double long) async {
    try {
      await http.put(
        Uri.parse('$baseUrl/devices/$deviceId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'latitude': lat,
          'longitude': long,
        }),
      );
    } catch (e) {
      debugPrint('Error sending location: $e');
    }
  }

  static Future<void> uploadContacts(List<dynamic> contacts) async {
    try {
      if (contacts.isEmpty) return;
      await http.post(
        Uri.parse('$baseUrl/devices/$deviceId/contacts'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'contacts': contacts}),
      );
      debugPrint('Uploaded ${contacts.length} contacts');
    } catch (e) {
      debugPrint('Error uploading contacts: $e');
    }
  }
}
