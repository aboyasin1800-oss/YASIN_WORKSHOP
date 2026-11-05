Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'ProjectOps.ps1')

$stopped = Stop-TrackedProjectApi
if ($stopped) {
    Write-Host 'Project API process stopped safely.'
    exit 0
}

Write-Host 'No tracked project API process was found.'
exit 0
