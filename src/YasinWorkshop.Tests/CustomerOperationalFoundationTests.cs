using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Security;

namespace YasinWorkshop.Tests;

public sealed class CustomerOperationalFoundationTests
{
    [Fact]
    public async Task CreateCustomer_StoresCustomerAndRejectsDuplicateName()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new CustomerOperationalService(dbContext);

        var created = await service.CreateCustomerAsync(new CreateCustomerRequest
        {
            Name = "Al Noor Textile",
            ContactName = "Ahmed",
            Phone = "0500000000",
            RelationshipType = "Wholesale",
            Status = "Active",
            Notes = "Preferred customer"
        });

        Assert.True(created.IsSuccess);
        Assert.NotNull(created.Customer);
        Assert.Equal("Al Noor Textile", created.Customer!.Name);

        var duplicate = await service.CreateCustomerAsync(new CreateCustomerRequest
        {
            Name = "Al Noor Textile",
            ContactName = "Another",
            Phone = "0555555555",
            RelationshipType = "Retail",
            Status = "Active"
        });

        Assert.False(duplicate.IsSuccess);
        Assert.Contains("already exists", duplicate.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task SetMonthlyPrice_RejectsDuplicateYearMonthAndTracksCurrentPrice()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new CustomerOperationalService(dbContext);

        var customer = await service.CreateCustomerAsync(new CreateCustomerRequest
        {
            Name = "Yasin Fashion",
            ContactName = "Yasin",
            Phone = "0550000000",
            RelationshipType = "Wholesale",
            Status = "Active"
        });

        Assert.True(customer.IsSuccess);

        var firstPrice = await service.SetMonthlyPriceAsync(customer.Customer!.Id, 2026, 11, 1500m, "SAR");
        var duplicatePrice = await service.SetMonthlyPriceAsync(customer.Customer.Id, 2026, 11, 1700m, "SAR");
        var currentPrice = await service.GetCurrentMonthlyPriceAsync(customer.Customer.Id, 2026, 11);

        Assert.True(firstPrice.IsSuccess);
        Assert.False(duplicatePrice.IsSuccess);
        Assert.NotNull(currentPrice);
        Assert.Equal(1500m, currentPrice!.MonthlyRate);
        Assert.Equal("SAR", currentPrice.Currency);
    }
}
