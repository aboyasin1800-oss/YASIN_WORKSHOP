using System.Text.Json;
using System.Text.Json.Nodes;
using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;

namespace YasinWorkshop.Api.Security;

public sealed record SupplierSyncRequest
{
    public Guid OperationId { get; init; }
    public Guid ClientId { get; init; }
    public string EntityType { get; init; } = "supplier";
    public string EntityId { get; init; } = string.Empty;
    public string OperationType { get; init; } = "create";
    public string Payload { get; init; } = "{}";
    public string BaseVersion { get; init; } = string.Empty;
    public string IdempotencyKey { get; init; } = string.Empty;
}

public sealed record SupplierSyncResult
{
    public bool IsSuccess { get; init; }
    public string ResultCode { get; init; } = "success";
    public string Message { get; init; } = string.Empty;
    public string ServerVersion { get; init; } = string.Empty;
    public Supplier? Supplier { get; init; }
}

public sealed record SupplierSyncPullItem
{
    public string EntityId { get; init; } = string.Empty;
    public string Version { get; init; } = string.Empty;
    public string Payload { get; init; } = "{}";
}

public sealed record SupplierSyncPullResult
{
    public string NextVersion { get; init; } = string.Empty;
    public bool HasMore { get; init; }
    public List<SupplierSyncPullItem> Items { get; init; } = new();
}

public sealed class SupplierSyncService
{
    private const string OperationScope = "supplier-sync";
    private readonly YasinWorkshopDbContext _dbContext;

    public SupplierSyncService(YasinWorkshopDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<SupplierSyncResult> ApplySupplierSyncAsync(SupplierSyncRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.IdempotencyKey))
        {
            return new SupplierSyncResult
            {
                IsSuccess = false,
                ResultCode = "validation-failure",
                Message = "IdempotencyKey is required."
            };
        }

        if (!string.Equals(request.EntityType, "supplier", StringComparison.OrdinalIgnoreCase))
        {
            return new SupplierSyncResult
            {
                IsSuccess = false,
                ResultCode = "unsupported-entity",
                Message = "Only supplier sync is supported."
            };
        }

        var existingIdempotency = await _dbContext.IdempotencyKeys
            .FirstOrDefaultAsync(x => x.OperationScope == OperationScope && x.IdempotencyKeyValue == request.IdempotencyKey);

        if (existingIdempotency is not null)
        {
            var supplier = await ResolveSupplierByIdempotencyAsync(existingIdempotency.ResponsePayload);
            return new SupplierSyncResult
            {
                IsSuccess = true,
                ResultCode = "replay",
                Message = "Operation replayed using the stored idempotency record.",
                ServerVersion = existingIdempotency.ResponsePayload ?? string.Empty,
                Supplier = supplier
            };
        }

        var payloadNode = JsonNode.Parse(request.Payload) as JsonObject ?? new JsonObject();
        var supplierCode = payloadNode["supplierCode"]?.GetValue<string>() ?? payloadNode["supplier_code"]?.GetValue<string>() ?? string.Empty;
        var name = payloadNode["name"]?.GetValue<string>() ?? string.Empty;
        var contactName = payloadNode["contactName"]?.GetValue<string>();
        var phone = payloadNode["phone"]?.GetValue<string>();
        var whatsApp = payloadNode["whatsApp"]?.GetValue<string>() ?? payloadNode["whats_app"]?.GetValue<string>();
        var email = payloadNode["email"]?.GetValue<string>();
        var supplierType = payloadNode["supplierType"]?.GetValue<string>() ?? payloadNode["supplier_type"]?.GetValue<string>() ?? "General";
        var status = payloadNode["status"]?.GetValue<string>() ?? "Active";
        var isArchived = payloadNode["isArchived"]?.GetValue<bool>() ?? false;
        var notes = payloadNode["notes"]?.GetValue<string>();

        if (string.IsNullOrWhiteSpace(supplierCode) || string.IsNullOrWhiteSpace(name))
        {
            return new SupplierSyncResult
            {
                IsSuccess = false,
                ResultCode = "validation-failure",
                Message = "Supplier code and name are required for supplier sync."
            };
        }

