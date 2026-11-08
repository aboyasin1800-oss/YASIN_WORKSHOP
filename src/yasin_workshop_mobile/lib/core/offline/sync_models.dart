enum SyncState { pending, syncing, synced, failed, conflict, tombstoned }

enum SyncOperationType { create, update, delete, upsert, messageSend }

class SyncOutboxOperation {
  SyncOutboxOperation({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payload,
    required this.createdAt,
    required this.attemptCount,
    required this.syncState,
    required this.idempotencyKey,
    this.correlationId,
    this.lastError,
  });

  final String operationId;
  final String entityType;
  final String entityId;
  final SyncOperationType operationType;
  final String payload;
  final DateTime createdAt;
  final int attemptCount;
  final SyncState syncState;
  final String idempotencyKey;
  final String? correlationId;
  final String? lastError;

  Map<String, Object?> toMap() {
    return {
      'operation_id': operationId,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation_type': operationType.name,
      'payload': payload,
      'created_at': createdAt.toUtc().toIso8601String(),
      'attempt_count': attemptCount,
      'sync_state': syncState.name,
      'idempotency_key': idempotencyKey,
      'correlation_id': correlationId,
      'last_error': lastError,
    };
  }

  factory SyncOutboxOperation.fromMap(Map<String, dynamic> map) {
    return SyncOutboxOperation(
      operationId: map['operation_id'] as String,
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as String,
      operationType: SyncOperationType.values.firstWhere(
        (value) => value.name == map['operation_type'],
        orElse: () => SyncOperationType.create,
      ),
      payload: map['payload'] as String? ?? '',
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      attemptCount: map['attempt_count'] as int? ?? 0,
      syncState: SyncState.values.firstWhere(
        (value) => value.name == map['sync_state'],
        orElse: () => SyncState.pending,
      ),
      idempotencyKey: map['idempotency_key'] as String? ?? '',
      correlationId: map['correlation_id'] as String?,
      lastError: map['last_error'] as String?,
    );
  }
}

class SyncConflict {
  SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localVersion,
    required this.serverVersion,
    required this.conflictDetails,
    required this.createdAt,
  });

  final String entityType;
  final String entityId;
  final String localVersion;
  final String serverVersion;
  final String conflictDetails;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'entity_type': entityType,
      'entity_id': entityId,
      'local_version': localVersion,
      'server_version': serverVersion,
      'conflict_details': conflictDetails,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
