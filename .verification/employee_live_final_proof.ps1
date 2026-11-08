$ErrorActionPreference = 'Stop'
$baseUrl = 'http://127.0.0.1:5200'
$headers = @{
    'X-User-Name' = 'customer-sync-proof-user'
    'Content-Type' = 'application/json'
}

$code = 'EMP-LIVE-FINAL-' + [DateTime]::UtcNow.ToString('yyyyMMddHHmmssfff')
$idempotencyKey = 'emp-live-final-' + [Guid]::NewGuid().ToString('N')

$payloadObject = @{
    employeeCode = $code
    name = 'Employee Final Proof'
    phone = '0501111111'
    whatsApp = '0501111111'
    email = ('emp.final.' + $code.ToLower() + '@example.com')
    employeeType = 'Piece'
    status = 'Active'
    isArchived = $false
    notes = 'Employee live sync final proof'
}

$bodyObject = @{
    operationId = [Guid]::NewGuid().ToString()
    clientId = [Guid]::NewGuid().ToString()
    entityType = 'employee'
    entityId = ''
    operationType = 'create'
    payload = ($payloadObject | ConvertTo-Json -Compress)
    baseVersion = ''
    idempotencyKey = $idempotencyKey
}

$pushResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri ($baseUrl + '/api/employee-sync/push') -Headers $headers -Body ($bodyObject | ConvertTo-Json -Compress)
$pushJson = $pushResponse.Content | ConvertFrom-Json

Write-Host ('HTTP_STATUS=' + $pushResponse.StatusCode)
Write-Host ('OPERATION_ID=' + $bodyObject.operationId)
Write-Host ('ENTITY_ID=' + $pushJson.employee.id)
Write-Host ('EMPLOYEE_CODE=' + $pushJson.employee.employeeCode)
Write-Host ('IDEMPOTENCY_KEY=' + $idempotencyKey)
Write-Host ('SERVER_VERSION=' + $pushJson.serverVersion)
Write-Host ('RESULT_CODE=' + $pushJson.resultCode)
Write-Host ('RESULT_MESSAGE=' + $pushJson.message)

$retryBodyObject = @{
    operationId = [Guid]::NewGuid().ToString()
    clientId = [Guid]::NewGuid().ToString()
    entityType = 'employee'
    entityId = $pushJson.employee.id
    operationType = 'create'
    payload = ($payloadObject | ConvertTo-Json -Compress)
    baseVersion = ''
    idempotencyKey = $idempotencyKey
}

$retryResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri ($baseUrl + '/api/employee-sync/push') -Headers $headers -Body ($retryBodyObject | ConvertTo-Json -Compress)
$retryJson = $retryResponse.Content | ConvertFrom-Json

Write-Host ('RETRY_STATUS=' + $retryResponse.StatusCode)
Write-Host ('RETRY_RESULT_CODE=' + $retryJson.resultCode)
Write-Host ('RETRY_MESSAGE=' + $retryJson.message)
Write-Host ('RETRY_SERVER_VERSION=' + $retryJson.serverVersion)

$pullResponse = Invoke-WebRequest -UseBasicParsing -Method Get -Uri ($baseUrl + '/api/employee-sync/pull?fromVersion=') -Headers $headers
$pullJson = $pullResponse.Content | ConvertFrom-Json
$matchedCount = @($pullJson.items | Where-Object { $_.payload -match [regex]::Escape($code) }).Count

Write-Host ('PULL_STATUS=' + $pullResponse.StatusCode)
Write-Host ('PULL_ITEM_COUNT=' + $pullJson.items.Count)
Write-Host ('PULL_FOUND_EMPLOYEE=' + ($matchedCount -gt 0))

$oldVersion = $pushJson.serverVersion
$updatedPayloadObject = @{
    employeeCode = $code
    name = 'Employee Final Proof Updated'
    phone = '0502222222'
    whatsApp = '0502222222'
    email = ('emp.updated.' + $code.ToLower() + '@example.com')
    employeeType = 'Salary'
    status = 'Active'
    isArchived = $false
    notes = 'Employee live sync final proof updated'
}

$updateBodyObject = @{
    operationId = [Guid]::NewGuid().ToString()
    clientId = [Guid]::NewGuid().ToString()
    entityType = 'employee'
    entityId = $pushJson.employee.id
    operationType = 'update'
    payload = ($updatedPayloadObject | ConvertTo-Json -Compress)
    baseVersion = $oldVersion
    idempotencyKey = 'emp-live-final-update-' + [Guid]::NewGuid().ToString('N')
}

$updateResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri ($baseUrl + '/api/employee-sync/push') -Headers $headers -Body ($updateBodyObject | ConvertTo-Json -Compress)
$updateJson = $updateResponse.Content | ConvertFrom-Json

Write-Host ('VALID_UPDATE_STATUS=' + $updateResponse.StatusCode)
Write-Host ('VALID_UPDATE_RESULT=' + $updateJson.resultCode)
Write-Host ('VALID_UPDATE_NEW_VERSION=' + $updateJson.serverVersion)

$conflictBodyObject = @{
    operationId = [Guid]::NewGuid().ToString()
    clientId = [Guid]::NewGuid().ToString()
    entityType = 'employee'
    entityId = $pushJson.employee.id
    operationType = 'update'
    payload = (@{
        employeeCode = $code
        name = 'Old Version Attempt'
        phone = '0503333333'
        whatsApp = '0503333333'
        email = ('emp.stale.' + $code.ToLower() + '@example.com')
        employeeType = 'Piece'
        status = 'Active'
        isArchived = $false
        notes = 'Old version conflict attempt'
    } | ConvertTo-Json -Compress)
    baseVersion = $oldVersion
    idempotencyKey = 'emp-live-final-conflict-' + [Guid]::NewGuid().ToString('N')
}

$conflictResponse = Invoke-WebRequest -UseBasicParsing -Method Post -Uri ($baseUrl + '/api/employee-sync/push') -Headers $headers -Body ($conflictBodyObject | ConvertTo-Json -Compress)
$conflictJson = $conflictResponse.Content | ConvertFrom-Json

Write-Host ('CONFLICT_STATUS=' + $conflictResponse.StatusCode)
Write-Host ('CONFLICT_RESULT_CODE=' + $conflictJson.resultCode)
Write-Host ('CONFLICT_MESSAGE=' + $conflictJson.message)
Write-Host ('CONFLICT_SERVER_VERSION=' + $conflictJson.serverVersion)
Write-Host ('FINAL_TARGET=' + $code)
Write-Host ('TX_GUID=' + $pushJson.employee.id)
