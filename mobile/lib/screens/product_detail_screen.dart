import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/loan_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int? selectedTenor;
  List<int> tenors = [];
  double monthlyInstallment = 0;

  @override
  void initState() {
    super.initState();
    // Parse Tenors
    try {
      if (widget.product['tenorOptions'] != null) {
        tenors = List<int>.from(widget.product['tenorOptions']);
      }
    } catch (e) {
      tenors = [3, 6, 12]; // Fallback
    }
  }

  void _calculateInstallment() {
    if (selectedTenor == null) return;
    double price = double.tryParse(widget.product['price'].toString()) ?? 0;
    // Simple logic: 2.5% interest per month
    double totalInterest = price * 0.025 * selectedTenor!;
    double total = price + totalInterest;
    setState(() {
      monthlyInstallment = total / selectedTenor!;
    });
  }

  String formatCurrency(dynamic amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }

  Future<void> _submitApplication() async {
    if (selectedTenor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tenor cicilan dulu')));
      return;
    }

    // Call API to create Loan
    bool success = await LoanService.createLoan(
      amount: double.tryParse(widget.product['price'].toString()) ?? 0,
      merchantName: 'Cicilan ${widget.product['name']}',
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pengajuan Berhasil Diproses!')));
        Navigator.pop(context); // Back to Catalog
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal mengajukan cicilan')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.product['name'] ?? 'Detail Produk')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: widget.product['imageUrl'] != null
                  ? Image.network(widget.product['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) =>
                          const Icon(Icons.phone_android, size: 100))
                  : const Icon(Icons.phone_android, size: 100),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product['name'] ?? 'Unknown',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(formatCurrency(widget.product['price']),
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue.shade800,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Deskripsi:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.product['description'] ?? 'Tidak ada deskripsi'),
                  const SizedBox(height: 24),
                  const Text('Pilih Tenor Cicilan:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: tenors.map((t) {
                      return ChoiceChip(
                        label: Text('$t Bulan'),
                        selected: selectedTenor == t,
                        onSelected: (selected) {
                          setState(() {
                            selectedTenor = selected ? t : null;
                            _calculateInstallment();
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (selectedTenor != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Cicilan per bulan:'),
                          Text(formatCurrency(monthlyInstallment),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitApplication,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          foregroundColor: Colors.white),
                      child: const Text('AJUKAN CICILAN SEKARANG'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
