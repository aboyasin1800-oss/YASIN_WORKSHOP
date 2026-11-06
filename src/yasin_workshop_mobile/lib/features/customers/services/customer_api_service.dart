import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/app_config.dart';
import '../models/customer.dart';

class CustomerApiService {
  CustomerApiService({
    required this.config,
    http.Client? client,
    String? userName,
  })  : client = client ?? http.Client(),
        userName = userName ?? config.defaultUserName;

  final AppConfig config;
  final http.Client client;
  final String userName;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-User-Name': userName,
      };

  Future<List<Customer>> fetchCustomers({String? search, String? status}) async {
    final query = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (status != null && status.trim().isNotEmpty) {
      query['status'] = status.trim();
    }

    final uri = query.isEmpty ? Uri.parse(config.customersUrl) : Uri.parse(config.customersUrl).replace(queryParameters: query);
    final response = await client.get(uri, headers: _headers).timeout(const Duration(seconds: 6));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Customer list payload is invalid.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Customer.fromJson)
        .toList(growable: false);
  }

  Future<Customer> fetchCustomer(String id) async {
    final response = await client.get(Uri.parse(config.customerUrl(id)), headers: _headers).timeout(const Duration(seconds: 6));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Customer payload is invalid.');
    }

    return Customer.fromJson(decoded);
  }

  Future<Customer> createCustomer(CustomerDraft draft) async {
    final response = await client
        .post(
          Uri.parse(config.customersUrl),
          headers: _headers,
          body: jsonEncode(draft.toJson()),
        )
        .timeout(const Duration(seconds: 6));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Customer create response is invalid.');
    }

    return Customer.fromJson(decoded);
  }

  Future<Customer> updateCustomer(String id, CustomerDraft draft) async {
    final response = await client
        .patch(
          Uri.parse(config.customerUrl(id)),
          headers: _headers,
          body: jsonEncode(draft.toJson()),
        )
        .timeout(const Duration(seconds: 6));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Customer update response is invalid.');
    }

    return Customer.fromJson(decoded);
  }

  String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'];
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }
    } catch (_) {
      // Ignore decode failures and fall back to status code text.
    }

    return 'Request failed with status ${response.statusCode}';
  }
}
