using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Security;

namespace YasinWorkshop.Api.Api;

public static class EmployeeOperationalEndpoints
{
    public static WebApplication MapEmployeeOperationalEndpoints(this WebApplication app)
    {
        app.MapGet("/api/employees", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, string? search, string? status, string? type, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "employees.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var service = new EmployeeOperationalService(dbContext);
            var employees = await service.ListEmployeesAsync(search, status, type);

            return Results.Ok(employees.Select(x => new
            {
                x.Id,
                x.EmployeeCode,
                x.Name,
                x.Phone,
                x.WhatsApp,
                x.Email,
                x.EmployeeType,
                x.Status,
                x.IsArchived,
                x.StartDate,
                x.EndDate,
                x.Notes,
                x.CreatedAt,
                x.UpdatedAt
            }));
        });

        app.MapGet("/api/employees/{id:guid}", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, Guid id, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "employees.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var employee = await dbContext.Employees
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

            if (employee is null)
            {
                return Results.NotFound();
            }

            return Results.Ok(new
            {
                employee.Id,
                employee.EmployeeCode,
                employee.Name,
                employee.Phone,
                employee.WhatsApp,
                employee.Email,
                employee.EmployeeType,
                employee.Status,
                employee.IsArchived,
                employee.StartDate,
                employee.EndDate,
                employee.Notes,
                employee.CreatedAt,
                employee.UpdatedAt
            });
        });

        app.MapPost("/api/employees", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, CreateEmployeeRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "employees.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var service = new EmployeeOperationalService(dbContext);
            var result = await service.CreateEmployeeAsync(request);
            if (!result.IsSuccess)
            {
                return Results.BadRequest(new { result.Message });
            }

            await userSecurityService.WriteAuditAsync(new WriteAuditRequest
            {
                EntityName = "employees",
                EntityId = result.Employee!.Id.ToString(),
                Action = "create",
                ActorUserName = auth.UserName,
                Reason = "Employee created via operational foundation workflow.",
                AfterJson = $"{{\"employeeCode\":\"{result.Employee.EmployeeCode}\",\"name\":\"{result.Employee.Name}\"}}"
            });

            return Results.Ok(new
            {
                result.Employee.Id,
                result.Employee.EmployeeCode,
                result.Employee.Name,
                result.Employee.EmployeeType,
                result.Employee.Status,
                result.Message
            });
        });

        app.MapPatch("/api/employees/{id:guid}", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, Guid id, UpdateEmployeeRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "employees.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var employee = await dbContext.Employees.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
            if (employee is null)
            {
                return Results.NotFound();
            }

            var beforeJson = $"{{\"employeeCode\":\"{employee.EmployeeCode}\",\"name\":\"{employee.Name}\",\"status\":\"{employee.Status}\"}}";

            employee.EmployeeCode = string.IsNullOrWhiteSpace(request.EmployeeCode) ? employee.EmployeeCode : request.EmployeeCode.Trim();
            employee.Name = string.IsNullOrWhiteSpace(request.Name) ? employee.Name : request.Name.Trim();
            employee.Phone = request.Phone is null ? employee.Phone : string.IsNullOrWhiteSpace(request.Phone) ? null : request.Phone.Trim();
            employee.WhatsApp = request.WhatsApp is null ? employee.WhatsApp : string.IsNullOrWhiteSpace(request.WhatsApp) ? null : request.WhatsApp.Trim();
            employee.Email = request.Email is null ? employee.Email : string.IsNullOrWhiteSpace(request.Email) ? null : request.Email.Trim();
            employee.EmployeeType = string.IsNullOrWhiteSpace(request.EmployeeType) ? employee.EmployeeType : request.EmployeeType.Trim();
            employee.Status = string.IsNullOrWhiteSpace(request.Status) ? employee.Status : request.Status.Trim();
            employee.IsArchived = request.IsArchived ?? employee.IsArchived;
            employee.StartDate = request.StartDate ?? employee.StartDate;
            employee.EndDate = request.EndDate ?? employee.EndDate;
            employee.Notes = request.Notes is null ? employee.Notes : string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim();
            employee.UpdatedAt = DateTime.UtcNow;

            await dbContext.SaveChangesAsync(cancellationToken);
            await userSecurityService.WriteAuditAsync(new WriteAuditRequest
            {
                EntityName = "employees",
                EntityId = employee.Id.ToString(),
                Action = "update",
                ActorUserName = auth.UserName,
                Reason = "Employee profile updated via operational workflow.",
                BeforeJson = beforeJson,
                AfterJson = $"{{\"employeeCode\":\"{employee.EmployeeCode}\",\"name\":\"{employee.Name}\",\"status\":\"{employee.Status}\"}}"
            });

            return Results.Ok(new
            {
                employee.Id,
                employee.EmployeeCode,
                employee.Name,
                employee.Status,
                employee.UpdatedAt
            });
        });

        app.MapPost("/api/employee-sync/push", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, EmployeeSyncRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "employees.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var syncService = new EmployeeSyncService(dbContext);
            var result = await syncService.ApplyEmployeeSyncAsync(request);

            if (!result.IsSuccess)
            {
                if (string.Equals(result.ResultCode, "conflict", StringComparison.OrdinalIgnoreCase) ||
                    string.Equals(result.ResultCode, "not-found", StringComparison.OrdinalIgnoreCase))
                {
                    return Results.Conflict(new
                    {
                        result.ResultCode,
                        result.Message,
                        result.ServerVersion,
                        result.Employee
                    });
                }

                return Results.BadRequest(new
                {
                    result.ResultCode,
                    result.Message,
                    result.ServerVersion
                });
            }

            return Results.Ok(result);
        });

        app.MapGet("/api/employee-sync/pull", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, [FromQuery] string? fromVersion, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "employees.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var syncService = new EmployeeSyncService(dbContext);
            var result = await syncService.PullEmployeeChangesAsync(fromVersion);
            return Results.Ok(result);
        });

        app.MapPost("/api/employees/{employeeId:guid}/production", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, Guid employeeId, CreateEmployeeProductionRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "employees.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var service = new EmployeeFinancialService(dbContext);
            var result = await service.CreateProductionAsync(new CreateEmployeeProductionRequest
            {
                EmployeeId = employeeId,
                OperationDate = request.OperationDate,
                Quantity = request.Quantity,
                ResolvedUnitRate = request.ResolvedUnitRate,
                CreatedBy = string.IsNullOrWhiteSpace(request.CreatedBy) ? auth.UserName : request.CreatedBy,
                Notes = request.Notes
            });

            if (!result.IsSuccess)
            {
                return Results.BadRequest(new { result.Message });
            }

            return Results.Ok(new
            {
                result.Message,
                Production = result.Production is null ? null : new
                {
                    result.Production.Id,
                    result.Production.EmployeeId,
                    result.Production.OperationDate,
                    result.Production.Quantity,
                    result.Production.ResolvedUnitRate,
                    result.Production.CalculatedAmount,
                    result.Production.FirstSavedAt,
                    result.Production.CreatedAt,
                    result.Production.UpdatedAt,
                    result.Production.CreatedBy,
                    result.Production.Notes
                },
                CreatedAt = result.Production?.CreatedAt,
                FirstSavedAt = result.Production?.FirstSavedAt
            });
        });

        app.MapPost("/api/employees/{employeeId:guid}/expenses", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, Guid employeeId, CreateEmployeeExpenseRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "employees.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var service = new EmployeeFinancialService(dbContext);
            var result = await service.CreateExpenseAsync(new CreateEmployeeExpenseRequest
            {
                EmployeeId = employeeId,
                OperationDate = request.OperationDate,
                Amount = request.Amount,
                CreatedBy = string.IsNullOrWhiteSpace(request.CreatedBy) ? auth.UserName : request.CreatedBy,
                Notes = request.Notes
            });

            if (!result.IsSuccess)
            {
                return Results.BadRequest(new { result.Message });
            }

            return Results.Ok(new
            {
                result.Message,
                Expense = result.Expense is null ? null : new
                {
                    result.Expense.Id,
                    result.Expense.EmployeeId,
                    result.Expense.OperationDate,
                    result.Expense.Amount,
                    result.Expense.FirstSavedAt,
                    result.Expense.CreatedAt,
                    result.Expense.UpdatedAt,
                    result.Expense.CreatedBy,
                    result.Expense.Notes
                },
                CreatedAt = result.Expense?.CreatedAt,
                FirstSavedAt = result.Expense?.FirstSavedAt
            });
        });

        app.MapGet("/api/employees/{employeeId:guid}/statement", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, Guid employeeId, [FromQuery] int year, [FromQuery] int month, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "employees.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var service = new EmployeeFinancialService(dbContext);
            var summary = await service.GetStatementAsync(employeeId, year, month);
            return Results.Ok(summary);
        });

        return app;
    }

    private static async Task<(bool IsAuthorized, string UserName)> AuthorizeAsync(
        HttpContext httpContext,
        YasinWorkshopDbContext dbContext,
        UserSecurityService userSecurityService,
        string requiredPermission,
        CancellationToken cancellationToken)
    {
        var actorUserName = httpContext.Request.Headers["X-User-Name"].FirstOrDefault();
        if (string.IsNullOrWhiteSpace(actorUserName))
        {
            return (false, string.Empty);
        }

        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.UserName == actorUserName.Trim(), cancellationToken);
        if (user is null || !user.IsActive)
        {
            return (false, string.Empty);
        }

        var isAuthorized = await userSecurityService.HasPermissionAsync(user.Id, requiredPermission);
        return isAuthorized ? (true, user.UserName) : (false, string.Empty);
    }

    public sealed record UpdateEmployeeRequest
    {
        public string? EmployeeCode { get; init; }
        public string? Name { get; init; }
        public string? Phone { get; init; }
        public string? WhatsApp { get; init; }
        public string? Email { get; init; }
        public string? EmployeeType { get; init; }
        public string? Status { get; init; }
        public bool? IsArchived { get; init; }
        public DateTime? StartDate { get; init; }
        public DateTime? EndDate { get; init; }
        public string? Notes { get; init; }
    }
}
