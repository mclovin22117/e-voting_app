import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendApiService {
  BackendApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<Map<String, dynamic>> healthCheck() async {
    final response = await _client.get(Uri.parse('$baseUrl/health'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Backend health check failed: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
