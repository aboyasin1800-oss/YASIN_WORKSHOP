using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Security;

namespace YasinWorkshop.Api.Api;

public static class CustomerOperationalEndpoints
{
    public static WebApplication MapCustomerOperationalEndpoints(this WebApplication app)
    {
        app.MapGet("/api/customers", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, string? search, string? status, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "customers.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var service = new CustomerOperationalService(dbContext);
            var customers = await service.ListCustomersAsync(search, status);

            return Results.Ok(customers.Select(x => new
            {
                x.Id,
                x.Name,
                x.ContactName,
                x.Phone,
                x.WhatsApp,
                x.Email,
                x.RelationshipType,
                x.DeliveryLocation,
                x.Status,
                x.IsArchived,
                x.Notes,
                x.CreatedAt,
                x.UpdatedAt
            }));
        });

        app.MapGet("/api/customers/{id:guid}", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, Guid id, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "customers.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var customer = await dbContext.Customers
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.Id == id, cancellationToken);

            if (customer is null)
            {
                return Results.NotFound();
            }

            return Results.Ok(new
            {
                customer.Id,
                customer.Name,
                customer.ContactName,
                customer.Phone,
                customer.WhatsApp,
                customer.Email,
                customer.RelationshipType,
                customer.DeliveryLocation,
                customer.Status,
                customer.IsArchived,
                customer.Notes,
                customer.CreatedAt,
                customer.UpdatedAt
            });
        });

        app.MapPost("/api/customers", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, CreateCustomerRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "customers.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var service = new CustomerOperationalService(dbContext);
            var result = await service.CreateCustomerAsync(request);
            if (!result.IsSuccess)
            {
                return Results.BadRequest(new { result.Message });
            }

            await userSecurityService.WriteAuditAsync(new WriteAuditRequest
            {
                EntityName = "customers",
                EntityId = result.Customer!.Id.ToString(),
                Action = "create",
                ActorUserName = auth.UserName,
                Reason = "Customer created via operational foundation workflow.",
                AfterJson = $"{{\"customerName\":\"{result.Customer.Name}\"}}"
            });

            return Results.Ok(new
            {
                result.Customer.Id,
                result.Customer.Name,
                result.Customer.ContactName,
                result.Customer.Phone,
                result.Customer.Email,
                result.Customer.Status,
                result.Message
            });
        });

        app.MapPatch("/api/customers/{id:guid}", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, Guid id, UpdateCustomerRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "customers.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var customer = await dbContext.Customers.FirstOrDefaultAsync(x => x.Id == id, cancellationToken);
            if (customer is null)
            {
                return Results.NotFound();
            }

            var beforeJson = $"{{\"name\":\"{customer.Name}\",\"status\":\"{customer.Status}\",\"isArchived\":{customer.IsArchived.ToString().ToLowerInvariant()} }}";

            customer.Name = string.IsNullOrWhiteSpace(request.Name) ? customer.Name : request.Name.Trim();
            customer.ContactName = request.ContactName is null ? customer.ContactName : string.IsNullOrWhiteSpace(request.ContactName) ? null : request.ContactName.Trim();
            customer.Phone = request.Phone is null ? customer.Phone : string.IsNullOrWhiteSpace(request.Phone) ? null : request.Phone.Trim();
            customer.WhatsApp = request.WhatsApp is null ? customer.WhatsApp : string.IsNullOrWhiteSpace(request.WhatsApp) ? null : request.WhatsApp.Trim();
            customer.Email = request.Email is null ? customer.Email : string.IsNullOrWhiteSpace(request.Email) ? null : request.Email.Trim();
            customer.RelationshipType = string.IsNullOrWhiteSpace(request.RelationshipType) ? customer.RelationshipType : request.RelationshipType.Trim();
            customer.DeliveryLocation = request.DeliveryLocation is null ? customer.DeliveryLocation : string.IsNullOrWhiteSpace(request.DeliveryLocation) ? null : request.DeliveryLocation.Trim();
            customer.Status = string.IsNullOrWhiteSpace(request.Status) ? customer.Status : request.Status.Trim();
            customer.IsArchived = request.IsArchived ?? customer.IsArchived;
            customer.Notes = request.Notes is null ? customer.Notes : string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim();
            customer.UpdatedAt = DateTime.UtcNow;

            await dbContext.SaveChangesAsync(cancellationToken);
            await userSecurityService.WriteAuditAsync(new WriteAuditRequest
            {
                EntityName = "customers",
                EntityId = customer.Id.ToString(),
                Action = "update",
                ActorUserName = auth.UserName,
                Reason = "Customer profile updated via operational workflow.",
                BeforeJson = beforeJson,
                AfterJson = $"{{\"name\":\"{customer.Name}\",\"status\":\"{customer.Status}\",\"isArchived\":{customer.IsArchived.ToString().ToLowerInvariant()} }}"
            });

            return Results.Ok(new
            {
                customer.Id,
                customer.Name,
                customer.Status,
                customer.IsArchived,
                customer.UpdatedAt
            });
        });

        app.MapPost("/api/customers/{id:guid}/monthly-price", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, Guid id, CustomerMonthlyPriceInput input, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "customers.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var service = new CustomerOperationalService(dbContext);
            var result = await service.SetMonthlyPriceAsync(id, input.Year, input.Month, input.MonthlyRate, input.Currency ?? "SAR");
            if (!result.IsSuccess)
            {
                return Results.BadRequest(new { result.Message });
            }

            await userSecurityService.WriteAuditAsync(new WriteAuditRequest
            {
                EntityName = "customer_monthly_prices",
                EntityId = result.Price!.Id.ToString(),
                Action = "create",
                ActorUserName = auth.UserName,
                Reason = "Monthly customer price saved.",
                AfterJson = $"{{\"customerId\":\"{id}\",\"year\":{input.Year},\"month\":{input.Month},\"monthlyRate\":{result.Price.MonthlyRate}}}"
            });

            return Results.Ok(new
            {
                result.Price.Id,
                result.Price.CustomerId,
                result.Price.Year,
                result.Price.Month,
                result.Price.MonthlyRate,
                result.Price.Currency,
                result.Price.IsCurrent,
                result.Message
            });
        });

        app.MapGet("/api/customers/{id:guid}/monthly-prices", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, Guid id, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "customers.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var customer = await dbContext.Customers.AnyAsync(x => x.Id == id, cancellationToken);
            if (!customer)
            {
                return Results.NotFound();
            }

            var service = new CustomerOperationalService(dbContext);
            var prices = await service.GetMonthlyPricesAsync(id);
            return Results.Ok(prices.Select(x => new
            {
                x.Id,
                x.CustomerId,
                x.Year,
                x.Month,
                x.MonthlyRate,
                x.Currency,
                x.IsCurrent,
                x.CreatedAt,
                x.UpdatedAt
            }));
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

    public sealed record UpdateCustomerRequest
    {
        public string? Name { get; init; }
        public string? ContactName { get; init; }
        public string? Phone { get; init; }
        public string? WhatsApp { get; init; }
        public string? Email { get; init; }
        public string? RelationshipType { get; init; }
        public string? DeliveryLocation { get; init; }
        public string? Status { get; init; }
        public bool? IsArchived { get; init; }
        public string? Notes { get; init; }
    }

    public sealed record CustomerMonthlyPriceInput
    {
        public int Year { get; init; }
        public int Month { get; init; }
        public decimal MonthlyRate { get; init; }
        public string? Currency { get; init; }
    }
}
