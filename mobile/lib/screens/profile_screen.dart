import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'welcome_screen.dart'; // For Logout navigation

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  Map<String, dynamic> _profile = {};

  final _nameController = TextEditingController();
  final _nikController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final data = await ApiService.getProfile();
    if (data != null) {
      setState(() {
        _profile = data;
        _nameController.text = data['ownerName'] ?? '';
        _nikController.text = data['nik'] ?? '';
        _phoneController.text = data['phoneNumber'] ?? '';
        _addressController.text = data['address'] ?? '';
        _emergencyController.text = data['emergencyContact'] ?? '';
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final error = await ApiService.updateProfile(
      name: _nameController.text,
      nik: _nikController.text,
      phone: _phoneController.text,
      address: _addressController.text,
      emergencyContact: _emergencyController.text,
    );

    setState(() {
      _isLoading = false;
      if (error == null) {
        _isEditing = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil disimpan')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $error'), backgroundColor: Colors.red),
        );
      }
    });
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Akun Saya', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon:
                Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.blue),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  // Cancel edit, reload original data
                  _nameController.text = _profile['ownerName'] ?? '';
                  _nikController.text = _profile['nik'] ?? '';
                  _phoneController.text = _profile['phoneNumber'] ?? '';
                  _addressController.text = _profile['address'] ?? '';
                  _emergencyController.text =
                      _profile['emergencyContact'] ?? '';
                }
                _isEditing = !_isEditing;
              });
            },
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Avatar Section
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(Icons.person,
                            size: 40, color: Colors.blue),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text
                            : 'Pelanggan',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Device ID: ${ApiService.deviceId}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields
                _buildSectionHeader('Informasi Pribadi'),
                _buildTextField('Nama Lengkap', _nameController, Icons.person),
                _buildTextField('NIK', _nikController, Icons.credit_card,
                    isNumber: true),
                _buildTextField('Nomor HP', _phoneController, Icons.phone,
                    isNumber: true),
                const SizedBox(height: 16),

                _buildSectionHeader('Detail Alamat'),
                _buildTextField(
                    'Alamat Lengkap', _addressController, Icons.location_on,
                    maxLines: 3),
                const SizedBox(height: 16),

                _buildSectionHeader('Kontak Darurat'),
                _buildTextField('Nama/Nomor Darurat', _emergencyController,
                    Icons.contact_phone),

                const SizedBox(height: 24),

                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('SIMPAN PERUBAHAN',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),

                const SizedBox(height: 24),
                _buildMenuItem(Icons.logout, 'Keluar', _logout,
                    isDestructive: true),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
            color: Colors.grey[700], fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isNumber = false, int maxLines = 1}) {
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
      child: TextField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blue.shade300),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading:
            Icon(icon, color: isDestructive ? Colors.red : Colors.grey[700]),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
