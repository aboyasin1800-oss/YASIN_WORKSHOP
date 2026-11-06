using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;

namespace YasinWorkshop.Api.Security;

public sealed record EnqueueMessageRequest
{
    public string MessageKey { get; init; } = string.Empty;
    public string TemplateCode { get; init; } = string.Empty;
    public string Provider { get; init; } = "LocalWhatsApp";
    public string RecipientType { get; init; } = "Customer";
    public string RecipientReference { get; init; } = string.Empty;
    public string MessageType { get; init; } = "Notification";
    public string Payload { get; init; } = string.Empty;
    public string? CorrelationId { get; init; }
}

public sealed record MessageQueueResult
{
    public bool IsSuccess { get; init; }
    public string Message { get; init; } = string.Empty;
    public MessageOutboxEntry? OutboxEntry { get; init; }
}

public sealed record LocalWhatsAppSendRequest
{
    public string TemplateCode { get; init; } = string.Empty;
    public string Provider { get; init; } = "LocalWhatsApp";
    public string RecipientType { get; init; } = "Customer";
    public string RecipientReference { get; init; } = string.Empty;
    public string MessageType { get; init; } = "Notification";
    public string Payload { get; init; } = string.Empty;
    public string? CorrelationId { get; init; }
}

public sealed record LocalWhatsAppSendResult
{
    public bool IsSuccess { get; init; }
    public string? ProviderReference { get; init; }
    public string? ErrorMessage { get; init; }
}

public interface ILocalWhatsAppGateway
{
    Task<LocalWhatsAppSendResult> SendAsync(LocalWhatsAppSendRequest request, CancellationToken cancellationToken = default);
}

public sealed class LocalWhatsAppGateway : ILocalWhatsAppGateway
{
    public Task<LocalWhatsAppSendResult> SendAsync(LocalWhatsAppSendRequest request, CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(request.TemplateCode))
        {
            return Task.FromResult(new LocalWhatsAppSendResult
            {
                IsSuccess = false,
                ErrorMessage = "Template code is required for Local WhatsApp delivery."
            });
        }

        if (string.IsNullOrWhiteSpace(request.RecipientReference))
        {
            return Task.FromResult(new LocalWhatsAppSendResult
            {
                IsSuccess = false,
                ErrorMessage = "Recipient reference is required for Local WhatsApp delivery."
            });
        }

        return Task.FromResult(new LocalWhatsAppSendResult
        {
            IsSuccess = true,
            ProviderReference = $"wa-local-{Guid.NewGuid():N}"
        });
    }
}

public sealed class MessageOperationalService
{
    private readonly YasinWorkshopDbContext _dbContext;
    private readonly ILocalWhatsAppGateway _localWhatsAppGateway;

    public MessageOperationalService(YasinWorkshopDbContext dbContext, ILocalWhatsAppGateway localWhatsAppGateway)
    {
        _dbContext = dbContext;
        _localWhatsAppGateway = localWhatsAppGateway;
    }

