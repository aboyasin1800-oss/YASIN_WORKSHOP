import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/app_config.dart';
import '../models/employee.dart';

abstract interface class EmployeeApiServiceContract {
  Future<List<Employee>> fetchEmployees();
  Future<Employee> fetchEmployee(String id);
  Future<Employee> createEmployee(EmployeeDraft draft);
  Future<Employee> updateEmployee(String id, EmployeeDraft draft);
}

class EmployeeApiService implements EmployeeApiServiceContract {
  EmployeeApiService({
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

  @override
  Future<List<Employee>> fetchEmployees({String? search, String? status, String? type}) async {
    final query = <String, String>{};
    if (search != null && search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }
    if (status != null && status.trim().isNotEmpty) {
      query['status'] = status.trim();
    }
    if (type != null && type.trim().isNotEmpty) {
      query['type'] = type.trim();
    }

    final uri = query.isEmpty ? Uri.parse(config.employeesUrl) : Uri.parse(config.employeesUrl).replace(queryParameters: query);
    final response = await client.get(uri, headers: _headers).timeout(const Duration(seconds: 6));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Employee list payload is invalid.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Employee.fromJson)
        .toList(growable: false);
  }

  @override
  Future<Employee> fetchEmployee(String id) async {
    final response = await client.get(Uri.parse(config.employeeUrl(id)), headers: _headers).timeout(const Duration(seconds: 6));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Employee payload is invalid.');
    }

    return Employee.fromJson(decoded);
  }

  @override
  Future<Employee> createEmployee(EmployeeDraft draft) async {
    final response = await client
        .post(
          Uri.parse(config.employeesUrl),
          headers: _headers,
          body: jsonEncode(draft.toJson()),
        )
        .timeout(const Duration(seconds: 6));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Employee create response is invalid.');
    }

    return Employee.fromJson(decoded);
  }

  @override
  Future<Employee> updateEmployee(String id, EmployeeDraft draft) async {
    final response = await client
        .patch(
          Uri.parse(config.employeeUrl(id)),
          headers: _headers,
          body: jsonEncode(draft.toJson()),
        )
        .timeout(const Duration(seconds: 6));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(_errorMessage(response));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Employee update response is invalid.');
    }

    return Employee.fromJson(decoded);
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
      // Ignore decode errors and return the status code fallback.
    }

    return 'Request failed with status ${response.statusCode}';
  }
}
