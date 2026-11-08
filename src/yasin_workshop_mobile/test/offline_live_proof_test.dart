import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yasin_workshop_mobile/core/offline/local_sync_store.dart';
import 'package:yasin_workshop_mobile/features/customers/services/customer_offline_service.dart';

void main() {
  test('live offline-first proof sequence', () async {
    final dbPath = await LocalSqliteStore.createTestDatabasePath();
    final initialStore = LocalSqliteStore(databasePath: dbPath);
    await initialStore.deleteAll();
    final initialPending = await initialStore.getPendingOperations();

    debugPrint('INITIAL_CHECKPOINT=');
    debugPrint('INITIAL_PENDING_OUTBOX_COUNT=${initialPending.length}');

    await initialStore.close();

    final service = CustomerOfflineService(databasePath: dbPath);
    final uniqueId = 'customer-proof-${DateTime.now().microsecondsSinceEpoch}';
    final customer = await service.saveCustomerOffline(
      id: uniqueId,
      name: 'Customer Proof Offline',
      contactName: 'Offline Proof Contact',
      phone: '+966500000001',
      email: 'offline-proof-${DateTime.now().millisecondsSinceEpoch}@example.com',
      relationshipType: 'Wholesale',
      deliveryLocation: 'Riyadh',
      status: 'Active',
      notes: 'Offline first proof',
    );

    final localRecords = await service.getLocalCustomers();
    final pendingOps = await LocalSqliteStore(databasePath: dbPath).getPendingOperations();
    final outboxCount = pendingOps.length;

    debugPrint('OFFLINE_CUSTOMER_CREATE=PASS');
    debugPrint('LOCAL_RECORD_EXISTS=${localRecords.any((x) => x.id == customer.id)}');
    debugPrint('OUTBOX_OPERATION_EXISTS=${pendingOps.isNotEmpty}');
    debugPrint('OUTBOX_PENDING_COUNT=$outboxCount');
    debugPrint('CUSTOMER_SYNC_STATE=${localRecords.firstWhere((x) => x.id == customer.id).syncState.name}');

    await service.close();

    final reopenedStore = LocalSqliteStore(databasePath: dbPath);
    final reopenedRecords = await reopenedStore.getLocalCustomers();
    final reopenedOps = await reopenedStore.getPendingOperations();

    debugPrint('RESTART_PERSISTENCE=PASS');
    debugPrint('LOCAL_RECORD_EXISTS_AFTER_RESTART=${reopenedRecords.any((x) => x.id == customer.id)}');
    debugPrint('OUTBOX_EXISTS_AFTER_RESTART=${reopenedOps.isNotEmpty}');
    debugPrint('OUTBOX_PENDING_AFTER_RESTART=${reopenedOps.length}');

    expect(localRecords.any((x) => x.id == customer.id), isTrue);
    expect(pendingOps.length, 1);
    expect(reopenedRecords.any((x) => x.id == customer.id), isTrue);
    expect(reopenedOps.length, 1);

    await reopenedStore.close();
  });
}
