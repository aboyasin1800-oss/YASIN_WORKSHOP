using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Security;

namespace YasinWorkshop.Tests;

public sealed class CustomerSyncOperationalFoundationTests
{
    [Fact]
    public async Task PushCustomerCreate_IsIdempotent_AndConflictDetectedWhenBaseVersionDiffers()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new CustomerSyncService(dbContext);

        var first = await service.ApplyCustomerSyncAsync(new CustomerSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            IdempotencyKey = "sync-customer-1",
            EntityType = "customer",
            EntityId = "customer-101",
            OperationType = "create",
            BaseVersion = "v0",
            Payload = "{\"name\":\"Test Sync Customer\",\"email\":\"sync@example.com\"}"
        });

        Assert.True(first.IsSuccess);
        Assert.Equal(1, await dbContext.Customers.CountAsync());

        var retry = await service.ApplyCustomerSyncAsync(new CustomerSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            IdempotencyKey = "sync-customer-1",
            EntityType = "customer",
            EntityId = "customer-101",
            OperationType = "create",
            BaseVersion = "v0",
            Payload = "{\"name\":\"Test Sync Customer\",\"email\":\"sync@example.com\"}"
        });

        Assert.True(retry.IsSuccess);
        Assert.Equal(1, await dbContext.Customers.CountAsync());

        var serverCustomer = await dbContext.Customers.SingleAsync();
        var conflict = await service.ApplyCustomerSyncAsync(new CustomerSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            IdempotencyKey = "sync-customer-2",
            EntityType = "customer",
            EntityId = serverCustomer.Id.ToString(),
            OperationType = "update",
            BaseVersion = "stale-version",
            Payload = "{\"name\":\"Updated Remote\"}"
        });

        Assert.False(conflict.IsSuccess);
        Assert.Equal("conflict", conflict.ResultCode);
    }

    [Fact]
    public async Task PullCustomerChanges_UsesVersionCursor()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new CustomerSyncService(dbContext);

        var created = await service.ApplyCustomerSyncAsync(new CustomerSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            IdempotencyKey = "sync-customer-pull-1",
            EntityType = "customer",
            EntityId = "customer-200",
            OperationType = "create",
            BaseVersion = "v0",
            Payload = "{\"name\":\"Pull Customer\",\"email\":\"pull@example.com\"}"
        });

        Assert.True(created.IsSuccess);

        var pull = await service.PullCustomerChangesAsync("v0");

        Assert.NotNull(pull);
        Assert.NotEmpty(pull.Items);
        Assert.True(pull.HasMore == false || pull.Items.Count > 0);
    }
}
