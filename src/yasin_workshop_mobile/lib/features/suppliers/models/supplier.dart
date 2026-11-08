import '../../../core/offline/sync_models.dart';

class Supplier {
  const Supplier({
    required this.id,
    required this.supplierCode,
    required this.name,
    this.contactName,
    this.phone,
    this.whatsApp,
    this.email,
    this.supplierType = 'General',
    this.status = 'Active',
    this.isArchived = false,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.syncState = SyncState.synced,
  });

  final String id;
  final String supplierCode;
  final String name;
  final String? contactName;
  final String? phone;
  final String? whatsApp;
  final String? email;
  final String supplierType;
  final String status;
  final bool isArchived;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SyncState syncState;

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: (json['Id'] ?? json['id'] ?? '').toString(),
      supplierCode: (json['SupplierCode'] ?? json['supplierCode'] ?? '').toString(),
      name: (json['Name'] ?? json['name'] ?? '').toString(),
      contactName: _stringValue(json['ContactName'] ?? json['contactName']),
      phone: _stringValue(json['Phone'] ?? json['phone']),
      whatsApp: _stringValue(json['WhatsApp'] ?? json['whatsApp']),
      email: _stringValue(json['Email'] ?? json['email']),
      supplierType: (json['SupplierType'] ?? json['supplierType'] ?? 'General').toString(),
      status: (json['Status'] ?? json['status'] ?? 'Active').toString(),
      isArchived: json['IsArchived'] == true || json['isArchived'] == true,
      notes: _stringValue(json['Notes'] ?? json['notes']),
      createdAt: _dateTimeValue(json['CreatedAt'] ?? json['createdAt']),
      updatedAt: _dateTimeValue(json['UpdatedAt'] ?? json['updatedAt']),
      syncState: SyncState.synced,
    );
  }

  static String? _stringValue(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime? _dateTimeValue(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString();
    if (text.isEmpty) {
      return null;
    }
    return DateTime.tryParse(text);
  }
}

class SupplierDraft {
  const SupplierDraft({
    required this.supplierCode,
    required this.name,
    this.contactName,
    this.phone,
    this.whatsApp,
    this.email,
    this.supplierType = 'General',
    this.status = 'Active',
    this.isArchived = false,
    this.notes,
  });

  final String supplierCode;
  final String name;
  final String? contactName;
  final String? phone;
  final String? whatsApp;
  final String? email;
  final String supplierType;
  final String status;
  final bool isArchived;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'SupplierCode': supplierCode,
      'Name': name,
      'ContactName': contactName,
      'Phone': phone,
      'WhatsApp': whatsApp,
      'Email': email,
      'SupplierType': supplierType,
      'Status': status,
      'IsArchived': isArchived,
      'Notes': notes,
    };
  }
}
