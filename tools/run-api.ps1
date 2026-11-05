Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'ProjectOps.ps1')

$preferredPort = Get-PreferredPort
$port = $preferredPort
$checked = @()
for ($i = 0; $i -lt 10; $i++) {
    $checked += $port
    if (Test-PortAvailable -Port $port) {
        break
    }
    $port++
}

if (-not (Test-PortAvailable -Port $port)) {
    throw ("No free backend port found in the supported range. Checked: {0}" -f ($checked -join ', '))
}

Write-Host ("Starting API on http://127.0.0.1:{0}" -f $port)
Start-ProjectApi -Port $port -LogPrefix 'api' | Out-Null

$ready = Wait-ForHealth -Port $port -TimeoutSeconds 60
if (-not $ready) {
    throw "Backend did not become healthy within the timeout window."
}

Write-Host "Backend ready: PASS"
Write-Host "PORT=$port"
exit 0
