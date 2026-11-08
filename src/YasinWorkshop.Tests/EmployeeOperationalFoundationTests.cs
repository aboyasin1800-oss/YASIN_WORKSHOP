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

    [Fact]
    public async Task CreateEmployee_AllowsSameNameButRejectsDuplicateCode()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new EmployeeOperationalService(dbContext);

        var first = await service.CreateEmployeeAsync(new CreateEmployeeRequest
        {
            EmployeeCode = "EMP-3001",
            Name = "محمد علي",
            EmployeeType = "Piece",
            Status = "Active"
        });

        var second = await service.CreateEmployeeAsync(new CreateEmployeeRequest
        {
            EmployeeCode = "EMP-3002",
            Name = "محمد علي",
            EmployeeType = "Salary",
            Status = "Active"
        });

        Assert.True(first.IsSuccess);
        Assert.True(second.IsSuccess);
        Assert.Equal(2, await dbContext.Employees.CountAsync());
    }

    [Fact]
    public async Task EmployeeSync_RejectsOldBaseVersionAndReplaysIdempotently()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new EmployeeSyncService(dbContext);

        var created = await service.ApplyEmployeeSyncAsync(new EmployeeSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            EntityType = "employee",
            EntityId = string.Empty,
            OperationType = "create",
            Payload = "{\"employeeCode\":\"EMP-9001\",\"name\":\"Worker One\",\"phone\":\"0500000001\",\"employeeType\":\"Piece\",\"status\":\"Active\"}",
            BaseVersion = string.Empty,
            IdempotencyKey = "emp-sync-9001"
        });

        Assert.True(created.IsSuccess);
        Assert.Equal("success", created.ResultCode, ignoreCase: true);

        var employee = await dbContext.Employees.SingleAsync(x => x.EmployeeCode == "EMP-9001");
        var stale = await service.ApplyEmployeeSyncAsync(new EmployeeSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            EntityType = "employee",
            EntityId = employee.Id.ToString(),
            OperationType = "update",
            Payload = "{\"employeeCode\":\"EMP-9001\",\"name\":\"Worker One Updated\",\"phone\":\"0500000002\",\"employeeType\":\"Piece\",\"status\":\"Active\"}",
            BaseVersion = "stale-version",
            IdempotencyKey = "emp-sync-9001-old"
        });

        Assert.False(stale.IsSuccess);
        Assert.Equal("conflict", stale.ResultCode, ignoreCase: true);

        var replay = await service.ApplyEmployeeSyncAsync(new EmployeeSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            EntityType = "employee",
            EntityId = employee.Id.ToString(),
            OperationType = "update",
            Payload = "{\"employeeCode\":\"EMP-9001\",\"name\":\"Worker One Updated\",\"phone\":\"0500000002\",\"employeeType\":\"Piece\",\"status\":\"Active\"}",
            BaseVersion = created.ServerVersion,
            IdempotencyKey = "emp-sync-9001-repeat"
        });

        Assert.True(replay.IsSuccess);
        Assert.Equal("success", replay.ResultCode, ignoreCase: true);

        var idempotentReplay = await service.ApplyEmployeeSyncAsync(new EmployeeSyncRequest
        {
            OperationId = Guid.NewGuid(),
            ClientId = Guid.NewGuid(),
            EntityType = "employee",
            EntityId = employee.Id.ToString(),
            OperationType = "update",
            Payload = "{\"employeeCode\":\"EMP-9001\",\"name\":\"Worker One Updated\",\"phone\":\"0500000002\",\"employeeType\":\"Piece\",\"status\":\"Active\"}",
            BaseVersion = created.ServerVersion,
            IdempotencyKey = "emp-sync-9001-repeat"
        });

        Assert.True(idempotentReplay.IsSuccess);
        Assert.Equal("replay", idempotentReplay.ResultCode, ignoreCase: true);
        Assert.Equal(1, await dbContext.Employees.CountAsync(x => x.EmployeeCode == "EMP-9001"));
    }

    [Fact]
    public async Task MonthlyCompensation_InheritsPreviousMonthAndKeepsHistoricalMonthsIndependent()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var employee = await CreateEmployeeAsync(dbContext, "EMP-4001", "Ali");
        var compensationService = new EmployeeFinancialService(dbContext, new FixedClock(new DateTime(2026, 1, 10, 8, 0, 0, DateTimeKind.Utc)));

        var firstMonth = await compensationService.SetMonthlyCompensationAsync(employee.Id, 2026, 1, "Piece", 25m, "SAR");
        Assert.True(firstMonth.IsSuccess);

        var secondMonth = await compensationService.SetMonthlyCompensationAsync(employee.Id, 2026, 2, "Piece", 30m, "SAR");
        Assert.True(secondMonth.IsSuccess);

        var inherited = await compensationService.GetEffectiveCompensationAsync(employee.Id, 2026, 3);
        Assert.NotNull(inherited);
        Assert.Equal(30m, inherited!.Amount);

        var january = await compensationService.GetEffectiveCompensationAsync(employee.Id, 2026, 1);
        Assert.NotNull(january);
        Assert.Equal(25m, january!.Amount);
    }

    [Fact]
    public async Task DailyProduction_UsesOperationMonthRateAndCalculatesAmount()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var employee = await CreateEmployeeAsync(dbContext, "EMP-5001", "Production Worker");
        var service = new EmployeeFinancialService(dbContext, new FixedClock(new DateTime(2026, 2, 10, 9, 0, 0, DateTimeKind.Utc)));

        var contract = await service.SetMonthlyCompensationAsync(employee.Id, 2026, 2, "Piece", 12m, "SAR");
        Assert.True(contract.IsSuccess);

        var production = await service.CreateProductionAsync(new CreateEmployeeProductionRequest
        {
            EmployeeId = employee.Id,
            OperationDate = new DateTime(2026, 2, 15),
            Quantity = 12,
            ResolvedUnitRate = 12m,
            CreatedBy = "ops-1",
            Notes = "Late entry test"
        });

        Assert.True(production.IsSuccess);
        Assert.Equal(144m, production.Production!.CalculatedAmount);
        Assert.Equal(2026, production.Production.OperationDate.Year);
        Assert.Equal(2, production.Production.OperationDate.Month);
        Assert.Equal("ops-1", production.Production.CreatedBy);
    }

    [Fact]
    public async Task Settlement_AllocatesOldestFirstAndCreatesDebtWhenNeeded()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var employee = await CreateEmployeeAsync(dbContext, "EMP-6001", "Settlement Worker");
        var service = new EmployeeFinancialService(dbContext, new FixedClock(new DateTime(2026, 3, 20, 8, 0, 0, DateTimeKind.Utc)));

        await service.SetMonthlyCompensationAsync(employee.Id, 2026, 3, "Piece", 50m, "SAR");
        await service.CreateProductionAsync(new CreateEmployeeProductionRequest
        {
            EmployeeId = employee.Id,
            OperationDate = new DateTime(2026, 3, 5),
            Quantity = 4,
            ResolvedUnitRate = 20m,
            CreatedBy = "ops-1"
        });

        await service.CreateExpenseAsync(new CreateEmployeeExpenseRequest
        {
            EmployeeId = employee.Id,
            OperationDate = new DateTime(2026, 3, 7),
            Amount = 30m,
            CreatedBy = "ops-1",
            Notes = "Draw"
        });

        var settlement = await service.CreateSettlementAsync(new CreateEmployeeSettlementRequest
        {
            EmployeeId = employee.Id,
            SettlementDate = new DateTime(2026, 3, 20),
            Amount = 100m,
            CreatedBy = "ops-1",
            Notes = "Monthly settlement"
        });

        Assert.True(settlement.IsSuccess);
        Assert.True(settlement.Settlement!.TotalAllocated > 0m);
        Assert.Equal(1, await dbContext.EmployeeSettlementAllocations.CountAsync());
    }

    [Fact]
    public async Task Expense_RecordsAmount_And_FirstSavedAt_Immutable()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var employee = await CreateEmployeeAsync(dbContext, "EMP-7001", "Cash Worker");
        var now = new DateTime(2026, 4, 5, 10, 0, 0, DateTimeKind.Utc);
        var service = new EmployeeFinancialService(dbContext, new FixedClock(now));

        var expense = await service.CreateExpenseAsync(new CreateEmployeeExpenseRequest
        {
            EmployeeId = employee.Id,
            OperationDate = new DateTime(2026, 4, 3),
            Amount = 120m,
            CreatedBy = "ops-1"
        });

        Assert.True(expense.IsSuccess);
        Assert.NotNull(expense.Expense);
        Assert.Equal(120m, expense.Expense!.Amount);
        Assert.Equal(now, expense.Expense.FirstSavedAt);

        var allowedUpdate = await service.UpdateExpenseAsync(new UpdateEmployeeExpenseRequest
        {
            ExpenseId = expense.Expense.Id,
            Amount = 200m,
            CreatedBy = "ops-2",
            Reason = "Within window",
            AcceptedByPrivilege = false
        });

        Assert.True(allowedUpdate.IsSuccess);
        Assert.Equal(200m, allowedUpdate.Expense!.Amount);

        var staleExpense = new EmployeeExpense
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            OperationDate = new DateTime(2026, 4, 1),
            Amount = 50m,
            FirstSavedAt = new DateTime(2026, 4, 1, 8, 0, 0, DateTimeKind.Utc),
            CreatedAt = new DateTime(2026, 4, 1, 8, 0, 0, DateTimeKind.Utc),
            UpdatedAt = new DateTime(2026, 4, 1, 8, 0, 0, DateTimeKind.Utc),
            CreatedBy = "ops-old"
        };

        dbContext.EmployeeExpenses.Add(staleExpense);
        await dbContext.SaveChangesAsync();

        var rejectedUpdate = await service.UpdateExpenseAsync(new UpdateEmployeeExpenseRequest
        {
            ExpenseId = staleExpense.Id,
            Amount = 75m,
            CreatedBy = "ops-3",
            Reason = "Late correction",
            AcceptedByPrivilege = false
        });

        Assert.False(rejectedUpdate.IsSuccess);
        Assert.Contains("24", rejectedUpdate.Message, StringComparison.OrdinalIgnoreCase);
    }

    public static async Task<Employee> CreateEmployeeAsync(YasinWorkshopDbContext dbContext, string employeeCode, string name)
    {
        var service = new EmployeeOperationalService(dbContext);
        var result = await service.CreateEmployeeAsync(new CreateEmployeeRequest
        {
            EmployeeCode = employeeCode,
            Name = name,
            EmployeeType = "Piece",
            Status = "Active"
        });

        Assert.True(result.IsSuccess, result.Message);
        return result.Employee!;
    }

    private sealed class FixedClock : IEmployeeClock
    {
        private readonly DateTime _now;

        public FixedClock(DateTime now)
        {
            _now = now;
        }

        public DateTime UtcNow => _now;
    }
}
