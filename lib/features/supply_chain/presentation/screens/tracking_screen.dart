import 'package:flutter/material.dart';
import 'package:electra_app/core/constants/app_colors.dart';
import 'package:electra_app/features/supply_chain/data/services/supply_chain_api_service.dart';
import 'package:electra_app/features/verification/presentation/screens/qr_verification_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<dynamic> _batches = [];
  List<dynamic> _shipments = [];
  List<dynamic> _checkins = [];
  bool _isLoading = true;

  // Controllers Registrasi Batch
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedGeneration = 'G1';

  // Controllers Buat Pengiriman Paket
  final TextEditingController _shipDestinationController = TextEditingController();
  final TextEditingController _shipQuantityController = TextEditingController();
  final TextEditingController _shipNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _varietyController.dispose();
    _quantityController.dispose();
    _shipDestinationController.dispose();
    _shipQuantityController.dispose();
    _shipNotesController.dispose();
    super.dispose();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);
    final batchData = await SupplyChainApiService.getBatches();
    final shipmentData = await SupplyChainApiService.getShipments();
    final checkinData = await SupplyChainApiService.getCheckins();

    if (mounted) {
      setState(() {
        _batches = batchData;
        _shipments = shipmentData;
        _checkins = checkinData;
        _isLoading = false;
      });
    }
  }

  // 1. Handlers Registrasi Batch Baru
  Future<void> _handleCreateBatch() async {
    final variety = _varietyController.text.trim();
    final quantityStr = _quantityController.text.trim();

    if (variety.isEmpty || quantityStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Varietas dan kuantitas wajib diisi!')),
      );
      return;
    }

    final quantity = int.tryParse(quantityStr) ?? 100;

    final res = await SupplyChainApiService.createBatch(
      variety: variety,
      generation: _selectedGeneration,
      quantity: quantity,
    );

    if (mounted) {
      Navigator.pop(context);
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Batch Tanam [$_selectedGeneration] Berhasil Didaftarkan!')),
        );
        _fetchAllData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Gagal membuat batch')),
        );
      }
    }
  }

  void _showAddBatchModal() {
    _varietyController.clear();
    _quantityController.clear();
    _selectedGeneration = 'G1';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌱 Registrasi Batch & Generasi Benih',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInputField(label: 'Varietas Tanaman', hint: 'cth: Cabai Rawit Merah / Tomat F1', controller: _varietyController),
                  const SizedBox(height: 12),
                  const Text('Generasi Benih:', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedGeneration,
                        dropdownColor: AppColors.cardDark,
                        isExpanded: true,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        items: ['G0', 'G1', 'G2', 'G3', 'F1'].map((gen) {
                          return DropdownMenuItem(value: gen, child: Text('Generasi Benih: $gen'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => _selectedGeneration = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(label: 'Kuantitas Semai', hint: 'cth: 1200', controller: _quantityController, isNumeric: true),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _handleCreateBatch,
                      child: const Text('Simpan Registrasi Batch', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 2. Handlers Update Fase Budidaya oleh Petani
  void _showUpdatePhaseModal(Map<String, dynamic> batch) {
    String selectedPhase = batch['phase'] ?? 'PENYEMAIAN';
    String healthStatus = batch['health_status'] ?? 'SEHAT';
    final TextEditingController notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔄 Update Fase Budidaya (${batch['id']})',
                    style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Pilih Fase Terbaru:', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPhase,
                        dropdownColor: AppColors.cardDark,
                        isExpanded: true,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        items: ['PENYEMAIAN', 'VEGETATIF_AWAL', 'VEGETATIF_LANJUT', 'GENERATIF', 'PANEN'].map((p) {
                          return DropdownMenuItem(value: p, child: Text('Fase: $p'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedPhase = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Kondisi Kesehatan Tanaman:', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: healthStatus,
                        dropdownColor: AppColors.cardDark,
                        isExpanded: true,
                        style: TextStyle(color: healthStatus == 'SEHAT' ? AppColors.alertSuccess : AppColors.alertError, fontWeight: FontWeight.bold),
                        items: ['SEHAT', 'PERLU_PERHATIAN', 'TERSOROT_HAMA'].map((h) {
                          return DropdownMenuItem(value: h, child: Text('Kondisi: $h'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => healthStatus = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(label: 'Catatan Perubahan Budidaya', hint: 'cth: Pemberian pupuk NPK & pemangkasan daun', controller: notesController),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final res = await SupplyChainApiService.updateBatchPhase(
                          batchId: batch['id'].toString(),
                          toPhase: selectedPhase,
                          healthStatus: healthStatus,
                          notes: notesController.text.trim(),
                        );
                        if (context.mounted) {
                          Navigator.pop(context);
                          if (res['success'] == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Fase Budidaya Berhasil Diperbarui & Dicatat!')),
                            );
                            _fetchAllData();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res['message'] ?? 'Gagal update fase')),
                            );
                          }
                        }
                      },
                      child: const Text('Simpan Perubahan Fase', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 3. Handlers Penentuan Paket Pengiriman Benih oleh Petani
  void _showCreateShipmentModal() {
    if (_batches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada batch tanam yang tersedia untuk dikirim.')),
      );
      return;
    }

    String selectedBatchId = _batches.first['id'].toString();
    _shipDestinationController.clear();
    _shipQuantityController.clear();
    _shipNotesController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🚚 Tentukan Paket Benih yang Akan Dikirim',
                    style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Pilih Batch Benih:', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedBatchId,
                        dropdownColor: AppColors.cardDark,
                        isExpanded: true,
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                        items: _batches.map((b) {
                          final idStr = b['id'].toString();
                          final varietyStr = b['variety'].toString();
                          return DropdownMenuItem(value: idStr, child: Text('$idStr - $varietyStr'));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedBatchId = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInputField(label: 'Alamat / Tujuan Pengiriman', hint: 'cth: Dinas Pertanian Suka Makmur, Blok C', controller: _shipDestinationController),
                  const SizedBox(height: 12),
                  _buildInputField(label: 'Jumlah Paket Benih', hint: 'cth: 250', controller: _shipQuantityController, isNumeric: true),
                  const SizedBox(height: 12),
                  _buildInputField(label: 'Catatan Pengiriman', hint: 'cth: Paket awal benih siap dijemput kurir', controller: _shipNotesController),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final dest = _shipDestinationController.text.trim();
                        final qtyStr = _shipQuantityController.text.trim();

                        if (dest.isEmpty || qtyStr.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tujuan dan jumlah paket wajib diisi!')),
                          );
                          return;
                        }

                        final qty = int.tryParse(qtyStr) ?? 10;

                        final res = await SupplyChainApiService.createShipment(
                          batchId: selectedBatchId,
                          destination: dest,
                          packageQuantity: qty,
                          notes: _shipNotesController.text.trim(),
                        );

                        if (context.mounted) {
                          Navigator.pop(context);
                          if (res['success'] == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Paket Pengiriman Benih Berhasil Didaftarkan!')),
                            );
                            _fetchAllData();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res['message'] ?? 'Gagal membuat paket')),
                            );
                          }
                        }
                      },
                      child: const Text('Daftarkan Paket Pengiriman', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 4. Modal Riwayat Alur Perubahan Budidaya
  void _showBatchLogsModal(Map<String, dynamic> batch) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<List<dynamic>>(
          future: SupplyChainApiService.getBatchLogs(batch['id'].toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
            }

            final logs = snapshot.data ?? [];

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📜 Riwayat Alur Perubahan Budidaya (${batch['id']})',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  if (logs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Belum ada riwayat perubahan fase budidaya.', style: TextStyle(color: AppColors.textMuted)),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, idx) {
                          final logItem = logs[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${logItem['from_phase']} → ${logItem['to_phase']}',
                                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(logItem['created_by'] ?? 'User', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                  ],
                                ),
                                if (logItem['notes'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text('Catatan: ${logItem['notes']}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracking & Budidaya Benih'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _fetchAllData,
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
            onPressed: () {
              final firstId = _batches.isNotEmpty ? _batches.first['id'] : 'BATCH-B092';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QrVerificationScreen(batchId: firstId.toString()),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Batch Benih'),
            Tab(icon: Icon(Icons.grass_outlined), text: 'Budidaya'),
            Tab(icon: Icon(Icons.local_shipping_outlined), text: 'Pengiriman'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBatchModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text('Batch & Gen Baru', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBatchTab(),
                _buildBudidayaTab(),
                _buildTrackingPosisiTab(),
              ],
            ),
    );
  }

  // TAB 1: Daftar Batch & Generasi Benih
  Widget _buildBatchTab() {
    return RefreshIndicator(
      onRefresh: _fetchAllData,
      color: AppColors.primary,
      child: _batches.isEmpty
          ? const Center(child: Text('Belum ada data batch tanam pada database.', style: TextStyle(color: AppColors.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _batches.length,
              itemBuilder: (context, index) {
                final batch = _batches[index];
                final batchId = batch['id'] ?? 'BATCH-00';
                final variety = batch['variety'] ?? 'Tanaman';
                final generation = batch['generation'] ?? 'G1';
                final phase = batch['phase'] ?? 'PENYEMAIAN';
                final producer = batch['producer_name'] ?? 'Produsen';
                final quantity = batch['quantity']?.toString() ?? '0';

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            batchId.toString(),
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withAlpha(50),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Gen: $generation',
                              style: const TextStyle(color: AppColors.secondary, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        variety.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Produsen: $producer • Semai: $quantity Unit • Fase: $phase',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // TAB 2: Bagian Budidaya Batch Tanam (Update Fase & Lihat Riwayat Alur)
  Widget _buildBudidayaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🌾 Budidaya Benih & Tanaman',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text('${_batches.length} Batch Aktif', style: const TextStyle(color: AppColors.primary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          ..._batches.map((batch) {
            final phase = batch['phase'] ?? 'PENYEMAIAN';
            final health = batch['health_status'] ?? 'SEHAT';
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(batch['variety'] ?? 'Varietas', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: health == 'SEHAT' ? AppColors.alertSuccess.withAlpha(40) : AppColors.alertError.withAlpha(40),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Kondisi: $health',
                          style: TextStyle(color: health == 'SEHAT' ? AppColors.alertSuccess : AppColors.alertError, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('ID Batch: ${batch['id']}', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  const SizedBox(height: 12),
                  const Text('Progress Fase Budidaya:', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: phase == 'PENYEMAIAN' ? 0.2 : (phase == 'VEGETATIF_AWAL' ? 0.5 : (phase == 'VEGETATIF_LANJUT' ? 0.75 : 1.0)),
                    backgroundColor: AppColors.backgroundDark,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 6),
                  Text('Fase Aktif Saat Ini: $phase', style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                  const SizedBox(height: 14),

                  // Tombol Update Fase & Riwayat Alur Budidaya
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _showUpdatePhaseModal(batch),
                          icon: const Icon(Icons.edit, color: AppColors.primary, size: 16),
                          label: const Text('Update Fase', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cardDark,
                            side: const BorderSide(color: AppColors.borderDark),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _showBatchLogsModal(batch),
                          icon: const Icon(Icons.history, color: Colors.white, size: 16),
                          label: const Text('Alur Riwayat', style: TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // TAB 3: Tracking Pengiriman Benih (Penentuan Paket Kirim & Alur Riwayat Pengiriman)
  Widget _buildTrackingPosisiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '🚚 Logistik & Pengiriman Benih',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _showCreateShipmentModal,
                icon: const Icon(Icons.add_location_alt_outlined, color: Colors.black, size: 16),
                label: const Text('Kirim Paket', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Daftar Riwayat Paket Pengiriman Benih
          const Text('Daftar Paket Resi Pengiriman:', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_shipments.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: const Text('Belum ada paket pengiriman benih didaftarkan.', style: TextStyle(color: AppColors.textMuted)),
            )
          else
            ..._shipments.map((ship) {
              final status = ship['status'] ?? 'READY_FOR_PICKUP';
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Resi: ${ship['receiptNumber']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withAlpha(40),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(status, style: const TextStyle(color: AppColors.secondary, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Batch ID: ${ship['batchId']} • Varietas: ${ship['variety']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text('Tujuan: ${ship['destination']} • Jumlah: ${ship['packageQuantity']} Paket', style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                    Text('Kurir: ${ship['courierName'] ?? 'Belum Ditugaskan'}', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.backgroundDark,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _showShipmentTrackingLogsModal(ship['receiptNumber'].toString()),
                        icon: const Icon(Icons.route, color: AppColors.primary, size: 16),
                        label: const Text('Lihat Alur Tracking Perjalanan Paket', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 20),
          const Text('📍 Alur Posisi Check-in Perjalanan Seluruh Paket:', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          // Log Checkin Posisi Terakhir Perjalanan
          if (_checkins.isEmpty)
            const Text('Belum ada data posisi check-in perjalanan dari kurir.', style: TextStyle(color: AppColors.textMuted, fontSize: 11))
          else
            ..._checkins.map((chk) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Resi: ${chk['receipt_number']} - ${chk['status']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          Text('Koordinat: (${chk['latitude']}, ${chk['longitude']}) • Kondisi: ${chk['cargo_condition']}', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          Text('Suhu Container: ${chk['container_temperature_c'] ?? '-'}°C • Waktu: ${chk['recorded_at']}', style: const TextStyle(color: AppColors.primary, fontSize: 10)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // 5. Modal Dialog Alur Posisi Check-in Perjalanan Spesifik Per Resi
  void _showShipmentTrackingLogsModal(String receiptNumber) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FutureBuilder<List<dynamic>>(
          future: SupplyChainApiService.getCheckins(receiptNumber: receiptNumber),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator(color: AppColors.primary)));
            }

            final trackingLogs = snapshot.data ?? [];

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📍 Alur Perjalanan Resi: $receiptNumber',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  if (trackingLogs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Belum ada data lokasi check-in untuk nomor resi ini.', style: TextStyle(color: AppColors.textMuted)),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: trackingLogs.length,
                        itemBuilder: (context, idx) {
                          final item = trackingLogs[idx];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item['status'] ?? 'Check-in', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text(item['recorded_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Kurir: ${item['courier_name'] ?? 'Kurir'}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                Text('Koordinat GPS: (${item['latitude']}, ${item['longitude']})', style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                                Text('Kondisi Muatan: ${item['cargo_condition']} • Suhu: ${item['container_temperature_c']}°C', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                if (item['notes'] != null) Text('Catatan: ${item['notes']}', style: const TextStyle(color: AppColors.primary, fontSize: 11)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isNumeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            filled: true,
            fillColor: AppColors.cardDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
