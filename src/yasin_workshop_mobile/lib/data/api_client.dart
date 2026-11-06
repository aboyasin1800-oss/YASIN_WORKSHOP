import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import '../core/backend_status_model.dart';

class ApiClient {
  ApiClient({
    required this.config,
    http.Client? client,
  }) : client = client ?? http.Client();

  final AppConfig config;
  final http.Client client;

  Future<BackendStatus> fetchStatus() async {
    final response = await client.get(Uri.parse(config.statusUrl));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load backend status: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backend status payload is invalid.');
    }

    return BackendStatus.fromJson(decoded);
  }
}