    public async Task<MessageQueueResult> QueueMessageAsync(EnqueueMessageRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.MessageKey))
        {
            return new MessageQueueResult { IsSuccess = false, Message = "Message key is required." };
        }

        if (string.IsNullOrWhiteSpace(request.TemplateCode))
        {
            return new MessageQueueResult { IsSuccess = false, Message = "Template code is required." };
        }

        if (string.IsNullOrWhiteSpace(request.RecipientReference))
        {
            return new MessageQueueResult { IsSuccess = false, Message = "Recipient reference is required." };
        }

        var exists = await _dbContext.MessageOutbox.AnyAsync(x => x.MessageKey == request.MessageKey.Trim());
        if (exists)
        {
            return new MessageQueueResult
            {
                IsSuccess = false,
                Message = $"Message '{request.MessageKey.Trim()}' already exists in the outbox."
            };
        }

        var now = DateTime.UtcNow;
        var entry = new MessageOutboxEntry
        {
            Id = Guid.NewGuid(),
            MessageKey = request.MessageKey.Trim(),
            TemplateCode = request.TemplateCode.Trim(),
            Provider = string.IsNullOrWhiteSpace(request.Provider) ? "LocalWhatsApp" : request.Provider.Trim(),
            RecipientType = string.IsNullOrWhiteSpace(request.RecipientType) ? "Customer" : request.RecipientType.Trim(),
            RecipientReference = request.RecipientReference.Trim(),
            MessageType = string.IsNullOrWhiteSpace(request.MessageType) ? "Notification" : request.MessageType.Trim(),
            Status = "Queued",
            MessagePayload = request.Payload,
            CreatedAt = now,
            UpdatedAt = now
        };

        _dbContext.MessageOutbox.Add(entry);
        await _dbContext.SaveChangesAsync();

        return new MessageQueueResult
        {
            IsSuccess = true,
            Message = "Message queued successfully for Local WhatsApp processing.",
            OutboxEntry = entry
        };
    }

    public async Task<List<MessageOutboxEntry>> GetPendingMessagesAsync(CancellationToken cancellationToken = default)
    {
        return await _dbContext.MessageOutbox
            .AsNoTracking()
            .Where(x => x.Status == "Queued")
            .OrderBy(x => x.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<List<MessageOutboxEntry>> ProcessPendingMessagesAsync(CancellationToken cancellationToken = default)
    {
        var pending = await _dbContext.MessageOutbox
            .Where(x => x.Status == "Queued")
            .OrderBy(x => x.CreatedAt)
            .ToListAsync(cancellationToken);

        foreach (var entry in pending)
        {
            var deliveryRequest = new LocalWhatsAppSendRequest
            {
                TemplateCode = entry.TemplateCode,
                Provider = entry.Provider,
                RecipientType = entry.RecipientType,
                RecipientReference = entry.RecipientReference,
                MessageType = entry.MessageType,
                Payload = entry.MessagePayload,
                CorrelationId = entry.MessageKey
            };

            var result = await _localWhatsAppGateway.SendAsync(deliveryRequest, cancellationToken);
            var attempt = new MessageAttempt
            {
                Id = Guid.NewGuid(),
                MessageOutboxId = entry.Id,
                Status = result.IsSuccess ? "Succeeded" : "Failed",
                ProviderReference = result.ProviderReference,
                ErrorMessage = result.ErrorMessage,
                CreatedAt = DateTime.UtcNow
            };

            _dbContext.MessageAttempts.Add(attempt);
            entry.AttemptCount += 1;
            entry.LastAttemptAt = attempt.CreatedAt;
            entry.UpdatedAt = attempt.CreatedAt;

            if (result.IsSuccess)
            {
                entry.Status = "Sent";
                entry.SentAt = attempt.CreatedAt;
                entry.FailureMessage = null;
            }
            else
            {
                entry.Status = "Failed";
                entry.FailureMessage = result.ErrorMessage;
            }
        }

        if (pending.Count > 0)
        {
            await _dbContext.SaveChangesAsync(cancellationToken);
        }

        return pending;
    }
}

public sealed record StatementSummary
{
    public string SourceType { get; init; } = string.Empty;
    public string SourceReference { get; init; } = string.Empty;
    public int Year { get; init; }
    public int Month { get; init; }
    public decimal TotalDebits { get; init; }
    public decimal TotalCredits { get; init; }
    public decimal NetAmount { get; init; }
    public int EntryCount { get; init; }
    public DateTime GeneratedAt { get; init; } = DateTime.UtcNow;
}

public sealed class StatementOperationalService
{
    private readonly YasinWorkshopDbContext _dbContext;

    public StatementOperationalService(YasinWorkshopDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<StatementSummary?> GetStatementSummaryAsync(string sourceType, string sourceReference, int year, int month)
    {
        var normalizedType = sourceType?.Trim();
        var normalizedReference = sourceReference?.Trim();

        if (string.IsNullOrWhiteSpace(normalizedType) ||
            string.IsNullOrWhiteSpace(normalizedReference) ||
            year < 1900 ||
            month is < 1 or > 12)
        {
            return null;
        }

        var postings = await _dbContext.FinancialPostings
            .AsNoTracking()
            .Where(x => x.SourceType == normalizedType &&
                x.SourceReference == normalizedReference &&
                x.Year == year &&
                x.Month == month)
            .ToListAsync();

        var totalDebits = postings
            .Where(x => x.Direction.Equals("Debit", StringComparison.OrdinalIgnoreCase))
            .Sum(x => x.Amount);

        var totalCredits = postings
            .Where(x => x.Direction.Equals("Credit", StringComparison.OrdinalIgnoreCase))
            .Sum(x => x.Amount);

        return new StatementSummary
        {
            SourceType = normalizedType,
            SourceReference = normalizedReference,
            Year = year,
            Month = month,
            TotalDebits = totalDebits,
            TotalCredits = totalCredits,
            NetAmount = totalDebits - totalCredits,
            EntryCount = postings.Count,
            GeneratedAt = DateTime.UtcNow
        };
    }
}
