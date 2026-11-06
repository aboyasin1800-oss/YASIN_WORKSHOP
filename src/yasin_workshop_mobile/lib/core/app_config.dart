class AppConfig {
  const AppConfig({
    required this.baseUrl,
    this.defaultUserName = 'admin',
  });

  final String baseUrl;
  final String defaultUserName;

  String get statusUrl => '$baseUrl/api/status';
  String get customersUrl => '$baseUrl/api/customers';
  String get employeesUrl => '$baseUrl/api/employees';

  String customerUrl(String id) => '$customersUrl/$id';
  String employeeUrl(String id) => '$employeesUrl/$id';
}
