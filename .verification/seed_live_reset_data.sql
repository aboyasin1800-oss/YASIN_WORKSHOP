DECLARE @CustomerId uniqueidentifier = '8ad22eba-051e-4695-bd13-a86f42546e71';
DECLARE @MonthlyPriceId uniqueidentifier = '54dd5ba5-159d-4242-a76c-0f7b1c935c9e';
DECLARE @FinancialId uniqueidentifier = '9d17701f-0c72-4cbd-9848-eb8c78b8d46b';
DECLARE @IdempotencyId uniqueidentifier = 'b6a0c204-98ab-4430-a8ba-ef8d402a408d';
DECLARE @OutboxId uniqueidentifier = '432bddc7-bd91-408e-9615-d464139cadc6';
DECLARE @AttemptId uniqueidentifier = '993a1c26-92e3-4a54-9318-a956d9b42511';
DECLARE @AuditId uniqueidentifier = 'c90a7d86-a5c9-4c33-8b9c-e0c04a45300c';

INSERT INTO customers (Id, Name, ContactName, Phone, WhatsApp, Email, RelationshipType, DeliveryLocation, Status, IsArchived, Notes, CreatedAt, UpdatedAt)
VALUES (@CustomerId, 'LIVE_RESET_TEST_CUSTOMER', 'Test Contact', '0500000000', '0500000000', 'live-reset@example.com', 'Wholesale', 'Test Location', 'Active', 0, 'Verifying reset engine', GETUTCDATE(), GETUTCDATE());

INSERT INTO customer_monthly_prices (Id, CustomerId, Year, Month, MonthlyRate, Currency, IsCurrent, CreatedAt, UpdatedAt)
VALUES (@MonthlyPriceId, @CustomerId, 2026, 11, 1234.50, 'SAR', 1, GETUTCDATE(), GETUTCDATE());

INSERT INTO financial_postings (Id, PostingType, SourceType, SourceReference, OperationDate, Year, Month, Amount, Direction, Status, ReversalReference, CreatedAt)
VALUES (@FinancialId, 'Operating', 'customer', CAST(@CustomerId AS varchar(50)), CAST(GETUTCDATE() AS date), YEAR(GETUTCDATE()), MONTH(GETUTCDATE()), 250.00, 'Debit', 'Pending', NULL, GETUTCDATE());

INSERT INTO idempotency_keys (Id, OperationScope, IdempotencyKeyValue, RequestHash, Status, ResponsePayload, CreatedAt)
VALUES (@IdempotencyId, 'live-reset-test', 'live-reset-test-key', 'abc123', 'Completed', '{"ok":true}', GETUTCDATE());

INSERT INTO message_outbox (Id, MessageKey, TemplateCode, Provider, RecipientType, RecipientReference, MessageType, Status, MessagePayload, FailureMessage, AttemptCount, CreatedAt, UpdatedAt, LastAttemptAt, SentAt)
VALUES (@OutboxId, 'live-reset-key', 'reset-test-message', 'sms', 'customer', CAST(@CustomerId AS varchar(50)), 'notification', 'Queued', '{"message":"test"}', NULL, 0, GETUTCDATE(), GETUTCDATE(), NULL, NULL);

INSERT INTO message_attempts (Id, MessageOutboxId, Status, ProviderReference, ErrorMessage, CreatedAt)
VALUES (@AttemptId, @OutboxId, 'Queued', 'provider-ref', NULL, GETUTCDATE());

INSERT INTO audit_log (Id, EntityName, EntityId, Action, ActorUserName, CorrelationId, Reason, BeforeJson, AfterJson, OperationTime)
VALUES (@AuditId, 'customers', CAST(@CustomerId AS varchar(50)), 'create', 'live-reset-operator', 'reset-live-test', 'Manual live verification seed', '{"status":"before"}', '{"status":"after"}', GETUTCDATE());
