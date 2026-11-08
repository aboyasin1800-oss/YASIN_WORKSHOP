import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:yasin_workshop_mobile/core/app_config.dart';
import 'package:yasin_workshop_mobile/core/offline/local_sync_store.dart';
import 'package:yasin_workshop_mobile/data/api_client.dart';
import 'package:yasin_workshop_mobile/features/customers/models/customer.dart';
import 'package:yasin_workshop_mobile/features/customers/services/customer_api_service.dart';
import 'package:yasin_workshop_mobile/features/customers/services/customer_offline_service.dart';
import 'package:yasin_workshop_mobile/features/employees/models/employee.dart';
import 'package:yasin_workshop_mobile/features/employees/services/employee_api_service.dart';
import 'package:yasin_workshop_mobile/main.dart';

void main() {
  testWidgets('Yasin Workshop app renders Arabic foundation shell', (
    tester,
  ) async {
    await tester.pumpWidget(const YasinWorkshopApp());

    expect(find.text('معمل ياسين'), findsOneWidget);
    expect(find.text('حالة الخادم'), findsOneWidget);
  });

  test('Customer offline sync posts the real backend contract and uses the approved sync user', () async {
    final service = CustomerOfflineService(
      databasePath: await LocalSqliteStore.createTestDatabasePath(),
    );
    await service.clear();

    final uniqueId = 'customer-sync-contract-${DateTime.now().microsecondsSinceEpoch}';
    await service.saveCustomerOffline(
      id: uniqueId,
      name: 'Contract Customer',
      contactName: 'Contract Contact',
      phone: '+966500000010',
      email: 'contract-${DateTime.now().millisecondsSinceEpoch}@example.com',
      relationshipType: 'Wholesale',
      deliveryLocation: 'Riyadh',
      status: 'Active',
      notes: 'sync contract proof',
    );

    final client = _CapturingSyncClient();
    final pushed = await service.pushPendingCustomers(
      baseUrl: 'http://127.0.0.1:5200',
      userName: 'customer-sync-proof-user',
      client: client,
    );

    expect(pushed, equals(1));
    expect(client.lastRequest, isNotNull);
    expect(client.lastHeaders?['X-User-Name'], equals('customer-sync-proof-user'));

    final body = jsonDecode(client.lastBody ?? '{}') as Map<String, dynamic>;
    expect(body['entityType'], equals('customer'));
    expect(body['entityId'], equals(uniqueId));
    expect(body['operationType'], equals('create'));
    expect(body['idempotencyKey'], isNotEmpty);
    expect(body['payload'], isA<String>());
    final payloadMap = jsonDecode(body['payload'] as String) as Map<String, dynamic>;
    expect(payloadMap['id'], equals(uniqueId));

    await service.close();
  });

  test('App config builds backend health and status URLs from the configured base URL', () {
    const config = AppConfig(baseUrl: 'https://localhost:7262');

    expect(config.healthUrl, equals('https://localhost:7262/health'));
    expect(config.statusUrl, equals('https://localhost:7262/api/status'));
    expect(config.baseUrl, isNotEmpty);
  });

  test('Api client parses status payload from the backend status contract', () async {
    final client = _FakeClient({
      'https://localhost:7262/api/status': jsonEncode({
        'Environment': 'Development',
        'Database': 'YASIN_WORKSHOP_ES_VALIDATION',
        'Guarded': true,
        'GoldenBaselineProtected': true,
        'LumarProtected': true,
        'CoreFoundation': true,
        'OperationalFoundation': true,
      }),
    });

    final apiClient = ApiClient(
      client: client,
      config: const AppConfig(baseUrl: 'https://localhost:7262'),
    );

    final status = await apiClient.fetchStatus();

    expect(status.environment, equals('Development'));
    expect(status.database, equals('YASIN_WORKSHOP_ES_VALIDATION'));
    expect(status.guarded, isTrue);
    expect(status.operationReady, isTrue);
  });

  test('Customer API config exposes the real customer endpoint paths', () {
    const config = AppConfig(
      baseUrl: 'https://localhost:7262',
      defaultUserName: 'admin',
    );

    expect(config.customersUrl, equals('https://localhost:7262/api/customers'));
    expect(config.defaultUserName, equals('admin'));
  });

  test('Customer model parses the backend JSON contract', () {
    final customer = Customer.fromJson({
      'Id': '11111111-1111-1111-1111-111111111111',
      'Name': 'شركة النور',
      'ContactName': 'أحمد',
      'Phone': '0500000000',
      'WhatsApp': '0500000000',
      'Email': 'ahmed@example.com',
      'RelationshipType': 'Wholesale',
      'DeliveryLocation': 'الرياض',
      'Status': 'Active',
      'IsArchived': false,
      'Notes': 'عميل ثابت',
      'CreatedAt': '2024-01-01T00:00:00Z',
      'UpdatedAt': '2024-01-02T00:00:00Z',
    });

    expect(customer.id, equals('11111111-1111-1111-1111-111111111111'));
    expect(customer.name, equals('شركة النور'));
    expect(customer.status, equals('Active'));
    expect(customer.isArchived, isFalse);
  });

  test(
    'Customer API service reads customer list from the backend contract',
    () async {
      final client = _FakeClient({
        'https://localhost:7262/api/customers': jsonEncode([
          {
            'Id': '11111111-1111-1111-1111-111111111111',
            'Name': 'شركة النور',
            'ContactName': 'أحمد',
            'Phone': '0500000000',
            'WhatsApp': '0500000000',
            'Email': 'ahmed@example.com',
            'RelationshipType': 'Wholesale',
            'DeliveryLocation': 'الرياض',
            'Status': 'Active',
            'IsArchived': false,
            'Notes': 'عميل ثابت',
            'CreatedAt': '2024-01-01T00:00:00Z',
            'UpdatedAt': '2024-01-02T00:00:00Z',
          },
        ]),
      });

      final service = CustomerApiService(
        config: const AppConfig(
          baseUrl: 'https://localhost:7262',
          defaultUserName: 'admin',
        ),
        client: client,
      );

      final customers = await service.fetchCustomers();

      expect(customers, hasLength(1));
      expect(customers.first.name, equals('شركة النور'));
      expect(customers.first.status, equals('Active'));
    },
  );

  test('Employee API config exposes the real employee endpoint paths', () {
    const config = AppConfig(
      baseUrl: 'https://localhost:7262',
      defaultUserName: 'admin',
    );

    expect(config.employeesUrl, equals('https://localhost:7262/api/employees'));
    expect(config.defaultUserName, equals('admin'));
  });

  test('Employee model parses the backend JSON contract', () {
    final employee = Employee.fromJson({
      'Id': '22222222-2222-2222-2222-222222222222',
      'EmployeeCode': 'EMP-001',
      'Name': 'سعد الأحمد',
      'Phone': '0550000000',
      'WhatsApp': '0550000000',
      'Email': 'saad@example.com',
      'EmployeeType': 'Piece',
      'Status': 'Active',
      'IsArchived': false,
      'StartDate': '2024-01-01T00:00:00Z',
      'EndDate': null,
      'Notes': 'موظف ثابت',
      'CreatedAt': '2024-01-01T00:00:00Z',
      'UpdatedAt': '2024-01-02T00:00:00Z',
    });

    expect(employee.id, equals('22222222-2222-2222-2222-222222222222'));
    expect(employee.employeeCode, equals('EMP-001'));
    expect(employee.name, equals('سعد الأحمد'));
    expect(employee.status, equals('Active'));
    expect(employee.employeeType, equals('Piece'));
  });

  test(
    'Employee API service reads employee list from the backend contract',
    () async {
      final client = _FakeClient({
        'https://localhost:7262/api/employees': jsonEncode([
          {
            'Id': '22222222-2222-2222-2222-222222222222',
            'EmployeeCode': 'EMP-001',
            'Name': 'سعد الأحمد',
            'Phone': '0550000000',
            'WhatsApp': '0550000000',
            'Email': 'saad@example.com',
            'EmployeeType': 'Piece',
            'Status': 'Active',
            'IsArchived': false,
            'StartDate': '2024-01-01T00:00:00Z',
            'EndDate': null,
            'Notes': 'موظف ثابت',
            'CreatedAt': '2024-01-01T00:00:00Z',
            'UpdatedAt': '2024-01-02T00:00:00Z',
          },
        ]),
      });

      final service = EmployeeApiService(
        config: const AppConfig(
          baseUrl: 'https://localhost:7262',
          defaultUserName: 'admin',
        ),
        client: client,
      );

      final employees = await service.fetchEmployees();

      expect(employees, hasLength(1));
      expect(employees.first.name, equals('سعد الأحمد'));
      expect(employees.first.employeeCode, equals('EMP-001'));
    },
  );

  testWidgets('Employee module shows empty state for no employees', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        home: EmployeeModuleView(apiService: _FakeEmployeeApiService(const [])),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('إدارة الموظفين'), findsOneWidget);
    expect(find.text('لا توجد موظفين في الخادم الآن.'), findsOneWidget);
  });

  testWidgets('Employee module shows error state when backend fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        home: EmployeeModuleView(
          apiService: _FakeEmployeeApiService.error('فشل الخادم'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('تعذر الاتصال بالخادم. حاول مرة أخرى.'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
  });

  testWidgets('Shell renders Arabic operational navigation destinations', (
    tester,
  ) async {
    await tester.pumpWidget(const YasinWorkshopApp());

    expect(find.text('معمل ياسين'), findsOneWidget);
    expect(find.text('العملاء'), findsOneWidget);
    expect(find.text('الموظفون'), findsOneWidget);
    expect(find.text('الموردون'), findsOneWidget);
    expect(find.text('الرسائل'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Navigation moves to the employee screen in the RTL shell', (
    tester,
  ) async {
    await tester.pumpWidget(const YasinWorkshopApp());

    await tester.tap(find.text('الموظفون'));
    await tester.pump();

    expect(find.text('إدارة الموظفين'), findsOneWidget);
    expect(find.byType(Directionality), findsOneWidget);
  });

  testWidgets('Customer error state hides raw backend details and offers retry', (
    tester,
  ) async {
    final offlineService = CustomerOfflineService(
      store: _TestCustomerOfflineStore(),
    );
    addTearDown(() async {
      await offlineService.close();
    });

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        home: CustomerModuleView(
          apiService: _FailingCustomerApiService(),
          offlineService: offlineService,
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('تعذر الاتصال بالخادم. حاول مرة أخرى.'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);
    expect(find.textContaining('Exception:'), findsNothing);
    expect(find.textContaining('SocketException'), findsNothing);
    expect(find.textContaining('StackTrace'), findsNothing);
  });

  testWidgets(
    'Employee editor validates required fields and blocks repeated saves',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: EmployeeEditorDialog(
            apiService: _FakeEmployeeApiService(const []),
            mode: EmployeeEditorMode.create,
          ),
        ),
      );

      await tester.tap(find.text('حفظ'));
      await tester.pump();

      expect(find.text('رمز الموظف مطلوب'), findsOneWidget);
      expect(find.text('اسم الموظف مطلوب'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(0), 'EMP-100');
      await tester.enterText(find.byType(TextFormField).at(1), 'علي السالم');
      await tester.tap(find.text('حفظ'));
      await tester.pump();

      expect(find.text('جارٍ الحفظ...'), findsOneWidget);
    },
  );
}

class _TestCustomerOfflineStore extends LocalSqliteStore {
  _TestCustomerOfflineStore() : super(databasePath: 'test_customer_offline_store.db');

  @override
  Future<List<LocalCustomerRecord>> getLocalCustomers() async => const [];

  @override
  Future<void> deleteAll() async {}

  @override
  Future<void> close() async {}
}

class _FailingCustomerApiService extends CustomerApiService {
  _FailingCustomerApiService()
    : super(
        config: const AppConfig(
          baseUrl: 'https://localhost:7262',
          defaultUserName: 'admin',
        ),
      );

  @override
  Future<List<Customer>> fetchCustomers({String? search, String? status}) async {
    return Future<List<Customer>>.error(
      Exception('Connection failed while contacting customer backend.'),
    );
  }
}

class _FakeEmployeeApiService implements EmployeeApiServiceContract {
  _FakeEmployeeApiService(this._employees, {Duration? delay})
    : errorMessage = null,
      _delay = delay ?? Duration.zero;

  factory _FakeEmployeeApiService.error(String? errorMessage) {
    final service = _FakeEmployeeApiService(const []);
    service.errorMessage = errorMessage;
    return service;
  }

  final List<Employee> _employees;
  String? errorMessage;
  final Duration _delay;

  @override
  Future<List<Employee>> fetchEmployees() async {
    if (_delay > Duration.zero) {
      await Future<void>.delayed(_delay);
    }
    if (errorMessage != null) {
      throw Exception(errorMessage);
    }
    return _employees;
  }

  @override
  Future<Employee> fetchEmployee(String id) async {
    if (_delay > Duration.zero) {
      await Future<void>.delayed(_delay);
    }
    if (errorMessage != null) {
      throw Exception(errorMessage);
    }
    for (final employee in _employees) {
      if (employee.id == id) {
        return employee;
      }
    }
    throw Exception('Employee not found');
  }

  @override
  Future<Employee> createEmployee(EmployeeDraft draft) async {
    if (_delay > Duration.zero) {
      await Future<void>.delayed(_delay);
    }
    if (errorMessage != null) {
      throw Exception(errorMessage);
    }
    return Employee(
      id: 'employee-1',
      employeeCode: draft.employeeCode,
      name: draft.name,
      phone: draft.phone,
      whatsApp: draft.whatsApp,
      email: draft.email,
      employeeType: draft.employeeType,
      status: draft.status,
      isArchived: draft.isArchived,
      startDate: draft.startDate,
      endDate: draft.endDate,
      notes: draft.notes,
    );
  }

  @override
  Future<Employee> updateEmployee(String id, EmployeeDraft draft) async {
    if (_delay > Duration.zero) {
      await Future<void>.delayed(_delay);
    }
    if (errorMessage != null) {
      throw Exception(errorMessage);
    }
    return Employee(
      id: id,
      employeeCode: draft.employeeCode,
      name: draft.name,
      phone: draft.phone,
      whatsApp: draft.whatsApp,
      email: draft.email,
      employeeType: draft.employeeType,
      status: draft.status,
      isArchived: draft.isArchived,
      startDate: draft.startDate,
      endDate: draft.endDate,
      notes: draft.notes,
    );
  }
}

class _FakeClient extends http.BaseClient {
  _FakeClient(this._responses);

  final Map<String, String> _responses;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = _responses[request.url.toString()];
    if (body == null) {
      throw Exception('Unexpected URL: ${request.url}');
    }

    final response = http.Response.bytes(
      utf8.encode(body),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

class _CapturingSyncClient extends http.BaseClient {
  http.BaseRequest? lastRequest;
  String? lastBody;
  Map<String, String>? lastHeaders;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    lastHeaders = request.headers;
    lastBody = await http.ByteStream(request.finalize()).bytesToString();

    final responseBody = jsonEncode({
      'isSuccess': true,
      'resultCode': 'created',
      'message': 'Customer created successfully.',
      'serverVersion': '2026-11-08T00:00:00.000Z',
    });

    return http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}
