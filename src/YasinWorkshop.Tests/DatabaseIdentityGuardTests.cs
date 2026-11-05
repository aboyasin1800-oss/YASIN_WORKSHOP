using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Database;
using YasinWorkshop.Api.Security;

namespace YasinWorkshop.Tests;

public sealed class DatabaseIdentityGuardTests
{
    [Theory]
    [InlineData("YASIN_WORKSHOP_ES_VALIDATION", true)]
    [InlineData("YASIN_WORKSHOP_GOLDEN_1", false)]
    [InlineData("LUMAR_SOMETHING", false)]
    [InlineData("OTHER_DATABASE", false)]
    public void ValidateIdentityDatabaseName_RejectsGoldenAndLumar(string databaseName, bool expected)
    {
        var options = Options.Create(new DatabaseIdentityOptions
        {
            DevelopmentDatabase = "YASIN_WORKSHOP_ES_VALIDATION",
            GoldenDatabase = "YASIN_WORKSHOP_GOLDEN_1",
            ForbiddenDatabasePrefixes = new List<string> { "LUMAR" }
        });

        var guard = new DatabaseIdentityGuard(options);
        var result = guard.ValidateIdentityDatabaseName(databaseName);

        Assert.Equal(expected, result.IsAllowed);
    }

    [Fact]
    public void MigrationAssembly_ContainsInitialCoreFoundationMigration()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseSqlServer("Server=(localdb)\\MSSQLLocalDB;Database=MockDb;Trusted_Connection=True;TrustServerCertificate=True;")
            .Options;

        using var dbContext = new YasinWorkshopDbContext(options);

        var migrations = dbContext.Database.GetMigrations();

