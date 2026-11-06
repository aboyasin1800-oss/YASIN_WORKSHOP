using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Security;

namespace YasinWorkshop.Tests;

public sealed class MessagingOperationalFoundationTests
{
    [Fact]
    public async Task QueueMessage_StoresOutboxEntryAndRejectsDuplicateMessageKey()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var gateway = new FakeLocalWhatsAppGateway();
        var service = new MessageOperationalService(dbContext, gateway);

        var queued = await service.QueueMessageAsync(new EnqueueMessageRequest
        {
            MessageKey = "customer-1001-reminder-1",
            TemplateCode = "customer_reminder",
            Provider = "LocalWhatsApp",
            RecipientType = "Customer",
            RecipientReference = "customer-1001",
            MessageType = "Reminder",
            Payload = "{{\"customerName\":\"Al Noor Textile\"}}"
        });

        Assert.True(queued.IsSuccess);
        Assert.NotNull(queued.OutboxEntry);
        Assert.Equal("Queued", queued.OutboxEntry!.Status);

        var duplicate = await service.QueueMessageAsync(new EnqueueMessageRequest
        {
            MessageKey = "customer-1001-reminder-1",
            TemplateCode = "customer_reminder",
            Provider = "LocalWhatsApp",
            RecipientType = "Customer",
            RecipientReference = "customer-1001",
            MessageType = "Reminder",
            Payload = "{{\"customerName\":\"Al Noor Textile\"}}"
        });

        Assert.False(duplicate.IsSuccess);
        Assert.Contains("already exists", duplicate.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public async Task ProcessPendingMessages_UsesGatewayAndTracksFailuresWithoutCancellingBusinessOperation()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var gateway = new FakeLocalWhatsAppGateway { ShouldFail = true };
        var service = new MessageOperationalService(dbContext, gateway);

        var queued = await service.QueueMessageAsync(new EnqueueMessageRequest
        {
            MessageKey = "supplier-2001-alert",
            TemplateCode = "supplier_alert",
            Provider = "LocalWhatsApp",
            RecipientType = "Supplier",
            RecipientReference = "supplier-2001",
            MessageType = "Alert",
            Payload = "{{\"supplierName\":\"Al Hamad Trading\"}}"
        });

        Assert.True(queued.IsSuccess);

        var processed = await service.ProcessPendingMessagesAsync();

        Assert.True(processed.Any());
        var entry = await dbContext.MessageOutbox.FirstAsync(x => x.MessageKey == "supplier-2001-alert");
        Assert.Equal("Failed", entry.Status);
        Assert.Equal(1, entry.AttemptCount);
        Assert.NotNull(entry.LastAttemptAt);
    }

    [Fact]
    public async Task BuildStatementSummary_UsesFinancialPostingsAsSourceOfTruth()
    {
        var options = new DbContextOptionsBuilder<YasinWorkshopDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;

        await using var dbContext = new YasinWorkshopDbContext(options);
        var service = new StatementOperationalService(dbContext);

        dbContext.FinancialPostings.AddRange(
            new FinancialPosting
            {
                Id = Guid.NewGuid(),
                PostingType = "Purchase",
                SourceType = "Supplier",
                SourceReference = "supplier-42",
                OperationDate = new DateTime(2026, 11, 01),
                Year = 2026,
                Month = 11,
                Amount = 2500m,
                Direction = "Debit",
                Status = "Posted",
                CreatedAt = DateTime.UtcNow
            },
            new FinancialPosting
            {
                Id = Guid.NewGuid(),
                PostingType = "Payment",
                SourceType = "Supplier",
                SourceReference = "supplier-42",
                OperationDate = new DateTime(2026, 11, 05),
                Year = 2026,
                Month = 11,
                Amount = 500m,
                Direction = "Credit",
                Status = "Posted",
                CreatedAt = DateTime.UtcNow
            });

        await dbContext.SaveChangesAsync();

        var summary = await service.GetStatementSummaryAsync("Supplier", "supplier-42", 2026, 11);

        Assert.NotNull(summary);
        Assert.Equal(2, summary!.EntryCount);
        Assert.Equal(2500m, summary.TotalDebits);
        Assert.Equal(500m, summary.TotalCredits);
        Assert.Equal(2000m, summary.NetAmount);
    }

    private sealed class FakeLocalWhatsAppGateway : ILocalWhatsAppGateway
    {
        public bool ShouldFail { get; set; }

        public Task<LocalWhatsAppSendResult> SendAsync(LocalWhatsAppSendRequest request, CancellationToken cancellationToken = default)
        {
            if (ShouldFail)
            {
                return Task.FromResult(new LocalWhatsAppSendResult
                {
                    IsSuccess = false,
                    ErrorMessage = "Local gateway unavailable."
                });
            }

            return Task.FromResult(new LocalWhatsAppSendResult
            {
                IsSuccess = true,
                ProviderReference = "wa-local-123"
            });
        }
    }
}
