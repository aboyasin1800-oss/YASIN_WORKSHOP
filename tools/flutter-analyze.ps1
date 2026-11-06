param(
    [switch]$Full
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$projectRoot = Join-Path $workspaceRoot 'src\yasin_workshop_mobile'
$pubspecPath = Join-Path $projectRoot 'pubspec.yaml'

if (-not (Test-Path $pubspecPath)) {
    Write-Host 'FLUTTER_STATUS=NOT_CREATED_YET'
    Write-Host 'FLUTTER_ANALYZE_RESULT=NOT_APPLICABLE_YET'
    Write-Host 'FLUTTER_ANALYZE_SCOPE_REASON=No Flutter project exists in the expected path under src/yasin_workshop_mobile.'
    exit 0
}

Push-Location $projectRoot
try {
    if ($Full) {
        Write-Host 'Running full Flutter analyze ...'
        & flutter analyze --no-fatal-infos --no-fatal-warnings
    }
    else {
        Write-Host 'Running targeted Flutter analyze ...'
        & flutter analyze --no-fatal-infos --no-fatal-warnings
    }
}
finally {
    Pop-Location
}

if ($LASTEXITCODE -ne 0) {
    throw 'Flutter analyze failed.'
}

Write-Host 'FLUTTER_ANALYZE_RESULT=PASS'
exit 0