        Assert.Contains("20261104000000_InitialCoreFoundation", migrations);
    }

    [Fact]
    public async Task CreateUser_StoresPasswordHashAndRejectsDuplicateUsername()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        using var dbContext = new YasinWorkshopDbContext(options);
        var service = new UserSecurityService(dbContext);

        var created = await service.CreateUserAsync(new CreateUserRequest
        {
            UserName = "admin",
            DisplayName = "System Admin",
            Email = "admin@yasin.local",
            Password = "StrongPass!123",
            IsActive = true
        });

        Assert.NotNull(created);
        Assert.False(string.IsNullOrWhiteSpace(created.PasswordHash));

        var duplicate = await service.CreateUserAsync(new CreateUserRequest
        {
            UserName = "admin",
            DisplayName = "Other",
            Email = "other@yasin.local",
            Password = "StrongPass!123",
            IsActive = true
        });

        Assert.False(duplicate.IsSuccess);
        Assert.Contains("already exists", duplicate.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task PasswordStorage_UsesPasswordHasher_NotPlainTextOrRawSha256()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        using var dbContext = new YasinWorkshopDbContext(options);
        var service = new UserSecurityService(dbContext);

        var first = await service.CreateUserAsync(new CreateUserRequest
        {
            UserName = "secure-user-1",
            DisplayName = "Secure User 1",
            Password = "StrongPass!123",
            IsActive = true
        });

        var second = await service.CreateUserAsync(new CreateUserRequest
        {
            UserName = "secure-user-2",
            DisplayName = "Secure User 2",
            Password = "StrongPass!123",
            IsActive = true
        });

        Assert.True(first.IsSuccess);
        Assert.True(second.IsSuccess);
        Assert.NotEqual("StrongPass!123", first.PasswordHash);
        Assert.NotEqual("StrongPass!123", second.PasswordHash);
        Assert.NotEqual(UserSecurityService.HashPassword("StrongPass!123"), first.PasswordHash);
        Assert.NotEqual(first.PasswordHash, second.PasswordHash);
        Assert.DoesNotContain("StrongPass!123", first.PasswordHash, StringComparison.Ordinal);
        Assert.DoesNotContain("StrongPass!123", second.PasswordHash, StringComparison.Ordinal);
    }

    [Fact]
    public async Task UserPermissionCheck_UsesRoleAssignments()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        using var dbContext = new YasinWorkshopDbContext(options);
        var service = new UserSecurityService(dbContext);

        var adminRole = await service.CreateRoleAsync(new CreateRoleRequest { Name = "Administrator", Description = "Admin" });
        var permission = await service.CreatePermissionAsync(new CreatePermissionRequest { Code = "settings.write", Description = "Edit settings" });
        await service.AssignPermissionToRoleAsync(adminRole.Id, permission.Id);

        var user = await service.CreateUserAsync(new CreateUserRequest
        {
            UserName = "owner",
            DisplayName = "Owner",
            Password = "StrongPass!123",
            IsActive = true
        });

        await service.AssignRoleToUserAsync(user.User!.Id, adminRole.Id);

        Assert.True(await service.HasPermissionAsync(user.User.Id, "settings.write"));
    }

    [Fact]
    public async Task Login_RequiresValidHash_AndDisabledUsersAreRejected()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        using var dbContext = new YasinWorkshopDbContext(options);
        var service = new UserSecurityService(dbContext);

        var user = await service.CreateUserAsync(new CreateUserRequest
        {
            UserName = "ops-user",
            DisplayName = "Ops User",
            Password = "StrongPass!123",
            IsActive = true
        });

        Assert.True(await service.IsValidLoginAsync("ops-user", "StrongPass!123"));
        Assert.False(await service.IsValidLoginAsync("ops-user", "WrongPass!123"));

        user.User!.IsActive = false;
        await dbContext.SaveChangesAsync();

        Assert.False(await service.IsValidLoginAsync("ops-user", "StrongPass!123"));
    }

    [Fact]
    public async Task DuplicateRoleAssignment_IsRejected()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        using var dbContext = new YasinWorkshopDbContext(options);
        var service = new UserSecurityService(dbContext);

        var user = await service.CreateUserAsync(new CreateUserRequest
        {
            UserName = "role-user",
            DisplayName = "Role User",
            Password = "StrongPass!123",
            IsActive = true
        });
        var role = await service.CreateRoleAsync(new CreateRoleRequest { Name = "Support" });

        await service.AssignRoleToUserAsync(user.User!.Id, role.Id);
        await service.AssignRoleToUserAsync(user.User.Id, role.Id);

        var count = await dbContext.UserRoles.CountAsync(x => x.UserId == user.User.Id && x.RoleId == role.Id);
        Assert.Equal(1, count);
    }

    [Fact]
    public async Task SettingsAudit_StoresBeforeAndAfterPayloads()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        using var dbContext = new YasinWorkshopDbContext(options);
        var service = new UserSecurityService(dbContext);

        var user = await service.CreateUserAsync(new CreateUserRequest
        {
            UserName = "auditor",
            DisplayName = "Auditor",
            Password = "StrongPass!123",
            IsActive = true
        });

        var audit = await service.WriteAuditAsync(new WriteAuditRequest
        {
            EntityName = "app_settings",
            EntityId = "general",
            Action = "update",
            ActorUserName = user.User!.UserName,
            CorrelationId = "corr-1",
            Reason = "Changed setting",
            BeforeJson = "{\"value\":\"old\"}",
            AfterJson = "{\"value\":\"new\"}"
        });

        Assert.NotNull(audit);
        Assert.Equal("app_settings", audit.EntityName);
        Assert.Equal("update", audit.Action);
    }

    [Fact]
    public async Task Authorization_ChecksPermissionFromAssignedRole()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        using var dbContext = new YasinWorkshopDbContext(options);
        var service = new UserSecurityService(dbContext);

        var adminRole = await service.CreateRoleAsync(new CreateRoleRequest { Name = "Administrator" });
        var permission = await service.CreatePermissionAsync(new CreatePermissionRequest { Code = "settings.write" });
        await service.AssignPermissionToRoleAsync(adminRole.Id, permission.Id);

        var user = await service.CreateUserAsync(new CreateUserRequest
        {
            UserName = "security-admin",
            DisplayName = "Security Admin",
            Password = "StrongPass!123",
            IsActive = true
        });

        await service.AssignRoleToUserAsync(user.User!.Id, adminRole.Id);

        Assert.True(await service.IsUserAuthorizedAsync("security-admin", "settings.write"));
        Assert.False(await service.IsUserAuthorizedAsync("security-admin", "secret.delete"));
    }
}
