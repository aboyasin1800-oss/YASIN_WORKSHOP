import 'package:flutter_test/flutter_test.dart';
import 'package:yasin_workshop_mobile/core/offline/local_sync_store.dart';
import 'package:yasin_workshop_mobile/core/offline/offline_foundation.dart';
import 'package:yasin_workshop_mobile/core/offline/sync_models.dart';
import 'package:yasin_workshop_mobile/features/customers/services/customer_offline_service.dart';

void main() {
  group('offline-first customer store', () {
    test('persists outbox operations and keeps state after reopen', () async {
      final dbPath = await LocalSqliteStore.createTestDatabasePath();
      final store = LocalSqliteStore(databasePath: dbPath);
      await store.deleteAll();

      final operation = SyncOutboxOperation(
        operationId: 'op-1',
        entityType: 'customer',
        entityId: 'cust-1',
        operationType: SyncOperationType.create,
        payload: '{"name":"شركة النور"}',
        createdAt: DateTime.utc(2025, 1, 1),
        attemptCount: 0,
        syncState: SyncState.pending,
        idempotencyKey: 'idem-1',
      );

      await store.saveOutboxOperation(operation);
      final pending = await store.getPendingOperations();

      expect(pending, hasLength(1));
      expect(pending.first.syncState, SyncState.pending);

      await store.close();

      final reopened = LocalSqliteStore(databasePath: dbPath);
      final afterRestart = await reopened.getPendingOperations();
      expect(afterRestart, hasLength(1));
      expect(afterRestart.first.idempotencyKey, 'idem-1');
      await reopened.close();
    });

    test(
      'customer offline service saves a local record and marks it pending',
      () async {
        final dbPath = await LocalSqliteStore.createTestDatabasePath();
        final service = CustomerOfflineService(databasePath: dbPath);
        await service.clear();

        final customer = await service.saveCustomerOffline(
          id: 'customer-local-1',
          name: 'عميل محلي',
          contactName: 'أحمد',
          email: 'ahmed@example.com',
        );

        expect(customer.name, 'عميل محلي');
        expect(customer.syncState, SyncState.pending);
        expect(await service.getPendingCustomers(), hasLength(1));

        await service.close();
      },
    );

    test('shared offline foundation keeps operations across restart', () async {
      final dbPath = await LocalSqliteStore.createTestDatabasePath();
      final store = LocalSqliteStore(databasePath: dbPath);
      final foundation = OfflineFoundation(store: store);

      final operationId = await foundation.enqueueOperation(
        entityType: 'supplier',
        entityId: 'supplier-1',
        operationType: 'create',
        payload: {'name': 'مورد محلي'},
        baseVersion: 'v0',
      );

      expect(operationId, isNotEmpty);
      expect(await foundation.getPendingOperations(), hasLength(1));

      await store.close();

      final reopened = LocalSqliteStore(databasePath: dbPath);
      final reopenedFoundation = OfflineFoundation(store: reopened);
      final afterRestart = await reopenedFoundation.getPendingOperations();

      expect(afterRestart, hasLength(1));
      expect(afterRestart.first.entityType, 'supplier');
      expect(afterRestart.first.syncState, SyncState.pending);

      await reopened.close();
    });
  });
}
