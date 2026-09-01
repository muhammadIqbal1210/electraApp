import 'dart:convert';
import 'package:electra_app/core/network/api_client.dart';

class AiAgentApiService {
  static Future<Map<String, dynamic>> sendChatMessage(String message, {List<dynamic>? history}) async {
    try {
      final response = await ApiClient.post('/agent/chat', {
        'message': message,
        'history': history ?? [],
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['reply'] != null) {
        return {'success': true, 'reply': data['reply']};
      }
      return {'success': false, 'message': data['error'] ?? 'Gagal mendapatkan balasan AI Agent'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal koneksi ke AI Agent backend: $e'};
    }
  }
}
