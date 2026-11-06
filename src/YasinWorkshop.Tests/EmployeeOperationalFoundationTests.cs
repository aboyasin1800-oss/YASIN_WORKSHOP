using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Security;

namespace YasinWorkshop.Tests;

public sealed class EmployeeOperationalFoundationTests
{
    [Fact]
    public async Task CreateEmployee_StoresEmployeeAndRejectsDuplicateCode()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new EmployeeOperationalService(dbContext);

        var created = await service.CreateEmployeeAsync(new CreateEmployeeRequest
        {
            EmployeeCode = "EMP-1001",
            Name = "Ali Ahmed",
            Phone = "0501111111",
            WhatsApp = "0501111111",
            EmployeeType = "Piece",
            Status = "Active",
            Notes = "Primary production worker"
        });

        Assert.True(created.IsSuccess);
        Assert.NotNull(created.Employee);
        Assert.Equal("EMP-1001", created.Employee!.EmployeeCode);

        var duplicate = await service.CreateEmployeeAsync(new CreateEmployeeRequest
        {
            EmployeeCode = "EMP-1001",
            Name = "Another Worker",
            Phone = "0502222222",
            EmployeeType = "Salary",
            Status = "Active"
        });

        Assert.False(duplicate.IsSuccess);
        Assert.Contains("already exists", duplicate.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task ListEmployees_FiltersByTypeAndStatus()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new EmployeeOperationalService(dbContext);

        await service.CreateEmployeeAsync(new CreateEmployeeRequest
        {
            EmployeeCode = "EMP-2001",
            Name = "Worker A",
            Phone = "0503333333",
            EmployeeType = "Piece",
            Status = "Active"
        });

        await service.CreateEmployeeAsync(new CreateEmployeeRequest
        {
            EmployeeCode = "EMP-2002",
            Name = "Worker B",
            Phone = "0504444444",
            EmployeeType = "Salary",
            Status = "Stopped"
        });

        var pieceEmployees = await service.ListEmployeesAsync(status: "Active");
        var salaryStopped = await service.ListEmployeesAsync(type: "Salary", status: "Stopped");

        Assert.Equal(1, pieceEmployees.Count(x => x.EmployeeType == "Piece"));
        Assert.Single(salaryStopped);
        Assert.Equal("Worker B", salaryStopped[0].Name);
    }
}
