import 'dart:convert';

import '../../../core/offline/local_sync_store.dart';
import '../../../core/offline/offline_foundation.dart';
import '../../../core/offline/sync_models.dart';
import '../models/employee.dart';

class EmployeeLocalRecord {
  EmployeeLocalRecord({
    required this.id,
    required this.employeeCode,
    required this.name,
    this.phone,
    this.whatsApp,
    this.email,
    required this.employeeType,
    required this.status,
    required this.isArchived,
    this.startDate,
    this.endDate,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
  });

  final String id;
  final String employeeCode;
  final String name;
  final String? phone;
  final String? whatsApp;
  final String? email;
  final String employeeType;
  final String status;
  final bool isArchived;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncState syncState;

  factory EmployeeLocalRecord.fromMap(Map<String, dynamic> map) {
    return EmployeeLocalRecord(
      id: map['id'] as String,
      employeeCode: map['employee_code'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phone: map['phone'] as String?,
      whatsApp: map['whats_app'] as String?,
      email: map['email'] as String?,
      employeeType: map['employee_type'] as String? ?? 'Piece',
      status: map['status'] as String? ?? 'Active',
      isArchived: (map['is_archived'] as int?) == 1,
      startDate: _parseDate(map['start_date']),
      endDate: _parseDate(map['end_date']),
      notes: map['notes'] as String?,
      createdAt: _parseDate(map['created_at']) ?? DateTime.now().toUtc(),
      updatedAt: _parseDate(map['updated_at']) ?? DateTime.now().toUtc(),
      syncState: SyncState.values.firstWhere(
        (value) => value.name == (map['sync_state'] as String? ?? SyncState.pending.name),
        orElse: () => SyncState.pending,
      ),
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}

class EmployeeOfflineService {
  EmployeeOfflineService({LocalSqliteStore? store, OfflineFoundation? foundation})
      : _store = store ?? LocalSqliteStore() {
    _foundation = foundation ?? OfflineFoundation(store: _store);
  }

  final LocalSqliteStore _store;
  late final OfflineFoundation _foundation;

  Future<Employee> saveEmployeeOffline(EmployeeDraft draft) async {
    final now = DateTime.now().toUtc();
    final employee = Employee(
      id: 'employee-offline-${now.microsecondsSinceEpoch}',
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
      createdAt: now,
      updatedAt: now,
    );

    await _store.saveLocalEntity(
      'employee',
      employee.employeeCode,
      {
        'id': employee.id,
        'employeeCode': employee.employeeCode,
        'name': employee.name,
        'phone': employee.phone,
        'whatsApp': employee.whatsApp,
        'email': employee.email,
        'employeeType': employee.employeeType,
        'status': employee.status,
        'isArchived': employee.isArchived,
        'startDate': employee.startDate?.toUtc().toIso8601String(),
        'endDate': employee.endDate?.toUtc().toIso8601String(),
        'notes': employee.notes,
        'createdAt': employee.createdAt?.toUtc().toIso8601String(),
        'updatedAt': employee.updatedAt?.toUtc().toIso8601String(),
      },
      id: employee.id,
      createdAt: now,
      updatedAt: now,
      syncState: SyncState.pending,
    );

    await _foundation.enqueueOperation(
      entityType: 'employee',
      entityId: employee.id,
      operationType: 'create',
      payload: {
        'id': employee.id,
        'employeeCode': employee.employeeCode,
        'name': employee.name,
        'phone': employee.phone,
        'whatsApp': employee.whatsApp,
        'email': employee.email,
        'employeeType': employee.employeeType,
        'status': employee.status,
        'isArchived': employee.isArchived,
        'startDate': employee.startDate?.toUtc().toIso8601String(),
        'endDate': employee.endDate?.toUtc().toIso8601String(),
        'notes': employee.notes,
      },
      baseVersion: '',
      correlationId: 'employee-${employee.id}',
      idempotencyKey: 'employee-${employee.employeeCode}-${now.microsecondsSinceEpoch}',
    );

    return employee;
  }

  Future<List<Employee>> getLocalEmployees() async {
    final rows = await _store.getLocalEntities('employee');
    return rows
        .map((row) {
          final payload = jsonDecode(row['payload'] as String) as Map<String, dynamic>;
          return Employee.fromJson(payload);
        })
        .toList(growable: false);
  }

  Future<List<SyncOutboxOperation>> getPendingOperations() async {
    return _foundation.getPendingOperations(entityType: 'employee');
  }

  Future<void> clear() async {
    await _store.deleteAll();
  }

  Future<void> close() async {
    await _store.close();
  }
}
