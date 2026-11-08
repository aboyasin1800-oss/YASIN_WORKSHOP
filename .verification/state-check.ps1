$pfile = 'd:\YASIN_WORKSHOP\.verification\runtime\api.pid.txt'
Write-Host 'PIDFILE='
if (Test-Path $pfile) { Get-Content $pfile } else { 'MISSING' }
Write-Host '---'
Get-NetTCPConnection -LocalPort 5090 -ErrorAction SilentlyContinue | Format-Table -AutoSize
Write-Host '---'
Get-NetTCPConnection -LocalPort 5091 -ErrorAction SilentlyContinue | Format-Table -AutoSize
Write-Host '---'
try {
    $r = Invoke-WebRequest -Uri 'http://127.0.0.1:5090/health' -UseBasicParsing -TimeoutSec 5
    $r.StatusCode
    $r.Content
} catch {
    Write-Host '5090_HEALTH_FAILED'
    $_.Exception.Message
}
