Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'ProjectOps.ps1')

$identity = Get-ProjectIdentitySummary
Write-Host ('Server={0}; Database={1}; Expected={2}' -f $identity.Server, $identity.Database, $identity.ExpectedDatabase)

if ($identity.Database -ne $identity.ExpectedDatabase) {
    Write-Host 'DB_VERIFY: FAIL CLOSED - expected database mismatch.'
    exit 1
}

if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
    Write-Host 'DB_VERIFY: PASS (config check only; sqlcmd not available on PATH).'
    exit 0
}

try {
    $result = & sqlcmd -S $identity.Server -d $identity.Database -Q "SELECT DB_NAME() AS CurrentDatabase; SELECT COUNT(*) AS TableCount FROM sys.tables;" -h -1 -W -s '|' 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw 'sqlcmd returned non-zero exit code.'
    }

    $out = ($result | Out-String)
    Write-Host $out
    Write-Host 'DB_VERIFY: PASS'
    exit 0
}
catch {
    Write-Host ('DB_VERIFY: FAIL - {0}' -f $_.Exception.Message)
    exit 1
}
