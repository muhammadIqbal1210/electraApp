import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Base URL backend Node.js (Express)
  static const String baseUrl = 'http://10.10.10.181:4000/api';
  
  static String? _authToken;

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static String? get authToken => _authToken;

  static Map<String, String> get _headers {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // Durasi timeout standar untuk semua request
  static const Duration _timeoutDuration = Duration(seconds: 10);

  // 1. GET METHOD (Diperbaiki: menggunakan http.get, tanpa body)
  static Future<http.Response> get(String path) async {
    final url = Uri.parse('$baseUrl$path');
    return await http
        .get(
          url,
          headers: _headers,
        )
        .timeout(
          _timeoutDuration,
          onTimeout: () {
            throw Exception('Koneksi ke server timeout (lebih dari 10 detik)');
          },
        );
  }

  // 2. POST METHOD (Diperbaiki: ditambahkan .timeout())
  static Future<http.Response> post(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    return await http
        .post(
          url,
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(
          _timeoutDuration,
          onTimeout: () {
            throw Exception('Koneksi ke server timeout (lebih dari 10 detik)');
          },
        );
  }

  // 3. PUT METHOD (Diperbaiki: ditambahkan .timeout())
  static Future<http.Response> put(String path, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$path');
    return await http
        .put(
          url,
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(
          _timeoutDuration,
          onTimeout: () {
            throw Exception('Koneksi ke server timeout (lebih dari 10 detik)');
          },
        );
  }
}