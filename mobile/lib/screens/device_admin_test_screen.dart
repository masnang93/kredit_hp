import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/device_admin_service.dart';
import '../services/api_service.dart';

class DeviceAdminTestScreen extends StatefulWidget {
  const DeviceAdminTestScreen({Key? key}) : super(key: key);

  @override
  State<DeviceAdminTestScreen> createState() => _DeviceAdminTestScreenState();
}

class _DeviceAdminTestScreenState extends State<DeviceAdminTestScreen> {
  bool _isDeviceAdminEnabled = false;
  bool _isKioskModeActive = false;
  bool _isLoading = false;
  String _logMessages = '';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _logMessages = '[$timestamp] $message\n$_logMessages';
    });
    debugPrint('[DeviceAdmin] $message');
  }

  Future<void> _checkStatus() async {
    setState(() => _isLoading = true);
    _addLog('Checking device admin status...');

    try {
      final isEnabled = await DeviceAdminService.isDeviceAdminEnabled();
      final isKiosk = await DeviceAdminService.isKioskModeActive();

      setState(() {
        _isDeviceAdminEnabled = isEnabled;
        _isKioskModeActive = isKiosk;
      });

      _addLog('Device Admin: ${isEnabled ? "ENABLED ✓" : "DISABLED ✗"}');
      _addLog('Kiosk Mode: ${isKiosk ? "ACTIVE ✓" : "INACTIVE ✗"}');
    } catch (e) {
      _addLog('Error checking status: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _requestDeviceAdmin() async {
    setState(() => _isLoading = true);
    _addLog('Requesting device admin permission...');

    try {
      final granted = await DeviceAdminService.requestDeviceAdminPermission();

      if (granted) {
        _addLog('✓ Device admin permission GRANTED!');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device Admin Activated!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _addLog('✗ Device admin permission DENIED');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permission Denied'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      await _checkStatus();
    } catch (e) {
      _addLog('ERROR requesting permission: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _lockDevice() async {
    if (!_isDeviceAdminEnabled) {
      _addLog('✗ Cannot lock: Device admin not enabled');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable Device Admin first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    _addLog('Attempting to lock device...');

    try {
      final success = await DeviceAdminService.lockDevice();

      if (success) {
        _addLog('✓ Device lock command sent successfully!');
        _addLog('Screen should lock in 3...2...1...');
      } else {
        _addLog('✗ Failed to lock device');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to lock device'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      _addLog('ERROR locking device: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _enableKioskMode() async {
    if (!_isDeviceAdminEnabled) {
      _addLog('✗ Cannot enable kiosk: Device admin not enabled');
      return;
    }

    setState(() => _isLoading = true);
    _addLog('Enabling kiosk mode...');

    try {
      final success = await DeviceAdminService.enableKioskMode();

      if (success) {
        _addLog('✓ Kiosk mode ENABLED!');
        _addLog('User cannot exit app now');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kiosk Mode Activated! Cannot exit app.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        _addLog('✗ Failed to enable kiosk mode');
      }

      await _checkStatus();
    } catch (e) {
      _addLog('ERROR enabling kiosk: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _disableKioskMode() async {
    setState(() => _isLoading = true);
    _addLog('Disabling kiosk mode...');

    try {
      final success = await DeviceAdminService.disableKioskMode();

      if (success) {
        _addLog('✓ Kiosk mode DISABLED');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kiosk Mode Deactivated'),
              backgroundColor: Colors.blue,
            ),
          );
        }
      }

      await _checkStatus();
    } catch (e) {
      _addLog('ERROR disabling kiosk: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAllData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data?'),
        content: const Text(
          'Ini akan menghapus semua data pelanggan dan kembali ke kondisi awal. '
          'Aplikasi akan restart. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Hapus Semua'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    _addLog('Clearing ALL app data...');

    try {
      // Clear all data from ApiService
      await ApiService.clearAllData();
      _addLog('✓ All customer data cleared');
      _addLog('✓ Device ID reset to default');
      _addLog('App will restart in 2 seconds...');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil dihapus! App akan restart...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Wait 2 seconds then restart
      await Future.delayed(const Duration(seconds: 2));

      // Restart app by popping all routes and rebuilding
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        // Force rebuild by using SystemNavigator
        SystemNavigator.pop(); // This will close the app
      }
    } catch (e) {
      _addLog('ERROR clearing data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Admin Test'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _checkStatus,
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status Cards
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                _buildStatusCard(
                  'Device Admin',
                  _isDeviceAdminEnabled,
                  Icons.security,
                ),
                const SizedBox(height: 8),
                _buildStatusCard(
                  'Kiosk Mode',
                  _isKioskModeActive,
                  Icons.lock_outline,
                ),
              ],
            ),
          ),

          // Control Buttons
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Control Panel',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Request Device Admin
                _buildActionButton(
                  icon: Icons.admin_panel_settings,
                  label: 'Request Device Admin',
                  color: Colors.blue,
                  onPressed: _isDeviceAdminEnabled ? null : _requestDeviceAdmin,
                  subtitle: _isDeviceAdminEnabled
                      ? 'Already enabled'
                      : 'Tap to activate',
                ),

                const Divider(height: 32),

                // Lock Device
                _buildActionButton(
                  icon: Icons.lock,
                  label: 'Lock Device NOW',
                  color: Colors.red,
                  onPressed: _isDeviceAdminEnabled ? _lockDevice : null,
                  subtitle: 'Screen will lock immediately',
                ),

                const SizedBox(height: 12),

                // Enable Kiosk
                _buildActionButton(
                  icon: Icons.fullscreen,
                  label: 'Enable Kiosk Mode',
                  color: Colors.orange,
                  onPressed: (_isDeviceAdminEnabled && !_isKioskModeActive)
                      ? _enableKioskMode
                      : null,
                  subtitle: 'User cannot exit app',
                ),

                const SizedBox(height: 12),

                // Disable Kiosk
                _buildActionButton(
                  icon: Icons.fullscreen_exit,
                  label: 'Disable Kiosk Mode',
                  color: Colors.green,
                  onPressed: _isKioskModeActive ? _disableKioskMode : null,
                  subtitle: 'Allow user to exit app',
                ),

                const Divider(height: 32),

                // Clear All Data
                _buildActionButton(
                  icon: Icons.delete_forever,
                  label: 'Clear All Data',
                  color: Colors.redAccent,
                  onPressed: _clearAllData,
                  subtitle: 'Reset app - remove customer history',
                ),

                const Divider(height: 32),

                const Text(
                  'Activity Log',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Log Container
                Container(
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _logMessages.isEmpty
                          ? 'No activity yet...'
                          : _logMessages,
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
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
                  Text('Processing...'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, bool isActive, IconData icon) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? Colors.green : Colors.grey,
          size: 32,
        ),
        title: Text(title),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isActive ? 'ACTIVE' : 'INACTIVE',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    required String subtitle,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
