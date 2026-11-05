param(
    [string]$Target = '',
    [string]$Pattern = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$pubspecPath = Join-Path $projectRoot 'pubspec.yaml'

if (-not (Test-Path $pubspecPath)) {
    Write-Host 'FLUTTER_STATUS=NOT_CREATED_YET'
    Write-Host 'FLUTTER_TEST_RESULT=NOT_APPLICABLE_YET'
    Write-Host 'TEST_SCOPE_REASON=No Flutter project exists yet in this workspace.'
    exit 0
}

$arguments = @('test')
if ($Target) {
    $arguments += $Target
}
if ($Pattern) {
    $arguments += '--plain-name'
    $arguments += $Pattern
}

Write-Host ('Running flutter test with: {0}' -f ($arguments -join ' '))
& flutter @arguments
if ($LASTEXITCODE -ne 0) {
    throw 'Flutter focused tests failed.'
}

Write-Host 'FLUTTER_TEST_RESULT=PASS'
exit 0
