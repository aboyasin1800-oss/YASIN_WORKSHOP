using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Database;

namespace YasinWorkshop.Api.Security;

public sealed record DevelopmentOperationalResetTableDefinition(
    string TableName,
    string Classification,
    int DeleteOrder,
    bool IsResettable,
    string Reason);

public sealed record DevelopmentOperationalResetPreview(
    bool IsAllowed,
    string Message,
    string? ServerName,
    string? DatabaseName,
    string? ConfirmationToken,
    bool IsDryRun,
    IReadOnlyList<DevelopmentOperationalResetTableDefinition> Tables,
    int TotalResettableRows,
    int TotalProtectedRows);

public sealed record DevelopmentOperationalResetRequest(
    string? ConfirmationToken = null,
    bool IsConfirmed = false,
    bool IsDryRun = true);

public sealed record DevelopmentOperationalResetResult(
    bool IsSuccess,
    string Message,
    string? DatabaseName,
    int DeletedRows,
    bool WasDryRun,
    string? ConfirmationToken);

public sealed class DevelopmentOperationalDataResetEngine
{
    private readonly YasinWorkshopDbContext _dbContext;
    private readonly DatabaseIdentityGuard _databaseIdentityGuard;

    public DevelopmentOperationalDataResetEngine(
        YasinWorkshopDbContext dbContext,
        DatabaseIdentityGuard databaseIdentityGuard)
    {
        _dbContext = dbContext;
        _databaseIdentityGuard = databaseIdentityGuard;
    }

    public IReadOnlyList<DevelopmentOperationalResetTableDefinition> GetManifest()
    {
        return new[]
        {
            new DevelopmentOperationalResetTableDefinition("app_settings", "REVIEW_REQUIRED", 0, false, "Application configuration values are protected unless explicitly reviewed."),
            new DevelopmentOperationalResetTableDefinition("audit_log", "SYSTEM_HISTORY_PROTECTED", 0, false, "Audit history must be preserved to retain operational traceability."),
            new DevelopmentOperationalResetTableDefinition("idempotency_keys", "SYSTEM_HISTORY_PROTECTED", 0, false, "Idempotency records protect against duplicate execution and must remain intact."),
            new DevelopmentOperationalResetTableDefinition("message_templates", "REFERENCE_PROTECTED", 0, false, "Message templates are reference configuration and should not be cleared by a runtime reset."),
            new DevelopmentOperationalResetTableDefinition("permissions", "BOOTSTRAP_PROTECTED", 0, false, "Permission catalog is the RBAC bootstrap layer and must survive a development reset so authorization can continue to work."),
            new DevelopmentOperationalResetTableDefinition("roles", "BOOTSTRAP_PROTECTED", 0, false, "Role catalog is the RBAC bootstrap layer and must survive a development reset so the reset operator remains authorized."),
            new DevelopmentOperationalResetTableDefinition("users", "BOOTSTRAP_PROTECTED", 0, false, "User identity data is the security bootstrap layer and must never be deleted by an operational reset."),
            new DevelopmentOperationalResetTableDefinition("role_permissions", "OPERATIONAL_RESETTABLE", 1, true, "Join records between roles and permissions are operational-only and safe to clear."),
            new DevelopmentOperationalResetTableDefinition("user_roles", "OPERATIONAL_RESETTABLE", 2, true, "User-to-role grants are operational state and can be reset safely."),
            new DevelopmentOperationalResetTableDefinition("financial_postings", "OPERATIONAL_RESETTABLE", 3, true, "Financial postings are operational ledger activity and should be reset in development only."),
            new DevelopmentOperationalResetTableDefinition("customer_monthly_prices", "OPERATIONAL_RESETTABLE", 4, true, "Customer monthly price records are operational and should be cleared before a fresh development seed."),
            new DevelopmentOperationalResetTableDefinition("message_attempts", "OPERATIONAL_RESETTABLE", 5, true, "Delivery attempts are transient operational activity and can be safely reset."),
            new DevelopmentOperationalResetTableDefinition("message_outbox", "OPERATIONAL_RESETTABLE", 6, true, "Outgoing message queue records are transient operational state."),
            new DevelopmentOperationalResetTableDefinition("customers", "OPERATIONAL_RESETTABLE", 7, true, "Customer operational records are development data and safe to clear."),
            new DevelopmentOperationalResetTableDefinition("employees", "OPERATIONAL_RESETTABLE", 8, true, "Employee records are development operational state and safe to clear."),
            new DevelopmentOperationalResetTableDefinition("suppliers", "OPERATIONAL_RESETTABLE", 9, true, "Supplier records are development operational state and safe to clear."),
        };
    }

