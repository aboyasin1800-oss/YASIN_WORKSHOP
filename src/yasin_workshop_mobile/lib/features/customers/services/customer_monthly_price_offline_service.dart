import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../../../core/offline/local_sync_store.dart';
import '../../../core/offline/sync_models.dart';

class CustomerMonthlyPriceOfflineService {
  CustomerMonthlyPriceOfflineService({String? databasePath, LocalSqliteStore? store})
      : _store = store ?? LocalSqliteStore(databasePath: databasePath ?? 'customer_monthly_price_local.db');

  final LocalSqliteStore _store;

  Future<void> clear() async {
    await _store.deleteAll();
  }

  Future<CustomerMonthlyPriceRecord> saveCustomerMonthlyPriceOffline({
    required String customerId,
    required int year,
    required int month,
    required double monthlyRate,
    String currency = 'SAR',
  }) async {
    final now = DateTime.now().toUtc();
    final key = 'customer-monthly-price-$customerId-$year-$month';
    final existing = await _store.getLocalCustomerMonthlyPrices();
    final matching = existing.where((record) =>
        record.customerId == customerId && record.year == year && record.month == month).toList();

    if (matching.isNotEmpty) {
      final existingRecord = matching.first;
      return existingRecord;
    }

    final record = CustomerMonthlyPriceRecord(
      customerId: customerId,
      year: year,
      month: month,
      monthlyRate: monthlyRate,
      currency: currency,
      createdAt: now,
      updatedAt: now,
      syncState: SyncState.pending,
      idempotencyKey: key,
      operationId: 'monthly-price-$customerId-$year-$month-${now.microsecondsSinceEpoch}',
    );

    await _store.saveLocalCustomerMonthlyPrice(record);
    await _store.saveOutboxOperation(
      SyncOutboxOperation(
        operationId: record.operationId!,
        entityType: 'customer_monthly_price',
        entityId: customerId,
        operationType: SyncOperationType.create,
        payload: jsonEncode({
          'customerId': customerId,
          'year': year,
          'month': month,
          'monthlyRate': monthlyRate,
          'currency': currency,
          'businessDate': DateTime(year, month, 1).toUtc().toIso8601String(),
        }),
        createdAt: now,
        attemptCount: 0,
        syncState: SyncState.pending,
        idempotencyKey: key,
      ),
    );

    return record;
  }

  Future<List<CustomerMonthlyPriceRecord>> getLocalCustomerMonthlyPrices(String customerId) async {
    final rows = await _store.getLocalCustomerMonthlyPrices();
    return rows.where((record) => record.customerId == customerId).toList(growable: false);
  }

  Future<List<CustomerMonthlyPriceRecord>> getPendingCustomerMonthlyPrices(String customerId) async {
    final rows = await _store.getLocalCustomerMonthlyPrices();
    return rows
        .where((record) => record.customerId == customerId && record.syncState == SyncState.pending)
        .toList(growable: false);
  }

  Future<int> pushPendingCustomerMonthlyPrices({
    required String baseUrl,
    required String userName,
    http.Client? client,
  }) async {
    final clientToUse = client ?? http.Client();
    int count = 0;
    final pending = await _store.getLocalCustomerMonthlyPrices();

    for (final record in pending) {
      if (record.syncState != SyncState.pending) {
        continue;
      }

      final payload = {
        'operationId': _newGuid(),
        'clientId': _newGuid(),
        'entityType': 'customer_monthly_price',
        'entityId': record.customerId,
        'operationType': 'create',
        'payload': jsonEncode({
          'customerId': record.customerId,
          'year': record.year,
          'month': record.month,
          'monthlyRate': record.monthlyRate,
          'currency': record.currency,
        }),
        'baseVersion': '',
        'idempotencyKey': record.idempotencyKey,
      };

      final response = await clientToUse.post(
        Uri.parse('$baseUrl/api/customers/${record.customerId}/monthly-price'),
        headers: {'Content-Type': 'application/json', 'X-User-Name': userName},
        body: jsonEncode(payload),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final updated = record;
        await _store.updateCustomerMonthlyPriceState(record.idempotencyKey, SyncState.synced);
        count += 1;
      } else {
        await _store.updateCustomerMonthlyPriceState(record.idempotencyKey, SyncState.failed, lastError: response.body);
      }
    }

    return count;
  }

  Future<void> close() async {
    await _store.close();
  }

  static String _newGuid() {
    final random = Random();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    values[6] = (values[6] & 0x0F) | 0x40;
    values[8] = (values[8] & 0x3F) | 0x80;
    final hex = values.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
