import 'package:yasin_workshop_mobile/core/offline/local_sync_store.dart';
import 'package:yasin_workshop_mobile/features/customers/services/customer_offline_service.dart';

Future<void> main() async {
  final dbPath = await LocalSqliteStore.createTestDatabasePath();
  final service = CustomerOfflineService(databasePath: dbPath);
  await service.clear();
  final customer = await service.saveCustomerOffline(
    id: 'customer-local-1',
    name: 'عميل محلي',
    contactName: 'أحمد',
    email: 'ahmed@example.com',
  );
  print('NAME=' + customer.name);
  print('SYNC=' + customer.syncState.name);
  print('PENDING=' + (await service.getPendingCustomers()).length.toString());
  await service.close();
}
