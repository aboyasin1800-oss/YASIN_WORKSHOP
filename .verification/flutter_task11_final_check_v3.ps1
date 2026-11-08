$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$root = 'D:\YASIN_WORKSHOP\src\yasin_workshop_mobile'
$pubspec = Join-Path $root 'pubspec.yaml'
$testDir = Join-Path $root 'test'
$webDir = Join-Path $root 'web'
$flutter = 'C:\src\flutter\bin\flutter.bat'

Write-Host ('CURRENT_DIRECTORY=' + (Get-Location).Path)
Write-Host ('PUBSPEC_FULL_PATH=' + $pubspec)
Write-Host ('PUBSPEC_EXISTS=' + (Test-Path $pubspec))
Write-Host ('TEST_DIRECTORY_EXISTS=' + (Test-Path $testDir))
Write-Host ('WEB_DIRECTORY_EXISTS=' + (Test-Path $webDir))

if (-not (Test-Path $root)) { throw 'Flutter root missing.' }
if (-not (Test-Path $pubspec)) { throw 'pubspec.yaml missing.' }
if (-not (Test-Path $testDir)) { throw 'test directory missing.' }
if (-not (Test-Path $webDir)) { throw 'web directory missing.' }

Set-Location $root
Write-Host ('CURRENT_DIRECTORY=' + (Get-Location).Path)

function Invoke-FlutterCommand {
    param(
        [Parameter(Mandatory=$true)][string]$Command,
        [Parameter(Mandatory=$true)][string]$LogPath
    )

    $stdoutLog = $LogPath + '.out.log'
    $stderrLog = $LogPath + '.err.log'
    $proc = Start-Process -FilePath $flutter -ArgumentList $Command -WorkingDirectory $root -RedirectStandardOutput $stdoutLog -RedirectStandardError $stderrLog -PassThru -Wait -NoNewWindow
    $exitCode = $proc.ExitCode
    $stdout = if (Test-Path $stdoutLog) { Get-Content -Path $stdoutLog -Raw -ErrorAction SilentlyContinue } else { '' }
    $stderr = if (Test-Path $stderrLog) { Get-Content -Path $stderrLog -Raw -ErrorAction SilentlyContinue } else { '' }
    $combined = $stdout + $stderr
    Write-Host ($Command.ToUpperInvariant() + '_EXIT_CODE=' + $exitCode)
    if ($combined.Length -gt 0) { Write-Host $combined }
    return $exitCode
}

$pubExit = Invoke-FlutterCommand -Command 'pub get' -LogPath (Join-Path $root 'flutter_pub_get')
if ($pubExit -ne 0) { throw 'flutter pub get failed.' }

$analyzeExit = Invoke-FlutterCommand -Command 'analyze' -LogPath (Join-Path $root 'flutter_analyze')
if ($analyzeExit -ne 0) { throw 'flutter analyze failed.' }

$testExit = Invoke-FlutterCommand -Command 'test' -LogPath (Join-Path $root 'flutter_test')
$testOutput = Get-Content -Path (Join-Path $root 'flutter_test.out.log') -Raw -ErrorAction SilentlyContinue
$passedMatch = [regex]::Match($testOutput, '(?is)(\d+)\s+passed')
$failedMatch = [regex]::Match($testOutput, '(?is)(\d+)\s+failed')
$passed = if ($passedMatch.Success) { [int]$passedMatch.Groups[1].Value } else { 0 }
$failed = if ($failedMatch.Success) { [int]$failedMatch.Groups[1].Value } else { 0 }
Write-Host ('FLUTTER_TESTS_TOTAL=' + ($passed + $failed))
Write-Host ('FLUTTER_TESTS_PASSED=' + $passed)
Write-Host ('FLUTTER_TESTS_FAILED=' + $failed)
if ($testExit -ne 0 -or $failed -ne 0) { throw 'flutter test failed.' }

$buildExit = Invoke-FlutterCommand -Command 'build web' -LogPath (Join-Path $root 'flutter_build_web')
if ($buildExit -ne 0) { throw 'flutter build web failed.' }

$apiScript = 'D:\YASIN_WORKSHOP\tools\run-api.ps1'
$apiProcesses = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'YasinWorkshop.Api.exe' })
foreach ($apiProcess in $apiProcesses) {
    Stop-Process -Id $apiProcess.ProcessId -Force -ErrorAction SilentlyContinue
}
& $apiScript
$apiExit = $LASTEXITCODE
Write-Host ('BACKEND_START_EXIT_CODE=' + $apiExit)
if ($apiExit -ne 0) { throw 'run-api.ps1 failed.' }

$runningApi = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'YasinWorkshop.Api.exe' })
Write-Host ('YASIN_WORKSHOP_API_INSTANCES_RUNNING=' + $runningApi.Count)
if ($runningApi.Count -ne 1) { throw 'Expected exactly one backend instance.' }

$healthResponse = Invoke-WebRequest -Uri 'http://127.0.0.1:5090/health' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
Write-Host ('HEALTH_HTTP_STATUS=' + $healthResponse.StatusCode)
Write-Host ('HEALTH_RESPONSE=' + ($healthResponse.Content.Substring(0, [Math]::Min(400, $healthResponse.Content.Length))))
if ($healthResponse.StatusCode -ne 200) { throw 'Health check failed.' }

$statusResponse = Invoke-WebRequest -Uri 'http://127.0.0.1:5090/api/status' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
Write-Host ('STATUS_HTTP_STATUS=' + $statusResponse.StatusCode)
$statusSummary = $statusResponse.Content.Replace("`r", ' ').Replace("`n", ' ')
if ($statusSummary.Length -gt 220) { $statusSummary = $statusSummary.Substring(0,220) }
Write-Host ('STATUS_RESPONSE_SAFE_SUMMARY=' + $statusSummary)
if ($statusResponse.StatusCode -ne 200) { throw 'Status endpoint failed.' }

Write-Host 'BACKEND_CONNECTION_VERIFIED=TRUE'
Write-Host 'FINAL_VERIFICATION=PASS'
