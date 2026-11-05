param(
    [ValidateSet('FAST', 'FULL')]
    [string]$Mode = 'FAST'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'ProjectOps.ps1')

$stopped = Stop-TrackedProjectApi
if ($stopped) {
    Write-Host 'Stopped stale project API process before build.'
}

$restoreDecision = Test-RestoreRequired
if ($restoreDecision.Required) {
    Write-Host 'RESTORE_REQUIRED=YES'
    foreach ($reason in $restoreDecision.Reasons) {
        Write-Host ("- {0}" -f $reason)
    }
    throw 'Restore is required before build, and the local cache is not currently sufficient.'
}

$arguments = @('build', $script:Solution, '--nologo', '--no-restore', '-p:NuGetAudit=false')
if ($Mode -eq 'FAST') {
    Write-Host 'FAST mode: incremental build without restore.'
}
else {
    Write-Host 'FULL mode: complete build validation without hidden restore.'
}

& dotnet $arguments
if ($LASTEXITCODE -ne 0) {
    throw "Build failed in $Mode mode."
}

Write-Host "Build passed in $Mode mode."
exit 0
