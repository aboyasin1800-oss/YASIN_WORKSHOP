$query = @'
IF OBJECT_ID(N'dbo.employee_monthly_compensations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.employee_monthly_compensations (
        Id uniqueidentifier NOT NULL,
        EmployeeId uniqueidentifier NOT NULL,
        Year int NOT NULL,
        Month int NOT NULL,
        CompensationType nvarchar(32) NOT NULL,
        Amount decimal(18,4) NOT NULL,
        Currency nvarchar(16) NOT NULL,
        IsCurrent bit NOT NULL,
        Notes nvarchar(max) NULL,
        CreatedAt datetime2 NOT NULL,
        UpdatedAt datetime2 NULL,
        CONSTRAINT PK_employee_monthly_compensations PRIMARY KEY (Id),
        CONSTRAINT FK_employee_monthly_compensations_employees_EmployeeId FOREIGN KEY (EmployeeId)
            REFERENCES dbo.employees (Id)
            ON DELETE CASCADE
    );
    CREATE UNIQUE INDEX IX_employee_monthly_compensations_EmployeeId_Year_Month ON dbo.employee_monthly_compensations (EmployeeId, Year, Month);
END;

IF OBJECT_ID(N'dbo.employee_production_entries', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.employee_production_entries (
        Id uniqueidentifier NOT NULL,
        EmployeeId uniqueidentifier NOT NULL,
        OperationDate date NOT NULL,
        Quantity decimal(18,4) NOT NULL,
        ResolvedUnitRate decimal(18,4) NOT NULL,
        CalculatedAmount decimal(18,4) NOT NULL,
        FirstSavedAt datetime2 NOT NULL,
        CreatedAt datetime2 NOT NULL,
        UpdatedAt datetime2 NULL,
        CreatedBy nvarchar(128) NOT NULL,
        Notes nvarchar(max) NULL,
        CONSTRAINT PK_employee_production_entries PRIMARY KEY (Id),
        CONSTRAINT FK_employee_production_entries_employees_EmployeeId FOREIGN KEY (EmployeeId)
            REFERENCES dbo.employees (Id)
            ON DELETE CASCADE
    );
    CREATE INDEX IX_employee_production_entries_EmployeeId_OperationDate ON dbo.employee_production_entries (EmployeeId, OperationDate);
END;

IF OBJECT_ID(N'dbo.employee_expenses', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.employee_expenses (
        Id uniqueidentifier NOT NULL,
        EmployeeId uniqueidentifier NOT NULL,
        OperationDate date NOT NULL,
        Amount decimal(18,4) NOT NULL,
        FirstSavedAt datetime2 NOT NULL,
        CreatedAt datetime2 NOT NULL,
        UpdatedAt datetime2 NULL,
        CreatedBy nvarchar(128) NOT NULL,
        Notes nvarchar(max) NULL,
        CONSTRAINT PK_employee_expenses PRIMARY KEY (Id),
        CONSTRAINT FK_employee_expenses_employees_EmployeeId FOREIGN KEY (EmployeeId)
            REFERENCES dbo.employees (Id)
            ON DELETE CASCADE
    );
    CREATE INDEX IX_employee_expenses_EmployeeId_OperationDate ON dbo.employee_expenses (EmployeeId, OperationDate);
END;

IF OBJECT_ID(N'dbo.employee_settlements', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.employee_settlements (
        Id uniqueidentifier NOT NULL,
        EmployeeId uniqueidentifier NOT NULL,
        SettlementDate date NOT NULL,
        TotalAmount decimal(18,4) NOT NULL,
        TotalAllocated decimal(18,4) NOT NULL,
        Currency nvarchar(16) NOT NULL,
        Status nvarchar(32) NOT NULL,
        CreatedAt datetime2 NOT NULL,
        UpdatedAt datetime2 NULL,
        CreatedBy nvarchar(128) NOT NULL,
        Notes nvarchar(max) NULL,
        CONSTRAINT PK_employee_settlements PRIMARY KEY (Id),
        CONSTRAINT FK_employee_settlements_employees_EmployeeId FOREIGN KEY (EmployeeId)
            REFERENCES dbo.employees (Id)
            ON DELETE CASCADE
    );
    CREATE INDEX IX_employee_settlements_EmployeeId_SettlementDate ON dbo.employee_settlements (EmployeeId, SettlementDate);
END;

IF OBJECT_ID(N'dbo.employee_settlement_allocations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.employee_settlement_allocations (
        Id uniqueidentifier NOT NULL,
        SettlementId uniqueidentifier NOT NULL,
        EmployeeId uniqueidentifier NOT NULL,
        SourceType nvarchar(32) NOT NULL,
        SourceReference nvarchar(128) NOT NULL,
        Amount decimal(18,4) NOT NULL,
        AllocationDate date NOT NULL,
        CreatedAt datetime2 NOT NULL,
        CreatedBy nvarchar(128) NOT NULL,
        Notes nvarchar(max) NULL,
        CONSTRAINT PK_employee_settlement_allocations PRIMARY KEY (Id),
        CONSTRAINT FK_employee_settlement_allocations_employee_settlements_SettlementId FOREIGN KEY (SettlementId)
            REFERENCES dbo.employee_settlements (Id)
            ON DELETE CASCADE,
        CONSTRAINT FK_employee_settlement_allocations_employees_EmployeeId FOREIGN KEY (EmployeeId)
            REFERENCES dbo.employees (Id)
            ON DELETE CASCADE
    );
    CREATE INDEX IX_employee_settlement_allocations_SettlementId ON dbo.employee_settlement_allocations (SettlementId);
    CREATE UNIQUE INDEX IX_employee_settlement_allocations_EmployeeId_SourceType_SourceReference ON dbo.employee_settlement_allocations (EmployeeId, SourceType, SourceReference);
END;

IF OBJECT_ID(N'dbo.employee_debts', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.employee_debts (
        Id uniqueidentifier NOT NULL,
        EmployeeId uniqueidentifier NOT NULL,
        Amount decimal(18,4) NOT NULL,
        OutstandingAmount decimal(18,4) NOT NULL,
        DebtType nvarchar(32) NOT NULL,
        Status nvarchar(32) NOT NULL,
        Reason nvarchar(max) NULL,
        CreatedAt datetime2 NOT NULL,
        UpdatedAt datetime2 NULL,
        CreatedBy nvarchar(128) NOT NULL,
        CONSTRAINT PK_employee_debts PRIMARY KEY (Id),
        CONSTRAINT FK_employee_debts_employees_EmployeeId FOREIGN KEY (EmployeeId)
            REFERENCES dbo.employees (Id)
            ON DELETE CASCADE
    );
    CREATE INDEX IX_employee_debts_EmployeeId_Status ON dbo.employee_debts (EmployeeId, Status);
END;

IF OBJECT_ID(N'dbo.employee_debt_recoveries', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.employee_debt_recoveries (
        Id uniqueidentifier NOT NULL,
        EmployeeId uniqueidentifier NOT NULL,
        DebtId uniqueidentifier NOT NULL,
        SourceType nvarchar(32) NOT NULL,
        SourceReference nvarchar(128) NOT NULL,
        Amount decimal(18,4) NOT NULL,
        RecoveryDate date NOT NULL,
        CreatedAt datetime2 NOT NULL,
        CreatedBy nvarchar(128) NOT NULL,
        Notes nvarchar(max) NULL,
        CONSTRAINT PK_employee_debt_recoveries PRIMARY KEY (Id),
        CONSTRAINT FK_employee_debt_recoveries_employee_debts_DebtId FOREIGN KEY (DebtId)
            REFERENCES dbo.employee_debts (Id)
            ON DELETE CASCADE,
        CONSTRAINT FK_employee_debt_recoveries_employees_EmployeeId FOREIGN KEY (EmployeeId)
            REFERENCES dbo.employees (Id)
            ON DELETE CASCADE
    );
    CREATE UNIQUE INDEX IX_employee_debt_recoveries_EmployeeId_DebtId_SourceType_SourceReference ON dbo.employee_debt_recoveries (EmployeeId, DebtId, SourceType, SourceReference);
END;
'@

Invoke-Sqlcmd -ServerInstance 'YASIN-YASIN\SQLEXPRESS' -Database 'YASIN_WORKSHOP_ES_VALIDATION' -Query $query
Write-Host 'employee financial tables ensured.'
