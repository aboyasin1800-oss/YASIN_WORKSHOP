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

    CREATE UNIQUE INDEX IX_employee_monthly_compensations_EmployeeId_Year_Month
        ON dbo.employee_monthly_compensations (EmployeeId, Year, Month);
END;
'@

Invoke-Sqlcmd -ServerInstance 'YASIN-YASIN\SQLEXPRESS' -Database 'YASIN_WORKSHOP_ES_VALIDATION' -Query $query
Write-Host 'employee_monthly_compensations ensured.'
