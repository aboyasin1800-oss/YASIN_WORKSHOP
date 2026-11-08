import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../../core/offline/local_sync_store.dart';
import '../../../core/offline/sync_models.dart';
import '../models/customer.dart';

class CustomerOfflineService {
  CustomerOfflineService({String? databasePath, LocalSqliteStore? store})
    : _store =
          store ??
          LocalSqliteStore(
            databasePath: databasePath ?? 'yasin_workshop_customer_local.db',
          );

  final LocalSqliteStore _store;

  Future<void> clear() async {
    await _store.deleteAll();
  }

  Future<Customer> saveCustomerOffline({
    required String id,
    required String name,
    String? contactName,
    String? phone,
    String? email,
    String relationshipType = 'Wholesale',
    String? deliveryLocation,
    String status = 'Active',
    bool isArchived = false,
    String? notes,
  }) async {
    final now = DateTime.now().toUtc();
    final customer = Customer(
      id: id,
      name: name,
      contactName: contactName,
      phone: phone,
      whatsApp: null,
      email: email,
      relationshipType: relationshipType,
      deliveryLocation: deliveryLocation,
      status: status,
      isArchived: isArchived,
      notes: notes,
      createdAt: now,
      updatedAt: now,
      syncState: SyncState.pending,
    );

    final record = LocalCustomerRecord(
      id: customer.id,
      name: customer.name,
      contactName: customer.contactName,
      phone: customer.phone,
      email: customer.email,
      relationshipType: customer.relationshipType,
      deliveryLocation: customer.deliveryLocation,
      status: customer.status,
      isArchived: customer.isArchived,
      notes: customer.notes,
      createdAt: now,
      updatedAt: now,
      syncState: SyncState.pending,
    );

    await _store.saveLocalCustomerRecord(record);
    await _store.saveOutboxOperation(
      SyncOutboxOperation(
        operationId: 'offline-${customer.id}-${now.millisecondsSinceEpoch}',
        entityType: 'customer',
        entityId: customer.id,
        operationType: SyncOperationType.create,
        payload: jsonEncode({
          'id': customer.id,
          'name': customer.name,
          'contactName': customer.contactName,
          'phone': customer.phone,
          'email': customer.email,
          'relationshipType': customer.relationshipType,
          'deliveryLocation': customer.deliveryLocation,
          'status': customer.status,
          'isArchived': customer.isArchived,
          'notes': customer.notes,
        }),
        createdAt: now,
        attemptCount: 0,
        syncState: SyncState.pending,
        idempotencyKey: 'offline-${customer.id}-${now.millisecondsSinceEpoch}',
      ),
    );

    return customer;
  }

  Future<List<Customer>> getPendingCustomers() async {
    final records = await _store.getLocalCustomers();
    return records
        .where((record) => record.syncState == SyncState.pending)
        .map(
          (record) => Customer(
            id: record.id,
            name: record.name,
            contactName: record.contactName,
            phone: record.phone,
            whatsApp: null,
            email: record.email,
            relationshipType: record.relationshipType,
            deliveryLocation: record.deliveryLocation,
            status: record.status,
            isArchived: record.isArchived,
            notes: record.notes,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
            syncState: record.syncState,
          ),
        )
        .toList(growable: false);
  }

  Future<int> pushPendingCustomers({
    required String baseUrl,
    String userName = 'customer-sync-proof-user',
    http.Client? client,
  }) async {
    final clientToUse = client ?? http.Client();
    final operations = await _store.getPendingOperations();
    var syncCount = 0;

    for (final operation in operations) {
      final payloadMap = jsonDecode(operation.payload) as Map<String, dynamic>;
      final requestBody = {
        'operationId': _newGuid(),
        'clientId': _newGuid(),
        'entityType': operation.entityType,
        'entityId': operation.entityId,
        'operationType': operation.operationType.name,
        'payload': jsonEncode(payloadMap),
        'baseVersion': '',
        'idempotencyKey': operation.idempotencyKey,
      };

      final response = await clientToUse
          .post(
            Uri.parse('$baseUrl/api/customer-sync/push'),
            headers: {
              'Content-Type': 'application/json',
              'X-User-Name': userName,
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 8));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await _store.deleteOutboxOperation(operation.operationId);
        syncCount += 1;
      } else {
        await _store.updateOutboxOperationState(
          operation.operationId,
          SyncState.failed,
          lastError: response.body,
        );
      }
    }

    return syncCount;
  }

  static String _newGuid() {
    final random = Random();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    values[6] = (values[6] & 0x0F) | 0x40;
    values[8] = (values[8] & 0x3F) | 0x80;

    final hex = values.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  Future<List<Customer>> getLocalCustomers() async {
    final records = await _store.getLocalCustomers();
    return records
        .map(
          (record) => Customer(
            id: record.id,
            name: record.name,
            contactName: record.contactName,
            phone: record.phone,
            whatsApp: null,
            email: record.email,
            relationshipType: record.relationshipType,
            deliveryLocation: record.deliveryLocation,
            status: record.status,
            isArchived: record.isArchived,
            notes: record.notes,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
            syncState: record.syncState,
          ),
        )
        .toList(growable: false);
  }

  Future<void> close() async {
    await _store.close();
  }
}
