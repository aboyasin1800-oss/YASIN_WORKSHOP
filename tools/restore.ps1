Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'ProjectOps.ps1')

$decision = Test-RestoreRequired
if (-not $decision.Required) {
    Write-Host 'RESTORE_REQUIRED=NO'
    Write-Host 'Restore not required. Existing assets are current and cache entries are present.'
    exit 0
}

Write-Host 'RESTORE_REQUIRED=YES'
Write-Host 'Restore required:'
foreach ($reason in $decision.Reasons) {
    Write-Host "- $reason"
}

$nugetPath = Get-NuGetGlobalPackagesPath
if (-not $nugetPath) {
    throw 'NuGet global packages path could not be resolved.'
}

& dotnet restore $script:Solution --nologo --packages $nugetPath --disable-parallel -p:NuGetAudit=false -p:RestoreIgnoreFailedSources=true
if ($LASTEXITCODE -ne 0) {
    throw 'Restore failed.'
}

Write-Host 'Restore completed successfully.'
exit 0
