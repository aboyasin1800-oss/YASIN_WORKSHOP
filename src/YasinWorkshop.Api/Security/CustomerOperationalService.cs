using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;

namespace YasinWorkshop.Api.Security;

public sealed record CreateCustomerRequest
{
    public string Name { get; init; } = string.Empty;
    public string? ContactName { get; init; }
    public string? Phone { get; init; }
    public string? WhatsApp { get; init; }
    public string? Email { get; init; }
    public string RelationshipType { get; init; } = "Wholesale";
    public string? DeliveryLocation { get; init; }
    public string Status { get; init; } = "Active";
    public bool IsArchived { get; init; } = false;
    public string? Notes { get; init; }
}

public sealed record CreateCustomerResult
{
    public bool IsSuccess { get; init; }
    public string Message { get; init; } = string.Empty;
    public Customer? Customer { get; init; }
}

public sealed record CustomerMonthlyPriceResult
{
    public bool IsSuccess { get; init; }
    public string Message { get; init; } = string.Empty;
    public CustomerMonthlyPrice? Price { get; init; }
}

public sealed class CustomerOperationalService
{
    private readonly YasinWorkshopDbContext _dbContext;

    public CustomerOperationalService(YasinWorkshopDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<CreateCustomerResult> CreateCustomerAsync(CreateCustomerRequest request)
    {
        var normalizedName = request.Name?.Trim();
        if (string.IsNullOrWhiteSpace(normalizedName))
        {
            return new CreateCustomerResult { IsSuccess = false, Message = "Customer name is required." };
        }

        if (await _dbContext.Customers.AnyAsync(x => x.Name == normalizedName))
        {
            return new CreateCustomerResult { IsSuccess = false, Message = $"Customer '{normalizedName}' already exists." };
        }

        var customer = new Customer
        {
            Id = Guid.NewGuid(),
            Name = normalizedName,
            ContactName = string.IsNullOrWhiteSpace(request.ContactName) ? null : request.ContactName.Trim(),
            Phone = string.IsNullOrWhiteSpace(request.Phone) ? null : request.Phone.Trim(),
            WhatsApp = string.IsNullOrWhiteSpace(request.WhatsApp) ? null : request.WhatsApp.Trim(),
            Email = string.IsNullOrWhiteSpace(request.Email) ? null : request.Email.Trim(),
            RelationshipType = string.IsNullOrWhiteSpace(request.RelationshipType) ? "Wholesale" : request.RelationshipType.Trim(),
            DeliveryLocation = string.IsNullOrWhiteSpace(request.DeliveryLocation) ? null : request.DeliveryLocation.Trim(),
            Status = string.IsNullOrWhiteSpace(request.Status) ? "Active" : request.Status.Trim(),
            IsArchived = request.IsArchived,
            Notes = string.IsNullOrWhiteSpace(request.Notes) ? null : request.Notes.Trim(),
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _dbContext.Customers.Add(customer);
        await _dbContext.SaveChangesAsync();

        return new CreateCustomerResult
        {
            IsSuccess = true,
            Message = "Customer created successfully.",
            Customer = customer
        };
    }

    public async Task<Customer?> GetCustomerAsync(Guid customerId)
    {
        return await _dbContext.Customers
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == customerId);
    }

    public async Task<List<Customer>> ListCustomersAsync(string? search = null, string? status = null)
    {
        var query = _dbContext.Customers.AsNoTracking().AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
        {
            var term = search.Trim();
            query = query.Where(x => x.Name.Contains(term) || (x.ContactName != null && x.ContactName.Contains(term)) || (x.Phone != null && x.Phone.Contains(term)) || (x.WhatsApp != null && x.WhatsApp.Contains(term)));
        }

        if (!string.IsNullOrWhiteSpace(status))
        {
            query = query.Where(x => x.Status == status.Trim());
        }

        return await query
            .OrderBy(x => x.Name)
            .ToListAsync();
    }

    public async Task<CustomerMonthlyPriceResult> SetMonthlyPriceAsync(Guid customerId, int year, int month, decimal monthlyRate, string currency = "SAR")
    {
        if (year < 1900 || month is < 1 or > 12)
        {
            return new CustomerMonthlyPriceResult { IsSuccess = false, Message = "Year and month must be valid." };
        }

        if (monthlyRate < 0)
        {
            return new CustomerMonthlyPriceResult { IsSuccess = false, Message = "Monthly rate cannot be negative." };
        }

        var customer = await _dbContext.Customers.FirstOrDefaultAsync(x => x.Id == customerId);
        if (customer is null)
        {
            return new CustomerMonthlyPriceResult { IsSuccess = false, Message = "Customer was not found." };
        }

        var existing = await _dbContext.CustomerMonthlyPrices
            .FirstOrDefaultAsync(x => x.CustomerId == customerId && x.Year == year && x.Month == month);

        if (existing is not null)
        {
            return new CustomerMonthlyPriceResult { IsSuccess = false, Message = $"A price already exists for {year}-{month:00}." };
        }

        var price = new CustomerMonthlyPrice
        {
            Id = Guid.NewGuid(),
            CustomerId = customerId,
            Year = year,
            Month = month,
            MonthlyRate = monthlyRate,
            Currency = string.IsNullOrWhiteSpace(currency) ? "SAR" : currency.Trim(),
            IsCurrent = true,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _dbContext.CustomerMonthlyPrices.Add(price);
        await _dbContext.SaveChangesAsync();

        return new CustomerMonthlyPriceResult
        {
            IsSuccess = true,
            Message = "Monthly price saved successfully.",
            Price = price
        };
    }

    public async Task<CustomerMonthlyPrice?> GetCurrentMonthlyPriceAsync(Guid customerId, int year, int month)
    {
        return await _dbContext.CustomerMonthlyPrices
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.CustomerId == customerId && x.Year == year && x.Month == month);
    }

    public async Task<List<CustomerMonthlyPrice>> GetMonthlyPricesAsync(Guid customerId)
    {
        return await _dbContext.CustomerMonthlyPrices
            .AsNoTracking()
            .Where(x => x.CustomerId == customerId)
            .OrderByDescending(x => x.Year)
            .ThenByDescending(x => x.Month)
            .ToListAsync();
    }
}
