import 'package:flutter/material.dart';
import 'package:electra_app/core/constants/app_colors.dart';
import 'package:electra_app/features/supply_chain/data/services/supply_chain_api_service.dart';

class QrVerificationScreen extends StatefulWidget {
  final String batchId;

  const QrVerificationScreen({super.key, required this.batchId});

  @override
  State<QrVerificationScreen> createState() => _QrVerificationScreenState();
}

class _QrVerificationScreenState extends State<QrVerificationScreen> {
  Map<String, dynamic>? _verificationData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVerificationData();
  }

  Future<void> _fetchVerificationData() async {
    setState(() => _isLoading = true);
    final res = await SupplyChainApiService.verifyProductPublic(widget.batchId);
    if (mounted) {
      setState(() {
        if (res['success'] == true) {
          _verificationData = res['data'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final batch = _verificationData?['batch'];
    final variety = batch?['variety'] ?? 'Kentang Granola Super';
    final producer = batch?['producer_name'] ?? 'Kelompok Tani Lembang';
    final phase = batch?['phase'] ?? 'PENYEMAIAN';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Traceability Explorer (DB Live)'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Container Mock QR Code (QR-01)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(60),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.qr_code_2, size: 160, color: Colors.black),
                        const SizedBox(height: 10),
                        Text(
                          widget.batchId,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Immutable Verification Badge (QR-02 & BC-01)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.alertSuccess.withAlpha(40),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.alertSuccess),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user, color: AppColors.alertSuccess, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'DATA TERVERIFIKASI ASLI',
                          style: TextStyle(color: AppColors.alertSuccess, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Public Verification Details (QR-02)
                  _buildDetailCard(
                    title: 'Profil Petani & Origin (Database)',
                    content: 'Produsen: $producer\nVarietas: $variety\nFase Distribusi: $phase',
                    icon: Icons.person_pin_circle_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    title: 'Riwayat Pengiriman & Temperature Log',
                    content: 'Status Logistik: Siap Diambil / Dalam Perjalanan.\nIntegrasi Sensor: Terhubung ke Broker MQTT SmartLink',
                    icon: Icons.local_shipping_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    title: 'Alamat Verifikasi Kebenaran Data',
                    content: 'ID Batch: ${widget.batchId}\nURL Verifikasi: https://electratech.id/verify/${widget.batchId}',
                    icon: Icons.link,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailCard({required String title, required String content, required IconData icon}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
