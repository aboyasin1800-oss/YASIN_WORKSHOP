import 'dart:convert';

import '../../../core/offline/local_sync_store.dart';
import '../../../core/offline/offline_foundation.dart';
import '../../../core/offline/sync_models.dart';

class EmployeeProductionLocalRecord {
  EmployeeProductionLocalRecord({
    required this.id,
    required this.employeeId,
    required this.operationDate,
    required this.quantity,
    required this.resolvedUnitRate,
    required this.calculatedAmount,
    required this.createdBy,
    this.notes,
    required this.firstSavedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
  });

  final String id;
  final String employeeId;
  final DateTime operationDate;
  final double quantity;
  final double resolvedUnitRate;
  final double calculatedAmount;
  final String createdBy;
  final String? notes;
  final DateTime firstSavedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncState syncState;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'operationDate': operationDate.toUtc().toIso8601String(),
      'quantity': quantity,
      'resolvedUnitRate': resolvedUnitRate,
      'calculatedAmount': calculatedAmount,
      'createdBy': createdBy,
      'notes': notes,
      'firstSavedAt': firstSavedAt.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'syncState': syncState.name,
    };
  }

  factory EmployeeProductionLocalRecord.fromJson(Map<String, dynamic> json) {
    final createdAt = _dateTime(json['createdAt'] ?? json['created_at']) ?? DateTime.now().toUtc();
    final updatedAt = _dateTime(json['updatedAt'] ?? json['updated_at']) ?? createdAt;
    final firstSavedAt = _dateTime(json['firstSavedAt'] ?? json['first_saved_at']) ?? createdAt;
    final operationDate = _dateTime(json['operationDate'] ?? json['operation_date']) ?? createdAt;

    return EmployeeProductionLocalRecord(
      id: (json['id'] ?? '').toString(),
      employeeId: (json['employeeId'] ?? json['employee_id'] ?? '').toString(),
      operationDate: operationDate,
      quantity: _doubleValue(json['quantity']),
      resolvedUnitRate: _doubleValue(json['resolvedUnitRate'] ?? json['resolved_unit_rate']),
      calculatedAmount: _doubleValue(json['calculatedAmount'] ?? json['calculated_amount']),
      createdBy: (json['createdBy'] ?? json['created_by'] ?? 'system').toString(),
      notes: json['notes'] == null ? null : json['notes'].toString(),
      firstSavedAt: firstSavedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncState: _syncState(json['syncState'] ?? json['sync_state']),
    );
  }

  static DateTime? _dateTime(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static double _doubleValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value == null) {
      return 0;
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  static SyncState _syncState(Object? value) {
    final name = value?.toString() ?? SyncState.pending.name;
    return SyncState.values.firstWhere(
      (state) => state.name == name,
      orElse: () => SyncState.pending,
    );
  }
}

class EmployeeExpenseLocalRecord {
  EmployeeExpenseLocalRecord({
    required this.id,
    required this.employeeId,
    required this.operationDate,
    required this.amount,
    required this.createdBy,
    this.notes,
    required this.firstSavedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
  });

  final String id;
  final String employeeId;
  final DateTime operationDate;
  final double amount;
  final String createdBy;
  final String? notes;
  final DateTime firstSavedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncState syncState;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'operationDate': operationDate.toUtc().toIso8601String(),
      'amount': amount,
      'createdBy': createdBy,
      'notes': notes,
      'firstSavedAt': firstSavedAt.toUtc().toIso8601String(),
      'createdAt': createdAt.toUtc().toIso8601String(),
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'syncState': syncState.name,
    };
  }

  factory EmployeeExpenseLocalRecord.fromJson(Map<String, dynamic> json) {
    final createdAt = _dateTime(json['createdAt'] ?? json['created_at']) ?? DateTime.now().toUtc();
    final updatedAt = _dateTime(json['updatedAt'] ?? json['updated_at']) ?? createdAt;
    final firstSavedAt = _dateTime(json['firstSavedAt'] ?? json['first_saved_at']) ?? createdAt;
    final operationDate = _dateTime(json['operationDate'] ?? json['operation_date']) ?? createdAt;

    return EmployeeExpenseLocalRecord(
      id: (json['id'] ?? '').toString(),
      employeeId: (json['employeeId'] ?? json['employee_id'] ?? '').toString(),
      operationDate: operationDate,
      amount: _doubleValue(json['amount']),
      createdBy: (json['createdBy'] ?? json['created_by'] ?? 'system').toString(),
      notes: json['notes'] == null ? null : json['notes'].toString(),
      firstSavedAt: firstSavedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      syncState: _syncState(json['syncState'] ?? json['sync_state']),
    );
  }

  static DateTime? _dateTime(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static double _doubleValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value == null) {
      return 0;
    }
    return double.tryParse(value.toString()) ?? 0;
  }

  static SyncState _syncState(Object? value) {
    final name = value?.toString() ?? SyncState.pending.name;
    return SyncState.values.firstWhere(
      (state) => state.name == name,
      orElse: () => SyncState.pending,
    );
  }
}

