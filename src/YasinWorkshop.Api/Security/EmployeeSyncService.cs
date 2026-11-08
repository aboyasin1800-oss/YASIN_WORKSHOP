using System.Text.Json;
using System.Text.Json.Nodes;
using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;

namespace YasinWorkshop.Api.Security;

public sealed record EmployeeSyncRequest
{
    public Guid OperationId { get; init; }
    public Guid ClientId { get; init; }
    public string EntityType { get; init; } = "employee";
    public string EntityId { get; init; } = string.Empty;
    public string OperationType { get; init; } = "create";
    public string Payload { get; init; } = "{}";
    public string BaseVersion { get; init; } = string.Empty;
    public string IdempotencyKey { get; init; } = string.Empty;
}

public sealed record EmployeeSyncResult
{
    public bool IsSuccess { get; init; }
    public string ResultCode { get; init; } = "success";
    public string Message { get; init; } = string.Empty;
    public string ServerVersion { get; init; } = string.Empty;
    public Employee? Employee { get; init; }
}

public sealed record EmployeeSyncPullItem
{
    public string EntityId { get; init; } = string.Empty;
    public string Version { get; init; } = string.Empty;
    public string Payload { get; init; } = "{}";
}

public sealed record EmployeeSyncPullResult
{
    public string NextVersion { get; init; } = string.Empty;
    public bool HasMore { get; init; }
    public List<EmployeeSyncPullItem> Items { get; init; } = new();
}

public sealed class EmployeeSyncService
{
    private const string OperationScope = "employee-sync";
    private readonly YasinWorkshopDbContext _dbContext;

    public EmployeeSyncService(YasinWorkshopDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<EmployeeSyncResult> ApplyEmployeeSyncAsync(EmployeeSyncRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.IdempotencyKey))
        {
            return new EmployeeSyncResult
            {
                IsSuccess = false,
                ResultCode = "validation-failure",
                Message = "IdempotencyKey is required."
            };
        }

        if (!string.Equals(request.EntityType, "employee", StringComparison.OrdinalIgnoreCase))
        {
            return new EmployeeSyncResult
            {
                IsSuccess = false,
                ResultCode = "unsupported-entity",
                Message = "Only employee sync is supported."
            };
        }

        var existingIdempotency = await _dbContext.IdempotencyKeys
            .FirstOrDefaultAsync(x => x.OperationScope == OperationScope && x.IdempotencyKeyValue == request.IdempotencyKey);

        if (existingIdempotency is not null)
        {
            var employee = await ResolveEmployeeByIdempotencyAsync(existingIdempotency.ResponsePayload);
            return new EmployeeSyncResult
            {
                IsSuccess = true,
                ResultCode = "replay",
                Message = "Operation replayed using the stored idempotency record.",
                ServerVersion = existingIdempotency.ResponsePayload ?? string.Empty,
                Employee = employee
            };
        }

        var payloadNode = JsonNode.Parse(request.Payload) as JsonObject ?? new JsonObject();
        var employeeCode = payloadNode["employeeCode"]?.GetValue<string>() ?? payloadNode["employee_code"]?.GetValue<string>() ?? string.Empty;
        var name = payloadNode["name"]?.GetValue<string>() ?? string.Empty;
        var phone = payloadNode["phone"]?.GetValue<string>();
        var whatsApp = payloadNode["whatsApp"]?.GetValue<string>() ?? payloadNode["whats_app"]?.GetValue<string>();
        var email = payloadNode["email"]?.GetValue<string>();
        var employeeType = payloadNode["employeeType"]?.GetValue<string>() ?? payloadNode["employee_type"]?.GetValue<string>() ?? "Piece";
        var status = payloadNode["status"]?.GetValue<string>() ?? "Active";
        var isArchived = payloadNode["isArchived"]?.GetValue<bool>() ?? false;
        var startDate = payloadNode["startDate"]?.GetValue<string>();
        var endDate = payloadNode["endDate"]?.GetValue<string>();
        var notes = payloadNode["notes"]?.GetValue<string>();

        if (string.IsNullOrWhiteSpace(employeeCode) || string.IsNullOrWhiteSpace(name))
        {
            return new EmployeeSyncResult
            {
                IsSuccess = false,
                ResultCode = "validation-failure",
                Message = "Employee code and name are required for employee sync."
            };
        }

