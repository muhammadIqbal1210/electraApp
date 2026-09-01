import 'dart:convert';
import 'package:electra_app/core/network/api_client.dart';

class BlogApiService {
  static Future<List<dynamic>> getPublishedBlogs({int limit = 10}) async {
    try {
      final response = await ApiClient.get('/blogs?limit=$limit');
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
}
