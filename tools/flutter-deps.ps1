Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$pubspecPath = Join-Path $projectRoot 'pubspec.yaml'

if (-not (Test-Path $pubspecPath)) {
    Write-Host 'FLUTTER_STATUS=NOT_CREATED_YET'
    Write-Host 'DEPS_ACTION=SKIPPED'
    Write-Host 'RESTORE_SKIPPED_REASON=No Flutter project exists in this workspace yet.'
    exit 0
}

Write-Host 'Running flutter pub get ...'
& flutter pub get --directory $projectRoot
if ($LASTEXITCODE -ne 0) {
    throw 'Flutter dependency resolution failed.'
}

Write-Host 'Flutter dependencies are current.'
exit 0
