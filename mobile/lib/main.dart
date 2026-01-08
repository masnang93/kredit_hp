import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/background_service.dart';
import 'services/loan_service.dart'; // Import LoanService
import 'screens/ekyc_screen.dart';
import 'screens/loan_dashboard.dart';
import 'screens/welcome_screen.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize API & Session BEFORE running app
  await ApiService.init();

  // 2. Start Background Service (Polling for Lock Status)
  BackgroundService.startPolling();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fintech Credit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const LockScreenCheck(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LockScreenCheck extends StatefulWidget {
  const LockScreenCheck({super.key});

  @override
  State<LockScreenCheck> createState() => _LockScreenCheckState();
}

class _LockScreenCheckState extends State<LockScreenCheck> {
  bool _isLocked = false;
  bool _isLoggedIn = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    // Periodic check every 10 seconds (Simulated Push Notification)
    _timer =
        Timer.periodic(const Duration(seconds: 10), (timer) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    // 1. Check Local Session First (Fast - Persistence)
    try {
      bool loggedIn = await ApiService.hasSession();
      if (mounted && loggedIn != _isLoggedIn) {
        setState(() => _isLoggedIn = loggedIn);
        debugPrint("Session restored: $loggedIn");
      }
    } catch (e) {
      debugPrint("Session check failed: $e");
    }

    // 2. Check Device Status (Backend - Network)
    try {
      final status = await ApiService.getDeviceStatus();
      if (mounted) {
        setState(() {
          _isLocked = (status == 'LOCKED');
        });

        if (_isLocked) {
          _enforceLock();
        }
      }
    } catch (e) {
      debugPrint('Error checking status: $e');
    }
  }

  void _enforceLock() {
    // In a real app, we would call startLockTask() here via Platform Channel
    // SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLocked) {
      return const LockOverlay();
    }
    if (_isLoggedIn) {
      return const LoanDashboard();
    }
    return const WelcomeScreen();
  }
}

class LockOverlay extends StatelessWidget {
  const LockOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // WillPopScope is deprecated, using PopScope in newer Flutter
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'PERANGKAT TERKUNCI',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Mohon segera lakukan pembayaran cicilan Anda untuk membuka akses perangkat ini kembali.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  // Navigate to Payment VA instructions
                  // Fetch active loan and open payment
                  try {
                    final loans = await LoanService.getActiveLoans();
                    if (loans.isNotEmpty) {
                      final loan = loans.first;
                      final loanId = loan['id'];
                      final amount = (loan['amount'] as double).toInt();

                      await LoanService.payLoan(loanId, amount);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Tidak ada tagihan yang ditemukan.')),
                        );
                      }
                    }
                  } catch (e) {
                    debugPrint('Error opening payment: $e');
                  }
                },
                child: const Text('LIHAT CARA BAYAR'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Credit App')),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                children: [
                  Text('Limit Tersedia', style: TextStyle(fontSize: 16)),
                  Text('Rp 5.000.000',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EkycScreen()),
                );
              },
              child: const Text("Ajukan Cicilan Baru"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoanDashboard()),
                );
              },
              child: const Text("Buka Dashboard (Mode Test)"),
            ),
          ],
        ),
      ),
    );
  }
}
