class AppConfig {
  static const String defaultBackendUrl = String.fromEnvironment(
    'YASIN_WORKSHOP_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:5200',
  );

  const AppConfig({
    this.baseUrl = defaultBackendUrl,
    this.defaultUserName = 'customer-sync-proof-user',
  });

  final String baseUrl;
  final String defaultUserName;

  String get healthUrl => '$baseUrl/health';
  String get statusUrl => '$baseUrl/api/status';
  String get customersUrl => '$baseUrl/api/customers';
  String get employeesUrl => '$baseUrl/api/employees';

  String customerUrl(String id) => '$customersUrl/$id';
  String employeeUrl(String id) => '$employeesUrl/$id';
}
