class Employee {
  const Employee({
    required this.id,
    required this.employeeCode,
    required this.name,
    this.phone,
    this.whatsApp,
    this.email,
    this.employeeType = 'Piece',
    this.status = 'Active',
    this.isArchived = false,
    this.startDate,
    this.endDate,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String employeeCode;
  final String name;
  final String? phone;
  final String? whatsApp;
  final String? email;
  final String employeeType;
  final String status;
  final bool isArchived;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: (json['Id'] ?? json['id'] ?? '').toString(),
      employeeCode: (json['EmployeeCode'] ?? json['employeeCode'] ?? '').toString(),
      name: (json['Name'] ?? json['name'] ?? '').toString(),
      phone: _stringValue(json['Phone']),
      whatsApp: _stringValue(json['WhatsApp']),
      email: _stringValue(json['Email']),
      employeeType: (json['EmployeeType'] ?? json['employeeType'] ?? 'Piece').toString(),
      status: (json['Status'] ?? json['status'] ?? 'Active').toString(),
      isArchived: json['IsArchived'] == true || json['isArchived'] == true,
      startDate: _dateTimeValue(json['StartDate'] ?? json['startDate']),
      endDate: _dateTimeValue(json['EndDate'] ?? json['endDate']),
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

class EmployeeDraft {
  const EmployeeDraft({
    required this.employeeCode,
    required this.name,
    this.phone,
    this.whatsApp,
    this.email,
    this.employeeType = 'Piece',
    this.status = 'Active',
    this.isArchived = false,
    this.startDate,
    this.endDate,
    this.notes,
  });

  final String employeeCode;
  final String name;
  final String? phone;
  final String? whatsApp;
  final String? email;
  final String employeeType;
  final String status;
  final bool isArchived;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'EmployeeCode': employeeCode,
      'Name': name,
      'Phone': phone,
      'WhatsApp': whatsApp,
      'Email': email,
      'EmployeeType': employeeType,
      'Status': status,
      'IsArchived': isArchived,
      'StartDate': startDate?.toUtc().toIso8601String(),
      'EndDate': endDate?.toUtc().toIso8601String(),
      'Notes': notes,
    };
  }
}
