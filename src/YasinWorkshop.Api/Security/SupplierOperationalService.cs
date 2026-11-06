using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;

namespace YasinWorkshop.Api.Security;

public sealed record CreateSupplierRequest
{
    public string SupplierCode { get; init; } = string.Empty;
    public string Name { get; init; } = string.Empty;
    public string? ContactName { get; init; }
    public string? Phone { get; init; }
    public string? WhatsApp { get; init; }
    public string? Email { get; init; }
    public string SupplierType { get; init; } = "General";
    public string Status { get; init; } = "Active";
    public bool IsArchived { get; init; }
    public string? Notes { get; init; }
}

public sealed record CreateSupplierResult
{
    public bool IsSuccess { get; init; }
    public string Message { get; init; } = string.Empty;
    public Supplier? Supplier { get; init; }
}

public sealed class SupplierOperationalService
{
    private readonly YasinWorkshopDbContext _dbContext;

    public SupplierOperationalService(YasinWorkshopDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<CreateSupplierResult> CreateSupplierAsync(CreateSupplierRequest request)
    {
        var normalizedCode = request.SupplierCode?.Trim();
        var normalizedName = request.Name?.Trim();

        if (string.IsNullOrWhiteSpace(normalizedCode))
        {
            return new CreateSupplierResult { IsSuccess = false, Message = "Supplier code is required." };
        }

        if (string.IsNullOrWhiteSpace(normalizedName))
        {
            return new CreateSupplierResult { IsSuccess = false, Message = "Supplier name is required." };
        }

        if (await _dbContext.Suppliers.AnyAsync(x => x.SupplierCode == normalizedCode))
        {
            return new CreateSupplierResult { IsSuccess = false, Message = $"Supplier code '{normalizedCode}' already exists." };
        }

        if (await _dbContext.Suppliers.AnyAsync(x => x.Name == normalizedName))
        {
            return new CreateSupplierResult { IsSuccess = false, Message = $"Supplier '{normalizedName}' already exists." };
        }

        var supplier = new Supplier
        {
            Id = Guid.NewGuid(),
            SupplierCode = normalizedCode,
            Name = normalizedName,
            ContactName = string.IsNullOrWhiteSpace(request.ContactName) ? null : request.ContactName.Trim(),
            Phone = string.IsNullOrWhiteSpace(request.Phone) ? null : request.Phone.Trim(),
            WhatsApp = string.IsNullOrWhiteSpace(request.WhatsApp) ? null : request.WhatsApp.Trim(),
            Email = string.IsNullOrWhiteSpace(request.Email) ? null : request.Email.Trim(),
            SupplierType = string.IsNullOrWhiteSpace(request.SupplierType) ? "General" : request.SupplierType.Trim(),
            Status = string.IsNullOrWhiteSpace(request.Status) ? "Active" : request.Status.Trim(),
            IsArchived = request.IsArchived,
            Notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _dbContext.Suppliers.Add(supplier);
        await _dbContext.SaveChangesAsync();

        return new CreateSupplierResult
        {
            IsSuccess = true,
            Message = "Supplier created successfully.",
            Supplier = supplier
        };
    }

    public async Task<Supplier?> GetSupplierAsync(Guid supplierId)
    {
        return await _dbContext.Suppliers
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == supplierId);
    }

    public async Task<List<Supplier>> ListSuppliersAsync(string? search = null, string? status = null, string? type = null)
    {
        var query = _dbContext.Suppliers.AsNoTracking().AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim();
            query = query.Where(x => x.SupplierCode.Contains(term)
                || x.Name.Contains(term)
                || (x.ContactName != null && x.ContactName.Contains(term))
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
            query = query.Where(x => x.SupplierType == type.Trim());
        }

        return await query
            .OrderBy(x => x.Name)
            .ToListAsync();
    }
}
