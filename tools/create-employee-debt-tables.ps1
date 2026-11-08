$query = @'
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
            ON DELETE NO ACTION
    );
    CREATE UNIQUE INDEX IX_employee_debt_recoveries_EmployeeId_DebtId_SourceType_SourceReference ON dbo.employee_debt_recoveries (EmployeeId, DebtId, SourceType, SourceReference);
END;
'@

Invoke-Sqlcmd -ServerInstance 'YASIN-YASIN\SQLEXPRESS' -Database 'YASIN_WORKSHOP_ES_VALIDATION' -Query $query
Write-Host 'employee debt tables ensured.'
