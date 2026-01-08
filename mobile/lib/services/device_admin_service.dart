import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Service to handle device admin operations for locking the device
class DeviceAdminService {
  static const MethodChannel _channel = MethodChannel('device_admin');

  /// Request device admin permissions from the user
  /// Returns true if already enabled or user grants permission
  static Future<bool> requestDeviceAdminPermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestDeviceAdmin');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error requesting device admin: ${e.message}');
      return false;
    }
  }

  /// Check if device admin is currently enabled
  static Future<bool> isDeviceAdminEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('isDeviceAdminEnabled');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error checking device admin status: ${e.message}');
      return false;
    }
  }

  /// Lock the device screen immediately
  /// Requires device admin to be enabled first
  static Future<bool> lockDevice() async {
    try {
      final bool result = await _channel.invokeMethod('lockDevice');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error locking device: ${e.message}');
      return false;
    }
  }

  /// Enable kiosk mode (lock task mode) - prevents user from leaving the app
  /// Requires device admin to be enabled first
  static Future<bool> enableKioskMode() async {
    try {
      final bool result = await _channel.invokeMethod('enableKioskMode');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error enabling kiosk mode: ${e.message}');
      return false;
    }
  }

  /// Disable kiosk mode (lock task mode)
  static Future<bool> disableKioskMode() async {
    try {
      final bool result = await _channel.invokeMethod('disableKioskMode');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error disabling kiosk mode: ${e.message}');
      return false;
    }
  }

  /// Check if kiosk mode is currently active
  static Future<bool> isKioskModeActive() async {
    try {
      final bool result = await _channel.invokeMethod('isKioskModeActive');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error checking kiosk mode: ${e.message}');
      return false;
    }
  }

  /// Remove device admin - should only be called when uninstalling or testing
  static Future<bool> removeDeviceAdmin() async {
    try {
      final bool result = await _channel.invokeMethod('removeDeviceAdmin');
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error removing device admin: ${e.message}');
      return false;
    }
  }
}
