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
}
