import 'package:flutter/material.dart';
import '../services/loan_service.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'payment_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart'; // Import Geolocator
import '../services/api_service.dart';
import '../services/data_sync_service.dart';
import 'catalog_screen.dart';

class LoanDashboard extends StatefulWidget {
  const LoanDashboard({super.key});

  @override
  State<LoanDashboard> createState() => _LoanDashboardState();
}

class _LoanDashboardState extends State<LoanDashboard> {
  Map<String, dynamic>? creditData;
  List<Map<String, dynamic>> activeLoans = [];
  bool isLoading = true;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startLocationTracking();
    DataSyncService.syncAll();
  }

  Future<void> _startLocationTracking() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        // Get current location
        Position position = await Geolocator.getCurrentPosition();
        debugPrint('Location: ${position.latitude}, ${position.longitude}');

        // Send to Backend
        await ApiService.updateLocation(position.latitude, position.longitude);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _loadData() async {
    final limit = await LoanService.getCreditLimit();
    final loans = await LoanService.getActiveLoans();

    if (mounted) {
      setState(() {
        creditData = limit;
        activeLoans = loans;
        isLoading = false;
      });
    }
  }

  String formatCurrency(dynamic amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Fintech Credit',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedIndex == 0
              ? RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCreditCard(),
                          const SizedBox(height: 24),
                          _buildActionButtons(),
                          const SizedBox(height: 24),
                          const Text(
                            'Tagihan Aktif',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                          const SizedBox(height: 12),
                          _buildLoanList(),
                        ],
                      ),
                    ),
                  ),
                )
              : _selectedIndex == 1
                  ? const HistoryScreen()
                  : _selectedIndex == 2
                      ? const PaymentScreen()
                      : const ProfileScreen(),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.blue.shade800,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Bayar'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
      ),
    );
  }

  Widget _buildCreditCard() {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Limit Tersedia',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              Icon(Icons.credit_card,
                  color: Colors.white.withValues(alpha: 0.5)),
            ],
          ),
          Text(
            creditData != null
                ? formatCurrency(creditData!['availableLimit'])
                : 'Rp -',
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Limit',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    creditData != null
                        ? formatCurrency(creditData!['totalLimit'])
                        : '-',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Gold Member',
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMenuButton(Icons.phone_android, 'Katalog\nHP', Colors.green,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CatalogScreen()),
              );
            }),
            _buildMenuButton(Icons.qr_code_scanner, 'Bayar\nQRIS', Colors.blue,
                () {
              setState(() {
                _selectedIndex = 2; // Switch to Payment Tab
              });
            }),
            _buildMenuButton(
                Icons.account_balance_wallet, 'Topup\nSaldo', Colors.orange,
                () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur Topup segera hadir')));
            }),
            _buildMenuButton(Icons.send, 'Kirim\nUang', Colors.purple, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Fitur Kirim Uang segera hadir')));
            }),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMenuButton(
                Icons.water_drop, 'Tagihan\nAir', Colors.cyan, () {}),
            _buildMenuButton(Icons.electric_bolt, 'Token\nListrik',
                Colors.yellow.shade800, () {}),
            _buildMenuButton(
                Icons.wifi, 'Internet\n& TV', Colors.indigo, () {}),
            _buildMenuButton(Icons.more_horiz, 'Lainnya', Colors.grey, () {}),
          ],
        )
      ],
    );
  }

  Widget _buildMenuButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanList() {
    if (activeLoans.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: const Text('Tidak ada tagihan aktif.'),
      );
    }

    return Column(
      children: activeLoans.map((loan) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.receipt_long, color: Colors.red.shade400),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loan['title'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Jatuh Tempo: ${loan['dueDate']}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(formatCurrency(loan['amount']),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      // Call Payment API
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Membuka halaman pembayaran...')),
                      );

                      final urlStr =
                          await LoanService.payLoan(loan['id'], loan['amount']);

                      if (urlStr != null) {
                        final Uri url = Uri.parse(urlStr);
                        if (!await launchUrl(url,
                            mode: LaunchMode.externalApplication)) {
                          throw Exception('Could not launch $url');
                        }
                      }
                    },
                    child: Text(
                      'BAYAR',
                      style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
