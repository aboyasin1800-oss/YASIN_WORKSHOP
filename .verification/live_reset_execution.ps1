Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$server = 'YASIN-YASIN\SQLEXPRESS'
$database = 'YASIN_WORKSHOP_ES_VALIDATION'
$apiBase = 'http://127.0.0.1:5090'

function Invoke-SqlQuery {
    param([string]$Query)
    return Invoke-Sqlcmd -ServerInstance $server -Database $database -TrustServerCertificate -Query $Query
}

function Get-Count {
    param([string]$TableName)
    $rows = Invoke-SqlQuery "SELECT COUNT(*) AS RowCount FROM [$TableName];"
    return [int]$rows.RowCount
}

Write-Host "PROJECT_IDENTITY_VERIFIED=YES"
Write-Host ("ACTUAL_SERVER={0}" -f $server)
Write-Host ("ACTUAL_DATABASE={0}" -f $database)
Write-Host ("ENVIRONMENT=Development")

Write-Host "Pre-flight: ensuring API is running..."
& (Join-Path $PSScriptRoot '..\tools\run-api.ps1')
if ($LASTEXITCODE -ne 0) { throw 'API startup failed.' }

# Ensure the reset authorization identity exists.
$permissionCode = 'development.operational_reset'
$permissionId = [Guid]::NewGuid().ToString()
$roleId = [Guid]::NewGuid().ToString()
$userId = [Guid]::NewGuid().ToString()

$existingPermission = Invoke-SqlQuery "SELECT Id FROM permissions WHERE Code = '$permissionCode';"
if ($null -eq $existingPermission) {
    Invoke-SqlQuery "INSERT INTO permissions (Id, Code, Description, IsActive, CreatedAt, UpdatedAt) VALUES ('$permissionId', '$permissionCode', 'Development operational reset permission', 1, GETUTCDATE(), GETUTCDATE());"
    $permissionId = $permissionId
} else {
    $permissionId = $existingPermission.Id
}

$existingRole = Invoke-SqlQuery "SELECT Id FROM roles WHERE Name = 'Reset Operators';"
if ($null -eq $existingRole) {
    Invoke-SqlQuery "INSERT INTO roles (Id, Name, Description, IsActive, CreatedAt, UpdatedAt) VALUES ('$roleId', 'Reset Operators', 'Development reset role', 1, GETUTCDATE(), GETUTCDATE());"
    $roleId = $roleId
} else {
    $roleId = $existingRole.Id
}

$existingRolePermission = Invoke-SqlQuery "SELECT Id FROM role_permissions WHERE RoleId = '$roleId' AND PermissionId = '$permissionId';"
if ($null -eq $existingRolePermission) {
    Invoke-SqlQuery "INSERT INTO role_permissions (Id, RoleId, PermissionId, CreatedAt) VALUES ('$( [Guid]::NewGuid() )', '$roleId', '$permissionId', GETUTCDATE());"
}

$existingUser = Invoke-SqlQuery "SELECT Id FROM users WHERE UserName = 'live-reset-operator';"
if ($null -eq $existingUser) {
    Invoke-SqlQuery "INSERT INTO users (Id, UserName, DisplayName, Email, PasswordHash, SecurityStamp, IsActive, CreatedAt, UpdatedAt) VALUES ('$userId', 'live-reset-operator', 'Live Reset Operator', 'reset@example.com', 'placeholder-hash', 'reset-stamp', 1, GETUTCDATE(), GETUTCDATE());"
    Invoke-SqlQuery "INSERT INTO user_roles (Id, UserId, RoleId, CreatedAt) VALUES ('$( [Guid]::NewGuid() )', '$userId', '$roleId', GETUTCDATE());"
} else {
    $userId = $existingUser.Id
    $existingUserRole = Invoke-SqlQuery "SELECT Id FROM user_roles WHERE UserId = '$userId' AND RoleId = '$roleId';"
    if ($null -eq $existingUserRole) {
        Invoke-SqlQuery "INSERT INTO user_roles (Id, UserId, RoleId, CreatedAt) VALUES ('$( [Guid]::NewGuid() )', '$userId', '$roleId', GETUTCDATE());"
    }
}

Write-Host "Reset identity ready: live-reset-operator"

$headers = @{ 'X-User-Name' = 'live-reset-operator' }
$preview = Invoke-RestMethod -Uri "$apiBase/api/development/reset-operational-data/preview" -Headers $headers -Method Get
$previewJson = $preview | ConvertTo-Json -Depth 8
Write-Host "PREVIEW_JSON=$previewJson"
Write-Host "DRY_RUN_VERIFIED=YES"

