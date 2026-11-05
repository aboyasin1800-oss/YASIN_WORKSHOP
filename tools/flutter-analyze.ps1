param(
    [switch]$Full
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$pubspecPath = Join-Path $projectRoot 'pubspec.yaml'

if (-not (Test-Path $pubspecPath)) {
    Write-Host 'FLUTTER_STATUS=NOT_CREATED_YET'
    Write-Host 'FLUTTER_ANALYZE_RESULT=NOT_APPLICABLE_YET'
    Write-Host 'FLUTTER_ANALYZE_SCOPE_REASON=No Flutter project exists yet in this workspace.'
    exit 0
}

if ($Full) {
    Write-Host 'Running full Flutter analyze ...'
    & flutter analyze --no-fatal-infos --no-fatal-warnings
}
else {
    Write-Host 'Running targeted Flutter analyze ...'
    & flutter analyze --no-fatal-infos --no-fatal-warnings
}

if ($LASTEXITCODE -ne 0) {
    throw 'Flutter analyze failed.'
}

Write-Host 'FLUTTER_ANALYZE_RESULT=PASS'
exit 0
