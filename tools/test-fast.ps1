param(
    [string]$Project = $null,
    [string]$Filter = '',
    [switch]$NoBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'ProjectOps.ps1')

if (-not $Project) {
    $Project = $script:TestProject
}

$restoreDecision = Test-RestoreRequired -ProjectPaths @($Project)
if ($restoreDecision.Required) {
    Write-Host 'RESTORE_REQUIRED=YES'
    foreach ($reason in $restoreDecision.Reasons) {
        Write-Host ("- {0}" -f $reason)
    }
    throw 'Restore is required before focused tests, and the cache is not complete.'
}

$arguments = @('test', $Project, '--nologo', '--logger', 'console;verbosity=minimal', '--no-restore', '-p:NuGetAudit=false')
if ($NoBuild) {
    $arguments += '--no-build'
}
if (-not [string]::IsNullOrWhiteSpace($Filter)) {
    $arguments += '--filter'
    $arguments += $Filter
}

Write-Host ('Running tests: {0}' -f ($arguments -join ' '))
& dotnet $arguments
if ($LASTEXITCODE -ne 0) {
    throw 'Focused test execution failed.'
}

Write-Host 'Focused tests passed.'
exit 0
