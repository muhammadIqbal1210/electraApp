import 'dart:convert';
import 'package:electra_app/core/network/api_client.dart';

class IotApiService {
  static Future<List<dynamic>> getIotDevices() async {
    try {
      final response = await ApiClient.get('/iot/devices');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getIotLogs({String? deviceCode, int limit = 50}) async {
    try {
      final String query = deviceCode != null ? '?deviceCode=$deviceCode&limit=$limit' : '?limit=$limit';
      final response = await ApiClient.get('/iot/logs$query');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return data['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> controlActuator(int componentId, String value) async {
    try {
      final response = await ApiClient.post('/iot/components/$componentId/control', {
        'value': value,
      });
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200 && data['ok'] == true,
        'message': data['message'] ?? 'Kontrol aktuator selesai',
        'data': data['data'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal koneksi server IoT: $e'};
    }
  }
}
