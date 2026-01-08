import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'device_admin_service.dart';

class BackgroundService {
  static Timer? _timer;
  static bool _isLocked = false;

  /// Start polling the backend for device status
  static void startPolling() {
    if (_timer != null && _timer!.isActive) return;

    debugPrint('[BackgroundService] Starting poll service...');

    // Poll every 1 minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      await _checkStatus();
    });

    // Check immediately on start
    _checkStatus();
  }

  static void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _checkStatus() async {
    try {
      final status = await ApiService.getDeviceStatus();
      debugPrint('[BackgroundService] Device Status: $status');

      if (status == 'LOCKED') {
        _isLocked = true;
        // Trigger lock
        await DeviceAdminService.lockDevice();

        // Ensure Kiosk is active if locked
        final isKiosk = await DeviceAdminService.isKioskModeActive();
        if (!isKiosk) {
          await DeviceAdminService.enableKioskMode();
        }
      } else if (status == 'UNLOCKED' && _isLocked) {
        _isLocked = false;
        // Optional: Notify user or disable kiosk if it was enabled forcedly
        // await DeviceAdminService.disableKioskMode();
      }
    } catch (e) {
      debugPrint('[BackgroundService] Error checking status: $e');
    }
  }
}
