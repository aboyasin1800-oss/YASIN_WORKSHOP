using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Security;

namespace YasinWorkshop.Tests;

public sealed class SupplierOperationalFoundationTests
{
    [Fact]
    public async Task CreateSupplier_StoresSupplierAndRejectsDuplicateCode()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new SupplierOperationalService(dbContext);

        var created = await service.CreateSupplierAsync(new CreateSupplierRequest
        {
            SupplierCode = "SUP-1001",
            Name = "Al Hamad Trading",
            Phone = "0501111111",
            WhatsApp = "0501111111",
            SupplierType = "General",
            Status = "Active",
            Notes = "Primary supplier"
        });

        Assert.True(created.IsSuccess);
        Assert.NotNull(created.Supplier);
        Assert.Equal("SUP-1001", created.Supplier!.SupplierCode);

        var duplicate = await service.CreateSupplierAsync(new CreateSupplierRequest
        {
            SupplierCode = "SUP-1001",
            Name = "Another Supplier",
            Phone = "0502222222",
            SupplierType = "Material",
            Status = "Active"
        });

        Assert.False(duplicate.IsSuccess);
        Assert.Contains("already exists", duplicate.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task ListSuppliers_FiltersByTypeAndStatus()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new SupplierOperationalService(dbContext);

        await service.CreateSupplierAsync(new CreateSupplierRequest
        {
            SupplierCode = "SUP-2001",
            Name = "Supplier A",
            Phone = "0503333333",
            SupplierType = "General",
            Status = "Active"
        });

        await service.CreateSupplierAsync(new CreateSupplierRequest
        {
            SupplierCode = "SUP-2002",
            Name = "Supplier B",
            Phone = "0504444444",
            SupplierType = "Material",
            Status = "Stopped"
        });

        var activeSuppliers = await service.ListSuppliersAsync(status: "Active");
        var materialStopped = await service.ListSuppliersAsync(type: "Material", status: "Stopped");

        Assert.Equal(1, activeSuppliers.Count(x => x.SupplierType == "General"));
        Assert.Single(materialStopped);
        Assert.Equal("Supplier B", materialStopped[0].Name);
    }

    [Fact]
    public async Task SupplierSync_CreateSameNameDifferentCode_ReturnsValidationFailureInsteadOfThrowing()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new SupplierSyncService(dbContext);

        await service.ApplySupplierSyncAsync(new SupplierSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            EntityType = "supplier",
            EntityId = string.Empty,
            OperationType = "create",
            Payload = "{\"supplierCode\":\"SUP-1001\",\"name\":\"Supplier One\",\"phone\":\"0500000001\",\"supplierType\":\"General\",\"status\":\"Active\"}",
            BaseVersion = string.Empty,
            IdempotencyKey = "supp-sync-name-1"
        });

        var duplicateName = await service.ApplySupplierSyncAsync(new SupplierSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            EntityType = "supplier",
            EntityId = string.Empty,
            OperationType = "create",
            Payload = "{\"supplierCode\":\"SUP-1002\",\"name\":\"Supplier One\",\"phone\":\"0500000002\",\"supplierType\":\"Material\",\"status\":\"Active\"}",
            BaseVersion = string.Empty,
            IdempotencyKey = "supp-sync-name-2"
        });

        Assert.False(duplicateName.IsSuccess);
        Assert.Equal("validation-failure", duplicateName.ResultCode, ignoreCase: true);
        Assert.Contains("already exists", duplicateName.Message, StringComparison.OrdinalIgnoreCase);
        Assert.Equal(1, await dbContext.Suppliers.CountAsync(x => x.Name == "Supplier One"));
    }

    [Fact]
    public async Task SupplierSync_RejectsOldBaseVersion_AndReplaysIdempotently()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new SupplierSyncService(dbContext);

        var created = await service.ApplySupplierSyncAsync(new SupplierSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            EntityType = "supplier",
            EntityId = string.Empty,
            OperationType = "create",
            Payload = "{\"supplierCode\":\"SUP-9001\",\"name\":\"Supplier One\",\"phone\":\"0500000001\",\"supplierType\":\"General\",\"status\":\"Active\"}",
            BaseVersion = string.Empty,
            IdempotencyKey = "supp-sync-9001"
        });

        Assert.True(created.IsSuccess);
        Assert.Equal("success", created.ResultCode, ignoreCase: true);

        var supplier = await dbContext.Suppliers.SingleAsync(x => x.SupplierCode == "SUP-9001");
        var stale = await service.ApplySupplierSyncAsync(new SupplierSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            EntityType = "supplier",
            EntityId = supplier.Id.ToString(),
            OperationType = "update",
            Payload = "{\"supplierCode\":\"SUP-9001\",\"name\":\"Supplier One Updated\",\"phone\":\"0500000002\",\"supplierType\":\"General\",\"status\":\"Active\"}",
            BaseVersion = "stale-version",
            IdempotencyKey = "supp-sync-9001-old"
        });

        Assert.False(stale.IsSuccess);
        Assert.Equal("conflict", stale.ResultCode, ignoreCase: true);

        var replay = await service.ApplySupplierSyncAsync(new SupplierSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            EntityType = "supplier",
            EntityId = supplier.Id.ToString(),
            OperationType = "update",
            Payload = "{\"supplierCode\":\"SUP-9001\",\"name\":\"Supplier One Updated\",\"phone\":\"0500000002\",\"supplierType\":\"General\",\"status\":\"Active\"}",
            BaseVersion = created.ServerVersion,
            IdempotencyKey = "supp-sync-9001-repeat"
        });

        Assert.True(replay.IsSuccess);
        Assert.Equal("success", replay.ResultCode, ignoreCase: true);

        var idempotentReplay = await service.ApplySupplierSyncAsync(new SupplierSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            EntityType = "supplier",
            EntityId = supplier.Id.ToString(),
            OperationType = "update",
            Payload = "{\"supplierCode\":\"SUP-9001\",\"name\":\"Supplier One Updated\",\"phone\":\"0500000002\",\"supplierType\":\"General\",\"status\":\"Active\"}",
            BaseVersion = created.ServerVersion,
            IdempotencyKey = "supp-sync-9001-repeat"
        });

        Assert.True(idempotentReplay.IsSuccess);
        Assert.Equal("replay", idempotentReplay.ResultCode, ignoreCase: true);
        Assert.Equal(1, await dbContext.Suppliers.CountAsync(x => x.SupplierCode == "SUP-9001"));
    }
}
