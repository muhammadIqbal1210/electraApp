import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:electra_app/core/constants/app_colors.dart';
import 'package:electra_app/features/ai_agent/presentation/screens/ai_agent_screen.dart';
import 'package:electra_app/features/iot/data/services/iot_api_service.dart';

class IotScreen extends StatefulWidget {
  const IotScreen({super.key});

  @override
  State<IotScreen> createState() => _IotScreenState();
}

class _IotScreenState extends State<IotScreen> {
  bool _isLoading = true;
  List<dynamic> _devices = [];
  List<dynamic> _logs = [];
  String? _selectedDeviceCode;

  @override
  void initState() {
    super.initState();
    _fetchIotData();
  }

  Future<void> _fetchIotData() async {
    setState(() => _isLoading = true);

    final devicesData = await IotApiService.getIotDevices();
    final logsData = await IotApiService.getIotLogs(limit: 20);

    if (!mounted) return;

    setState(() {
      _devices = devicesData;
      _logs = logsData;
      if (_devices.isNotEmpty && _selectedDeviceCode == null) {
        _selectedDeviceCode = _devices.first['deviceCode']?.toString();
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredDevices =
        _selectedDeviceCode == null || _selectedDeviceCode == 'ALL'
        ? _devices
        : _devices
              .where((d) => d['deviceCode']?.toString() == _selectedDeviceCode)
              .toList();

    final visibleLogs = _logs.take(20).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFEFF3F0),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _fetchIotData,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                children: [
                  _buildHeaderBanner('User'),
                  const SizedBox(height: 22),
                  const Text(
                    'IoT Devices & Sensors',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Real-time monitoring and analytics across your farm infrastructure.',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 16,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildFilterCard(),
                  const SizedBox(height: 10),
                  Text(
                    '${filteredDevices.length} device${filteredDevices.length == 1 ? '' : 's'} terpilih',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.58,
                    children: [
                      _buildMetricTile(
                        icon: Icons.thermostat,
                        label: 'Temp',
                        value: '24.5°C',
                        status: 'OK',
                        statusColor: const Color(0xFF4CAF50),
                        iconColor: const Color(0xFF1F2937),
                        bgColor: const Color(0xFFF8FAFC),
                      ),
                      _buildMetricTile(
                        icon: Icons.water_drop_outlined,
                        label: 'Humidity',
                        value: '68%',
                        status: 'OK',
                        statusColor: const Color(0xFF4CAF50),
                        iconColor: const Color(0xFF7C3AED),
                        bgColor: const Color(0xFFF8FAFC),
                      ),
                      _buildMetricTile(
                        icon: Icons.grass,
                        label: 'Soil Moist',
                        value: '32%',
                        status: 'Low',
                        statusColor: const Color(0xFFEF4444),
                        iconColor: const Color(0xFFEF4444),
                        bgColor: const Color(0xFFFDF2F2),
                      ),
                      _buildMetricTile(
                        icon: Icons.science_outlined,
                        label: 'pH Level',
                        value: '6.5 pH',
                        status: 'OK',
                        statusColor: const Color(0xFF4CAF50),
                        iconColor: const Color(0xFF1F2937),
                        bgColor: const Color(0xFFF8FAFC),
                      ),
                      _buildMetricTile(
                        icon: Icons.light_mode_outlined,
                        label: 'Light',
                        value: '850 lx',
                        status: 'OK',
                        statusColor: const Color(0xFF4CAF50),
                        iconColor: const Color(0xFFF59E0B),
                        bgColor: const Color(0xFFF8FAFC),
                      ),
                      _buildMetricTile(
                        icon: Icons.air,
                        label: 'CO2',
                        value: '420 ppm',
                        status: 'OK',
                        statusColor: const Color(0xFF4CAF50),
                        iconColor: const Color(0xFF3B82F6),
                        bgColor: const Color(0xFFF8FAFC),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _buildHistoryCard(visibleLogs),
                  const SizedBox(height: 22),
                  const Text(
                    'Actuator Controls',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.7,
                    children: [
                      _buildActuatorCard(
                        title: 'Water Pump',
                        subtitle: 'ON',
                        icon: Icons.water_drop_rounded,
                        isOn: true,
                        accent: const Color(0xFF4CAF50),
                        tag: 'MAN',
                        autoTag: 'AUTO',
                      ),
                      _buildActuatorCard(
                        title: 'Cooling Fans',
                        subtitle: 'Auto: > 28°C',
                        icon: Icons.air,
                        isOn: false,
                        accent: const Color(0xFF3B82F6),
                        tag: 'MAN',
                        autoTag: 'AUTO',
                      ),
                      _buildActuatorCard(
                        title: 'Grow Lights',
                        subtitle: 'ON',
                        icon: Icons.light_mode,
                        isOn: true,
                        accent: const Color(0xFF4CAF50),
                        tag: 'MAN',
                        autoTag: 'AUTO',
                      ),
                      _buildActuatorCard(
                        title: 'Mist System',
                        subtitle: 'Auto: 30% - 60%',
                        icon: Icons.water_drop_outlined,
                        isOn: false,
                        accent: const Color(0xFF3B82F6),
                        tag: 'MAN',
                        autoTag: 'AUTO',
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Connected Devices',
                    style: TextStyle(
                      color: Color(0xFF1F2937),
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDeviceRow(
                    title: 'Temp Node A1',
                    subtitle: 'Greenhouse 1',
                    icon: Icons.device_thermostat_outlined,
                    status: '98%',
                    statusTone: const Color(0xFF4CAF50),
                    accent: const Color(0xFFB7E4C7),
                  ),
                  const SizedBox(height: 10),
                  _buildDeviceRow(
                    title: 'Soil Node B2',
                    subtitle: 'Open Field West',
                    icon: Icons.grass,
                    status: '15%',
                    statusTone: const Color(0xFFEF4444),
                    accent: const Color(0xFFFECACA),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const AiAgentScreen()));
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('AI'),
      ),
    );
  }

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

  Widget _buildFilterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Zone / Device',
            style: TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedDeviceCode ?? 'ALL',
                isExpanded: true,
                dropdownColor: Colors.white,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                items: [
                  const DropdownMenuItem(
                    value: 'ALL',
                    child: Text('Greenhouse 1 - Main Unit'),
                  ),
                  ...(_devices.map((d) {
                    final code = d['deviceCode']?.toString() ?? 'DEV';
                    final name = d['boxName']?.toString() ?? 'Greenhouse';
                    return DropdownMenuItem(
                      value: code,
                      child: Text('$name ($code)'),
                    );
                  }).toList()),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDeviceCode = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required String status,
    required Color statusColor,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF374151),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 36,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(List<dynamic> logs) {
    final chartLogs = logs.isEmpty ? <dynamic>[] : logs;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '24h History',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Last 24 Hours',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: _HistoryChartPainter(chartLogs),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActuatorCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isOn,
    required Color accent,
    required String tag,
    required String autoTag,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 25),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (autoTag.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        autoTag,
                        style: const TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subtitle,
                style: TextStyle(
                  color: isOn ? accent : const Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Switch(value: isOn, onChanged: (_) {}, activeThumbColor: accent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required String status,
    required Color statusTone,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                status,
                style: TextStyle(
                  color: statusTone,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusTone,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryChartPainter extends CustomPainter {
  _HistoryChartPainter(this.logs);

  final List<dynamic> logs;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFF8FAFC);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(14),
      ),
      bgPaint,
    );

    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1;

    for (double y = 18; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = const Color(0xFF8B5CF6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final secondLinePaint = Paint()
      ..color = const Color(0xFF22C55E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final secondPath = Path();

    final points = logs.isEmpty
        ? [
            const Offset(0, 130),
            const Offset(30, 120),
            const Offset(60, 110),
            const Offset(90, 128),
            const Offset(120, 100),
            const Offset(150, 90),
            const Offset(180, 105),
            const Offset(210, 95),
            const Offset(240, 80),
            const Offset(270, 110),
          ]
        : List.generate(logs.length, (index) {
            final value =
                double.tryParse(logs[index]['value']?.toString() ?? '50') ?? 50;
            final x =
                (index / (logs.length - 1).clamp(1, 1000000)) *
                    (size.width - 20) +
                10;
            final y =
                size.height -
                24 -
                ((value.clamp(0, 100) / 100) * (size.height - 50));
            return Offset(x, y);
          });

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
        secondPath.moveTo(p.dx, p.dy + 18);
      } else {
        path.lineTo(p.dx, p.dy);
        secondPath.lineTo(p.dx, p.dy + 18);
      }
    }

    canvas.drawPath(path, linePaint);
    canvas.drawPath(secondPath, secondLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