    public async Task<DevelopmentOperationalResetPreview> PreviewAsync(
        string? databaseNameOverride = null,
        CancellationToken cancellationToken = default)
    {
        var identity = await ResolveDatabaseIdentityAsync(databaseNameOverride, cancellationToken);
        if (!identity.IsAllowed)
        {
            return new DevelopmentOperationalResetPreview(
                false,
                identity.Message ?? "Database validation failed.",
                identity.ServerName,
                identity.DatabaseName,
                null,
                true,
                GetManifest(),
                0,
                0);
        }

        var tableCounts = await GetTableCountsAsync(cancellationToken);
        var tables = GetManifest();
        var totalResettableRows = 0;
        foreach (var table in tables.Where(x => x.IsResettable))
        {
            totalResettableRows += tableCounts.GetValueOrDefault(table.TableName, 0);
        }

        var totalProtectedRows = 0;
        foreach (var table in tables.Where(x => !x.IsResettable))
        {
            totalProtectedRows += tableCounts.GetValueOrDefault(table.TableName, 0);
        }

        var confirmationToken = ComputeConfirmationToken(identity.DatabaseName!);

        return new DevelopmentOperationalResetPreview(
            true,
            $"Development operational reset preview for {identity.DatabaseName}.",
            identity.ServerName,
            identity.DatabaseName,
            confirmationToken,
            true,
            tables,
            totalResettableRows,
            totalProtectedRows);
    }

    public async Task<DevelopmentOperationalResetResult> ExecuteAsync(
        DevelopmentOperationalResetRequest request,
        string? databaseNameOverride = null,
        CancellationToken cancellationToken = default)
    {
        var identity = await ResolveDatabaseIdentityAsync(databaseNameOverride, cancellationToken);
        if (!identity.IsAllowed)
        {
            return new DevelopmentOperationalResetResult(
                false,
                identity.Message ?? "Database validation failed.",
                identity.DatabaseName,
                0,
                false,
                null);
        }

        if (!request.IsConfirmed)
        {
            return new DevelopmentOperationalResetResult(
                false,
                "Reset execution requires confirmation to be explicitly enabled.",
                identity.DatabaseName,
                0,
                request.IsDryRun,
                null);
        }

        var expectedToken = ComputeConfirmationToken(identity.DatabaseName!);
        if (string.IsNullOrWhiteSpace(request.ConfirmationToken) ||
            !string.Equals(request.ConfirmationToken, expectedToken, StringComparison.OrdinalIgnoreCase))
        {
            return new DevelopmentOperationalResetResult(
                false,
                "Reset execution requires a valid confirmation token from the preview response.",
                identity.DatabaseName,
                0,
                request.IsDryRun,
                request.ConfirmationToken);
        }

        if (request.IsDryRun)
        {
            var preview = await PreviewAsync(identity.DatabaseName, cancellationToken);
            return new DevelopmentOperationalResetResult(
                true,
                preview.Message,
                preview.DatabaseName,
                preview.TotalResettableRows,
                true,
                preview.ConfirmationToken);
        }

        var deletedRows = 0;
        var supportsTransactions = !string.Equals(
            _dbContext.Database.ProviderName,
            "Microsoft.EntityFrameworkCore.InMemory",
            StringComparison.Ordinal);

        if (supportsTransactions)
        {
            foreach (var table in GetManifest()
                         .Where(x => x.IsResettable)
                         .OrderBy(x => x.DeleteOrder))
            {
                deletedRows += await DeleteTableAsync(table.TableName, cancellationToken);
            }
        }
        else
        {
            foreach (var table in GetManifest()
                         .Where(x => x.IsResettable)
                         .OrderBy(x => x.DeleteOrder))
            {
                deletedRows += await DeleteTableAsync(table.TableName, cancellationToken);
            }
        }

        return new DevelopmentOperationalResetResult(
            true,
            $"Development operational data reset completed for {identity.DatabaseName}. Deleted {deletedRows} rows.",
            identity.DatabaseName,
            deletedRows,
            false,
            expectedToken);
    }

    public static string ComputeConfirmationToken(string databaseName)
    {
        var normalized = (databaseName ?? "unknown").Trim();
        var safeName = normalized
            .Replace(' ', '-')
            .Replace('_', '-')
            .Replace("--", "-")
            .Trim('-')
            .ToUpperInvariant();

        return $"DEV-RESET-{safeName}-{DateTime.UtcNow:yyyyMMdd}";
    }

    private async Task<DatabaseIdentityGuard.ValidationResult> ResolveDatabaseIdentityAsync(
        string? databaseNameOverride,
        CancellationToken cancellationToken)
    {
        if (!string.IsNullOrWhiteSpace(databaseNameOverride))
        {
            return _databaseIdentityGuard.ValidateIdentityDatabaseName(databaseNameOverride);
        }

        var connectionString = _dbContext.Database.GetConnectionString();
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return new DatabaseIdentityGuard.ValidationResult(
                false,
                "Connection string is unavailable for development database validation.",
                null,
                null,
                null);
        }

