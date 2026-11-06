using Microsoft.AspNetCore.Http;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Security;

namespace YasinWorkshop.Api.Api;

public static class MessagingOperationalEndpoints
{
    public static WebApplication MapMessagingOperationalEndpoints(this WebApplication app)
    {
        app.MapPost("/api/messages/outbox/queue", async (YasinWorkshopDbContext dbContext, ILocalWhatsAppGateway localWhatsAppGateway, EnqueueMessageRequest request, CancellationToken cancellationToken) =>
        {
            var service = new MessageOperationalService(dbContext, localWhatsAppGateway);
            var result = await service.QueueMessageAsync(request);

            if (!result.IsSuccess)
            {
                return Results.BadRequest(new { result.Message });
            }

            return Results.Ok(new
            {
                result.OutboxEntry!.Id,
                result.OutboxEntry.MessageKey,
                result.OutboxEntry.TemplateCode,
                result.OutboxEntry.Provider,
                result.OutboxEntry.RecipientType,
                result.OutboxEntry.RecipientReference,
                result.OutboxEntry.MessageType,
                result.OutboxEntry.Status,
                result.Message,
                result.OutboxEntry.CreatedAt
            });
        });

        app.MapGet("/api/messages/outbox/pending", async (YasinWorkshopDbContext dbContext, ILocalWhatsAppGateway localWhatsAppGateway, CancellationToken cancellationToken) =>
        {
            var service = new MessageOperationalService(dbContext, localWhatsAppGateway);
            var entries = await service.GetPendingMessagesAsync(cancellationToken);
            return Results.Ok(entries.Select(x => new
            {
                x.Id,
                x.MessageKey,
                x.TemplateCode,
                x.Provider,
                x.RecipientType,
                x.RecipientReference,
                x.MessageType,
                x.Status,
                x.AttemptCount,
                x.LastAttemptAt,
                x.CreatedAt
            }));
        });

        app.MapPost("/api/messages/outbox/process", async (YasinWorkshopDbContext dbContext, ILocalWhatsAppGateway localWhatsAppGateway, CancellationToken cancellationToken) =>
        {
            var service = new MessageOperationalService(dbContext, localWhatsAppGateway);
            var processed = await service.ProcessPendingMessagesAsync(cancellationToken);
            return Results.Ok(processed.Select(x => new
            {
                x.Id,
                x.MessageKey,
                x.TemplateCode,
                x.Provider,
                x.Status,
                x.AttemptCount,
                x.LastAttemptAt,
                x.FailureMessage,
                x.SentAt
            }));
        });

        app.MapGet("/api/messages/statements/{sourceType}/{sourceReference}", async (YasinWorkshopDbContext dbContext, string sourceType, string sourceReference, int year, int month, CancellationToken cancellationToken) =>
        {
            var service = new StatementOperationalService(dbContext);
            var summary = await service.GetStatementSummaryAsync(sourceType, sourceReference, year, month);
            if (summary is null)
            {
                return Results.BadRequest(new { Message = "Statement summary requires a valid source type, source reference, year, and month." });
            }

            return Results.Ok(summary);
        });

        return app;
    }
}
