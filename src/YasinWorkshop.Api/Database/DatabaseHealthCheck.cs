using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace YasinWorkshop.Api.Database;

public sealed class DatabaseHealthCheck : IHealthCheck
{
    private readonly DatabaseIdentityGuard _guard;
    private readonly IConfiguration _configuration;

    public DatabaseHealthCheck(DatabaseIdentityGuard guard, IConfiguration configuration)
    {
        _guard = guard;
        _configuration = configuration;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        var connectionString = _configuration.GetConnectionString("DevelopmentDatabase");
        var result = await _guard.ValidateDevelopmentDatabaseAsync(connectionString, cancellationToken);

        if (!result.IsAllowed)
        {
            return HealthCheckResult.Unhealthy(result.Message ?? "Database identity protection failed.");
        }

        return HealthCheckResult.Healthy(result.Message ?? "Database identity verified.");
    }
}
