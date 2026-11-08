import 'dart:convert';

import '../../../core/offline/local_sync_store.dart';
import '../../../core/offline/offline_foundation.dart';
import '../../../core/offline/sync_models.dart';
import '../models/supplier.dart';

class SupplierOfflineService {
  SupplierOfflineService({LocalSqliteStore? store, OfflineFoundation? foundation})
      : _store = store ?? LocalSqliteStore() {
    _foundation = foundation ?? OfflineFoundation(store: _store);
  }

  final LocalSqliteStore _store;
  late final OfflineFoundation _foundation;

  Future<Supplier> saveSupplierOffline(SupplierDraft draft) async {
    final now = DateTime.now().toUtc();
    final supplier = Supplier(
      id: 'supplier-offline-${now.microsecondsSinceEpoch}',
      supplierCode: draft.supplierCode,
      name: draft.name,
      contactName: draft.contactName,
      phone: draft.phone,
      whatsApp: draft.whatsApp,
      email: draft.email,
      supplierType: draft.supplierType,
      status: draft.status,
      isArchived: draft.isArchived,
      notes: draft.notes,
      createdAt: now,
      updatedAt: now,
      syncState: SyncState.pending,
    );

    await _store.saveLocalEntity(
      'supplier',
      supplier.supplierCode,
      {
        'id': supplier.id,
        'supplierCode': supplier.supplierCode,
        'name': supplier.name,
        'contactName': supplier.contactName,
        'phone': supplier.phone,
        'whatsApp': supplier.whatsApp,
        'email': supplier.email,
        'supplierType': supplier.supplierType,
        'status': supplier.status,
        'isArchived': supplier.isArchived,
        'notes': supplier.notes,
        'createdAt': supplier.createdAt?.toUtc().toIso8601String(),
        'updatedAt': supplier.updatedAt?.toUtc().toIso8601String(),
      },
      id: supplier.id,
      createdAt: now,
      updatedAt: now,
      syncState: SyncState.pending,
    );

    await _foundation.enqueueOperation(
      entityType: 'supplier',
      entityId: supplier.id,
      operationType: 'create',
      payload: {
        'id': supplier.id,
        'supplierCode': supplier.supplierCode,
        'name': supplier.name,
        'contactName': supplier.contactName,
        'phone': supplier.phone,
        'whatsApp': supplier.whatsApp,
        'email': supplier.email,
        'supplierType': supplier.supplierType,
        'status': supplier.status,
        'isArchived': supplier.isArchived,
        'notes': supplier.notes,
      },
      baseVersion: '',
      correlationId: 'supplier-${supplier.id}',
      idempotencyKey: 'supplier-${supplier.supplierCode}-${now.microsecondsSinceEpoch}',
    );

    return supplier;
  }

  Future<List<Supplier>> getLocalSuppliers() async {
    final rows = await _store.getLocalEntities('supplier');
    return rows
        .map((row) {
          final payload = jsonDecode(row['payload'] as String) as Map<String, dynamic>;
          return Supplier.fromJson(payload);
        })
        .toList(growable: false);
  }

  Future<List<SyncOutboxOperation>> getPendingOperations() async {
    return _foundation.getPendingOperations(entityType: 'supplier');
  }

  Future<void> clear() async {
    await _store.deleteAll();
  }

  Future<void> close() async {
    await _store.close();
  }
}
