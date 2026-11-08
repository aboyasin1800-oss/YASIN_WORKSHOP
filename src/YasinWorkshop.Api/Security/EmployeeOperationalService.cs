using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;

namespace YasinWorkshop.Api.Security;

public sealed record CreateEmployeeRequest
{
    public string EmployeeCode { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public string? Phone { get; init; }
    public string? WhatsApp { get; init; }
    public string? Email { get; init; }
    public string EmployeeType { get; init; } = "Piece";
    public string Status { get; init; } = "Active";
    public bool IsArchived { get; init; }
    public DateTime? StartDate { get; init; }
    public DateTime? EndDate { get; init; }
    public string? Notes { get; init; }
}

public sealed record CreateEmployeeResult
{
    public bool IsSuccess { get; init; }
    public string Message { get; init; } = string.Empty;
    public Employee? Employee { get; init; }
}

public sealed class EmployeeOperationalService
{
    private readonly YasinWorkshopDbContext _dbContext;

    public EmployeeOperationalService(YasinWorkshopDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<CreateEmployeeResult> CreateEmployeeAsync(CreateEmployeeRequest request)
    {
        var normalizedCode = request.EmployeeCode?.Trim();
        var normalizedName = request.Name?.Trim();

        if (string.IsNullOrWhiteSpace(normalizedCode))
        {
            return new CreateEmployeeResult { IsSuccess = false, Message = "Employee code is required." };
        }

        if (string.IsNullOrWhiteSpace(normalizedName))
        {
            return new CreateEmployeeResult { IsSuccess = false, Message = "Employee name is required." };
        }

        if (await _dbContext.Employees.AnyAsync(x => x.EmployeeCode == normalizedCode))
        {
            return new CreateEmployeeResult { IsSuccess = false, Message = $"Employee code '{normalizedCode}' already exists." };
        }

        var employee = new Employee
        {
            Id = Guid.NewGuid(),
            EmployeeCode = normalizedCode,
            Name = normalizedName,
            Phone = string.IsNullOrWhiteSpace(request.Phone) ? null : request.Phone.Trim(),
            WhatsApp = string.IsNullOrWhiteSpace(request.WhatsApp) ? null : request.WhatsApp.Trim(),
            Email = string.IsNullOrWhiteSpace(request.Email) ? null : request.Email.Trim(),
            EmployeeType = string.IsNullOrWhiteSpace(request.EmployeeType) ? "Piece" : request.EmployeeType.Trim(),
            Status = string.IsNullOrWhiteSpace(request.Status) ? "Active" : request.Status.Trim(),
            IsArchived = request.IsArchived,
            StartDate = request.StartDate,
            EndDate = request.EndDate,
            Notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _dbContext.Employees.Add(employee);
        await _dbContext.SaveChangesAsync();

        return new CreateEmployeeResult
        {
            IsSuccess = true,
            Message = "Employee created successfully.",
            Employee = employee
        };
    }

    public async Task<Employee?> GetEmployeeAsync(Guid employeeId)
    {
        return await _dbContext.Employees
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == employeeId);
    }

    public async Task<List<Employee>> ListEmployeesAsync(string? search = null, string? status = null, string? type = null)
    {
        var query = _dbContext.Employees.AsNoTracking().AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim();
            query = query.Where(x => x.EmployeeCode.Contains(term)
                || x.Name.Contains(term)
                || (x.Phone != null && x.Phone.Contains(term))
                || (x.WhatsApp != null && x.WhatsApp.Contains(term))
                || (x.Email != null && x.Email.Contains(term)));
        }

        if (!string.IsNullOrWhiteSpace(status))
        {
            query = query.Where(x => x.Status == status.Trim());
        }

        if (!string.IsNullOrWhiteSpace(type))
        {
            query = query.Where(x => x.EmployeeType == type.Trim());
        }

        return await query
            .OrderBy(x => x.Name)
            .ToListAsync();
    }
}
