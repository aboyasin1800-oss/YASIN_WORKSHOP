using System.Text.Json;
using System.Text.Json.Nodes;
using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;

namespace YasinWorkshop.Api.Security;

public sealed record CustomerSyncRequest
{
    public Guid OperationId { get; init; }
    public Guid ClientId { get; init; }
    public string EntityType { get; init; } = "customer";
    public string EntityId { get; init; } = string.Empty;
    public string OperationType { get; init; } = "create";
    public string Payload { get; init; } = "{}";
    public string BaseVersion { get; init; } = string.Empty;
    public string IdempotencyKey { get; init; } = string.Empty;
}

public sealed record CustomerSyncResult
{
    public bool IsSuccess { get; init; }
    public string ResultCode { get; init; } = "ok";
    public string Message { get; init; } = string.Empty;
    public string ServerVersion { get; init; } = string.Empty;
    public Customer? Customer { get; init; }
}

public sealed record CustomerSyncPullItem
{
    public string EntityId { get; init; } = string.Empty;
    public string Version { get; init; } = string.Empty;
    public string Payload { get; init; } = "{}";
}

public sealed record CustomerSyncPullResult
{
    public string NextVersion { get; init; } = string.Empty;
    public bool HasMore { get; init; }
    public List<CustomerSyncPullItem> Items { get; init; } = new();
}

public sealed class CustomerSyncService
{
    private const string OperationScope = "customer-sync";
    private readonly YasinWorkshopDbContext _dbContext;

    public CustomerSyncService(YasinWorkshopDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<CustomerSyncResult> ApplyCustomerSyncAsync(CustomerSyncRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.IdempotencyKey))
        {
            return new CustomerSyncResult { IsSuccess = false, ResultCode = "invalid-request", Message = "IdempotencyKey is required." };
        }

        if (!string.Equals(request.EntityType, "customer", StringComparison.OrdinalIgnoreCase))
        {
            return new CustomerSyncResult { IsSuccess = false, ResultCode = "unsupported-entity", Message = "Only customer sync is supported." };
        }

        var existingIdempotency = await _dbContext.IdempotencyKeys
            .FirstOrDefaultAsync(x => x.OperationScope == OperationScope && x.IdempotencyKeyValue == request.IdempotencyKey);

        if (existingIdempotency is not null)
        {
            return new CustomerSyncResult
            {
                IsSuccess = true,
                ResultCode = "idempotent-replay",
                Message = "Operation replayed from safe idempotency record.",
                ServerVersion = existingIdempotency.ResponsePayload ?? string.Empty,
                Customer = await TryResolveCustomerByIdempotencyAsync(request)
            };
        }

        var payloadNode = JsonNode.Parse(request.Payload) as JsonObject ?? new JsonObject();
        var name = payloadNode["name"]?.GetValue<string>() ?? "Customer";
        var email = payloadNode["email"]?.GetValue<string>() ?? string.Empty;
        var contactName = payloadNode["contactName"]?.GetValue<string>();
        var phone = payloadNode["phone"]?.GetValue<string>();
        var relationshipType = payloadNode["relationshipType"]?.GetValue<string>() ?? "Wholesale";