        if (string.Equals(request.OperationType, "create", StringComparison.OrdinalIgnoreCase) ||
            string.Equals(request.OperationType, "upsert", StringComparison.OrdinalIgnoreCase))
        {
            var existingSupplierByCode = await ResolveSupplierByCodeAsync(supplierCode);
            if (existingSupplierByCode is not null)
            {
                var currentVersion = GetSupplierVersion(existingSupplierByCode);
                if (!string.IsNullOrWhiteSpace(request.BaseVersion) && !string.Equals(request.BaseVersion, currentVersion, StringComparison.Ordinal))
                {
                    return new SupplierSyncResult
                    {
                        IsSuccess = false,
                        ResultCode = "conflict",
                        Message = "Supplier version differs from the supplied base version.",
                        ServerVersion = currentVersion,
                        Supplier = existingSupplierByCode
                    };
                }

                return await SaveIdempotencyAndReturnAsync(request, existingSupplierByCode, "success");
            }

            var existingSupplierByName = await _dbContext.Suppliers.FirstOrDefaultAsync(x => x.Name == name.Trim());
            if (existingSupplierByName is not null)
            {
                return new SupplierSyncResult
                {
                    IsSuccess = false,
                    ResultCode = "validation-failure",
                    Message = $"Supplier '{name.Trim()}' already exists.",
                    ServerVersion = GetSupplierVersion(existingSupplierByName),
                    Supplier = existingSupplierByName
                };
            }

            var supplier = new Supplier
            {
                Id = Guid.NewGuid(),
                SupplierCode = supplierCode,
                Name = name,
                ContactName = string.IsNullOrWhiteSpace(contactName) ? null : contactName.Trim(),
                Phone = string.IsNullOrWhiteSpace(phone) ? null : phone.Trim(),
                WhatsApp = string.IsNullOrWhiteSpace(whatsApp) ? null : whatsApp.Trim(),
                Email = string.IsNullOrWhiteSpace(email) ? null : email.Trim(),
                SupplierType = string.IsNullOrWhiteSpace(supplierType) ? "General" : supplierType.Trim(),
                Status = string.IsNullOrWhiteSpace(status) ? "Active" : status.Trim(),
                IsArchived = isArchived,
                Notes = string.IsNullOrWhiteSpace(notes) ? null : notes.Trim(),
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            };

            _dbContext.Suppliers.Add(supplier);
            await _dbContext.SaveChangesAsync();

            return await SaveIdempotencyAndReturnAsync(request, supplier, "success");
        }

        if (string.Equals(request.OperationType, "update", StringComparison.OrdinalIgnoreCase))
        {
            var supplier = await ResolveSupplierByRequestAsync(request, supplierCode);
            if (supplier is null)
            {
                return new SupplierSyncResult
                {
                    IsSuccess = false,
                    ResultCode = "not-found",
                    Message = "Supplier not found for update."
                };
            }

            var currentVersion = GetSupplierVersion(supplier);
            if (!string.IsNullOrWhiteSpace(request.BaseVersion) && !string.Equals(request.BaseVersion, currentVersion, StringComparison.Ordinal))
            {
                return new SupplierSyncResult
                {
                    IsSuccess = false,
                    ResultCode = "conflict",
                    Message = "Conflict: supplier server version differs from the supplied base version.",
                    ServerVersion = currentVersion,
                    Supplier = supplier
                };
            }

            supplier.SupplierCode = supplierCode;
            supplier.Name = name;
            supplier.ContactName = string.IsNullOrWhiteSpace(contactName) ? null : contactName.Trim();
            supplier.Phone = string.IsNullOrWhiteSpace(phone) ? null : phone.Trim();
            supplier.WhatsApp = string.IsNullOrWhiteSpace(whatsApp) ? null : whatsApp.Trim();
            supplier.Email = string.IsNullOrWhiteSpace(email) ? null : email.Trim();
            supplier.SupplierType = string.IsNullOrWhiteSpace(supplierType) ? "General" : supplierType.Trim();
            supplier.Status = string.IsNullOrWhiteSpace(status) ? "Active" : status.Trim();
            supplier.IsArchived = isArchived;
            supplier.Notes = string.IsNullOrWhiteSpace(notes) ? null : notes.Trim();
            supplier.UpdatedAt = DateTime.UtcNow;

            await _dbContext.SaveChangesAsync();

            return await SaveIdempotencyAndReturnAsync(request, supplier, "success");
        }

