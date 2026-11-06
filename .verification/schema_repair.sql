IF COL_LENGTH('users', 'LastLoginAt') IS NULL
BEGIN
    ALTER TABLE [users] ADD [LastLoginAt] datetime2 NULL;
END;

IF COL_LENGTH('users', 'PasswordHash') IS NULL
BEGIN
    ALTER TABLE [users] ADD [PasswordHash] nvarchar(512) NOT NULL CONSTRAINT DF_users_PasswordHash DEFAULT '';
END;

IF COL_LENGTH('users', 'SecurityStamp') IS NULL
BEGIN
    ALTER TABLE [users] ADD [SecurityStamp] nvarchar(128) NULL;
END;

IF OBJECT_ID(N'[customers]', N'U') IS NULL
BEGIN
    CREATE TABLE [customers] (
        [Id] uniqueidentifier NOT NULL,
        [Name] nvarchar(256) NOT NULL,
        [ContactName] nvarchar(128) NULL,
        [Phone] nvarchar(64) NULL,
        [WhatsApp] nvarchar(64) NULL,
        [Email] nvarchar(256) NULL,
        [RelationshipType] nvarchar(64) NOT NULL DEFAULT 'Wholesale',
        [DeliveryLocation] nvarchar(512) NULL,
        [Status] nvarchar(32) NOT NULL DEFAULT 'Active',
        [IsArchived] bit NOT NULL DEFAULT 0,
        [Notes] nvarchar(max) NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_customers] PRIMARY KEY ([Id]),
        CONSTRAINT [UQ_customers_Name] UNIQUE ([Name])
    );
    CREATE INDEX [IX_customers_Status] ON [customers] ([Status]);
END;

IF OBJECT_ID(N'[employees]', N'U') IS NULL
BEGIN
    CREATE TABLE [employees] (
        [Id] uniqueidentifier NOT NULL,
        [EmployeeCode] nvarchar(64) NOT NULL,
        [Name] nvarchar(256) NOT NULL,
        [Phone] nvarchar(64) NULL,
        [WhatsApp] nvarchar(64) NULL,
        [Email] nvarchar(256) NULL,
        [EmployeeType] nvarchar(32) NOT NULL DEFAULT 'Piece',
        [Status] nvarchar(32) NOT NULL DEFAULT 'Active',
        [IsArchived] bit NOT NULL DEFAULT 0,
        [StartDate] date NULL,
        [EndDate] date NULL,
        [Notes] nvarchar(max) NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_employees] PRIMARY KEY ([Id]),
        CONSTRAINT [UQ_employees_EmployeeCode] UNIQUE ([EmployeeCode]),
        CONSTRAINT [UQ_employees_Name] UNIQUE ([Name])
    );
    CREATE INDEX [IX_employees_Status] ON [employees] ([Status]);
    CREATE INDEX [IX_employees_EmployeeType] ON [employees] ([EmployeeType]);
END;

IF OBJECT_ID(N'[suppliers]', N'U') IS NULL
BEGIN
    CREATE TABLE [suppliers] (
        [Id] uniqueidentifier NOT NULL,
        [SupplierCode] nvarchar(64) NOT NULL,
        [Name] nvarchar(256) NOT NULL,
        [ContactName] nvarchar(128) NULL,
        [Phone] nvarchar(64) NULL,
        [WhatsApp] nvarchar(64) NULL,
        [Email] nvarchar(256) NULL,
        [SupplierType] nvarchar(32) NOT NULL DEFAULT 'General',
        [Status] nvarchar(32) NOT NULL DEFAULT 'Active',
        [IsArchived] bit NOT NULL DEFAULT 0,
        [Notes] nvarchar(max) NULL,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_suppliers] PRIMARY KEY ([Id]),
        CONSTRAINT [UQ_suppliers_SupplierCode] UNIQUE ([SupplierCode]),
        CONSTRAINT [UQ_suppliers_Name] UNIQUE ([Name])
    );
    CREATE INDEX [IX_suppliers_Status] ON [suppliers] ([Status]);
    CREATE INDEX [IX_suppliers_SupplierType] ON [suppliers] ([SupplierType]);
END;

IF OBJECT_ID(N'[customer_monthly_prices]', N'U') IS NULL
BEGIN
    CREATE TABLE [customer_monthly_prices] (
        [Id] uniqueidentifier NOT NULL,
        [CustomerId] uniqueidentifier NOT NULL,
        [Year] int NOT NULL,
        [Month] int NOT NULL,
        [MonthlyRate] decimal(18,4) NOT NULL,
        [Currency] nvarchar(16) NOT NULL DEFAULT 'SAR',
        [IsCurrent] bit NOT NULL DEFAULT 1,
        [CreatedAt] datetime2 NOT NULL,
        [UpdatedAt] datetime2 NULL,
        CONSTRAINT [PK_customer_monthly_prices] PRIMARY KEY ([Id]),
        CONSTRAINT [UQ_customer_monthly_prices_CustomerId_Year_Month] UNIQUE ([CustomerId], [Year], [Month]),
        CONSTRAINT [FK_customer_monthly_prices_customers_CustomerId] FOREIGN KEY ([CustomerId]) REFERENCES [customers] ([Id]) ON DELETE CASCADE
    );
END;
