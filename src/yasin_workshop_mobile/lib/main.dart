import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_config.dart';
import 'features/customers/models/customer.dart';
import 'features/customers/services/customer_api_service.dart';
import 'features/employees/models/employee.dart';
import 'features/employees/services/employee_api_service.dart';

void main() {
  runApp(const YasinWorkshopApp());
}

class YasinWorkshopApp extends StatelessWidget {
  const YasinWorkshopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'معمل ياسين',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E5F74)),
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Roboto'),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E5F74), brightness: Brightness.dark),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Roboto'),
      ),
      themeMode: ThemeMode.system,
      home: const FoundationHomeScreen(),
    );
  }
}

class FoundationHomeScreen extends StatefulWidget {
  const FoundationHomeScreen({super.key});

  @override
  State<FoundationHomeScreen> createState() => _FoundationHomeScreenState();
}

class _FoundationHomeScreenState extends State<FoundationHomeScreen> {
  int _selectedIndex = 0;
  late final CustomerApiService _customerApiService = CustomerApiService(
    config: const AppConfig(baseUrl: 'https://localhost:7262', defaultUserName: 'admin'),
  );
  late final EmployeeApiService _employeeApiService = EmployeeApiService(
    config: const AppConfig(baseUrl: 'https://localhost:7262', defaultUserName: 'admin'),
  );

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      CustomerModuleView(
        key: _customerModuleKey,
        apiService: _customerApiService,
      ),
      EmployeeModuleView(
        key: _employeeModuleKey,
        apiService: _employeeApiService,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('معمل ياسين'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _selectedIndex == 0 ? () => _customerModuleKey.currentState?._loadCustomers() : () => _employeeModuleKey.currentState?._loadEmployees(),
              icon: const Icon(Icons.refresh),
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) => setState(() => _selectedIndex = index),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.people_alt_rounded), label: 'العملاء'),
            NavigationDestination(icon: Icon(Icons.badge_rounded), label: 'الموظفون'),
          ],
        ),
      ),
    );
  }

  final GlobalKey<CustomerModuleViewState> _customerModuleKey = GlobalKey();
  final GlobalKey<EmployeeModuleViewState> _employeeModuleKey = GlobalKey();
}

class CustomerModuleView extends StatefulWidget {
  const CustomerModuleView({super.key, required this.apiService});

  final CustomerApiService apiService;

  @override
  State<CustomerModuleView> createState() => CustomerModuleViewState();
}

