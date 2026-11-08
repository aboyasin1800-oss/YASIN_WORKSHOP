import 'dart:io';

import 'local_sync_store.dart';
import 'sync_models.dart';

enum OfflineConnectivityStatus { online, offline, unknown }

abstract class OfflineModuleAdapter {
  String get moduleName;

  String get entityType;

  Future<List<SyncOutboxOperation>> loadPendingOperations(
    LocalSqliteStore store,
  ) async {
    return store.getPendingOperations();
  }

  Future<void> markOperationState(
    LocalSqliteStore store,
    String operationId,
    SyncState state, {
    String? lastError,
  }) async {
    await store.updateOutboxOperationState(operationId, state, lastError: lastError);
  }
}

class OfflineFoundation {
  OfflineFoundation({LocalSqliteStore? store}) : _store = store ?? LocalSqliteStore();

  final LocalSqliteStore _store;

  Future<String> enqueueOperation({
    required String entityType,
    required String entityId,
    required String operationType,
    required Map<String, dynamic> payload,
    String? baseVersion,
    String? correlationId,
    String? idempotencyKey,
  }) async {
    final now = DateTime.now().toUtc();
    final operationId = idempotencyKey ?? _createOperationId(entityType, entityId, operationType, now);
    final normalizedIdempotencyKey = idempotencyKey ?? operationId;

    final operation = SyncOutboxOperation(
      operationId: operationId,
      entityType: entityType,
      entityId: entityId,
      operationType: SyncOperationType.values.firstWhere(
        (value) => value.name == operationType,
        orElse: () => SyncOperationType.create,
      ),
      payload: _encodePayload(payload, baseVersion),
      createdAt: now,
      attemptCount: 0,
      syncState: SyncState.pending,
      idempotencyKey: normalizedIdempotencyKey,
      correlationId: correlationId,
    );

    await _store.saveOutboxOperation(operation);
    return operationId;
  }

  Future<List<SyncOutboxOperation>> getPendingOperations({String? entityType}) async {
    final pending = await _store.getPendingOperations();
    if (entityType == null || entityType.isEmpty) {
      return pending;
    }
    return pending.where((item) => item.entityType == entityType).toList();
  }

  Future<void> updateOperationState(
    String operationId,
    SyncState state, {
    String? lastError,
  }) async {
    await _store.updateOutboxOperationState(operationId, state, lastError: lastError);
  }

  Future<void> recordConflict({
    required String entityType,
    required String entityId,
    required String localVersion,
    required String serverVersion,
    required String conflictDetails,
  }) async {
    final conflict = SyncConflict(
      entityType: entityType,
      entityId: entityId,
      localVersion: localVersion,
      serverVersion: serverVersion,
      conflictDetails: conflictDetails,
      createdAt: DateTime.now().toUtc(),
    );

    await _store.saveConflict(conflict);
  }

  Future<List<SyncConflict>> getConflicts() async {
    return _store.getConflictRecords();
  }

  Future<OfflineConnectivityStatus> probeConnectivity() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty) {
        return OfflineConnectivityStatus.online;
      }
      return OfflineConnectivityStatus.offline;
    } on SocketException {
      return OfflineConnectivityStatus.offline;
    } catch (_) {
      return OfflineConnectivityStatus.unknown;
    }
  }

  static String _createOperationId(
    String entityType,
    String entityId,
    String operationType,
    DateTime createdAt,
  ) {
    final suffix = createdAt.microsecondsSinceEpoch.toString();
    return '${entityType}-${entityId}-${operationType}-${suffix}';
  }

  static String _encodePayload(Map<String, dynamic> payload, String? baseVersion) {
    final encoded = Map<String, dynamic>.from(payload);
    if (baseVersion != null && baseVersion.isNotEmpty) {
      encoded['baseVersion'] = baseVersion;
    }
    return encoded.toString();
  }
}
