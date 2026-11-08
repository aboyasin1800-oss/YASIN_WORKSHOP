import 'dart:convert';
import 'dart:io';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'sync_models.dart';

void configureSqliteForDesktop() {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
}

class LocalCustomerRecord {
  LocalCustomerRecord({
    required this.id,
    required this.name,
    required this.contactName,
    required this.phone,
    required this.email,
    required this.relationshipType,
    required this.deliveryLocation,
    required this.status,
    required this.isArchived,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.syncState,
  });

  final String id;
  final String name;
  final String? contactName;
  final String? phone;
  final String? email;
  final String relationshipType;
  final String? deliveryLocation;
  final String status;
  final bool isArchived;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncState syncState;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'contact_name': contactName,
      'phone': phone,
      'email': email,
      'relationship_type': relationshipType,
      'delivery_location': deliveryLocation,
      'status': status,
      'is_archived': isArchived ? 1 : 0,
      'notes': notes,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'sync_state': syncState.name,
    };
  }

  factory LocalCustomerRecord.fromMap(Map<String, dynamic> map) {
    return LocalCustomerRecord(
      id: map['id'] as String,
      name: map['name'] as String,
      contactName: map['contact_name'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      relationshipType: map['relationship_type'] as String? ?? 'Wholesale',
      deliveryLocation: map['delivery_location'] as String?,
      status: map['status'] as String? ?? 'Active',
      isArchived: (map['is_archived'] as int?) == 1,
      notes: map['notes'] as String?,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      updatedAt:
          DateTime.tryParse(map['updated_at'] as String? ?? '') ??
          DateTime.now().toUtc(),
      syncState: SyncState.values.firstWhere(
        (value) =>
            value.name ==
            (map['sync_state'] as String? ?? SyncState.pending.name),
        orElse: () => SyncState.pending,
      ),
    );
  }
}

class LocalSqliteStore {
  LocalSqliteStore({String? databasePath})
    : databasePath = databasePath ?? _defaultDatabasePath() {
        _ensureSqliteRuntime();
      }

  final String databasePath;
  Database? _database;

