Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$pubspecPath = Join-Path $projectRoot 'pubspec.yaml'

$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
$dartCmd = Get-Command dart -ErrorAction SilentlyContinue

if (-not $flutterCmd) {
    Write-Host 'FLUTTER_STATUS=NOT_AVAILABLE'
    exit 0
}

Write-Host ('FLUTTER_SDK_PATH={0}' -f $flutterCmd.Source)
Write-Host ('FLUTTER_VERSION={0}' -f (& flutter --version 2>$null | Select-Object -First 1))
Write-Host ('DART_VERSION={0}' -f (& dart --version 2>$null | Select-Object -First 1))

if (-not (Test-Path $pubspecPath)) {
    Write-Host 'FLUTTER_STATUS=NOT_CREATED_YET'
    Write-Host 'PUBSPEC_PATH=NOT_FOUND'
    Write-Host 'FLUTTER_PROJECT_READY=NO'
    exit 0
}

Write-Host ('PUBSPEC_PATH={0}' -f $pubspecPath)
Write-Host 'FLUTTER_STATUS=PROJECT_PRESENT'
Write-Host 'FLUTTER_PROJECT_READY=YES'
exit 0
