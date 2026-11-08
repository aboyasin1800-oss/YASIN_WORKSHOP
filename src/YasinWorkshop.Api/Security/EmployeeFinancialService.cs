using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;

namespace YasinWorkshop.Api.Security;

public interface IEmployeeClock
{
    DateTime UtcNow { get; }
}

public sealed class SystemEmployeeClock : IEmployeeClock
{
    public DateTime UtcNow => DateTime.UtcNow;
}

public sealed record CreateEmployeeMonthlyCompensationRequest
{
    public Guid EmployeeId { get; init; }
    public int Year { get; init; }
    public int Month { get; init; }
    public string CompensationType { get; init; } = "Piece";
    public decimal Amount { get; init; }
    public string Currency { get; init; } = "SAR";
    public string? Notes { get; init; }
}

public sealed record CreateEmployeeProductionRequest
{
    public Guid EmployeeId { get; init; }
    public DateTime OperationDate { get; init; }
    public decimal Quantity { get; init; }
    public decimal ResolvedUnitRate { get; init; }
    public string CreatedBy { get; init; } = "system";
    public string? Notes { get; init; }
}

public sealed record CreateEmployeeExpenseRequest
{
    public Guid EmployeeId { get; init; }
    public DateTime OperationDate { get; init; }
    public decimal Amount { get; init; }
    public string CreatedBy { get; init; } = "system";
    public string? Notes { get; init; }
}

public sealed record UpdateEmployeeExpenseRequest
{
    public Guid ExpenseId { get; init; }
    public DateTime? OperationDate { get; init; }
    public decimal? Amount { get; init; }
    public string? CreatedBy { get; init; }
    public string? Reason { get; init; }
    public bool AcceptedByPrivilege { get; init; }
    public string? Notes { get; init; }
}

public sealed record CreateEmployeeSettlementRequest
{
    public Guid EmployeeId { get; init; }
    public DateTime SettlementDate { get; init; }
    public decimal Amount { get; init; }
    public string CreatedBy { get; init; } = "system";
    public string? Notes { get; init; }
}

public sealed record EmployeeFinancialActionResult
{
    public bool IsSuccess { get; init; }
    public string Message { get; init; } = string.Empty;
    public EmployeeMonthlyCompensation? Compensation { get; init; }
    public EmployeeProductionEntry? Production { get; init; }
    public EmployeeExpense? Expense { get; init; }
    public EmployeeSettlement? Settlement { get; init; }
}

public sealed record EmployeeStatementSummary
{
    public Guid EmployeeId { get; init; }
    public int Year { get; init; }
    public int Month { get; init; }
    public decimal ProductionEarnings { get; init; }
    public decimal MonthlySalaryEntitlement { get; init; }
    public decimal ExpenseTotal { get; init; }
    public decimal Settlements { get; init; }
    public decimal DebtCreated { get; init; }
    public decimal DebtRecovery { get; init; }
    public decimal OutstandingDebt { get; init; }
    public decimal DerivedBalance { get; init; }
}

public sealed class EmployeeFinancialService
{
    private readonly YasinWorkshopDbContext _dbContext;
    private readonly IEmployeeClock _clock;

    public EmployeeFinancialService(YasinWorkshopDbContext dbContext, IEmployeeClock? clock = null)
    {
        _dbContext = dbContext;
        _clock = clock ?? new SystemEmployeeClock();
    }

    public async Task<EmployeeFinancialActionResult> SetMonthlyCompensationAsync(
        Guid employeeId,
        int year,
        int month,
        string compensationType,
        decimal amount,
        string currency = "SAR",
        string? notes = null)
    {
        if (year < 2000 || month is < 1 or > 12)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Year and month must be valid." };
        }