  static void _ensureSqliteRuntime() {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  static String _defaultDatabasePath() {
    final fileName = 'yasin_workshop_local.db';
    return File('${Directory.systemTemp.path}/$fileName').path;
  }

  static Future<String> createTestDatabasePath() async {
    final file = File(
      '${Directory.systemTemp.path}/yasin_workshop_test_${DateTime.now().microsecondsSinceEpoch}.db',
    );
    if (await file.exists()) {
      await file.delete();
    }
    return file.path;
  }

  Future<Database> _open() async {
    _ensureSqliteRuntime();

    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: _createSchema,
      onUpgrade: _upgradeSchema,
    );

    return _database!;
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sync_outbox (
        operation_id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation_type TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        attempt_count INTEGER NOT NULL DEFAULT 0,
        sync_state TEXT NOT NULL,
        idempotency_key TEXT NOT NULL,
        correlation_id TEXT,
        last_error TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE sync_conflicts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        local_version TEXT NOT NULL,
        server_version TEXT NOT NULL,
        conflict_details TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE local_customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        contact_name TEXT,
        phone TEXT,
        email TEXT,
        relationship_type TEXT NOT NULL DEFAULT 'Wholesale',
        delivery_location TEXT,
        status TEXT NOT NULL DEFAULT 'Active',
        is_archived INTEGER NOT NULL DEFAULT 0,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'pending'
      );
    ''');

    await db.execute('''
      CREATE TABLE local_entities (
        id TEXT PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_key TEXT NOT NULL,
        payload TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'pending'
      );
    ''');
    await db.execute('''
      CREATE TABLE local_customer_monthly_prices (
        customer_id TEXT NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        monthly_rate REAL NOT NULL,
        currency TEXT NOT NULL DEFAULT 'SAR',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        sync_state TEXT NOT NULL DEFAULT 'pending',
        idempotency_key TEXT NOT NULL,
        operation_id TEXT NOT NULL,
        last_error TEXT,
        PRIMARY KEY (customer_id, year, month)
      );
    ''' );  }

  Future<void> _upgradeSchema(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 1) {
      await _createSchema(db, newVersion);
    }
  }

  Future<void> saveOutboxOperation(SyncOutboxOperation operation) async {
    final db = await _open();
    await db.insert(
      'sync_outbox',
      operation.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SyncOutboxOperation>> getPendingOperations() async {
    final db = await _open();
    final rows = await db.query(
      'sync_outbox',
      where: 'sync_state = ?',
      whereArgs: [SyncState.pending.name],
      orderBy: 'created_at ASC',
    );

    return rows.map(SyncOutboxOperation.fromMap).toList(growable: false);
  }

  Future<void> updateOutboxOperationState(
    String operationId,
    SyncState state, {
    String? lastError,
  }) async {
    final db = await _open();
    await db.update(
      'sync_outbox',
      {
        'sync_state': state.name,
        'last_error': lastError,
      },
      where: 'operation_id = ?',
      whereArgs: [operationId],
    );
  }

  Future<void> deleteOutboxOperation(String operationId) async {
    final db = await _open();
    await db.delete(
      'sync_outbox',
      where: 'operation_id = ?',
      whereArgs: [operationId],
    );
  }

  Future<void> saveLocalCustomerRecord(LocalCustomerRecord record) async {
    final db = await _open();
    await db.insert(
      'local_customers',
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveLocalCustomerMonthlyPrice(CustomerMonthlyPriceRecord record) async {
    final db = await _open();
    await db.insert(
      'local_customer_monthly_prices',
      {
        'customer_id': record.customerId,
        'year': record.year,
        'month': record.month,
        'monthly_rate': record.monthlyRate,
        'currency': record.currency,
        'created_at': record.createdAt.toUtc().toIso8601String(),
        'updated_at': record.updatedAt.toUtc().toIso8601String(),
        'sync_state': record.syncState.name,
        'idempotency_key': record.idempotencyKey,
        'operation_id': record.operationId,
        'last_error': null,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CustomerMonthlyPriceRecord>> getLocalCustomerMonthlyPrices() async {
    final db = await _open();
    final rows = await db.query(
      'local_customer_monthly_prices',
      orderBy: 'updated_at DESC',
    );

    return rows.map((row) {
      return CustomerMonthlyPriceRecord(
        customerId: row['customer_id'] as String? ?? '',
        year: (row['year'] as num?)?.toInt() ?? DateTime.now().year,
        month: (row['month'] as num?)?.toInt() ?? 1,
        monthlyRate: (row['monthly_rate'] as num?)?.toDouble() ?? 0,
        currency: row['currency'] as String? ?? 'SAR',
        createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now().toUtc(),
        updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ?? DateTime.now().toUtc(),
        syncState: SyncState.values.firstWhere(
            (value) => value.name == (row['sync_state'] as String? ?? SyncState.pending.name),
            orElse: () => SyncState.pending,
          ),
        idempotencyKey: row['idempotency_key'] as String? ?? '',
        operationId: row['operation_id'] as String?,
      );
    }).toList(growable: false);
  }

  Future<void> updateCustomerMonthlyPriceState(
    String idempotencyKey,
    SyncState state, {
    String? lastError,
  }) async {
    final db = await _open();
    await db.update(
      'local_customer_monthly_prices',
      {
        'sync_state': state.name,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'last_error': lastError,
      },
      where: 'idempotency_key = ?',
      whereArgs: [idempotencyKey],
    );
  }

  Future<void> saveLocalEntity(
    String entityType,
    String entityKey,
    Map<String, dynamic> payload, {
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    SyncState syncState = SyncState.pending,
  }) async {
    final db = await _open();
    final now = (updatedAt ?? DateTime.now().toUtc()).toUtc();
    final record = {
      'id': id ?? '${entityType}-${entityKey}-${now.microsecondsSinceEpoch}',
      'entity_type': entityType,
      'entity_key': entityKey,
      'payload': jsonEncode(payload),
      'created_at': (createdAt ?? now).toUtc().toIso8601String(),
      'updated_at': now.toIso8601String(),
      'sync_state': syncState.name,
    };

    await db.insert('local_entities', record, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getLocalEntities(String entityType) async {
    final db = await _open();
    final rows = await db.query(
      'local_entities',
      where: 'entity_type = ?',
      whereArgs: [entityType],
      orderBy: 'updated_at DESC',
    );
    return rows;
  }

  Future<void> saveConflict(SyncConflict conflict) async {
    final db = await _open();
    await db.insert('sync_conflicts', conflict.toMap());
  }

  Future<List<SyncConflict>> getConflictRecords() async {
    final db = await _open();
    final rows = await db.query(
      'sync_conflicts',
      orderBy: 'created_at DESC',
    );

    return rows.map((row) {
      return SyncConflict(
        entityType: row['entity_type'] as String? ?? 'unknown',
        entityId: row['entity_id'] as String? ?? 'unknown',
        localVersion: row['local_version'] as String? ?? '',
        serverVersion: row['server_version'] as String? ?? '',
        conflictDetails: row['conflict_details'] as String? ?? '',
        createdAt:
            DateTime.tryParse(row['created_at'] as String? ?? '') ??
            DateTime.now().toUtc(),
      );
    }).toList(growable: false);
  }

  Future<List<LocalCustomerRecord>> getLocalCustomers() async {
    final db = await _open();
    final rows = await db.query('local_customers', orderBy: 'updated_at DESC');

    return rows.map(LocalCustomerRecord.fromMap).toList(growable: false);
  }

  Future<void> deleteAll() async {
    final db = await _open();
    await db.delete('sync_outbox');
    await db.delete('sync_conflicts');
    await db.delete('local_customers');
    await db.delete('local_entities');
    await db.delete('local_customer_monthly_prices');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
    _database = null;
  }
}
