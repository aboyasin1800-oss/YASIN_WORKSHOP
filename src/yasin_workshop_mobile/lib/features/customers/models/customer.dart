class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.contactName,
    this.phone,
    this.whatsApp,
    this.email,
    this.relationshipType = 'Wholesale',
    this.deliveryLocation,
    this.status = 'Active',
    this.isArchived = false,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String? contactName;
  final String? phone;
  final String? whatsApp;
  final String? email;
  final String relationshipType;
  final String? deliveryLocation;
  final String status;
  final bool isArchived;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: (json['Id'] ?? json['id'] ?? '').toString(),
      name: (json['Name'] ?? json['name'] ?? '').toString(),
      contactName: _stringValue(json['ContactName']),
      phone: _stringValue(json['Phone']),
      whatsApp: _stringValue(json['WhatsApp']),
      email: _stringValue(json['Email']),
      relationshipType: (json['RelationshipType'] ?? json['relationshipType'] ?? 'Wholesale').toString(),
      deliveryLocation: _stringValue(json['DeliveryLocation']),
      status: (json['Status'] ?? json['status'] ?? 'Active').toString(),
      isArchived: json['IsArchived'] == true || json['isArchived'] == true,
      notes: _stringValue(json['Notes']),
      createdAt: _dateTimeValue(json['CreatedAt'] ?? json['createdAt']),
      updatedAt: _dateTimeValue(json['UpdatedAt'] ?? json['updatedAt']),
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

class CustomerDraft {
  const CustomerDraft({
    required this.name,
    this.contactName,
    this.phone,
    this.whatsApp,
    this.email,
    this.relationshipType = 'Wholesale',
    this.deliveryLocation,
    this.status = 'Active',
    this.isArchived = false,
    this.notes,
  });

  final String name;
  final String? contactName;
  final String? phone;
  final String? whatsApp;
  final String? email;
  final String relationshipType;
  final String? deliveryLocation;
  final String status;
  final bool isArchived;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'ContactName': contactName,
      'Phone': phone,
      'WhatsApp': whatsApp,
      'Email': email,
      'RelationshipType': relationshipType,
      'DeliveryLocation': deliveryLocation,
      'Status': status,
      'IsArchived': isArchived,
      'Notes': notes,
    };
  }
}
