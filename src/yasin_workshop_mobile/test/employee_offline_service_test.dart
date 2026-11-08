import 'package:flutter_test/flutter_test.dart';
import 'package:yasin_workshop_mobile/core/offline/local_sync_store.dart';
import 'package:yasin_workshop_mobile/core/offline/sync_models.dart';
import 'package:yasin_workshop_mobile/features/employees/models/employee.dart';
import 'package:yasin_workshop_mobile/features/employees/services/employee_offline_service.dart';

void main() {
  group('employee offline foundation integration', () {
    test('employee local record persists and is queued for sync', () async {
      final dbPath = await LocalSqliteStore.createTestDatabasePath();
      final store = LocalSqliteStore(databasePath: dbPath);
      final service = EmployeeOfflineService(store: store);

      await service.clear();

      final draft = EmployeeDraft(
        employeeCode: 'EMP-1001',
        name: 'موظف محلي',
        phone: '0500000001',
        email: 'emp@example.com',
        employeeType: 'Piece',
      );

      final created = await service.saveEmployeeOffline(draft);

      expect(created.employeeCode, 'EMP-1001');
      expect((await service.getLocalEmployees()).length, 1);
      expect((await service.getPendingOperations()).length, 1);

      await service.close();
      await store.close();
    });

    test('employee queued operation survives app restart', () async {
      final dbPath = await LocalSqliteStore.createTestDatabasePath();
      final firstStore = LocalSqliteStore(databasePath: dbPath);
      final firstService = EmployeeOfflineService(store: firstStore);

      await firstService.clear();
      await firstService.saveEmployeeOffline(
        EmployeeDraft(
          employeeCode: 'EMP-2002',
          name: 'موظف بعد إعادة التشغيل',
          employeeType: 'Salary',
        ),
      );

      await firstStore.close();

      final reopenedStore = LocalSqliteStore(databasePath: dbPath);
      final reopened = EmployeeOfflineService(store: reopenedStore);
      final localEmployees = await reopened.getLocalEmployees();
      final pending = await reopened.getPendingOperations();

      expect(localEmployees, hasLength(1));
      expect(localEmployees.first.employeeCode, 'EMP-2002');
      expect(pending, hasLength(1));
      expect(pending.first.entityType, 'employee');
      expect(pending.first.syncState, SyncState.pending);

      await reopened.close();
    });
  });
}
