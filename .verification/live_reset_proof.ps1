$server = 'YASIN-YASIN\SQLEXPRESS'
$database = 'YASIN_WORKSHOP_ES_VALIDATION'
$baseUri = 'http://127.0.0.1:5090'
$headers = @{ 'X-User-Name' = 'live-reset-operator' }
$token = 'DEV-RESET-YASIN-WORKSHOP-ES-VALIDATION-20261106'

$customerId = [Guid]::NewGuid().ToString()
$monthlyPriceId = [Guid]::NewGuid().ToString()
$financialId = [Guid]::NewGuid().ToString()
$idempotencyId = [Guid]::NewGuid().ToString()
$outboxId = [Guid]::NewGuid().ToString()
$attemptId = [Guid]::NewGuid().ToString()
$auditId = [Guid]::NewGuid().ToString()

Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO customers (Id, Name, ContactName, Phone, WhatsApp, Email, RelationshipType, DeliveryLocation, Status, IsArchived, Notes, CreatedAt, UpdatedAt) VALUES ('$customerId', 'LIVE_RESET_TEST_CUSTOMER', 'Test Contact', '0500000000', '0500000000', 'live-reset@example.com', 'Wholesale', 'Test Location', 'Active', 0, 'Verifying reset engine', GETUTCDATE(), GETUTCDATE());"
Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO customer_monthly_prices (Id, CustomerId, Year, Month, MonthlyRate, Currency, IsCurrent, CreatedAt, UpdatedAt) VALUES ('$monthlyPriceId', '$customerId', 2026, 11, 1234.50, 'SAR', 1, GETUTCDATE(), GETUTCDATE());"
Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO financial_postings (Id, PostingType, SourceType, SourceReference, OperationDate, Year, Month, Amount, Direction, Status, ReversalReference, CreatedAt) VALUES ('$financialId', 'Operating', 'customer', '$customerId', CAST(GETUTCDATE() AS date), YEAR(GETUTCDATE()), MONTH(GETUTCDATE()), 250.00, 'Debit', 'Pending', NULL, GETUTCDATE());"
Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO idempotency_keys (Id, OperationScope, IdempotencyKeyValue, RequestHash, Status, ResponsePayload, CreatedAt) VALUES ('$idempotencyId', 'live-reset-test', 'live-reset-test-key', 'abc123', 'Completed', '{\"ok\":true}', GETUTCDATE());"
Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO message_outbox (Id, MessageKey, TemplateCode, Provider, RecipientType, RecipientReference, MessageType, Status, MessagePayload, FailureMessage, AttemptCount, CreatedAt, UpdatedAt, LastAttemptAt, SentAt) VALUES ('$outboxId', 'live-reset-key', 'reset-test-message', 'sms', 'customer', '$customerId', 'notification', 'Queued', '{\"message\":\"test\"}', NULL, 0, GETUTCDATE(), GETUTCDATE(), NULL, NULL);"
Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO message_attempts (Id, MessageOutboxId, Status, ProviderReference, ErrorMessage, CreatedAt) VALUES ('$attemptId', '$outboxId', 'Queued', 'provider-ref', NULL, GETUTCDATE());"
Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO audit_log (Id, EntityName, EntityId, Action, ActorUserName, CorrelationId, Reason, BeforeJson, AfterJson, OperationTime) VALUES ('$auditId', 'customers', '$customerId', 'create', 'live-reset-operator', 'reset-live-test', 'Manual live verification seed', '{\"status\":\"before\"}', '{\"status\":\"after\"}', GETUTCDATE());"

Write-Host "LIVE_TEST_IDS=$customerId;$monthlyPriceId;$financialId;$idempotencyId;$outboxId;$attemptId;$auditId"

$body = @{ ConfirmationToken = $token; IsConfirmed = $true; IsDryRun = $false } | ConvertTo-Json -Depth 5
$resp = Invoke-RestMethod -Uri "$baseUri/api/development/reset-operational-data" -Headers $headers -Method Post -ContentType 'application/json' -Body $body
$resp | ConvertTo-Json -Depth 10 | Write-Host

$customerCount = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT COUNT(*) AS RowCount FROM customers;" | Select-Object -ExpandProperty RowCount
$monthlyCount = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT COUNT(*) AS RowCount FROM customer_monthly_prices;" | Select-Object -ExpandProperty RowCount
$financialCount = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT COUNT(*) AS RowCount FROM financial_postings;" | Select-Object -ExpandProperty RowCount
$outboxCount = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT COUNT(*) AS RowCount FROM message_outbox;" | Select-Object -ExpandProperty RowCount
$attemptCount = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT COUNT(*) AS RowCount FROM message_attempts;" | Select-Object -ExpandProperty RowCount
Write-Host "AFTER_RESET_CUSTOMERS=$customerCount"
Write-Host "AFTER_RESET_MONTHLY_PRICES=$monthlyCount"
Write-Host "AFTER_RESET_FINANCIAL_POSTINGS=$financialCount"
Write-Host "AFTER_RESET_OUTBOX=$outboxCount"
Write-Host "AFTER_RESET_MESSAGE_ATTEMPTS=$attemptCount"