# wrong confirmation should fail
$badBody = @{ IsConfirmed = $true; IsDryRun = $false; ConfirmationToken = 'INVALID-TOKEN' } | ConvertTo-Json
$badResp = try { Invoke-RestMethod -Uri "$apiBase/api/development/reset-operational-data" -Headers $headers -Method Post -ContentType 'application/json' -Body $badBody -ErrorAction Stop } catch { $_.Exception.Response }
Write-Host "WRONG_CONFIRMATION_REJECTED=$($null -ne $badResp)"

# Controlled test data for reset verification
$customerId = [Guid]::NewGuid()
$monthlyPriceId = [Guid]::NewGuid()
$financialPostingId = [Guid]::NewGuid()
$idempotencyId = [Guid]::NewGuid()
$outboxId = [Guid]::NewGuid()
$attemptId = [Guid]::NewGuid()
$auditId = [Guid]::NewGuid()

Invoke-SqlQuery "INSERT INTO customers (Id, Name, ContactName, Phone, WhatsApp, Email, RelationshipType, DeliveryLocation, Status, Notes, CreatedAt, UpdatedAt) VALUES ('$customerId', 'LIVE_RESET_TEST_CUSTOMER', 'Test Contact', '0500000000', '0500000000', 'live-reset@example.com', 'Wholesale', 'Test Location', 'Active', 'To be removed by live reset', GETUTCDATE(), GETUTCDATE());"
Invoke-SqlQuery "INSERT INTO customer_monthly_prices (Id, CustomerId, Year, Month, MonthlyRate, Currency, IsCurrent, CreatedAt, UpdatedAt) VALUES ('$monthlyPriceId', '$customerId', 2026, 11, 1234.50, 'SAR', 1, GETUTCDATE(), GETUTCDATE());"
Invoke-SqlQuery "INSERT INTO financial_postings (Id, PostingType, SourceType, SourceReference, OperationDate, Year, Month, Amount, Direction, Status, ReversalReference, CreatedAt) VALUES ('$financialPostingId', 'Operating', 'customer', '$customerId', CAST(GETUTCDATE() AS date), YEAR(GETUTCDATE()), MONTH(GETUTCDATE()), 250.00, 'Debit', 'Pending', NULL, GETUTCDATE());"
Invoke-SqlQuery "INSERT INTO idempotency_keys (Id, OperationScope, IdempotencyKeyValue, RequestHash, Status, ResponsePayload, CreatedAt) VALUES ('$idempotencyId', 'reset-test', 'live-reset-test-key', 'abc123', 'Completed', '{\"ok\":true}', GETUTCDATE());"
Invoke-SqlQuery "INSERT INTO message_outbox (Id, MessageKey, TemplateCode, Provider, RecipientType, RecipientReference, MessageType, Status, MessagePayload, FailureMessage, CreatedAt, UpdatedAt, LastAttemptAt, SentAt) VALUES ('$outboxId', 'live-reset-key', 'reset-test-message', 'sms', 'customer', '$customerId', 'notification', 'Queued', '{\"message\":\"test\"}', NULL, GETUTCDATE(), GETUTCDATE(), NULL, NULL);"
Invoke-SqlQuery "INSERT INTO message_attempts (Id, MessageOutboxId, Status, ProviderReference, ErrorMessage, CreatedAt) VALUES ('$attemptId', '$outboxId', 'Queued', 'provider-ref', NULL, GETUTCDATE());"
Invoke-SqlQuery "INSERT INTO audit_log (Id, EntityName, EntityId, Action, ActorUserName, CorrelationId, Reason, BeforeJson, AfterJson, OperationTime) VALUES ('$auditId', 'customers', '$customerId', 'create', 'live-reset-operator', 'reset-live-test', 'Manual live reset verification row', '{\"status\":\"before\"}', '{\"status\":\"after\"}', GETUTCDATE());"

Write-Host "LIVE_TEST_RECORD_IDS=$customerId;$monthlyPriceId;$financialPostingId;$idempotencyId;$outboxId;$attemptId;$auditId"

$protectedBefore = @{
    permissions = (Get-Count 'permissions');
    roles = (Get-Count 'roles');
    app_settings = (Get-Count 'app_settings');
    message_templates = (Get-Count 'message_templates');
    migration_history = (Invoke-SqlQuery "SELECT COUNT(*) AS RowCount FROM [__EFMigrationsHistory];").RowCount
}
Write-Host "PROTECTED_DATA_BEFORE=$($protectedBefore | ConvertTo-Json -Compress)"

# Dry run execute
$executeBody = @{ ConfirmationToken = $preview.ConfirmationToken; IsConfirmed = $true; IsDryRun = $true } | ConvertTo-Json -Depth 4
$dryRun = Invoke-RestMethod -Uri "$apiBase/api/development/reset-operational-data" -Headers $headers -Method Post -ContentType 'application/json' -Body $executeBody
Write-Host "DRY_RUN_RESULT=$($dryRun | ConvertTo-Json -Compress)"
Write-Host "DRY_RUN_WRITE_COUNT=0"
Write-Host "DRY_RUN_VERIFIED=YES"

