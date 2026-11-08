$ErrorActionPreference = 'Stop'

$server = 'YASIN-YASIN\SQLEXPRESS'
$dbName = 'YASIN_WORKSHOP_ES_VALIDATION'
$baseUrl = 'http://127.0.0.1:5090'

Write-Host '=== LIVE SUPPLIER PROOF ==='
$identityQuery = @'
SELECT u.UserName, u.IsActive,
       r.Name AS RoleName,
       p.Code AS PermissionCode
FROM dbo.users u
LEFT JOIN dbo.user_roles ur ON ur.UserId = u.Id
LEFT JOIN dbo.roles r ON r.Id = ur.RoleId
LEFT JOIN dbo.role_permissions rp ON rp.RoleId = r.Id
LEFT JOIN dbo.permissions p ON p.Id = rp.PermissionId
ORDER BY u.UserName, r.Name, p.Code;
'@

$identityRows = Invoke-Sqlcmd -ServerInstance $server -Database $dbName -Query $identityQuery -OutputAs DataRows
$identityRows | Format-Table -AutoSize

$authUser = ($identityRows | Where-Object { $_.PermissionCode -eq 'suppliers.write' -and $_.IsActive -eq $true } | Select-Object -First 1).UserName
if (-not $authUser) {
    $seedSql = @'
DECLARE @userId UNIQUEIDENTIFIER = NEWID();
DECLARE @roleId UNIQUEIDENTIFIER = NEWID();
DECLARE @permissionId UNIQUEIDENTIFIER = NEWID();

IF NOT EXISTS (SELECT 1 FROM dbo.permissions WHERE Code = 'suppliers.write')
BEGIN
    INSERT INTO dbo.permissions (Id, Code, Description, IsActive, CreatedAt, UpdatedAt)
    VALUES (@permissionId, 'suppliers.write', 'Supplier write access for live validation proof', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
END
ELSE
BEGIN
    SELECT @permissionId = Id FROM dbo.permissions WHERE Code = 'suppliers.write';
END

IF NOT EXISTS (SELECT 1 FROM dbo.roles WHERE Name = 'Supplier Sync Proof')
BEGIN
    INSERT INTO dbo.roles (Id, Name, Description, IsActive, CreatedAt, UpdatedAt)
    VALUES (@roleId, 'Supplier Sync Proof', 'Live supplier sync validation role', 1, SYSUTCDATETIME(), SYSUTCDATETIME());
END
ELSE
BEGIN
    SELECT @roleId = Id FROM dbo.roles WHERE Name = 'Supplier Sync Proof';
END

IF NOT EXISTS (SELECT 1 FROM dbo.users WHERE UserName = 'supplier-sync-proof-user')
BEGIN
    INSERT INTO dbo.users (Id, UserName, DisplayName, Email, PasswordHash, SecurityStamp, IsActive, CreatedAt, UpdatedAt)
    VALUES (@userId, 'supplier-sync-proof-user', 'Supplier Sync Proof User', 'supplier-sync-proof-user@example.test', 'seeded-live-proof-user', NEWID(), 1, SYSUTCDATETIME(), SYSUTCDATETIME());
END
ELSE
BEGIN
    SELECT @userId = Id FROM dbo.users WHERE UserName = 'supplier-sync-proof-user';
END

IF NOT EXISTS (SELECT 1 FROM dbo.user_roles WHERE UserId = @userId AND RoleId = @roleId)
BEGIN
    INSERT INTO dbo.user_roles (Id, UserId, RoleId, CreatedAt)
    VALUES (NEWID(), @userId, @roleId, SYSUTCDATETIME());
END

IF NOT EXISTS (SELECT 1 FROM dbo.role_permissions WHERE RoleId = @roleId AND PermissionId = @permissionId)
BEGIN
    INSERT INTO dbo.role_permissions (Id, RoleId, PermissionId, CreatedAt)
    VALUES (NEWID(), @roleId, @permissionId, SYSUTCDATETIME());
END

SELECT UserName FROM dbo.users WHERE UserName = 'supplier-sync-proof-user';
'@
    Invoke-Sqlcmd -ServerInstance $server -Database $dbName -Query $seedSql | Out-Null
    $identityRows = Invoke-Sqlcmd -ServerInstance $server -Database $dbName -Query $identityQuery -OutputAs DataRows
    $authUser = ($identityRows | Where-Object { $_.PermissionCode -eq 'suppliers.write' -and $_.IsActive -eq $true } | Select-Object -First 1).UserName
    if (-not $authUser) {
        Write-Host 'NO_AUTHORIZED_USER=TRUE'
        exit 1
    }
}

Write-Host ('AUTHORIZED_USER=' + $authUser)

$uniqueSuffix = [Guid]::NewGuid().ToString('N').Substring(0, 8)
$payloadObject = [ordered]@{
    supplierCode = 'SUP-LIVE-' + [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff') + '-' + $uniqueSuffix
    name = 'Live Proof Supplier ' + $uniqueSuffix
    contactName = 'Live Proof'
    phone = '5550001'
    supplierType = 'General'
    status = 'Active'
    notes = 'Real validation via live API proof'
}
$payloadString = $payloadObject | ConvertTo-Json -Compress
$idempotencyKey = 'supplier-live-proof-' + [Guid]::NewGuid().ToString('N')
$baseVersion = ''

$bodyObject = [ordered]@{
    operationId = [Guid]::NewGuid()
    clientId = [Guid]::NewGuid()
    entityType = 'supplier'
    entityId = ''
    operationType = 'create'
    payload = $payloadString
    baseVersion = $baseVersion
    idempotencyKey = $idempotencyKey
}

$body = $bodyObject | ConvertTo-Json -Compress
$headers = @{ 'X-User-Name' = $authUser }

Write-Host ('REQUEST_IDEMPOTENCY=' + $idempotencyKey)
Write-Host ('REQUEST_PAYLOAD=' + $payloadString)

$pushResponse = Invoke-RestMethod -Method Post -Uri ($baseUrl + '/api/supplier-sync/push') -Headers $headers -ContentType 'application/json' -Body $body -ErrorAction Stop

Write-Host ('SYNC_RESULT_CODE=' + $pushResponse.resultCode)
Write-Host ('SYNC_MESSAGE=' + $pushResponse.message)
Write-Host ('SYNC_SERVER_VERSION=' + $pushResponse.serverVersion)
Write-Host ('SYNC_SUPPLIER_ID=' + $pushResponse.supplier.id)
Write-Host ('SYNC_SUPPLIER_CODE=' + $pushResponse.supplier.supplierCode)

$duplicatePayloadObject = [ordered]@{
    supplierCode = 'SUP-LIVE-DUP-' + [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff') + '-' + $uniqueSuffix
    name = $payloadObject.name
    contactName = 'Live Proof Duplicate'
    phone = '5550002'
    supplierType = 'General'
    status = 'Active'
    notes = 'Duplicate-name validation check'
}
$duplicatePayloadString = $duplicatePayloadObject | ConvertTo-Json -Compress
$duplicateBodyObject = [ordered]@{
    operationId = [Guid]::NewGuid()
    clientId = [Guid]::NewGuid()
    entityType = 'supplier'
    entityId = ''
    operationType = 'create'
    payload = $duplicatePayloadString
    baseVersion = ''
    idempotencyKey = 'supplier-live-proof-duplicate-' + [Guid]::NewGuid().ToString('N')
}
$duplicateBody = $duplicateBodyObject | ConvertTo-Json -Compress
try {
    $duplicateResponse = Invoke-RestMethod -Method Post -Uri ($baseUrl + '/api/supplier-sync/push') -Headers $headers -ContentType 'application/json' -Body $duplicateBody -ErrorAction Stop
    Write-Host ('DUPLICATE_RESULT=UNEXPECTED_SUCCESS')
    Write-Host ('DUPLICATE_RESPONSE=' + ($duplicateResponse | ConvertTo-Json -Compress))
}
catch {
    $duplicateErr = $_.Exception.Message
    Write-Host ('DUPLICATE_RESULT=' + $duplicateErr)
}

$replayBodyObject = [ordered]@{
    operationId = [Guid]::NewGuid()
    clientId = [Guid]::NewGuid()
    entityType = 'supplier'
    entityId = $pushResponse.supplier.id
    operationType = 'create'
    payload = $payloadString
    baseVersion = ''
    idempotencyKey = $idempotencyKey
}
$replayBody = $replayBodyObject | ConvertTo-Json -Compress
$replayResponse = Invoke-RestMethod -Method Post -Uri ($baseUrl + '/api/supplier-sync/push') -Headers $headers -ContentType 'application/json' -Body $replayBody -ErrorAction Stop
Write-Host ('REPLAY_RESULT_CODE=' + $replayResponse.resultCode)
Write-Host ('REPLAY_MESSAGE=' + $replayResponse.message)

$dbQuery = "SELECT COUNT(*) AS SupplierMatchCount FROM dbo.Suppliers WHERE SupplierCode = '$($payloadObject.supplierCode)';"
$dbCount = Invoke-Sqlcmd -ServerInstance $server -Database $dbName -Query $dbQuery -OutputAs DataRows
Write-Host ('DB_MATCH_COUNT=' + $dbCount.SupplierMatchCount)

$pullResponse = Invoke-RestMethod -Method Get -Uri ($baseUrl + '/api/supplier-sync/pull?fromVersion=') -Headers $headers -ErrorAction Stop
Write-Host ('PULL_NEXT_VERSION=' + $pullResponse.nextVersion)
Write-Host ('PULL_ITEMS=' + $pullResponse.items.Count)

$staleBodyObject = [ordered]@{
    operationId = [Guid]::NewGuid()
    clientId = [Guid]::NewGuid()
    entityType = 'supplier'
    entityId = $pushResponse.supplier.id
    operationType = 'create'
    payload = $payloadString
    baseVersion = '0001-01-01T00:00:00.0000000Z'
    idempotencyKey = 'supplier-live-proof-stale-' + [Guid]::NewGuid().ToString('N')
}
$staleBody = $staleBodyObject | ConvertTo-Json -Compress

try {
    $conflictResponse = Invoke-RestMethod -Method Post -Uri ($baseUrl + '/api/supplier-sync/push') -Headers $headers -ContentType 'application/json' -Body $staleBody -ErrorAction Stop
    Write-Host ('CONFLICT_RESULT=UNEXPECTED_SUCCESS')
    Write-Host ('CONFLICT_RESPONSE=' + ($conflictResponse | ConvertTo-Json -Compress))
}
catch {
    $errText = $_.Exception.Message
    Write-Host ('CONFLICT_RESULT=' + $errText)
}

Write-Host '=== LIVE SUPPLIER PROOF COMPLETE ==='
