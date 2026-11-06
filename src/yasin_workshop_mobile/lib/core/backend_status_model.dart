class BackendStatus {
  const BackendStatus({
    required this.environment,
    required this.database,
    required this.guarded,
    required this.goldenBaselineProtected,
    required this.lumarProtected,
    required this.coreFoundation,
    required this.operationalFoundation,
  });

  final String environment;
  final String database;
  final bool guarded;
  final bool goldenBaselineProtected;
  final bool lumarProtected;
  final bool coreFoundation;
  final bool operationalFoundation;

  bool get operationReady => guarded && goldenBaselineProtected && lumarProtected && coreFoundation && operationalFoundation;

  factory BackendStatus.fromJson(Map<String, dynamic> json) {
    return BackendStatus(
      environment: (json['Environment'] ?? '').toString(),
      database: (json['Database'] ?? '').toString(),
      guarded: json['Guarded'] == true,
      goldenBaselineProtected: json['GoldenBaselineProtected'] == true,
      lumarProtected: json['LumarProtected'] == true,
      coreFoundation: json['CoreFoundation'] == true,
      operationalFoundation: json['OperationalFoundation'] == true,
    );
  }
}
