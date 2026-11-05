using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Api;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Database;
using YasinWorkshop.Api.Security;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<DatabaseIdentityOptions>(
    builder.Configuration.GetSection(DatabaseIdentityOptions.SectionName));

builder.Services.AddSingleton<DatabaseIdentityGuard>();
builder.Services.AddDbContext<YasinWorkshopDbContext>((serviceProvider, options) =>
{
    var connectionString = builder.Configuration.GetConnectionString("DevelopmentDatabase");
    options.UseSqlServer(connectionString, sql =>
    {
        sql.MigrationsAssembly(typeof(YasinWorkshopDbContext).Assembly.FullName);
        sql.EnableRetryOnFailure();
    });
});

builder.Services.AddHealthChecks()
    .AddCheck<DatabaseHealthCheck>("database-identity");

builder.Services.AddScoped<UserSecurityService>();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<YasinWorkshopDbContext>();
    await dbContext.Database.MigrateAsync();
}

app.UseHttpsRedirection();

app.MapHealthChecks("/health");

app.MapGet("/api/identity", async (DatabaseIdentityGuard guard, IConfiguration config, CancellationToken cancellationToken) =>
{
    var connectionString = config.GetConnectionString("DevelopmentDatabase");
    var result = await guard.ValidateDevelopmentDatabaseAsync(connectionString, cancellationToken);

    if (!result.IsAllowed)
    {
        return Results.BadRequest(new
        {
            result.IsAllowed,
            result.Message,
            result.ServerName,
            result.DatabaseName
        });
    }

    return Results.Ok(new
    {
        result.IsAllowed,
        result.Message,
        result.ServerName,
        result.DatabaseName,
        result.DatabaseIdentity
    });
});

app.MapGet("/api/db-foundation", async (YasinWorkshopDbContext dbContext, CancellationToken cancellationToken) =>
{
    var appSettingsCount = await dbContext.AppSettings.CountAsync(cancellationToken);
    var userCount = await dbContext.Users.CountAsync(cancellationToken);
    var auditCount = await dbContext.AuditLogs.CountAsync(cancellationToken);

    return Results.Ok(new
    {
        Database = "YASIN_WORKSHOP_ES_VALIDATION",
        AppSettingsCount = appSettingsCount,
        UserCount = userCount,
        AuditCount = auditCount,
        Status = "Core foundation active"
    });
});

app.MapGet("/api/status", () => new
{
    Environment = "Development",
    Database = "YASIN_WORKSHOP_ES_VALIDATION",
    Guarded = true,
    GoldenBaselineProtected = true,
    LumarProtected = true,
    CoreFoundation = true,
    OperationalFoundation = true
});

app.MapOperationalFoundationEndpoints();
app.MapCustomerOperationalEndpoints();

await app.RunAsync();
