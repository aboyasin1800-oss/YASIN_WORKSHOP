$ErrorActionPreference = 'Stop'
$headers = @{ 'Content-Type' = 'application/json'; 'X-User-Name' = 'customer-sync-proof-user' }
$entityId = 'live-proof-' + [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff')
$payload = @{ id = $entityId; name = 'Live Proof Customer'; email = ('liveproof.' + [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff') + '@example.com'); phone = '+966500000222'; contactName = 'Live Proof Contact'; relationshipType = 'Wholesale'; deliveryLocation = 'Riyadh'; status = 'Active'; notes = 'live proof' } | ConvertTo-Json -Compress
$body1 = @{ operationId = [Guid]::NewGuid().ToString(); clientId = [Guid]::NewGuid().ToString(); entityType = 'customer'; entityId = $entityId; operationType = 'create'; payload = $payload; baseVersion = ''; idempotencyKey = 'live-proof-key-' + [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff') } | ConvertTo-Json -Compress
$first = Invoke-RestMethod -Uri 'http://127.0.0.1:5200/api/customer-sync/push' -Headers $headers -Method Post -Body $body1
$retry = Invoke-RestMethod -Uri 'http://127.0.0.1:5200/api/customer-sync/push' -Headers $headers -Method Post -Body $body1
$conflictBody = @{ operationId = [Guid]::NewGuid().ToString(); clientId = [Guid]::NewGuid().ToString(); entityType = 'customer'; entityId = $entityId; operationType = 'update'; payload = ('{"id":"' + $entityId + '","name":"Conflict Name","email":"conflict@example.com"}'); baseVersion = 'stale-version'; idempotencyKey = 'live-conflict-key-' + [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff') } | ConvertTo-Json -Compress
$conflictStatus = 'NO_ERROR'; $conflictText = ''
try { Invoke-RestMethod -Uri 'http://127.0.0.1:5200/api/customer-sync/push' -Headers $headers -Method Post -Body $conflictBody -ErrorAction Stop | Out-Null; $conflictStatus = 'UNEXPECTED_SUCCESS' } catch { $resp = $_.Exception.Response; if ($null -ne $resp) { $stream = $resp.GetResponseStream(); $reader = New-Object System.IO.StreamReader($stream); $conflictText = $reader.ReadToEnd(); $conflictStatus = $resp.StatusCode.ToString(); } else { $conflictText = $_.Exception.Message } }
$pull = Invoke-RestMethod -Uri 'http://127.0.0.1:5200/api/customer-sync/pull?fromVersion=v0' -Headers $headers -Method Get
$db = Invoke-Sqlcmd -ServerInstance 'YASIN-YASIN\SQLEXPRESS' -Database 'YASIN_WORKSHOP_ES_VALIDATION' -Query "SELECT COUNT(*) AS CustomerCount FROM customers WHERE Name = 'Live Proof Customer';"
$result = [ordered]@{ firstResult = $first.resultCode; firstServerVersion = $first.serverVersion; retryResult = $retry.resultCode; conflictStatus = $conflictStatus; conflictResponse = $conflictText; pullItems = $pull.items.Count; pullHasMore = $pull.hasMore; dbCount = $db.CustomerCount; entityId = $entityId }
$result | ConvertTo-Json -Depth 5 | Out-File -Encoding UTF8 'D:\YASIN_WORKSHOP\.verification\live_customer_sync_proof.json'
$result | ConvertTo-Json -Depth 5
