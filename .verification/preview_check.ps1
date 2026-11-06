$headers = @{ 'X-User-Name' = 'live-reset-operator' }
try {
    $resp = Invoke-RestMethod -Uri 'http://127.0.0.1:5090/api/development/reset-operational-data/preview' -Headers $headers -Method Get
    $resp | ConvertTo-Json -Depth 10 | Write-Host
}
catch {
    $_.Exception.Message | Write-Host
    $_.Exception.Response | Write-Host
}
