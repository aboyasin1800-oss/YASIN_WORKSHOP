using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Security;

namespace YasinWorkshop.Api.Api;

public static class SupplierOperationalEndpoints
{
    public static WebApplication MapSupplierOperationalEndpoints(this WebApplication app)
    {
        app.MapGet("/api/suppliers", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, string? search, string? status, string? type, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "suppliers.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var service = new SupplierOperationalService(dbContext);
            var suppliers = await service.ListSuppliersAsync(search, status, type);

            return Results.Ok(suppliers.Select(x => new
            {
                x.Id,
                x.SupplierCode,
                x.Name,
                x.ContactName,
                x.Phone,
                x.WhatsApp,
                x.Email,
                x.SupplierType,
                x.Status,
                x.IsArchived,
                x.Notes,
                x.CreatedAt,
                x.UpdatedAt
            }));
        });

        app.MapGet("/api/suppliers/{id:guid}", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, Guid id, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "suppliers.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var supplier = await dbContext.Suppliers
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

            if (supplier is null)
            {
                return Results.NotFound();
            }

            return Results.Ok(new
            {
                supplier.Id,
                supplier.SupplierCode,
                supplier.Name,
                supplier.ContactName,
                supplier.Phone,
                supplier.WhatsApp,
                supplier.Email,
                supplier.SupplierType,
                supplier.Status,
                supplier.IsArchived,
                supplier.Notes,
                supplier.CreatedAt,
                supplier.UpdatedAt
            });
        });

        app.MapPost("/api/suppliers", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, CreateSupplierRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "suppliers.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var service = new SupplierOperationalService(dbContext);
            var result = await service.CreateSupplierAsync(request);
            if (!result.IsSuccess)
            {
                return Results.BadRequest(new { result.Message });
            }

            await userSecurityService.WriteAuditAsync(new WriteAuditRequest
            {
                EntityName = "suppliers",
                EntityId = result.Supplier!.Id.ToString(),
                Action = "create",
                ActorUserName = auth.UserName,
                Reason = "Supplier created via operational foundation workflow.",
                AfterJson = $"{{\"supplierCode\":\"{result.Supplier.SupplierCode}\",\"name\":\"{result.Supplier.Name}\"}}"
            });

            return Results.Ok(new
            {
                result.Supplier.Id,
                result.Supplier.SupplierCode,
                result.Supplier.Name,
                result.Supplier.SupplierType,
                result.Supplier.Status,
                result.Message
            });
        });

        app.MapPatch("/api/suppliers/{id:guid}", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, Guid id, UpdateSupplierRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "suppliers.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var supplier = await dbContext.Suppliers.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
            if (supplier is null)
            {
                return Results.NotFound();
            }

            var beforeJson = $"{{\"supplierCode\":\"{supplier.SupplierCode}\",\"name\":\"{supplier.Name}\",\"status\":\"{supplier.Status}\"}}";

            supplier.SupplierCode = string.IsNullOrWhiteSpace(request.SupplierCode) ? supplier.SupplierCode : request.SupplierCode.Trim();
            supplier.Name = string.IsNullOrWhiteSpace(request.Name) ? supplier.Name : request.Name.Trim();
            supplier.ContactName = request.ContactName is null ? supplier.ContactName : string.IsNullOrWhiteSpace(request.ContactName) ? null : request.ContactName.Trim();
            supplier.Phone = request.Phone is null ? supplier.Phone : string.IsNullOrWhiteSpace(request.Phone) ? null : request.Phone.Trim();
            supplier.WhatsApp = request.WhatsApp is null ? supplier.WhatsApp : string.IsNullOrWhiteSpace(request.WhatsApp) ? null : request.WhatsApp.Trim();
            supplier.Email = request.Email is null ? supplier.Email : string.IsNullOrWhiteSpace(request.Email) ? null : request.Email.Trim();
            supplier.SupplierType = string.IsNullOrWhiteSpace(request.SupplierType) ? supplier.SupplierType : request.SupplierType.Trim();
            supplier.Status = string.IsNullOrWhiteSpace(request.Status) ? supplier.Status : request.Status.Trim();
            supplier.IsArchived = request.IsArchived ?? supplier.IsArchived;
            supplier.Notes = request.Notes is null ? supplier.Notes : string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim();
            supplier.UpdatedAt = DateTime.UtcNow;

            await dbContext.SaveChangesAsync(cancellationToken);
            await userSecurityService.WriteAuditAsync(new WriteAuditRequest
            {
                EntityName = "suppliers",
                EntityId = supplier.Id.ToString(),
                Action = "update",
                ActorUserName = auth.UserName,
                Reason = "Supplier profile updated via operational workflow.",
                BeforeJson = beforeJson,
                AfterJson = $"{{\"supplierCode\":\"{supplier.SupplierCode}\",\"name\":\"{supplier.Name}\",\"status\":\"{supplier.Status}\"}}"
            });

            return Results.Ok(new
            {
                supplier.Id,
                supplier.SupplierCode,
                supplier.Name,
                supplier.Status,
                supplier.UpdatedAt
            });
        });

        app.MapPost("/api/supplier-sync/push", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, SupplierSyncRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "suppliers.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var syncService = new SupplierSyncService(dbContext);
            var result = await syncService.ApplySupplierSyncAsync(request);

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
                        result.Supplier
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

        app.MapGet("/api/supplier-sync/pull", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, [FromQuery] string? fromVersion, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "suppliers.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var syncService = new SupplierSyncService(dbContext);
            var result = await syncService.PullSupplierChangesAsync(fromVersion);
            return Results.Ok(result);
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

    public sealed record UpdateSupplierRequest
    {
        public string? SupplierCode { get; init; }
        public string? Name { get; init; }
        public string? ContactName { get; init; }
        public string? Phone { get; init; }
        public string? WhatsApp { get; init; }
        public string? Email { get; init; }
        public string? SupplierType { get; init; }
        public string? Status { get; init; }
        public bool? IsArchived { get; init; }
        public string? Notes { get; init; }
    }
}