        if (string.Equals(request.OperationType, "create", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(request.OperationType, "upsert", StringComparison.OrdinalIgnoreCase))
        {
            var existingEmployee = await ResolveEmployeeByCodeAsync(employeeCode);
            if (existingEmployee is not null)
            {
                var currentVersion = GetEmployeeVersion(existingEmployee);
                if (!string.IsNullOrWhiteSpace(request.BaseVersion) && !string.Equals(request.BaseVersion, currentVersion, StringComparison.Ordinal))
                {
                    return new EmployeeSyncResult
                    {
                        IsSuccess = false,
                        ResultCode = "conflict",
                        Message = "Employee version differs from supplied base version.",
                        ServerVersion = currentVersion,
                        Employee = existingEmployee
                    };
                }

                return await SaveIdempotencyAndReturnAsync(request, existingEmployee, "success");
            }

            var employee = new Employee
            {
                Id = Guid.NewGuid(),
                EmployeeCode = employeeCode,
                Name = name,
                Phone = string.IsNullOrWhiteSpace(phone) ? null : phone.Trim(),
                WhatsApp = string.IsNullOrWhiteSpace(whatsApp) ? null : whatsApp.Trim(),
                Email = string.IsNullOrWhiteSpace(email) ? null : email.Trim(),
                EmployeeType = string.IsNullOrWhiteSpace(employeeType) ? "Piece" : employeeType.Trim(),
                Status = string.IsNullOrWhiteSpace(status) ? "Active" : status.Trim(),
                IsArchived = isArchived,
                StartDate = ParseOptionalDate(startDate),
                EndDate = ParseOptionalDate(endDate),
                Notes = string.IsNullOrWhiteSpace(notes) ? null : notes.Trim(),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _dbContext.Employees.Add(employee);
            await _dbContext.SaveChangesAsync();

            return await SaveIdempotencyAndReturnAsync(request, employee, "success");
        }

        if (string.Equals(request.OperationType, "update", StringComparison.OrdinalIgnoreCase))
        {
            var employee = await ResolveEmployeeByRequestAsync(request, employeeCode);
            if (employee is null)
            {
                return new EmployeeSyncResult
                {
                    IsSuccess = false,
                    ResultCode = "not-found",
                    Message = "Employee not found for update."
                };
            }

            var currentVersion = GetEmployeeVersion(employee);
            if (!string.IsNullOrWhiteSpace(request.BaseVersion) && !string.Equals(request.BaseVersion, currentVersion, StringComparison.Ordinal))
            {
                return new EmployeeSyncResult
                {
                    IsSuccess = false,
                    ResultCode = "conflict",
                    Message = "Conflict: employee server version differs from supplied base version.",
                    ServerVersion = currentVersion,
                    Employee = employee
                };
            }

            employee.EmployeeCode = employeeCode;
            employee.Name = name;
            employee.Phone = string.IsNullOrWhiteSpace(phone) ? null : phone.Trim();
            employee.WhatsApp = string.IsNullOrWhiteSpace(whatsApp) ? null : whatsApp.Trim();
            employee.Email = string.IsNullOrWhiteSpace(email) ? null : email.Trim();
            employee.EmployeeType = string.IsNullOrWhiteSpace(employeeType) ? "Piece" : employeeType.Trim();
            employee.Status = string.IsNullOrWhiteSpace(status) ? "Active" : status.Trim();
            employee.IsArchived = isArchived;
            employee.StartDate = ParseOptionalDate(startDate) ?? employee.StartDate;
            employee.EndDate = ParseOptionalDate(endDate) ?? employee.EndDate;
            employee.Notes = string.IsNullOrWhiteSpace(notes) ? null : notes.Trim();
            employee.UpdatedAt = DateTime.UtcNow;

            await _dbContext.SaveChangesAsync();

            return await SaveIdempotencyAndReturnAsync(request, employee, "success");
        }

        return new EmployeeSyncResult
        {
            IsSuccess = false,
            ResultCode = "unsupported-operation",
            Message = "Unsupported employee sync operation."
        };
    }

    public async Task<EmployeeSyncPullResult> PullEmployeeChangesAsync(string? fromVersion)
    {
        DateTime fromDate = DateTime.MinValue;
        if (!string.IsNullOrWhiteSpace(fromVersion) && DateTimeOffset.TryParse(fromVersion, out var parsed))
        {
            fromDate = parsed.UtcDateTime;
        }

        var employees = await _dbContext.Employees
            .AsNoTracking()
            .Where(x => (x.UpdatedAt != null && x.UpdatedAt > fromDate) || (x.UpdatedAt == null && x.CreatedAt > fromDate))
            .OrderBy(x => x.CreatedAt)
            .ToListAsync();

        var items = employees
            .Select(employee => new EmployeeSyncPullItem
            {
                EntityId = employee.Id.ToString(),
                Version = GetEmployeeVersion(employee),
                Payload = JsonSerializer.Serialize(new
                {
                    id = employee.Id,
                    employeeCode = employee.EmployeeCode,
                    name = employee.Name,
                    phone = employee.Phone,
                    whatsApp = employee.WhatsApp,
                    email = employee.Email,
                    employeeType = employee.EmployeeType,
                    status = employee.Status,
                    isArchived = employee.IsArchived,
                    startDate = employee.StartDate,
                    endDate = employee.EndDate,
                    notes = employee.Notes,
                    updatedAt = employee.UpdatedAt ?? employee.CreatedAt
                })
            })
            .ToList();

        var nextVersion = items.Count > 0 ? items[^1].Version : fromVersion ?? string.Empty;

        return new EmployeeSyncPullResult
        {
            NextVersion = nextVersion,
            HasMore = false,
            Items = items
        };
    }

    private static string GetEmployeeVersion(Employee employee)
    {
        return (employee.UpdatedAt ?? employee.CreatedAt).ToString("O");
    }

    private static DateTime? ParseOptionalDate(string? rawValue)
    {
        if (string.IsNullOrWhiteSpace(rawValue))
        {
            return null;
        }

        return DateTime.TryParse(rawValue, out var parsed) ? parsed : null;
    }

    private async Task<Employee?> ResolveEmployeeByRequestAsync(EmployeeSyncRequest request, string employeeCode)
    {
        if (!string.IsNullOrWhiteSpace(request.EntityId) && Guid.TryParse(request.EntityId, out var employeeId))
        {
            var byId = await _dbContext.Employees.FirstOrDefaultAsync(x => x.Id == employeeId);
            if (byId is not null)
            {
                return byId;
            }
        }

        return await ResolveEmployeeByCodeAsync(employeeCode);
    }

    private async Task<Employee?> ResolveEmployeeByCodeAsync(string employeeCode)
    {
        return await _dbContext.Employees.FirstOrDefaultAsync(x => x.EmployeeCode == employeeCode);
    }

    private async Task<Employee?> ResolveEmployeeByIdempotencyAsync(string? responsePayload)
    {
        if (string.IsNullOrWhiteSpace(responsePayload))
        {
            return null;
        }

        try
        {
            using var json = JsonDocument.Parse(responsePayload);
            if (json.RootElement.TryGetProperty("employeeId", out var employeeIdProperty) && Guid.TryParse(employeeIdProperty.GetString(), out var employeeId))
            {
                return await _dbContext.Employees.FirstOrDefaultAsync(x => x.Id == employeeId);
            }
        }
        catch (JsonException)
        {
            return null;
        }

        return null;
    }

    private async Task<EmployeeSyncResult> SaveIdempotencyAndReturnAsync(EmployeeSyncRequest request, Employee employee, string resultCode)
    {
        var payload = JsonSerializer.Serialize(new
        {
            action = resultCode,
            employeeId = employee.Id,
            employeeCode = employee.EmployeeCode,
            name = employee.Name,
            version = GetEmployeeVersion(employee)
        });

        var record = new IdempotencyKey
        {
            Id = Guid.NewGuid(),
            OperationScope = OperationScope,
            IdempotencyKeyValue = request.IdempotencyKey,
            Status = "Completed",
            RequestHash = request.Payload,
            ResponsePayload = payload,
            CreatedAt = DateTime.UtcNow
        };

        _dbContext.IdempotencyKeys.Add(record);
        await _dbContext.SaveChangesAsync();

        return new EmployeeSyncResult
        {
            IsSuccess = true,
            ResultCode = resultCode,
            Message = "Employee sync applied successfully.",
            ServerVersion = GetEmployeeVersion(employee),
            Employee = employee
        };
    }
}