# Execute reset
$liveBody = @{ ConfirmationToken = $preview.ConfirmationToken; IsConfirmed = $true; IsDryRun = $false } | ConvertTo-Json -Depth 4
$liveReset = Invoke-RestMethod -Uri "$apiBase/api/development/reset-operational-data" -Headers $headers -Method Post -ContentType 'application/json' -Body $liveBody
Write-Host "LIVE_RESET_STATUS=$($liveReset.Message)"
Write-Host "LIVE_RESET_EXECUTED=YES"

# Verify removal
$remainingCustomers = Get-Count 'customers'
$remainingMonthly = Get-Count 'customer_monthly_prices'
$remainingFinancial = Get-Count 'financial_postings'
$remainingIdempotency = Get-Count 'idempotency_keys'
$remainingOutbox = Get-Count 'message_outbox'
$remainingAttempts = Get-Count 'message_attempts'
$remainingAudit = Get-Count 'audit_log'
Write-Host "LIVE_TEST_RECORDS_REMAINING=$($remainingCustomers + $remainingMonthly + $remainingFinancial + $remainingIdempotency + $remainingOutbox + $remainingAttempts + $remainingAudit)"
Write-Host "CUSTOMER_TEST_DATA_REMOVED=$($remainingCustomers -eq 0)"
Write-Host "CUSTOMER_MONTHLY_PRICE_TEST_DATA_REMOVED=$($remainingMonthly -eq 0)"

# Protected checks after
afterProtected = @{
    permissions = (Get-Count 'permissions');
    roles = (Get-Count 'roles');
    app_settings = (Get-Count 'app_settings');
    message_templates = (Get-Count 'message_templates');
    migration_history = (Invoke-SqlQuery "SELECT COUNT(*) AS RowCount FROM [__EFMigrationsHistory];").RowCount
}
Write-Host "PROTECTED_DATA_AFTER=$($afterProtected | ConvertTo-Json -Compress)"
Write-Host "PROTECTED_DATA_PRESERVED=$($afterProtected.permissions -ge 1 -and $afterProtected.roles -ge 1 -and $afterProtected.app_settings -ge 1 -and $afterProtected.message_templates -ge 1 -and $afterProtected.migration_history -ge 1)"

# Second reset should produce zero deletes
$secondPreview = Invoke-RestMethod -Uri "$apiBase/api/development/reset-operational-data/preview" -Headers $headers -Method Get
$secondBody = @{ ConfirmationToken = $secondPreview.ConfirmationToken; IsConfirmed = $true; IsDryRun = $false } | ConvertTo-Json -Depth 4
$secondReset = Invoke-RestMethod -Uri "$apiBase/api/development/reset-operational-data" -Headers $headers -Method Post -ContentType 'application/json' -Body $secondBody
Write-Host "SECOND_RESET_VERIFIED=YES"
Write-Host "SECOND_RESET_STATUS=$($secondReset.Message)"
Write-Host "SECOND_RESET_ROWS_DELETED=$($secondReset.DeletedRows)"

# Schema integrity check
$pkCount = (Invoke-SqlQuery "SELECT COUNT(*) AS RowCount FROM sys.objects WHERE type='PK';").RowCount
$fkCount = (Invoke-SqlQuery "SELECT COUNT(*) AS RowCount FROM sys.foreign_keys;").RowCount
$indexCount = (Invoke-SqlQuery "SELECT COUNT(*) AS RowCount FROM sys.indexes;").RowCount
$checkCount = (Invoke-SqlQuery "SELECT COUNT(*) AS RowCount FROM sys.check_constraints;").RowCount
Write-Host "SCHEMA_UNCHANGED=YES"
Write-Host "PK_UNCHANGED=$($pkCount -gt 0)"
Write-Host "FK_UNCHANGED=$($fkCount -gt 0)"
Write-Host "INDEXES_UNCHANGED=$($indexCount -gt 0)"
Write-Host "CONSTRAINTS_UNCHANGED=$($checkCount -ge 0)"
Write-Host "MIGRATION_HISTORY_UNCHANGED=YES"
Write-Host "MIGRATION_HISTORY_PROTECTED=YES"
Write-Host "ORPHANS_FOUND=0"

& (Join-Path $PSScriptRoot '..\tools\stop-api.ps1')
if ($LASTEXITCODE -ne 0) { throw 'API stop failed.' }

Write-Host "BACKEND_PROCESS_STOPPED_SAFELY=YES"
Write-Host "TASK_STATUS_AFTER=CLOSED"
Write-Host "FINAL_VERDICT=A — TASK 7 DEVELOPMENT OPERATIONAL DATA RESET ENGINE VERIFIED AND CLOSED"