class CustomerModuleViewState extends State<CustomerModuleView> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Customer> _customers = const [];

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final customers = await widget.apiService.fetchCustomers();
      if (!mounted) {
        return;
      }
      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _showCreateCustomerDialog() async {
    final result = await showDialog<CustomerDraft>(
      context: context,
      builder: (context) => const _CustomerEditorDialog(),
    );

    if (result == null) {
      return;
    }

    try {
      final created = await widget.apiService.createCustomer(result);
      if (!mounted) {
        return;
      }

      setState(() {
        _customers = [created, ..._customers];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إضافة العميل: ${created.name}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الحفظ: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'حالة الخادم',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('الأساس الخلفي متصل فعليًا من خلال عقد API الحالي.'),
                    SizedBox(height: 8),
                    Text('المرحلة الحالية: Customer Module Ready'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'إدارة العملاء',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.api_rounded),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('العقد الحقيقي: /api/customers'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'تعذر الاتصال بالخادم:\n$_errorMessage',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: _customers.isEmpty
                    ? const Center(child: Text('لا توجد بيانات عملاء في الخادم الآن.'))
                    : ListView.separated(
                        itemCount: _customers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final customer = _customers[index];
                          return Card(
                            child: ListTile(
                              title: Text(customer.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (customer.contactName != null) Text('المتواصل: ${customer.contactName}'),
                                  if (customer.phone != null) Text('الهاتف: ${customer.phone}'),
                                  if (customer.whatsApp != null) Text('واتساب: ${customer.whatsApp}'),
                                  Text('الحالة: ${customer.status}'),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(customer.isArchived ? 'مؤرشف' : 'نشط'),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              onPressed: _showCreateCustomerDialog,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('عميل جديد'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmployeeModuleView extends StatefulWidget {
  const EmployeeModuleView({super.key, required this.apiService});

  final EmployeeApiServiceContract apiService;

  @override
  State<EmployeeModuleView> createState() => EmployeeModuleViewState();
}

class EmployeeModuleViewState extends State<EmployeeModuleView> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Employee> _employees = const [];

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final employees = await widget.apiService.fetchEmployees();
      if (!mounted) {
        return;
      }
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _showCreateEmployeeDialog() async {
    final result = await showDialog<EmployeeDraft>(
      context: context,
      builder: (context) => EmployeeEditorDialog(
        apiService: widget.apiService,
        mode: EmployeeEditorMode.create,
      ),
    );

    if (result == null) {
      return;
    }

    try {
      final created = await widget.apiService.createEmployee(result);
      if (!mounted) {
        return;
      }
      setState(() {
        _employees = [created, ..._employees];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمت إضافة الموظف: ${created.name}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل حفظ الموظف: ${error.toString()}')),
      );
    }
  }

  Future<void> _showEditEmployeeDialog(Employee employee) async {
    final result = await showDialog<EmployeeDraft>(
      context: context,
      builder: (context) => EmployeeEditorDialog(
        apiService: widget.apiService,
        mode: EmployeeEditorMode.edit,
        employee: employee,
      ),
    );

    if (result == null) {
      return;
    }

    try {
      final updated = await widget.apiService.updateEmployee(employee.id, result);
      if (!mounted) {
        return;
      }
      setState(() {
        final index = _employees.indexWhere((item) => item.id == employee.id);
        if (index >= 0) {
          _employees[index] = updated;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث الموظف: ${updated.name}')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل تحديث الموظف: ${error.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'إدارة الموظفين',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.badge_outlined),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text('العقد الحقيقي: /api/employees'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'تعذّر الاتصال بالخادم:\n$_errorMessage',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: _employees.isEmpty
                    ? const Center(
                        child: Text('لا توجد موظفين في الخادم الآن.'),
                      )
                    : ListView.separated(
                        itemCount: _employees.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final employee = _employees[index];
                          return Card(
                            child: ListTile(
                              title: Text(employee.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (employee.employeeCode.isNotEmpty) Text('رمز الموظف: ${employee.employeeCode}'),
                                  if (employee.phone != null) Text('الهاتف: ${employee.phone}'),
                                  if (employee.email != null) Text('البريد: ${employee.email}'),
                                  Text('الحالة: ${employee.status}'),
                                  Text('النوع: ${employee.employeeType}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => _showEditEmployeeDialog(employee),
                                    icon: const Icon(Icons.edit),
                                    tooltip: 'تعديل',
                                  ),
                                  Chip(
                                    label: Text(employee.isArchived ? 'مؤرشف' : 'نشط'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            const SizedBox(height: 8),
            FloatingActionButton.extended(
              onPressed: _showCreateEmployeeDialog,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('موظف جديد'),
            ),
          ],
        ),
      ),
    );
  }
}

enum EmployeeEditorMode { create, edit }

class EmployeeEditorDialog extends StatefulWidget {
  const EmployeeEditorDialog({
    super.key,
    required this.apiService,
    required this.mode,
    this.employee,
  });

  final EmployeeApiServiceContract apiService;
  final EmployeeEditorMode mode;
  final Employee? employee;

  @override
  State<EmployeeEditorDialog> createState() => _EmployeeEditorDialogState();
}

class _EmployeeEditorDialogState extends State<EmployeeEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _employeeCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsAppController = TextEditingController();
  final _emailController = TextEditingController();
  final _employeeTypeController = TextEditingController(text: 'Piece');
  final _statusController = TextEditingController(text: 'Active');
  final _notesController = TextEditingController();
  bool _isSaving = false;
  String? _errorMessage;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final employee = widget.employee;
    if (employee != null) {
      _employeeCodeController.text = employee.employeeCode;
      _nameController.text = employee.name;
      _phoneController.text = employee.phone ?? '';
      _whatsAppController.text = employee.whatsApp ?? '';
      _emailController.text = employee.email ?? '';
      _employeeTypeController.text = employee.employeeType;
      _statusController.text = employee.status;
      _notesController.text = employee.notes ?? '';
      _startDate = employee.startDate;
      _endDate = employee.endDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.mode == EmployeeEditorMode.edit ? 'تعديل الموظف' : 'إضافة موظف جديد';

    return AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _employeeCodeController,
                decoration: const InputDecoration(labelText: 'رمز الموظف'),
                textDirection: TextDirection.ltr,
                validator: (value) => (value == null || value.trim().isEmpty) ? 'رمز الموظف مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم الموظف'),
                validator: (value) => (value == null || value.trim().isEmpty) ? 'اسم الموظف مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'الهاتف'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _whatsAppController,
                decoration: const InputDecoration(labelText: 'واتساب'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _employeeTypeController,
                decoration: const InputDecoration(labelText: 'نوع الموظف'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'الحالة'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _startDate = picked);
                        }
                      },
                      icon: const Icon(Icons.calendar_today_rounded),
                      label: Text(_startDate == null ? 'تاريخ البداية' : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => _endDate = picked);
                        }
                      },
                      icon: const Icon(Icons.event_available_rounded),
                      label: Text(_endDate == null ? 'تاريخ النهاية' : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _submit,
          child: Text(_isSaving ? 'جارٍ الحفظ...' : 'حفظ'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final draft = EmployeeDraft(
      employeeCode: _employeeCodeController.text.trim(),
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      whatsApp: _whatsAppController.text.trim().isEmpty ? null : _whatsAppController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      employeeType: _employeeTypeController.text.trim().isEmpty ? 'Piece' : _employeeTypeController.text.trim(),
      status: _statusController.text.trim().isEmpty ? 'Active' : _statusController.text.trim(),
      isArchived: false,
      startDate: _startDate,
      endDate: _endDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    try {
      if (widget.mode == EmployeeEditorMode.edit && widget.employee != null) {
        final updated = await widget.apiService.updateEmployee(widget.employee!.id, draft);
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(EmployeeDraft(
          employeeCode: updated.employeeCode,
          name: updated.name,
          phone: updated.phone,
          whatsApp: updated.whatsApp,
          email: updated.email,
          employeeType: updated.employeeType,
          status: updated.status,
          isArchived: updated.isArchived,
          startDate: updated.startDate,
          endDate: updated.endDate,
          notes: updated.notes,
        ));
      } else {
        final created = await widget.apiService.createEmployee(draft);
        if (!mounted) {
          return;
        }
        Navigator.of(context).pop(EmployeeDraft(
          employeeCode: created.employeeCode,
          name: created.name,
          phone: created.phone,
          whatsApp: created.whatsApp,
          email: created.email,
          employeeType: created.employeeType,
          status: created.status,
          isArchived: created.isArchived,
          startDate: created.startDate,
          endDate: created.endDate,
          notes: created.notes,
        ));
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = error.toString();
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _employeeCodeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _whatsAppController.dispose();
    _emailController.dispose();
    _employeeTypeController.dispose();
    _statusController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

class _CustomerEditorDialog extends StatefulWidget {
  const _CustomerEditorDialog();

  @override
  State<_CustomerEditorDialog> createState() => _CustomerEditorDialogState();
}

class _CustomerEditorDialogState extends State<_CustomerEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsAppController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _relationshipController = TextEditingController(text: 'Wholesale');
  final _statusController = TextEditingController(text: 'Active');

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة عميل جديد'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'اسم العميل'),
                validator: (value) => value == null || value.trim().isEmpty ? 'اسم العميل مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _contactController, decoration: const InputDecoration(labelText: 'اسم جهة الاتصال')),
              const SizedBox(height: 12),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'الهاتف')),
              const SizedBox(height: 12),
              TextFormField(controller: _whatsAppController, decoration: const InputDecoration(labelText: 'واتساب')),
              const SizedBox(height: 12),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'البريد الإلكتروني')),
              const SizedBox(height: 12),
              TextFormField(controller: _relationshipController, decoration: const InputDecoration(labelText: 'نوع العلاقة')),
              const SizedBox(height: 12),
              TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'موقع التوصيل')),
              const SizedBox(height: 12),
              TextFormField(controller: _statusController, decoration: const InputDecoration(labelText: 'الحالة')),
              const SizedBox(height: 12),
              TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'ملاحظات'), maxLines: 3),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('إلغاء')),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(
                CustomerDraft(
                  name: _nameController.text.trim(),
                  contactName: _contactController.text.trim().isEmpty ? null : _contactController.text.trim(),
                  phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
                  whatsApp: _whatsAppController.text.trim().isEmpty ? null : _whatsAppController.text.trim(),
                  email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
                  relationshipType: _relationshipController.text.trim().isEmpty ? 'Wholesale' : _relationshipController.text.trim(),
                  deliveryLocation: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
                  status: _statusController.text.trim().isEmpty ? 'Active' : _statusController.text.trim(),
                  notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                ),
              );
            }
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _whatsAppController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _relationshipController.dispose();
    _statusController.dispose();
    super.dispose();
  }
}
