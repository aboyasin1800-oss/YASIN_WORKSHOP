using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Database;
using YasinWorkshop.Api.Security;

namespace YasinWorkshop.Tests;

public sealed class DevelopmentOperationalDataResetEngineTests
{
    [Fact]
    public async Task PreviewAsync_UsesDevelopmentDatabaseGuardAndCreatesConfirmationToken()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        dbContext.Users.Add(new User
        {
            Id = Guid.NewGuid(),
            UserName = "dev-user",
            DisplayName = "Dev User",
            PasswordHash = "hash",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        });
        dbContext.Customers.Add(new Customer
        {
            Id = Guid.NewGuid(),
            Name = "Test Customer",
            RelationshipType = "Wholesale",
            Status = "Active",
            CreatedAt = DateTime.UtcNow
        });
        await dbContext.SaveChangesAsync();

        var engine = new DevelopmentOperationalDataResetEngine(
            dbContext,
            new DatabaseIdentityGuard(Options.Create(new DatabaseIdentityOptions())));

        var preview = await engine.PreviewAsync("YASIN_WORKSHOP_ES_VALIDATION");

        Assert.True(preview.IsAllowed);
        Assert.False(string.IsNullOrWhiteSpace(preview.ConfirmationToken));
        Assert.DoesNotContain(preview.Tables, x => x.TableName == "users" && x.IsResettable);
        Assert.Contains(preview.Tables, x => x.TableName == "customers" && x.IsResettable);
    }

    [Fact]
    public async Task ExecuteAsync_RejectsMissingConfirmationToken()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var engine = new DevelopmentOperationalDataResetEngine(
            dbContext,
            new DatabaseIdentityGuard(Options.Create(new DatabaseIdentityOptions())));

        var result = await engine.ExecuteAsync(new DevelopmentOperationalResetRequest
        {
            IsConfirmed = true,
            IsDryRun = false,
            ConfirmationToken = string.Empty
        }, "YASIN_WORKSHOP_ES_VALIDATION");

        Assert.False(result.IsSuccess);
        Assert.Contains("confirmation", result.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task ExecuteAsync_ResetsOperationalRowsWithoutTouchingProtectedHistory()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);

        dbContext.Users.Add(new User
        {
            Id = Guid.NewGuid(),
            UserName = "reset-user",
            DisplayName = "Reset User",
            PasswordHash = "hash",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        });
        dbContext.Customers.Add(new Customer
        {
            Id = Guid.NewGuid(),
            Name = "Reset Customer",
            RelationshipType = "Wholesale",
            Status = "Active",
            CreatedAt = DateTime.UtcNow
        });
        dbContext.AuditLogs.Add(new AuditLog
        {
            Id = Guid.NewGuid(),
            EntityName = "customers",
            Action = "create",
            OperationTime = DateTime.UtcNow
        });
        await dbContext.SaveChangesAsync();

        var engine = new DevelopmentOperationalDataResetEngine(
            dbContext,
            new DatabaseIdentityGuard(Options.Create(new DatabaseIdentityOptions())));

        var preview = await engine.PreviewAsync("YASIN_WORKSHOP_ES_VALIDATION");
        var result = await engine.ExecuteAsync(new DevelopmentOperationalResetRequest
        {
            ConfirmationToken = preview.ConfirmationToken,
            IsConfirmed = true,
            IsDryRun = false
        }, "YASIN_WORKSHOP_ES_VALIDATION");

        Assert.True(result.IsSuccess);
        Assert.Equal(1, await dbContext.Users.CountAsync());
        Assert.Equal(0, await dbContext.Customers.CountAsync());
        Assert.Equal(1, await dbContext.AuditLogs.CountAsync());
    }

    [Fact]
    public async Task ExecuteAsync_ProtectsBootstrapIdentityTables()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);

        dbContext.Users.Add(new User
        {
            Id = Guid.NewGuid(),
            UserName = "reset-operator",
            DisplayName = "Reset Operator",
            PasswordHash = "hash",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        });
        dbContext.Roles.Add(new Role
        {
            Id = Guid.NewGuid(),
            Name = "Reset Operators",
            Description = "Reset role",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        });
        dbContext.Permissions.Add(new Permission
        {
            Id = Guid.NewGuid(),
            Code = "development.operational_reset",
            Description = "Reset permission",
            IsActive = true,
            CreatedAt = DateTime.UtcNow
        });
        await dbContext.SaveChangesAsync();

        var engine = new DevelopmentOperationalDataResetEngine(
            dbContext,
            new DatabaseIdentityGuard(Options.Create(new DatabaseIdentityOptions())));

        var preview = await engine.PreviewAsync("YASIN_WORKSHOP_ES_VALIDATION");
        var result = await engine.ExecuteAsync(new DevelopmentOperationalResetRequest
        {
            ConfirmationToken = preview.ConfirmationToken,
            IsConfirmed = true,
            IsDryRun = false
        }, "YASIN_WORKSHOP_ES_VALIDATION");

        Assert.True(result.IsSuccess);
        Assert.Equal(1, await dbContext.Users.CountAsync());
        Assert.Equal(1, await dbContext.Roles.CountAsync());
        Assert.Equal(1, await dbContext.Permissions.CountAsync());
        Assert.DoesNotContain(preview.Tables, x => x.TableName == "users" && x.IsResettable);
        Assert.DoesNotContain(preview.Tables, x => x.TableName == "roles" && x.IsResettable);
        Assert.DoesNotContain(preview.Tables, x => x.TableName == "permissions" && x.IsResettable);
    }

    [Fact]
    public async Task PreviewAsync_RejectsGoldenDatabase()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var engine = new DevelopmentOperationalDataResetEngine(
            dbContext,
            new DatabaseIdentityGuard(Options.Create(new DatabaseIdentityOptions())));

        var preview = await engine.PreviewAsync("YASIN_WORKSHOP_GOLDEN_1");

        Assert.False(preview.IsAllowed);
        Assert.Contains("Golden", preview.Message, StringComparison.OrdinalIgnoreCase);
    }
}
