$ErrorActionPreference = 'Stop'
$uri = 'http://127.0.0.1:3001/'
$response = Invoke-WebRequest -Uri $uri -UseBasicParsing -TimeoutSec 20
$statusPath = 'D:\YASIN_WORKSHOP\.verification\flutter_http_status.txt'
$bodyPath = 'D:\YASIN_WORKSHOP\.verification\flutter_http_body.txt'
$response.StatusCode | Set-Content -Path $statusPath
$response.Content.Substring(0, [Math]::Min(200, $response.Content.Length)) | Set-Content -Path $bodyPath
Write-Host ('HTTP_STATUS=' + $response.StatusCode)
Write-Host ('HTTP_CONTENT_PREFIX=' + $response.Content.Substring(0, [Math]::Min(120, $response.Content.Length)))