        return new SupplierSyncResult
        {
            IsSuccess = false,
            ResultCode = "unsupported-operation",
            Message = "Unsupported supplier sync operation."
        };
    }

    public async Task<SupplierSyncPullResult> PullSupplierChangesAsync(string? fromVersion)
    {
        DateTime fromDate = DateTime.MinValue;
        if (!string.IsNullOrWhiteSpace(fromVersion) && DateTimeOffset.TryParse(fromVersion, out var parsed))
        {
            fromDate = parsed.UtcDateTime;
        }

        var suppliers = await _dbContext.Suppliers
            .AsNoTracking()
            .Where(x => (x.UpdatedAt != null && x.UpdatedAt > fromDate) || (x.UpdatedAt == null && x.CreatedAt > fromDate))
            .OrderBy(x => x.CreatedAt)
            .ToListAsync();

        var items = suppliers
            .Select(supplier => new SupplierSyncPullItem
            {
                EntityId = supplier.Id.ToString(),
                Version = GetSupplierVersion(supplier),
                Payload = JsonSerializer.Serialize(new
                {
                    id = supplier.Id,
                    supplierCode = supplier.SupplierCode,
                    name = supplier.Name,
                    contactName = supplier.ContactName,
                    phone = supplier.Phone,
                    whatsApp = supplier.WhatsApp,
                    email = supplier.Email,
                    supplierType = supplier.SupplierType,
                    status = supplier.Status,
                    isArchived = supplier.IsArchived,
                    notes = supplier.Notes,
                    updatedAt = supplier.UpdatedAt ?? supplier.CreatedAt
                })
            })
            .ToList();

        var nextVersion = items.Count > 0 ? items[^1].Version : fromVersion ?? string.Empty;

        return new SupplierSyncPullResult
        {
            NextVersion = nextVersion,
            HasMore = false,
            Items = items
        };
    }

    private static string GetSupplierVersion(Supplier supplier)
    {
        return (supplier.UpdatedAt ?? supplier.CreatedAt).ToString("O");
    }

    private async Task<Supplier?> ResolveSupplierByIdempotencyAsync(string? responsePayload)
    {
        if (string.IsNullOrWhiteSpace(responsePayload))
        {
            return null;
        }

        try
        {
            using var document = JsonDocument.Parse(responsePayload);
            if (document.RootElement.TryGetProperty("supplierId", out var supplierIdElement) &&
                Guid.TryParse(supplierIdElement.GetString(), out var supplierId))
            {
                return await _dbContext.Suppliers.FirstOrDefaultAsync(x => x.Id == supplierId);
            }
        }
        catch (JsonException)
        {
            // Ignore malformed payload and return null to avoid incorrect replay resolution.
        }

        return null;
    }

    private async Task<Supplier?> ResolveSupplierByCodeAsync(string supplierCode)
    {
        return await _dbContext.Suppliers.FirstOrDefaultAsync(x => x.SupplierCode == supplierCode);
    }

    private async Task<Supplier?> ResolveSupplierByRequestAsync(SupplierSyncRequest request, string supplierCode)
    {
        if (Guid.TryParse(request.EntityId, out var supplierId))
        {
            var byId = await _dbContext.Suppliers.FirstOrDefaultAsync(x => x.Id == supplierId);
            if (byId is not null)
            {
                return byId;
            }
        }

        return await _dbContext.Suppliers.FirstOrDefaultAsync(x => x.SupplierCode == supplierCode);
    }

    private async Task<SupplierSyncResult> SaveIdempotencyAndReturnAsync(SupplierSyncRequest request, Supplier supplier, string action)
    {
        var payload = JsonSerializer.Serialize(new
        {
            action,
            supplierId = supplier.Id,
            supplierCode = supplier.SupplierCode,
            name = supplier.Name,
            version = GetSupplierVersion(supplier)
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

        return new SupplierSyncResult
        {
            IsSuccess = true,
            ResultCode = action,
            Message = action switch
            {
                "success" => "Supplier sync completed successfully.",
                _ => "Supplier sync completed."
            },
            ServerVersion = GetSupplierVersion(supplier),
            Supplier = supplier
        };
    }
}