class EmployeeFinancialOfflineService {
  EmployeeFinancialOfflineService({LocalSqliteStore? store, OfflineFoundation? foundation})
      : _store = store ?? LocalSqliteStore() {
    _foundation = foundation ?? OfflineFoundation(store: _store);
  }

  final LocalSqliteStore _store;
  late final OfflineFoundation _foundation;

  Future<EmployeeProductionLocalRecord> saveProductionOffline({
    required String employeeId,
    required DateTime operationDate,
    required double quantity,
    required double resolvedUnitRate,
    required String createdBy,
    String? notes,
    DateTime? firstSavedAt,
  }) async {
    final now = DateTime.now().toUtc();
    final safeFirstSavedAt = (firstSavedAt ?? now).toUtc();
    final id = 'employee-production-${employeeId}-${now.microsecondsSinceEpoch}';
    final payload = {
      'id': id,
      'employeeId': employeeId,
      'operationDate': operationDate.toUtc().toIso8601String(),
      'quantity': quantity,
      'resolvedUnitRate': resolvedUnitRate,
      'calculatedAmount': quantity * resolvedUnitRate,
      'createdBy': createdBy,
      'notes': notes,
      'firstSavedAt': safeFirstSavedAt.toIso8601String(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'syncState': SyncState.pending.name,
    };

    await _store.saveLocalEntity(
      'employee-production',
      employeeId,
      payload,
      id: id,
      createdAt: now,
      updatedAt: now,
      syncState: SyncState.pending,
    );

    await _foundation.enqueueOperation(
      entityType: 'employee-production',
      entityId: id,
      operationType: 'create',
      payload: payload,
      correlationId: 'employee-production-$id',
      idempotencyKey: 'employee-production-$id',
    );

    return EmployeeProductionLocalRecord(
      id: id,
      employeeId: employeeId,
      operationDate: operationDate.toUtc(),
      quantity: quantity,
      resolvedUnitRate: resolvedUnitRate,
      calculatedAmount: quantity * resolvedUnitRate,
      createdBy: createdBy,
      notes: notes,
      firstSavedAt: safeFirstSavedAt,
      createdAt: now,
      updatedAt: now,
      syncState: SyncState.pending,
    );
  }

  Future<EmployeeExpenseLocalRecord> saveExpenseOffline({
    required String employeeId,
    required DateTime operationDate,
    required double amount,
    required String createdBy,
    String? notes,
    DateTime? firstSavedAt,
  }) async {
    final now = DateTime.now().toUtc();
    final safeFirstSavedAt = (firstSavedAt ?? now).toUtc();
    final id = 'employee-expense-${employeeId}-${now.microsecondsSinceEpoch}';
    final payload = {
      'id': id,
      'employeeId': employeeId,
      'operationDate': operationDate.toUtc().toIso8601String(),
      'amount': amount,
      'createdBy': createdBy,
      'notes': notes,
      'firstSavedAt': safeFirstSavedAt.toIso8601String(),
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'syncState': SyncState.pending.name,
    };

    await _store.saveLocalEntity(
      'employee-expense',
      employeeId,
      payload,
      id: id,
      createdAt: now,
      updatedAt: now,
      syncState: SyncState.pending,
    );

    await _foundation.enqueueOperation(
      entityType: 'employee-expense',
      entityId: id,
      operationType: 'create',
      payload: payload,
      correlationId: 'employee-expense-$id',
      idempotencyKey: 'employee-expense-$id',
    );

    return EmployeeExpenseLocalRecord(
      id: id,
      employeeId: employeeId,
      operationDate: operationDate.toUtc(),
      amount: amount,
      createdBy: createdBy,
      notes: notes,
      firstSavedAt: safeFirstSavedAt,
      createdAt: now,
      updatedAt: now,
      syncState: SyncState.pending,
    );
  }

  Future<List<EmployeeProductionLocalRecord>> getLocalProduction() async {
    final rows = await _store.getLocalEntities('employee-production');
    return rows
        .map((row) {
          final payload = jsonDecode(row['payload'] as String) as Map<String, dynamic>;
          return EmployeeProductionLocalRecord.fromJson(payload);
        })
        .toList(growable: false);
  }

  Future<List<EmployeeExpenseLocalRecord>> getLocalExpenses() async {
    final rows = await _store.getLocalEntities('employee-expense');
    return rows
        .map((row) {
          final payload = jsonDecode(row['payload'] as String) as Map<String, dynamic>;
          return EmployeeExpenseLocalRecord.fromJson(payload);
        })
        .toList(growable: false);
  }

  Future<List<SyncOutboxOperation>> getPendingProduction() async {
    return _foundation.getPendingOperations(entityType: 'employee-production');
  }

  Future<List<SyncOutboxOperation>> getPendingExpenses() async {
    return _foundation.getPendingOperations(entityType: 'employee-expense');
  }

  Future<void> clear() async {
    await _store.deleteAll();
  }

  Future<void> close() async {
    await _store.close();
  }
}
