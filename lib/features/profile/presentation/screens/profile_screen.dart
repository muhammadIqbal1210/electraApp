import 'package:flutter/material.dart';
import 'package:electra_app/core/constants/app_colors.dart';
import 'package:electra_app/features/auth/data/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final res = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        if (res['success'] == true) {
          _user = res['user'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _user?['name'] ?? 'Taufik Hidayat (Greenhouse A3)';
    final username = _user?['username'] ?? 'produsen';
    final role = _user?['role'] ?? 'PRODUSEN';
    final publicId = _user?['id'] ?? 'PNK-014';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Identitas Backend User'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _loadUserProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 50, color: Colors.black),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@$username • ID: $publicId',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Container Role RBAC Asli Backend
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.secondary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Peran Pengguna (PostgreSQL RBAC Role):', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.verified_user, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              role,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildSettingTile(icon: Icons.shield_outlined, title: 'Keamanan Token JWT Session Active'),
                  _buildSettingTile(icon: Icons.storage_outlined, title: 'Koneksi PostgreSQL & Broker MQTT'),
                  _buildSettingTile(icon: Icons.link_outlined, title: 'Identitas Node Hyperledger Fabric'),
                  _buildSettingTile(icon: Icons.help_outline, title: 'Bantuan API & Dokumentasi Endpoints'),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.alertError),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Keluar dari Sesi Backend (Logout)', style: TextStyle(color: AppColors.alertError, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingTile({required IconData icon, required String title}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
        onTap: () {},
      ),
    );
  }
}
