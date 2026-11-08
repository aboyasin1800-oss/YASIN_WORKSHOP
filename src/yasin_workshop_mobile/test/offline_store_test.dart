import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:yasin_workshop_mobile/core/offline/local_sync_store.dart';
import 'package:yasin_workshop_mobile/core/offline/offline_foundation.dart';
import 'package:yasin_workshop_mobile/core/offline/sync_models.dart';
import 'package:yasin_workshop_mobile/features/customers/services/customer_offline_service.dart';
import 'package:yasin_workshop_mobile/features/customers/services/customer_monthly_price_offline_service.dart';

class _FakeClient extends http.BaseClient {
  _FakeClient(this._responseBody);

  final String _responseBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final body = http.Response(_responseBody, 200, headers: {'content-type': 'application/json'});
    return http.StreamedResponse(Stream.value(body.bodyBytes), body.statusCode, headers: body.headers);
  }
}

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

    test('customer monthly price persists locally and prevents duplicates', () async {
      final dbPath = await LocalSqliteStore.createTestDatabasePath();
      final service = CustomerMonthlyPriceOfflineService(databasePath: dbPath);
      await service.clear();

      final first = await service.saveCustomerMonthlyPriceOffline(
        customerId: 'customer-1',
        year: 2026,
        month: 11,
        monthlyRate: 1500,
        currency: 'SAR',
      );

      final duplicate = await service.saveCustomerMonthlyPriceOffline(
        customerId: 'customer-1',
        year: 2026,
        month: 11,
        monthlyRate: 1700,
        currency: 'SAR',
      );

      final localPrices = await service.getLocalCustomerMonthlyPrices('customer-1');
      expect(first.monthlyRate, 1500);
      expect(duplicate.monthlyRate, 1500);
      expect(localPrices, hasLength(1));
      expect(localPrices.first.idempotencyKey, isNotEmpty);

      await service.close();

      final reopened = CustomerMonthlyPriceOfflineService(databasePath: dbPath);
      final afterRestart = await reopened.getLocalCustomerMonthlyPrices('customer-1');
      expect(afterRestart, hasLength(1));
      expect(afterRestart.first.year, 2026);
      expect(afterRestart.first.month, 11);
      await reopened.close();
    });

    test('customer monthly price sync pushes pending records and marks them synced', () async {
      final dbPath = await LocalSqliteStore.createTestDatabasePath();
      final service = CustomerMonthlyPriceOfflineService(databasePath: dbPath);
      await service.clear();

      await service.saveCustomerMonthlyPriceOffline(
        customerId: 'customer-2',
        year: 2026,
        month: 12,
        monthlyRate: 1800,
        currency: 'SAR',
      );

      final synced = await service.pushPendingCustomerMonthlyPrices(
        baseUrl: 'http://127.0.0.1:5200',
        userName: 'customer-sync-proof-user',
        client: _FakeClient(jsonEncode({'id': 'price-1', 'message': 'Monthly price saved successfully.'})),
      );

      expect(synced, 1);
      final remaining = await service.getPendingCustomerMonthlyPrices('customer-2');
      expect(remaining, isEmpty);

      final local = await service.getLocalCustomerMonthlyPrices('customer-2');
      expect(local, hasLength(1));
      expect(local.first.syncState, SyncState.synced);
      await service.close();
    });
  });
}
