import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:electra_app/features/auth/data/services/auth_service.dart';
import 'package:electra_app/features/iot/data/services/iot_api_service.dart';
import 'package:electra_app/features/supply_chain/data/services/supply_chain_api_service.dart';
import 'package:electra_app/features/dashboard/data/services/blog_api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _userData;
  List<dynamic> _devices = [];
  List<dynamic> _batches = [];
  List<dynamic> _shipments = [];
  List<dynamic> _iotLogs = [];
  List<dynamic> _publishedBlogs = [];
  List<Map<String, dynamic>> _userActivities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);

    // 1. Fetch User Profile
    final userRes = await AuthService.getCurrentUser();
    if (userRes['success'] == true) {
      _userData = userRes['user'];
    }

    // 2. Fetch User-Specific IoT Devices & Logs from DB (for stat grid)
    final devicesData = await IotApiService.getIotDevices();
    final iotLogData = await IotApiService.getIotLogs(limit: 20);

    // 3. Fetch User-Specific Batches (Tanaman) from DB
    final batchData = await SupplyChainApiService.getBatches();

    // 4. Fetch User-Specific Shipments & Checkins from DB
    final shipmentData = await SupplyChainApiService.getShipments();
    final checkinData = await SupplyChainApiService.getCheckins();

    // 5. Fetch Published News/Articles from DB
    final blogData = await BlogApiService.getPublishedBlogs(limit: 10);

    // 6. Compile 10 Recent Non-IoT User Activities
    final activities = _compileUserActivities(
      batches: batchData,
      shipments: shipmentData,
      checkins: checkinData,
    );

    if (mounted) {
      setState(() {
        _devices = devicesData;
        _iotLogs = iotLogData;
        _batches = batchData;
        _shipments = shipmentData;
        _publishedBlogs = blogData;
        _userActivities = activities;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _compileUserActivities({
    required List<dynamic> batches,
    required List<dynamic> shipments,
    required List<dynamic> checkins,
  }) {
    final List<Map<String, dynamic>> list = [];

    // 1. Pendaftaran Tanaman & Pembaruan Budidaya
    for (var b in batches) {
      final batchId = b['id'] ?? 'BATCH';
      final variety = b['variety'] ?? 'Tanaman';
      final qty = b['quantity'] ?? 0;
      final phase = b['phase'] ?? 'PENYEMAIAN';

      list.add({
        'type': 'PENDAFTARAN_TANAMAN',
        'title': 'Pendaftaran Tanaman: $batchId',
        'description':
            'Mendaftarkan tanaman $variety (Jumlah: $qty, Fase: $phase)',
        'timestamp': b['created_at'] ?? b['seeded_at'] ?? '',
        'icon': Icons.grass_rounded,
        'color': const Color(0xFF388E3C),
        'bgColor': const Color(0xFFE8F5E9),
      });

      if (phase != 'PENYEMAIAN') {
        list.add({
          'type': 'PEMBARUAN_FASE',
          'title': 'Pembaruan Fase Budidaya ($batchId)',
          'description': 'Tanaman $variety diperbarui ke fase $phase',
          'timestamp': b['created_at'] ?? '',
          'icon': Icons.eco_rounded,
          'color': const Color(0xFF10B981),
          'bgColor': const Color(0xFFECFDF5),
        });
      }
    }

    // 2. Pendaftaran Pengiriman Paket Benih
    for (var s in shipments) {
      final resi = s['receiptNumber'] ?? s['id'] ?? 'SHIPMENT';
      final dest = s['destination'] ?? 'Tujuan';
      final status = s['status'] ?? 'DIBUAT';
      final qty = s['packageQuantity'] ?? 1;

      list.add({
        'type': 'PENGIRIMAN',
        'title': 'Pengiriman Paket: Resi $resi',
        'description':
            'Mengirim $qty paket benih ke $dest (Status: $status)',
        'timestamp': s['createdAt'] ?? '',
        'icon': Icons.local_shipping_rounded,
        'color': const Color(0xFF4F46E5),
        'bgColor': const Color(0xFFEDE9FE),
      });
    }

    // 3. Check-in Tracking Pengiriman
    for (var c in checkins) {
      final resi = c['receipt_number'] ?? 'RESI';
      final status = c['status'] ?? 'Check-in';
      final condition = c['cargo_condition'] ?? 'Baik';

      list.add({
        'type': 'CHECKIN',
        'title': 'Check-in Lokasi Resi $resi',
        'description': 'Status: $status • Kondisi Muatan: $condition',
        'timestamp': c['recorded_at'] ?? '',
        'icon': Icons.location_on_rounded,
        'color': const Color(0xFFF59E0B),
        'bgColor': const Color(0xFFFEF3C7),
      });
    }

    // Sort by timestamp descending
    list.sort((a, b) {
      final dtA = DateTime.tryParse(a['timestamp'].toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final dtB = DateTime.tryParse(b['timestamp'].toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return dtB.compareTo(dtA);
    });

    return list.take(10).toList();
  }


  @override
  Widget build(BuildContext context) {
    final userName = _userData?['name'] ?? 'Admin Electra';

    // Calculate user-specific metrics from DB
    final deviceCount = _devices.length;
    int sensorCount = 0;
    for (var dev in _devices) {
      if (dev['components'] is List) {
        sensorCount += (dev['components'] as List).length;
      }
    }
    if (sensorCount == 0 && _iotLogs.isNotEmpty) {
      sensorCount = _iotLogs.length;
    }

    final plantCount = _batches.length;
    final deliveryCount = _shipments.length;


    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF388E3C)),
            )
          : RefreshIndicator(
              onRefresh: _fetchDashboardData,
              color: const Color(0xFF388E3C),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Header Banner Card with Greenhouse Background
                    _buildHeaderBanner(userName),

                    const SizedBox(height: 8),

                    // Main Body Padding
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Data Terkini Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Data Terkini',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.sync_rounded,
                                  color: Color(0xFF64748B),
                                  size: 22,
                                ),
                                onPressed: _fetchDashboardData,
                                tooltip: 'Refresh Data Database',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 2x2 Grid Stat Cards (User DB metrics)
                          _buildStatGrid(
                            deviceCount: deviceCount,
                            sensorCount: sensorCount,
                            plantCount: plantCount,
                            deliveryCount: deliveryCount,
                          ),

                          const SizedBox(height: 24),

                          // Section 2: Prakiraan Cuaca
                          const Text(
                            'Prakiraan Cuaca',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildWeatherCard(),

                          const SizedBox(height: 24),

                          // Section 3: Artikel Terbaru (Published Database Blogs)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Artikel Terbaru',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${_publishedBlogs.length} Berita',
                                      style: const TextStyle(
                                        color: Color(0xFF388E3C),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: _showAllArticlesModal,
                                child: const Text(
                                  'Lihat Semua',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF388E3C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildArticlesRow(),

                          const SizedBox(height: 28),

                          // Section 4: Aktivitas Terbaru (10 User Activities)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Aktivitas Terbaru',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE9FE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  '10 Terakhir',
                                  style: TextStyle(
                                    color: Color(0xFF4F46E5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildRecentActivitiesList(),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Header Banner Component
  Widget _buildHeaderBanner(String userName) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'lib/assets/bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2E7D32).withValues(alpha: 0.86),
                    const Color(0xFF388E3C).withValues(alpha: 0.78),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'lib/assets/logosmartfarm.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return SvgPicture.asset('lib/assets/logo.svg',
                                fit: BoxFit.contain);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SmartFarm',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'By Electra Tech',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Hi $userName 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Selamat datang di smarfarm ElectraTech Indonesia, pantau pertanian dan tingkatkan transparansi produk anda.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2x2 Grid of Stat Cards
  Widget _buildStatGrid({
    required int deviceCount,
    required int sensorCount,
    required int plantCount,
    required int deliveryCount,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.9,
      children: [
        _buildStatCard(
          icon: Icons.router_outlined,
          iconBgColor: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF388E3C),
          value: '$deviceCount',
          label: 'Perangkat',
        ),
        _buildStatCard(
          icon: Icons.sensors_rounded,
          iconBgColor: const Color(0xFFEDE9FE),
          iconColor: const Color(0xFF6366F1),
          value: '$sensorCount',
          label: 'Sensor',
        ),
        _buildStatCard(
          icon: Icons.local_florist_outlined,
          iconBgColor: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFFA855F7),
          value: '$plantCount',
          label: 'Tanaman',
        ),
        _buildStatCard(
          icon: Icons.local_shipping_outlined,
          iconBgColor: const Color(0xFFE8F5E9),
          iconColor: const Color(0xFF10B981),
          value: '$deliveryCount',
          label: 'Pengiriman',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Weather Card Component
  Widget _buildWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wb_sunny_outlined,
                color: Color(0xFFF59E0B),
                size: 38,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '28°C',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Cerah Berawan',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                'Kelembapan: 65%',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Angin: 12 km/h',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Published News Articles Horizontal Row Component
  Widget _buildArticlesRow() {
    if (_publishedBlogs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: const Text(
          'Belum ada artikel berita yang dipublikasikan di database.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _publishedBlogs.length,
        itemBuilder: (context, index) {
          final blog = _publishedBlogs[index];
          final title = blog['title'] ?? 'Artikel Berita';
          final category = blog['category'] ?? 'Umum';


          return GestureDetector(
            onTap: () => _openArticleDetail(blog),
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Badge & Thumbnail
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Color(0xFF388E3C),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEDE9FE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.newspaper_rounded,
                          color: Color(0xFF4F46E5),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Article Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 12, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimestamp(blog['created_at']),
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Section 4: Recent 10 User Activities List
  Widget _buildRecentActivitiesList() {
    if (_userActivities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: const Text(
          'Belum ada aktivitas terbaru pada akun pengguna ini.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _userActivities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final act = _userActivities[index];
        final icon = act['icon'] as IconData;
        final color = act['color'] as Color;
        final bgColor = act['bgColor'] as Color;
        final title = act['title'] as String;
        final desc = act['description'] as String;
        final timeStr = _formatTimestamp(act['timestamp']);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      desc,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timeStr,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Article Modal Detail
  void _openArticleDetail(Map<String, dynamic> blog) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      blog['category'] ?? 'Berita',
                      style: const TextStyle(
                        color: Color(0xFF388E3C),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    _formatTimestamp(blog['created_at']),
                    style: const TextStyle(
                        color: Color(0xFF94A3B8), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                blog['title'] ?? '',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Penulis: ${blog['author_name'] ?? 'Admin Electra'}',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Divider(height: 24),
              Text(
                blog['content'] ?? 'Konten berita tidak tersedia.',
                style: const TextStyle(
                  color: Color(0xFF334155),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showAllArticlesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Semua Artikel Dipublikasikan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _publishedBlogs.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final b = _publishedBlogs[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        b['title'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        '${b['category']} • ${b['author_name'] ?? 'Admin'}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _openArticleDetail(b);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null || timestamp.toString().isEmpty) return 'Baru saja';
    try {
      final dt = DateTime.parse(timestamp.toString()).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
      if (diff.inHours < 24) return '${diff.inHours}j lalu';
      if (diff.inDays < 7) return '${diff.inDays}h lalu';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return 'Baru saja';
    }
  }
}
