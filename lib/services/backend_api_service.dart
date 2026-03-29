import 'dart:convert';

import 'package:http/http.dart' as http;

class BackendVoterRecord {
  const BackendVoterRecord({
    required this.address,
    required this.cid,
    this.data,
  });

  final String address;
  final String cid;
  final Map<String, dynamic>? data;

  factory BackendVoterRecord.fromJson(Map<String, dynamic> json) {
    return BackendVoterRecord(
      address: (json['address'] ?? '').toString(),
      cid: (json['cid'] ?? '').toString(),
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

class BackendApiService {
  BackendApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  // Demo fallback map, aligned with the website's local demo mapping behavior.
  final Map<String, Map<String, String>> _localDemoLinkedWallets = {};

  Future<Map<String, dynamic>> healthCheck() async {
    final response = await _client.get(Uri.parse('$baseUrl/health'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Backend health check failed: ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> initOtp({
    required String name,
    required String mobile,
    required String vid,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/register/initOtp'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'mobile': mobile,
        'vid': vid,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('OTP initialization failed: ${response.statusCode}');
    }
  }

  Future<void> verifyOtp({
    required String vid,
    required String otp,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/register/verifyOtp'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'vid': vid,
        'otp': otp,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('OTP verification failed: ${response.statusCode}');
    }
  }

  Future<BackendVoterRecord?> getVoter(String address) async {
    final response = await _client.get(Uri.parse('$baseUrl/voter/$address'));
    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load voter record: ${response.statusCode}');
    }

    return BackendVoterRecord.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<BackendVoterRecord?> linkWallet({
    required String vid,
    required String address,
    String? name,
    String? mobile,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/register/linkWallet'),
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vid': vid,
          'address': address,
        }),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Wallet link failed: ${response.statusCode}');
      }

      return BackendVoterRecord.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } catch (_) {
      // Website-compatible fallback for demo environments.
      _localDemoLinkedWallets[address.toLowerCase()] = {
        'vid': vid,
        'name': name ?? '',
        'mobile': mobile ?? '',
      };

      return BackendVoterRecord(
        address: address,
        cid: 'local-demo',
        data: {
          'vid': vid,
          'name': name,
          'mobile': mobile,
        },
      );
    }
  }

  bool hasLocalDemoWalletLink(String address) {
    return _localDemoLinkedWallets.containsKey(address.toLowerCase());
  }
}