        if (amount < 0)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Amount cannot be negative." };
        }

        var normalizedType = (compensationType ?? string.Empty).Trim();
        if (!string.Equals(normalizedType, "Piece", StringComparison.OrdinalIgnoreCase) &&
            !string.Equals(normalizedType, "Salary", StringComparison.OrdinalIgnoreCase))
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Compensation type must be Piece or Salary." };
        }

        var employee = await _dbContext.Employees.FirstOrDefaultAsync(x => x.Id == employeeId);
        if (employee is null)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Employee was not found." };
        }

        var existing = await _dbContext.EmployeeMonthlyCompensations
            .FirstOrDefaultAsync(x => x.EmployeeId == employeeId && x.Year == year && x.Month == month);
        if (existing is not null)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = $"A compensation contract already exists for {year}-{month:00}." };
        }

        var contract = new EmployeeMonthlyCompensation
        {
            Id = Guid.NewGuid(),
            EmployeeId = employeeId,
            Year = year,
            Month = month,
            CompensationType = normalizedType,
            Amount = amount,
            Currency = string.IsNullOrWhiteSpace(currency) ? "SAR" : currency.Trim(),
            IsCurrent = true,
            Notes = string.IsNullOrWhiteSpace(notes) ? null : notes.Trim(),
            CreatedAt = _clock.UtcNow,
            UpdatedAt = _clock.UtcNow
        };

        _dbContext.EmployeeMonthlyCompensations.Add(contract);
        await _dbContext.SaveChangesAsync();

        await RecoverOpenDebtAsync(employeeId, "monthly-compensation", contract.Amount, "system", contract.Id, contract.Year, contract.Month);

        return new EmployeeFinancialActionResult
        {
            IsSuccess = true,
            Message = "Compensation contract saved successfully.",
            Compensation = contract
        };
    }

    public async Task<EmployeeMonthlyCompensation?> GetEffectiveCompensationAsync(Guid employeeId, int year, int month)
    {
        var exact = await _dbContext.EmployeeMonthlyCompensations
            .AsNoTracking()
            .Where(x => x.EmployeeId == employeeId && x.Year == year && x.Month == month)
            .OrderByDescending(x => x.Year)
            .ThenByDescending(x => x.Month)
            .FirstOrDefaultAsync();

        if (exact is not null)
        {
            return exact;
        }

        var latest = await _dbContext.EmployeeMonthlyCompensations
            .AsNoTracking()
            .Where(x => x.EmployeeId == employeeId && (x.Year < year || (x.Year == year && x.Month < month)))
            .OrderByDescending(x => x.Year)
            .ThenByDescending(x => x.Month)
            .FirstOrDefaultAsync();

        return latest;
    }

    public async Task<EmployeeFinancialActionResult> CreateProductionAsync(CreateEmployeeProductionRequest request)
    {
        var employee = await _dbContext.Employees.FirstOrDefaultAsync(x => x.Id == request.EmployeeId);
        if (employee is null)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Employee was not found." };
        }

        if (!string.Equals(employee.EmployeeType, "Piece", StringComparison.OrdinalIgnoreCase))
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Only Piece workers can create production entries." };
        }

        if (request.Quantity < 0)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Quantity cannot be negative." };
        }

        if (request.ResolvedUnitRate < 0)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Resolved unit rate cannot be negative." };
        }

        var contract = await GetEffectiveCompensationAsync(employee.Id, request.OperationDate.Year, request.OperationDate.Month);
        if (contract is null)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "No valid monthly compensation contract exists for the operation month." };
        }

        var now = _clock.UtcNow;
        var production = new EmployeeProductionEntry
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            OperationDate = request.OperationDate.Date,
            Quantity = request.Quantity,
            ResolvedUnitRate = request.ResolvedUnitRate,
            CalculatedAmount = request.Quantity * request.ResolvedUnitRate,
            FirstSavedAt = now,
            CreatedAt = now,
            UpdatedAt = now,
            CreatedBy = string.IsNullOrWhiteSpace(request.CreatedBy) ? "system" : request.CreatedBy.Trim(),
            Notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim()
        };

        _dbContext.EmployeeProductionEntries.Add(production);
        await _dbContext.SaveChangesAsync();

        await RecoverOpenDebtAsync(employee.Id, "production", production.CalculatedAmount, production.CreatedBy, production.Id, production.OperationDate.Year, production.OperationDate.Month);

        return new EmployeeFinancialActionResult
        {
            IsSuccess = true,
            Message = "Production entry created successfully.",
            Production = production
        };
    }

    public async Task<EmployeeFinancialActionResult> CreateExpenseAsync(CreateEmployeeExpenseRequest request)
    {
        var employee = await _dbContext.Employees.FirstOrDefaultAsync(x => x.Id == request.EmployeeId);
        if (employee is null)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Employee was not found." };
        }

        if (request.Amount < 0)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Amount cannot be negative." };
        }

        var now = _clock.UtcNow;
        var expense = new EmployeeExpense
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            OperationDate = request.OperationDate.Date,
            Amount = request.Amount,
            FirstSavedAt = now,
            CreatedAt = now,
            UpdatedAt = now,
            CreatedBy = string.IsNullOrWhiteSpace(request.CreatedBy) ? "system" : request.CreatedBy.Trim(),
            Notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim()
        };

        _dbContext.EmployeeExpenses.Add(expense);
        await _dbContext.SaveChangesAsync();

        return new EmployeeFinancialActionResult
        {
            IsSuccess = true,
            Message = "Expense recorded successfully.",
            Expense = expense
        };
    }

    public async Task<EmployeeFinancialActionResult> UpdateExpenseAsync(UpdateEmployeeExpenseRequest request)
    {
        var expense = await _dbContext.EmployeeExpenses.FirstOrDefaultAsync(x => x.Id == request.ExpenseId);
        if (expense is null)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Expense was not found." };
        }

        var now = _clock.UtcNow;
        var windowElapsed = now - expense.FirstSavedAt;
        var withinWindow = windowElapsed <= TimeSpan.FromHours(24);
        if (!withinWindow && !request.AcceptedByPrivilege)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Expense updates are denied after 24 hours unless a privileged correction is approved." };
        }

        if (!withinWindow && request.AcceptedByPrivilege)
        {
            if (string.IsNullOrWhiteSpace(request.Reason))
            {
                return new EmployeeFinancialActionResult { IsSuccess = false, Message = "A correction reason is required for privileged expense updates after 24 hours." };
            }
        }

        expense.OperationDate = (request.OperationDate ?? expense.OperationDate).Date;
        expense.Amount = request.Amount ?? expense.Amount;
        expense.UpdatedAt = now;
        expense.Notes = string.IsNullOrWhiteSpace(request.Notes) ? expense.Notes : request.Notes.Trim();

        await _dbContext.SaveChangesAsync();

        return new EmployeeFinancialActionResult
        {
            IsSuccess = true,
            Message = "Expense updated successfully.",
            Expense = expense
        };
    }

    public async Task<EmployeeFinancialActionResult> CreateSettlementAsync(CreateEmployeeSettlementRequest request)
    {
        if (request.Amount < 0)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Settlement amount cannot be negative." };
        }

        var employee = await _dbContext.Employees.FirstOrDefaultAsync(x => x.Id == request.EmployeeId);
        if (employee is null)
        {
            return new EmployeeFinancialActionResult { IsSuccess = false, Message = "Employee was not found." };
        }

        var settlement = new EmployeeSettlement
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            SettlementDate = request.SettlementDate.Date,
            TotalAmount = request.Amount,
            Currency = "SAR",
            Status = "Created",
            CreatedAt = _clock.UtcNow,
            UpdatedAt = _clock.UtcNow,
            CreatedBy = string.IsNullOrWhiteSpace(request.CreatedBy) ? "system" : request.CreatedBy.Trim(),
            Notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim()
        };

        _dbContext.EmployeeSettlements.Add(settlement);
        await _dbContext.SaveChangesAsync();

        var payable = request.Amount;
        var positiveEntries = await _dbContext.EmployeeProductionEntries
            .Where(x => x.EmployeeId == employee.Id)
            .OrderBy(x => x.OperationDate)
            .ThenBy(x => x.CreatedAt)
            .ToListAsync();

        foreach (var entry in positiveEntries)
        {
            if (payable <= 0)
            {
                break;
            }

            var allocated = Math.Min(entry.CalculatedAmount, payable);
            if (allocated <= 0)
            {
                continue;
            }

            _dbContext.EmployeeSettlementAllocations.Add(new EmployeeSettlementAllocation
            {
                Id = Guid.NewGuid(),
                SettlementId = settlement.Id,
                EmployeeId = employee.Id,
                SourceType = "production",
                SourceReference = entry.Id.ToString(),
                Amount = allocated,
                AllocationDate = _clock.UtcNow.Date,
                CreatedAt = _clock.UtcNow,
                CreatedBy = settlement.CreatedBy,
                Notes = $"Allocation for production {entry.Id}"
            });

            payable -= allocated;
        }

        if (payable > 0)
        {
            var debt = new EmployeeDebt
            {
                Id = Guid.NewGuid(),
                EmployeeId = employee.Id,
                Amount = payable,
                OutstandingAmount = payable,
                DebtType = "Shortfall",
                Status = "Open",
                CreatedAt = _clock.UtcNow,
                UpdatedAt = _clock.UtcNow,
                CreatedBy = settlement.CreatedBy,
                Reason = "Settlement shortfall created because available balance was insufficient."
            };

            _dbContext.EmployeeDebts.Add(debt);
        }

        settlement.Status = payable <= 0 ? "Settled" : "Partial";
        settlement.TotalAllocated = request.Amount - payable;
        settlement.UpdatedAt = _clock.UtcNow;
        await _dbContext.SaveChangesAsync();

        return new EmployeeFinancialActionResult
        {
            IsSuccess = true,
            Message = "Settlement recorded successfully.",
            Settlement = settlement
        };
    }

    public async Task<EmployeeStatementSummary> GetStatementAsync(Guid employeeId, int year, int month)
    {
        var production = await _dbContext.EmployeeProductionEntries
            .Where(x => x.EmployeeId == employeeId && x.OperationDate.Year == year && x.OperationDate.Month == month)
            .SumAsync(x => (decimal?)x.CalculatedAmount) ?? 0m;

        var salary = await _dbContext.EmployeeMonthlyCompensations
            .Where(x => x.EmployeeId == employeeId && x.Year == year && x.Month == month && x.CompensationType == "Salary")
            .SumAsync(x => (decimal?)x.Amount) ?? 0m;

        var expenses = await _dbContext.EmployeeExpenses
            .Where(x => x.EmployeeId == employeeId && x.OperationDate.Year == year && x.OperationDate.Month == month)
            .SumAsync(x => (decimal?)x.Amount) ?? 0m;

        var settlements = await _dbContext.EmployeeSettlementAllocations
            .Where(x => x.EmployeeId == employeeId && x.AllocationDate.Year == year && x.AllocationDate.Month == month)
            .SumAsync(x => (decimal?)x.Amount) ?? 0m;

        var debtCreated = await _dbContext.EmployeeDebts
            .Where(x => x.EmployeeId == employeeId && x.CreatedAt.Year == year && x.CreatedAt.Month == month)
            .SumAsync(x => (decimal?)x.Amount) ?? 0m;

        var debtRecovery = await _dbContext.EmployeeDebtRecoveries
            .Where(x => x.EmployeeId == employeeId && x.CreatedAt.Year == year && x.CreatedAt.Month == month)
            .SumAsync(x => (decimal?)x.Amount) ?? 0m;

        var outstandingDebt = await _dbContext.EmployeeDebts
            .Where(x => x.EmployeeId == employeeId && x.Status == "Open")
            .SumAsync(x => (decimal?)x.OutstandingAmount) ?? 0m;

        var derivedBalance = production + salary - expenses - settlements - outstandingDebt + debtRecovery;

        return new EmployeeStatementSummary
        {
            EmployeeId = employeeId,
            Year = year,
            Month = month,
            ProductionEarnings = production,
            MonthlySalaryEntitlement = salary,
            ExpenseTotal = expenses,
            Settlements = settlements,
            DebtCreated = debtCreated,
            DebtRecovery = debtRecovery,
            OutstandingDebt = outstandingDebt,
            DerivedBalance = derivedBalance
        };
    }

    private async Task RecoverOpenDebtAsync(Guid employeeId, string sourceType, decimal amount, string createdBy, Guid sourceId, int year, int month)
    {
        if (amount <= 0)
        {
            return;
        }

        var openDebts = await _dbContext.EmployeeDebts
            .Where(x => x.EmployeeId == employeeId && x.Status == "Open" && x.OutstandingAmount > 0)
            .OrderBy(x => x.CreatedAt)
            .ToListAsync();

        if (openDebts.Count == 0)
        {
            return;
        }

        foreach (var debt in openDebts)
        {
            if (amount <= 0)
            {
                break;
            }

            var used = Math.Min(amount, debt.OutstandingAmount);
            if (used <= 0)
            {
                continue;
            }

            var existingRecovery = await _dbContext.EmployeeDebtRecoveries.AnyAsync(x =>
                x.EmployeeId == employeeId && x.DebtId == debt.Id && x.SourceType == sourceType && x.SourceReference == sourceId.ToString());
            if (existingRecovery)
            {
                continue;
            }

            _dbContext.EmployeeDebtRecoveries.Add(new EmployeeDebtRecovery
            {
                Id = Guid.NewGuid(),
                EmployeeId = employeeId,
                DebtId = debt.Id,
                SourceType = sourceType,
                SourceReference = sourceId.ToString(),
                Amount = used,
                RecoveryDate = _clock.UtcNow.Date,
                CreatedAt = _clock.UtcNow,
                CreatedBy = createdBy,
                Notes = $"Automatic recovery for {sourceType}"
            });

            debt.OutstandingAmount -= used;
            debt.UpdatedAt = _clock.UtcNow;
            if (debt.OutstandingAmount <= 0)
            {
                debt.OutstandingAmount = 0;
                debt.Status = "Recovered";
            }

            amount -= used;
        }
    }
}
