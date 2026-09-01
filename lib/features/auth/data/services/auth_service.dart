import 'dart:convert';
import 'package:electra_app/core/network/api_client.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String username, String password, {String? role}) async {
    try {
      final response = await ApiClient.post('/auth/login', {
        'username': username,
        'password': password,
        if (role != null) 'role': role,
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['ok'] == true) {
        if (data['user'] == null) {
          return {
            'success': false,
            'message': 'Akses ditolak. Data pengguna tidak ditemukan.',
          };
        }

        final userRole = data['user']['role']?.toString().toLowerCase();

        if (userRole == null || userRole.isEmpty) {
          return {
            'success': false,
            'message': 'Akses ditolak. Role pengguna tidak ditemukan.',
          };
        }

        // Tolak akses jika peran user adalah 'admin' atau 'kurir'
        if (userRole == 'admin') {
          return {
            'success': false,
            'message': 'Akses ditolak. Akun Admin hanya dapat diakses melalui Web Dashboard.',
          };
        }

        if (userRole == 'kurir' || userRole == 'courier') {
          return {
            'success': false,
            'message': 'Akses ditolak. Akun Kurir tidak diperuntukkan bagi aplikasi ini.',
          };
        }

        // Simpan token hanya jika role valid (misal: petani / konsumen)
        ApiClient.setAuthToken(data['token']);
        return {'success': true, 'user': data['user'], 'token': data['token']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login gagal'};
      }

    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server backend ($e)'};
    }
  }

  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await ApiClient.get('/auth/me');
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['ok'] == true) {
        return {'success': true, 'user': data['user']};
      }
      return {'success': false, 'message': 'Gagal mengambil data user'};
    } catch (e) {
      return {'success': false, 'message': 'Gagal koneksi server: $e'};
    }
  }
}
