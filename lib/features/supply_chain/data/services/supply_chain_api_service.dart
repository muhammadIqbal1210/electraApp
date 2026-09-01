import 'dart:convert';
import 'package:electra_app/core/network/api_client.dart';

class SupplyChainApiService {
  static Future<List<dynamic>> getBatches() async {
    try {
      final response = await ApiClient.get('/batches');
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

  static Future<Map<String, dynamic>> createBatch({
    required String variety,
    required int quantity,
    String? publicId,
    String? generation,
    String? seededAt,
  }) async {
    try {
      final response = await ApiClient.post('/batches', {
        if (publicId != null) 'publicId': publicId,
        'variety': variety,
        'generation': generation ?? 'G1',
        'quantity': quantity,
        if (seededAt != null) 'seededAt': seededAt,
      });

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201 && data['ok'] == true,
        'data': data['data'],
        'message': data['message'] ?? 'Batch berhasil dibuat',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal koneksi server Batch: $e'};
    }
  }

  static Future<List<dynamic>> getBatchLogs(String batchId) async {
    try {
      final response = await ApiClient.get('/batches/$batchId/logs');
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

  static Future<Map<String, dynamic>> updateBatchPhase({
    required String batchId,
    required String toPhase,
    String? healthStatus,
    String? notes,
  }) async {
    try {
      final response = await ApiClient.post('/batches/$batchId/logs', {
        'toPhase': toPhase,
        if (healthStatus != null) 'healthStatus': healthStatus,
        if (notes != null) 'notes': notes,
      });

      final data = jsonDecode(response.body);
      return {
        'success': (response.statusCode == 200 || response.statusCode == 201) && data['ok'] == true,
        'data': data['data'],
        'message': data['message'] ?? 'Fase budidaya berhasil diperbarui',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal memperbarui fase budidaya: $e'};
    }
  }

  static Future<List<dynamic>> getShipments() async {
    try {
      final response = await ApiClient.get('/tracking/shipments');
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

  static Future<Map<String, dynamic>> createShipment({
    required String batchId,
    required String destination,
    required int packageQuantity,
    String? notes,
  }) async {
    try {
      final response = await ApiClient.post('/tracking/shipments', {
        'batchId': batchId,
        'destination': destination,
        'packageQuantity': packageQuantity,
        if (notes != null) 'notes': notes,
      });

      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201 && data['ok'] == true,
        'data': data['data'],
        'message': data['message'] ?? 'Paket pengiriman benih berhasil didaftarkan',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal mendaftarkan pengiriman: $e'};
    }
  }

  static Future<List<dynamic>> getCheckins({String? receiptNumber}) async {
    try {
      final query = receiptNumber != null ? '?receiptNumber=$receiptNumber' : '';
      final response = await ApiClient.get('/tracking$query');
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

  static Future<Map<String, dynamic>> createCheckin({
    required String receiptNumber,
    required String batchId,
    required String status,
    required String cargoCondition,
    double? latitude,
    double? longitude,
    double? containerTemperatureC,
    String? notes,
  }) async {
    try {
      final response = await ApiClient.post('/tracking/checkins', {
        'receiptNumber': receiptNumber,
        'batchId': batchId,
        'status': status,
        'cargoCondition': cargoCondition,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (containerTemperatureC != null) 'containerTemperatureC': containerTemperatureC,
        if (notes != null) 'notes': notes,
      });
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 201 && data['ok'] == true,
        'data': data['data'],
        'message': data['message'] ?? 'Check-in posisi benih berhasil dicatat',
      };
    } catch (e) {
      return {'success': false, 'message': 'Gagal koneksi tracking: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyProductPublic(String batchId) async {
    try {
      final response = await ApiClient.get('/verify/$batchId');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['ok'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Verifikasi gagal'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal terhubung ke service verifikasi: $e'};
    }
  }
}
