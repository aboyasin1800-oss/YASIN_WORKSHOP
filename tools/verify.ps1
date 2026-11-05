param(
    [ValidateSet('FAST', 'FULL')]
    [string]$Mode = 'FAST'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$steps = [System.Collections.Generic.List[string]]::new()

try {
    $steps.Add('Doctor')
    & (Join-Path $PSScriptRoot 'doctor.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'Doctor failed.' }

    $steps.Add('Restore')
    & (Join-Path $PSScriptRoot 'restore.ps1')
    if ($LASTEXITCODE -ne 0) { throw 'Restore failed.' }

    $steps.Add('Build-fast')
    & (Join-Path $PSScriptRoot 'build-fast.ps1') -Mode 'FAST'
    if ($LASTEXITCODE -ne 0) { throw 'Build-fast failed.' }

    $steps.Add('Test-fast')
    & (Join-Path $PSScriptRoot 'test-fast.ps1') -NoBuild
    if ($LASTEXITCODE -ne 0) { throw 'Test-fast failed.' }

    if ($Mode -eq 'FULL') {
        $steps.Add('Run-api')
        & (Join-Path $PSScriptRoot 'run-api.ps1')
        if ($LASTEXITCODE -ne 0) { throw 'API startup failed.' }

        $steps.Add('Smoke')
        & (Join-Path $PSScriptRoot 'smoke.ps1')
        if ($LASTEXITCODE -ne 0) { throw 'Smoke verification failed.' }

        $steps.Add('Db-verify')
        & (Join-Path $PSScriptRoot 'db-verify.ps1')
        if ($LASTEXITCODE -ne 0) { throw 'Database verification failed.' }

        $steps.Add('Stop-api')
        & (Join-Path $PSScriptRoot 'stop-api.ps1')
        if ($LASTEXITCODE -ne 0) { throw 'Stop-api failed.' }
    }

    Write-Host ('VERIFY_MODE={0}' -f $Mode)
    Write-Host 'PASS'
    foreach ($step in $steps) {
        Write-Host ("- {0}" -f $step)
    }
    exit 0
}
catch {
    Write-Host ('VERIFY_MODE={0}' -f $Mode)
    Write-Host 'FAIL'
    Write-Host ('FIRST_BROKEN_LINK={0}' -f $_.Exception.Message)
    Write-Host ('ROOT_CAUSE_EVIDENCE={0}' -f $_.Exception.Message)
    exit 1
}
