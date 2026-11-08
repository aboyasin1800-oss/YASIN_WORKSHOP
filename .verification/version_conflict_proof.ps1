$ErrorActionPreference = 'Stop'
$start = Get-Date
$sql = "SELECT TOP 1 CAST(Id AS varchar(50)) AS CustomerId, Name, Email, CONVERT(varchar(50), UpdatedAt, 127) AS ServerVersion FROM customers ORDER BY UpdatedAt DESC;"
$rows = & sqlcmd -S 'YASIN-YASIN\SQLEXPRESS' -d 'YASIN_WORKSHOP_ES_VALIDATION' -Q $sql -W -s ','
$line = ($rows | Where-Object { $_ -match '^[0-9A-Fa-f-]{36},' } | Select-Object -First 1)
if ([string]::IsNullOrWhiteSpace($line)) { throw 'No customer row found for conflict proof.' }
$parts = $line -split ','
$realId = $parts[0].Trim()
$realName = $parts[1].Trim()
$realEmail = $parts[2].Trim()
$oldVersion = $parts[3].Trim()

$headers = @{ 'Content-Type' = 'application/json'; 'X-User-Name' = 'customer-sync-proof-user' }
$updatePayload = @{ id = $realId; name = ($realName + ' Updated'); email = ($realEmail + '.updated'); phone = '+966500000333'; contactName = 'Version proof contact'; relationshipType = 'Wholesale'; deliveryLocation = 'Riyadh'; status = 'Active'; notes = 'version-proof' } | ConvertTo-Json -Compress
$updateBody = @{ operationId = [Guid]::NewGuid().ToString(); clientId = [Guid]::NewGuid().ToString(); entityType = 'customer'; entityId = $realId; operationType = 'update'; payload = $updatePayload; baseVersion = $oldVersion; idempotencyKey = ('version-proof-key-' + [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff')) } | ConvertTo-Json -Compress
$update = Invoke-RestMethod -Uri 'http://127.0.0.1:5200/api/customer-sync/push' -Headers $headers -Method Post -Body $updateBody
$newVersion = $update.serverVersion

$staleBody = @{ operationId = [Guid]::NewGuid().ToString(); clientId = [Guid]::NewGuid().ToString(); entityType = 'customer'; entityId = $realId; operationType = 'update'; payload = ('{"id":"' + $realId + '","name":"Stale Version Attempt","email":"stale@example.com"}'); baseVersion = $oldVersion; idempotencyKey = ('version-conflict-key-' + [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff')) } | ConvertTo-Json -Compress
$conflictStatus = 'NO_ERROR'
$conflictText = ''
try {
    Invoke-RestMethod -Uri 'http://127.0.0.1:5200/api/customer-sync/push' -Headers $headers -Method Post -Body $staleBody -ErrorAction Stop | Out-Null
    $conflictStatus = 'UNEXPECTED_SUCCESS'
}
catch {
    $resp = $_.Exception.Response
    if ($null -ne $resp) {
        $stream = $resp.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $conflictText = $reader.ReadToEnd()
        $conflictStatus = $resp.StatusCode.ToString()
    }
    else {
        $conflictText = $_.Exception.Message
    }
}

$checkSql = "SELECT COUNT(*) AS CustomerCount, MAX(CASE WHEN Id = '$realId' THEN 1 ELSE 0 END) AS ExistsForId, MAX(CASE WHEN Name LIKE '%Updated%' THEN 1 ELSE 0 END) AS HasUpdatedName FROM customers WHERE Id = '$realId' OR Email LIKE '%updated%';"
$check = & sqlcmd -S 'YASIN-YASIN\SQLEXPRESS' -d 'YASIN_WORKSHOP_ES_VALIDATION' -Q $checkSql -W -s ','
$elapsed = [math]::Round(((Get-Date) - $start).TotalMinutes, 2)
$result = [ordered]@{
    customerId = $realId
    realName = $realName
    oldServerVersion = $oldVersion
    updateResultCode = $update.resultCode
    updatedServerVersion = $newVersion
    staleBaseVersionUsed = $oldVersion
    conflictStatus = $conflictStatus
    conflictResponse = $conflictText
    postCheck = $check
    elapsedMinutes = $elapsed
}
$result | ConvertTo-Json -Depth 6 | Set-Content -Path 'D:\YASIN_WORKSHOP\.verification\version_conflict_proof.json' -Encoding UTF8
$result | ConvertTo-Json -Depth 6
