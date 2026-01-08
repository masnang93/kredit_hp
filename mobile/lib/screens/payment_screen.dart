import 'package:flutter/material.dart';
import '../services/loan_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _amountController = TextEditingController();

  Future<void> _scanQR() async {
    // Simulate scanning by picking image (since we are on emulator) or just delay
    // For now, let's just show a simulation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan QRIS'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue),
            SizedBox(height: 16),
            Text('Mendeteksi kode QR...'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _processPayment(50000); // Simulate finding 50k invoice
            },
            child: const Text('Simulasi Scan Berhasil'),
          ),
        ],
      ),
    );
  }

  void _processPayment(double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Konfirmasi Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Merchant'),
                Text('Toko Kelontong Budi',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Nominal'),
                Text('Rp ${amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.blue)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context); // Close bottom sheet

                  // Show loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Memproses Pembayaran...')),
                  );

                  // Call Backend
                  final success = await LoanService.createLoan(
                      amount: amount, merchantName: 'Toko Kelontong Budi');

                  if (!mounted) return;

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pembayaran Berhasil!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pembayaran Gagal / Saldo Tidak Cukup'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                ),
                child: const Text('BAYAR SEKARANG'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Menu Pembayaran',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scan QRIS Card
            GestureDetector(
              onTap: _scanQR,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade800, Colors.blue.shade500],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5)),
                  ],
                ),
                child: const Column(
                  children: [
                    Icon(Icons.qr_code_scanner, size: 64, color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Scan QRIS',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bayar di jutaan merchant QRIS',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Metode Pembayaran Lain',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildPaymentMethod(Icons.account_balance,
                'Transfer Virtual Account', 'BCA, Mandiri, BRI, BNI'),
            _buildPaymentMethod(
                Icons.store, 'Gerai Retail', 'Indomaret, Alfamart'),
            _buildPaymentMethod(Icons.wallet, 'E-Wallet', 'Gopay, OVO, Dana'),

            const SizedBox(height: 32),
            const Text(
              'Bayar Cicilan Manual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  labelText: 'Masukkan Jumlah Bayar',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.money),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (_amountController.text.isNotEmpty) {
                        _processPayment(double.parse(_amountController.text));
                      }
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Show Coming Soon
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur ini akan segera hadir')),
          );
        },
      ),
    );
  }
}
