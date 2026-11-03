using YasinWorkshop.Api.Database;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<DatabaseIdentityOptions>(
    builder.Configuration.GetSection(DatabaseIdentityOptions.SectionName));

builder.Services.AddSingleton<DatabaseIdentityGuard>();
builder.Services.AddHealthChecks()
    .AddCheck<DatabaseHealthCheck>("database-identity");

builder.Services.AddOpenApi();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
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

app.MapGet("/api/status", () => new
{
    Environment = "Development",
    Database = "YASIN_WORKSHOP_ES_VALIDATION",
    Guarded = true,
    GoldenBaselineProtected = true,
    LumarProtected = true
});

app.Run();
