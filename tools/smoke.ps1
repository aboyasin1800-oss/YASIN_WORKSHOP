Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'ProjectOps.ps1')

$port = Get-PreferredPort
$routes = @(
    @{ Name = 'Health'; Url = "http://127.0.0.1:$port/health" },
    @{ Name = 'Identity'; Url = "http://127.0.0.1:$port/api/identity" }
)

$failures = 0
foreach ($route in $routes) {
    try {
        $response = Invoke-WebRequest -Uri $route.Url -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
        $status = [int]$response.StatusCode
        if ($status -ge 200 -and $status -lt 400) {
            Write-Host ("[{0}] PASS - HTTP {1} - {2}" -f $route.Name, $status, $route.Url)
        }
        else {
            Write-Host ("[{0}] FAIL - HTTP {1} - {2}" -f $route.Name, $status, $route.Url)
            $failures++
        }
    }
    catch {
        Write-Host ("[{0}] FAIL - {1}" -f $route.Name, $_.Exception.Message)
        $failures++
    }
}

if ($failures -gt 0) {
    Write-Host 'Smoke result: FAIL'
    exit 1
}

Write-Host 'Smoke result: PASS'
exit 0
