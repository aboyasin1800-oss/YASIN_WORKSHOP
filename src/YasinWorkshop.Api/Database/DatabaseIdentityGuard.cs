using Microsoft.Data.SqlClient;

namespace YasinWorkshop.Api.Database;

public sealed class DatabaseIdentityGuard
{
    private readonly DatabaseIdentityOptions _options;

    public DatabaseIdentityGuard(Microsoft.Extensions.Options.IOptions<DatabaseIdentityOptions> options)
    {
        _options = options.Value;
    }

    public sealed record ValidationResult(
        bool IsAllowed,
        string? Message,
        string? ServerName,
        string? DatabaseName,
        string? DatabaseIdentity);

    public ValidationResult ValidateIdentityDatabaseName(string? databaseName)
    {
        if (string.IsNullOrWhiteSpace(databaseName))
        {
            return new ValidationResult(false, "Database name is missing.", null, null, null);
        }

        if (databaseName.Equals(_options.GoldenDatabase, StringComparison.OrdinalIgnoreCase))
        {
            return new ValidationResult(false, "Golden baseline is blocked for development runtime.", null, databaseName, null);
        }

        if (_options.ForbiddenDatabasePrefixes.Any(prefix =>
                databaseName.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)))
        {
            return new ValidationResult(false, "LUMAR database is out of write scope.", null, databaseName, null);
        }

        if (!databaseName.Equals(_options.DevelopmentDatabase, StringComparison.OrdinalIgnoreCase))
        {
            return new ValidationResult(false, $"Unexpected database identity '{databaseName}'.", null, databaseName, null);
        }

        return new ValidationResult(true, "Database identity matches development database.", null, databaseName, databaseName);
    }

    public async Task<ValidationResult> ValidateDevelopmentDatabaseAsync(string? connectionString, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            return new ValidationResult(false, "Connection string is missing for development database.", null, null, null);
        }

        var builder = new SqlConnectionStringBuilder(connectionString);
        var configuredDatabase = builder.InitialCatalog;
        var identityResult = ValidateIdentityDatabaseName(configuredDatabase);

        if (!identityResult.IsAllowed)
        {
            return identityResult with { ServerName = builder.DataSource };
        }

        await using var connection = new SqlConnection(connectionString);
        await connection.OpenAsync(cancellationToken);

        var actualDatabaseName = await new SqlCommand("SELECT DB_NAME();", connection)
            .ExecuteScalarAsync(cancellationToken) as string;

        var actualIdentity = ValidateIdentityDatabaseName(actualDatabaseName);
        if (!actualIdentity.IsAllowed)
        {
            return actualIdentity with { ServerName = connection.DataSource };
        }

        var serverName = connection.DataSource;
        return new ValidationResult(
            true,
            $"Connected to development database {actualDatabaseName} on {serverName}.",
            serverName,
            actualDatabaseName,
            actualDatabaseName);
    }
}
