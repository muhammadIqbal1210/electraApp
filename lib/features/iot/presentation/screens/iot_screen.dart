import 'package:flutter/material.dart';
import 'package:electra_app/core/constants/app_colors.dart';
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
  
  // Dropdown filter box perangkat
  String? _selectedDeviceCode; // null berarti 'Semua Box'
  final Map<int, bool> _actuatorStates = {};

  @override
  void initState() {
    super.initState();
    _fetchIotData();
  }

  Future<void> _fetchIotData() async {
    setState(() => _isLoading = true);

    final devicesData = await IotApiService.getIotDevices();
    final logsData = await IotApiService.getIotLogs(limit: 20); // 20 data terakhir

    if (mounted) {
      setState(() {
        _devices = devicesData;
        _logs = logsData;
        if (_devices.isNotEmpty && _selectedDeviceCode == null) {
          // Set default ke box pertama jika ada
          _selectedDeviceCode = _devices.first['deviceCode']?.toString();
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter devices berdasarkan dropdown pilihan
    final filteredDevices = _selectedDeviceCode == null || _selectedDeviceCode == 'ALL'
        ? _devices
        : _devices.where((d) => d['deviceCode']?.toString() == _selectedDeviceCode).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Farm IoT Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primary),
            onPressed: _fetchIotData,
          ),
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
                SizedBox(width: 4),
                Text('72.61.118.54:53937', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _fetchIotData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Dropdown Pengelompokan Box / Device Utama
                    const Text(
                      '📦 Filter & Kelompokkan Perangkat (Box / Device):',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.secondary.withAlpha(150), width: 1.5),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedDeviceCode ?? 'ALL',
                          dropdownColor: AppColors.cardDark,
                          isExpanded: true,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                          items: [
                            const DropdownMenuItem(value: 'ALL', child: Text('✨ Semua Box / Device Utama')),
                            ..._devices.map((d) {
                              final code = d['deviceCode']?.toString() ?? 'DEV';
                              final name = d['boxName']?.toString() ?? 'Box';
                              return DropdownMenuItem(
                                value: code,
                                child: Text('📦 $name ($code)'),
                              );
                            }),
                          ],
                          onChanged: (val) {
                            setState(() {
                              _selectedDeviceCode = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Tampilkan Komponen (Sensor & Actuator) per Box Device
                    if (filteredDevices.isEmpty && _devices.isNotEmpty)
                      const Text('Tidak ada perangkat yang sesuai dengan filter.', style: TextStyle(color: AppColors.textMuted))
                    else if (_devices.isEmpty)
                      _buildFallbackBoxGroup()
                    else
                      Column(
                        children: filteredDevices.map((device) {
                          final allComponents = device['components'] as List<dynamic>? ?? [];
                          // Pisahkan Sensor & Actuator
                          final sensors = allComponents.where((c) => c['componentType'] == 'sensor').toList();
                          final actuators = allComponents.where((c) => c['componentType'] == 'actuator').toList();

                          final boxName = device['boxName'] ?? 'Box Utama';
                          final deviceCode = device['deviceCode'] ?? 'BOX-01';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderDark, width: 1.5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Box Header Info
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary.withAlpha(40),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.developer_board, color: AppColors.secondary, size: 22),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              boxName.toString(),
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                            Text('Kode Device: $deviceCode', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(40),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: AppColors.primary),
                                      ),
                                      child: const Text('ONLINE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // A. BAGIAN SENSOR PERANGKAT
                                Row(
                                  children: [
                                    const Icon(Icons.sensors, color: AppColors.primary, size: 18),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Komponen Sensor (${sensors.length})',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (sensors.isEmpty)
                                  const Text('Belum ada sensor terpasang pada box ini.', style: TextStyle(color: AppColors.textMuted, fontSize: 11))
                                else
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.25,
                                    ),
                                    itemCount: sensors.length,
                                    itemBuilder: (context, idx) {
                                      final s = sensors[idx];
                                      final val = s['lastValue'] ?? '0.0';
                                      final unit = s['unit'] ?? '';
                                      final name = s['componentName'] ?? 'Sensor';

                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.backgroundDark,
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: AppColors.borderDark),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(name, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                            Text('$val $unit', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                            Text('Topic: ${s['mqttTopic']}', style: const TextStyle(color: AppColors.primary, fontSize: 9, fontFamily: 'monospace'), overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                const SizedBox(height: 18),

                                // B. BAGIAN AKTUATOR PERANGKAT
                                Row(
                                  children: [
                                    const Icon(Icons.toggle_on, color: AppColors.secondary, size: 20),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Komponen Actuator / Kendali (${actuators.length})',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (actuators.isEmpty)
                                  const Text('Belum ada aktuator pada box ini.', style: TextStyle(color: AppColors.textMuted, fontSize: 11))
                                else
                                  Column(
                                    children: actuators.map((act) {
                                      final compId = act['id'] as int? ?? 0;
                                      final actName = act['componentName'] ?? 'Actuator';
                                      final topic = act['mqttTopic'] ?? 'mqtt/actuator';
                                      return _buildActuatorControlRow(
                                        name: actName.toString(),
                                        topic: topic.toString(),
                                        componentId: compId,
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 10),

                    // 3. Grafik Real-time dari 20 Data Terakhir (IOT-02)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '📈 Grafik Real-Time Telemetri (20 Data Terakhir)',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text('${_logs.length} Data', style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _build20DataBarChart(_logs),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget Grafik Real-time Bar Chart dari 20 Data Terakhir Backend
  Widget _build20DataBarChart(List<dynamic> logs) {
    // Mengambil maksimal 20 data terakhir
    final recentLogs = logs.take(20).toList();

    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Deret Fluktuasi Nilai Telemetri (20 Logs)', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Row(
                children: [
                  CircleAvatar(radius: 3, backgroundColor: AppColors.primary),
                  SizedBox(width: 4),
                  Text('Live Stream', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentLogs.isEmpty)
            const Expanded(child: Center(child: Text('Belum ada log telemetri.', style: TextStyle(color: AppColors.textMuted))))
          else
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: recentLogs.map((logItem) {
                    final valNum = double.tryParse(logItem['value']?.toString() ?? '40') ?? 40;
                    final height = (valNum.clamp(10, 100)) * 1.2;
                    final compName = logItem['componentName']?.toString() ?? 'Sensor';
                    final valStr = logItem['value']?.toString() ?? '0';

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(valStr, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 18,
                            height: height,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.secondary],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 32,
                            child: Text(
                              compName,
                              style: const TextStyle(color: AppColors.textMuted, fontSize: 7),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackBoxGroup() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.inventory, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Greenhouse A3 (BOX-ESP32-01)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Text('Status: ONLINE', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.25,
            children: [
              _buildSensorCard(name: 'Suhu Udara', value: '28.5 °C', icon: Icons.thermostat, statusColor: AppColors.primary),
              _buildSensorCard(name: 'Kelembaban Udara', value: '76 %', icon: Icons.water_drop_outlined, statusColor: AppColors.primary),
              _buildSensorCard(name: 'Kelembaban Tanah', value: '42 %', icon: Icons.grass, statusColor: AppColors.alertError),
              _buildSensorCard(name: 'pH Tanah', value: '6.8 pH', icon: Icons.science_outlined, statusColor: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required String name,
    required String value,
    required IconData icon,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: statusColor.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
              Icon(icon, color: statusColor, size: 20),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text('Optimal Status', style: TextStyle(color: statusColor, fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildActuatorControlRow({
    required String name,
    required String topic,
    required int componentId,
  }) {
    final isSwitchedOn = _actuatorStates[componentId] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 2),
              Text('Topic: $topic', style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontFamily: 'monospace')),
            ],
          ),
          Row(
            children: [
              Text(
                isSwitchedOn ? 'ON' : 'OFF',
                style: TextStyle(
                  color: isSwitchedOn ? AppColors.primary : AppColors.textMuted,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 6),
              Switch(
                value: isSwitchedOn,
                activeThumbColor: AppColors.primary,
                onChanged: (bool value) async {
                  final newValueStr = value ? 'ON' : 'OFF';
                  setState(() {
                    _actuatorStates[componentId] = value;
                  });

                  final res = await IotApiService.controlActuator(componentId, newValueStr);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res['message'] ?? 'Perintah MQTT Terkirim ke Broker 72.61.118.54!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