        return await _databaseIdentityGuard.ValidateDevelopmentDatabaseAsync(connectionString, cancellationToken);
    }

    private async Task<Dictionary<string, int>> GetTableCountsAsync(CancellationToken cancellationToken)
    {
        var counts = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
        {
            ["app_settings"] = await _dbContext.AppSettings.CountAsync(cancellationToken),
            ["audit_log"] = await _dbContext.AuditLogs.CountAsync(cancellationToken),
            ["idempotency_keys"] = await _dbContext.IdempotencyKeys.CountAsync(cancellationToken),
            ["message_templates"] = await _dbContext.MessageTemplates.CountAsync(cancellationToken),
            ["role_permissions"] = await _dbContext.RolePermissions.CountAsync(cancellationToken),
            ["user_roles"] = await _dbContext.UserRoles.CountAsync(cancellationToken),
            ["financial_postings"] = await _dbContext.FinancialPostings.CountAsync(cancellationToken),
            ["customer_monthly_prices"] = await _dbContext.CustomerMonthlyPrices.CountAsync(cancellationToken),
            ["message_attempts"] = await _dbContext.MessageAttempts.CountAsync(cancellationToken),
            ["message_outbox"] = await _dbContext.MessageOutbox.CountAsync(cancellationToken),
            ["customers"] = await _dbContext.Customers.CountAsync(cancellationToken),
            ["employees"] = await _dbContext.Employees.CountAsync(cancellationToken),
            ["suppliers"] = await _dbContext.Suppliers.CountAsync(cancellationToken),
            ["permissions"] = await _dbContext.Permissions.CountAsync(cancellationToken),
            ["roles"] = await _dbContext.Roles.CountAsync(cancellationToken),
            ["users"] = await _dbContext.Users.CountAsync(cancellationToken)
        };

        return counts;
    }

    private async Task<int> DeleteTableAsync(string tableName, CancellationToken cancellationToken)
    {
        if (string.Equals(tableName, "users", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(tableName, "roles", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(tableName, "permissions", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException($"Protected bootstrap table '{tableName}' cannot be deleted by the operational reset engine.");
        }

        switch (tableName)
        {
            case "role_permissions":
                var rolePermissions = await _dbContext.RolePermissions.ToListAsync(cancellationToken);
                _dbContext.RolePermissions.RemoveRange(rolePermissions);
                await _dbContext.SaveChangesAsync(cancellationToken);
                return rolePermissions.Count;

            case "user_roles":
                var userRoles = await _dbContext.UserRoles.ToListAsync(cancellationToken);
                _dbContext.UserRoles.RemoveRange(userRoles);
                await _dbContext.SaveChangesAsync(cancellationToken);
                return userRoles.Count;

            case "financial_postings":
                var postings = await _dbContext.FinancialPostings.ToListAsync(cancellationToken);
                _dbContext.FinancialPostings.RemoveRange(postings);
                await _dbContext.SaveChangesAsync(cancellationToken);
                return postings.Count;

            case "customer_monthly_prices":
                var monthlyPrices = await _dbContext.CustomerMonthlyPrices.ToListAsync(cancellationToken);
                _dbContext.CustomerMonthlyPrices.RemoveRange(monthlyPrices);
                await _dbContext.SaveChangesAsync(cancellationToken);
                return monthlyPrices.Count;

            case "message_attempts":
                var attempts = await _dbContext.MessageAttempts.ToListAsync(cancellationToken);
                _dbContext.MessageAttempts.RemoveRange(attempts);
                await _dbContext.SaveChangesAsync(cancellationToken);
                return attempts.Count;

            case "message_outbox":
                var outboxEntries = await _dbContext.MessageOutbox.ToListAsync(cancellationToken);
                _dbContext.MessageOutbox.RemoveRange(outboxEntries);
                await _dbContext.SaveChangesAsync(cancellationToken);
                return outboxEntries.Count;

            case "customers":
                var customers = await _dbContext.Customers.ToListAsync(cancellationToken);
                _dbContext.Customers.RemoveRange(customers);
                await _dbContext.SaveChangesAsync(cancellationToken);
                return customers.Count;

            case "employees":
                var employees = await _dbContext.Employees.ToListAsync(cancellationToken);
                _dbContext.Employees.RemoveRange(employees);
                await _dbContext.SaveChangesAsync(cancellationToken);
                return employees.Count;

            case "suppliers":
                var suppliers = await _dbContext.Suppliers.ToListAsync(cancellationToken);
                _dbContext.Suppliers.RemoveRange(suppliers);
                await _dbContext.SaveChangesAsync(cancellationToken);
                return suppliers.Count;

            case "permissions":
                var permissions = await _dbContext.Permissions.ToListAsync(cancellationToken);
                _dbContext.Permissions.RemoveRange(permissions);
                await _dbContext.SaveChangesAsync(cancellationToken);
                return permissions.Count;

            case "roles":
                var roles = await _dbContext.Roles.ToListAsync(cancellationToken);
                _dbContext.Roles.RemoveRange(roles);
                await _dbContext.SaveChangesAsync(cancellationToken);
                return roles.Count;

            case "users":
                var users = await _dbContext.Users.ToListAsync(cancellationToken);
                _dbContext.Users.RemoveRange(users);
                await _dbContext.SaveChangesAsync(cancellationToken);
                return users.Count;

            default:
                return 0;
        }
    }
}