        if (string.Equals(request.OperationType, "create", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(request.OperationType, "upsert", StringComparison.OrdinalIgnoreCase))
        {
            var customer = await ResolveCustomerByNameOrEmailAsync(name, email);
            if (customer is not null)
            {
                var version = GetCustomerVersion(customer);
                if (!string.IsNullOrWhiteSpace(request.BaseVersion) && !string.Equals(request.BaseVersion, version, StringComparison.Ordinal))
                {
                    return new CustomerSyncResult { IsSuccess = false, ResultCode = "conflict", Message = "Customer version differs from base version." };
                }

                return await SaveIdempotencyAndReturnAsync(request, customer, "create-existing");
            }

            customer = new Customer
            {
                Id = Guid.NewGuid(),
                Name = name,
                ContactName = contactName,
                Phone = phone,
                Email = email,
                RelationshipType = relationshipType,
                Status = "Active",
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _dbContext.Customers.Add(customer);
            await _dbContext.SaveChangesAsync();

            return await SaveIdempotencyAndReturnAsync(request, customer, "created");
        }

        if (string.Equals(request.OperationType, "update", StringComparison.OrdinalIgnoreCase))
        {
            var customer = await ResolveCustomerByExternalIdAsync(request.EntityId, name, email);
            if (customer is null)
            {
                return new CustomerSyncResult { IsSuccess = false, ResultCode = "not-found", Message = "Customer not found for update." };
            }

            var currentVersion = GetCustomerVersion(customer);
            if (!string.IsNullOrWhiteSpace(request.BaseVersion) && !string.Equals(request.BaseVersion, currentVersion, StringComparison.Ordinal))
            {
                return new CustomerSyncResult { IsSuccess = false, ResultCode = "conflict", Message = "Conflict: server version differs from supplied base version." };
            }

            customer.Name = name;
            customer.ContactName = contactName;
            customer.Phone = phone;
            customer.Email = email;
            customer.RelationshipType = relationshipType;
            customer.UpdatedAt = DateTime.UtcNow;
            await _dbContext.SaveChangesAsync();

            return await SaveIdempotencyAndReturnAsync(request, customer, "updated");
        }

        return new CustomerSyncResult { IsSuccess = false, ResultCode = "unsupported-operation", Message = "Unsupported sync operation." };
    }

    public async Task<CustomerSyncPullResult> PullCustomerChangesAsync(string? fromVersion)
    {
        DateTime fromDate = DateTime.MinValue;
        if (!string.IsNullOrWhiteSpace(fromVersion) && DateTimeOffset.TryParse(fromVersion, out var parsed))
        {
            fromDate = parsed.UtcDateTime;
        }

        var customers = await _dbContext.Customers
            .AsNoTracking()
            .Where(x => x.UpdatedAt != null && x.UpdatedAt > fromDate || x.UpdatedAt == null && x.CreatedAt > fromDate)
            .OrderBy(x => x.CreatedAt)
            .ToListAsync();

        var items = customers
            .Select(customer => new CustomerSyncPullItem
            {
                EntityId = customer.Id.ToString(),
                Version = GetCustomerVersion(customer),
                Payload = JsonSerializer.Serialize(new
                {
                    id = customer.Id,
                    name = customer.Name,
                    email = customer.Email,
                    phone = customer.Phone,
                    contactName = customer.ContactName,
                    relationshipType = customer.RelationshipType,
                    status = customer.Status,
                    updatedAt = customer.UpdatedAt ?? customer.CreatedAt
                })
            })
            .ToList();

        var nextVersion = items.Count > 0 ? items[^1].Version : fromVersion ?? string.Empty;

        return new CustomerSyncPullResult
        {
            NextVersion = nextVersion,
            HasMore = false,
            Items = items
        };
    }

    private static string GetCustomerVersion(Customer customer)
    {
        return (customer.UpdatedAt ?? customer.CreatedAt).ToString("O");
    }

    private async Task<Customer?> ResolveCustomerByNameOrEmailAsync(string name, string email)
    {
        if (!string.IsNullOrWhiteSpace(email))
        {
            var byEmail = await _dbContext.Customers.FirstOrDefaultAsync(x => x.Email == email);
            if (byEmail is not null)
            {
                return byEmail;
            }
        }

        return await _dbContext.Customers.FirstOrDefaultAsync(x => x.Name == name);
    }

    private async Task<Customer?> ResolveCustomerByExternalIdAsync(string externalId, string fallbackName, string fallbackEmail)
    {
        if (Guid.TryParse(externalId, out var customerId))
        {
            return await _dbContext.Customers.FirstOrDefaultAsync(x => x.Id == customerId);
        }

        if (!string.IsNullOrWhiteSpace(fallbackEmail))
        {
            var byEmail = await _dbContext.Customers.FirstOrDefaultAsync(x => x.Email == fallbackEmail);
            if (byEmail is not null)
            {
                return byEmail;
            }
        }

        return await _dbContext.Customers.FirstOrDefaultAsync(x => x.Name == fallbackName);
    }

    private async Task<CustomerSyncResult> SaveIdempotencyAndReturnAsync(CustomerSyncRequest request, Customer customer, string action)
    {
        var payload = JsonSerializer.Serialize(new
        {
            action,
            customerId = customer.Id,
            customerName = customer.Name,
            email = customer.Email,
            version = GetCustomerVersion(customer)
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

        return new CustomerSyncResult
        {
            IsSuccess = true,
            ResultCode = action,
            Message = action switch
            {
                "created" => "Customer created successfully.",
                "updated" => "Customer updated successfully.",
                _ => "Customer sync replayed successfully."
            },
            ServerVersion = GetCustomerVersion(customer),
            Customer = customer
        };
    }

    private async Task<Customer?> TryResolveCustomerByIdempotencyAsync(CustomerSyncRequest request)
    {
        var record = await _dbContext.IdempotencyKeys
            .FirstOrDefaultAsync(x => x.OperationScope == OperationScope && x.IdempotencyKeyValue == request.IdempotencyKey);

        if (record is null || string.IsNullOrWhiteSpace(record.ResponsePayload))
        {
            return null;
        }

        try
        {
            using var payload = JsonDocument.Parse(record.ResponsePayload);
            var customerId = payload.RootElement.TryGetProperty("customerId", out var idElement) ? idElement.GetGuid() : default;
            if (customerId == Guid.Empty)
            {
                return null;
            }

            return await _dbContext.Customers.FirstOrDefaultAsync(x => x.Id == customerId);
        }
        catch
        {
            return null;
        }
    }
}
