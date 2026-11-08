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

$pubGetLog = Join-Path $root 'flutter_pub_get.log'
$analyzeLog = Join-Path $root 'flutter_analyze.log'
$testLog = Join-Path $root 'flutter_test.log'
$buildLog = Join-Path $root 'flutter_build_web.log'

& $flutter pub get 2>&1 | Tee-Object -FilePath $pubGetLog
$pubExit = $LASTEXITCODE
Write-Host ('PUB_GET_EXIT_CODE=' + $pubExit)
if ($pubExit -ne 0) { throw 'flutter pub get failed.' }

& $flutter analyze 2>&1 | Tee-Object -FilePath $analyzeLog
$analyzeExit = $LASTEXITCODE
Write-Host ('ANALYZE_EXIT_CODE=' + $analyzeExit)
if ($analyzeExit -ne 0) { throw 'flutter analyze failed.' }

& $flutter test 2>&1 | Tee-Object -FilePath $testLog
$flutterTestExit = $LASTEXITCODE
$testOutput = Get-Content -Path $testLog -Raw
Write-Host ('FLUTTER_TEST_EXIT_CODE=' + $flutterTestExit)
$failedMatch = [regex]::Match($testOutput, '(?is)(?:\b\d+\s+tests?,\s+)?(?:(\d+)\s+passed).*?(\d+)\s+failed')
$passedMatch = [regex]::Match($testOutput, '(?is)(\d+)\s+passed')
$failedCount = if ($failedMatch.Success -and $failedMatch.Groups[2].Success) { [int]$failedMatch.Groups[2].Value } else { 0 }
$passedCount = if ($passedMatch.Success) { [int]$passedMatch.Groups[1].Value } else { 0 }
Write-Host ('FLUTTER_TESTS_TOTAL=' + ($passedCount + $failedCount))
Write-Host ('FLUTTER_TESTS_PASSED=' + $passedCount)
Write-Host ('FLUTTER_TESTS_FAILED=' + $failedCount)
if ($flutterTestExit -ne 0 -or $failedCount -ne 0) { throw 'flutter test failed.' }

& $flutter build web 2>&1 | Tee-Object -FilePath $buildLog
$buildExit = $LASTEXITCODE
Write-Host ('BUILD_EXIT_CODE=' + $buildExit)
if ($buildExit -ne 0) { throw 'flutter build web failed.' }

# Start exactly one clean backend instance
$apiScript = 'D:\YASIN_WORKSHOP\tools\run-api.ps1'
$apiProcesses = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'YasinWorkshop.Api.exe' })
foreach ($apiProcess in $apiProcesses) {
    try { Stop-Process -Id $apiProcess.ProcessId -Force -ErrorAction Stop; Write-Host ('STOPPED_OLD_API_PID=' + $apiProcess.ProcessId) } catch { }
}

& $apiScript
$apiStartExit = $LASTEXITCODE
Write-Host ('BACKEND_START_EXIT_CODE=' + $apiStartExit)
if ($apiStartExit -ne 0) { throw 'run-api.ps1 failed.' }

$runningApi = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'YasinWorkshop.Api.exe' })
Write-Host ('YASIN_WORKSHOP_API_INSTANCES_RUNNING=' + $runningApi.Count)
if ($runningApi.Count -ne 1) { throw "Expected 1 API instance but found $($runningApi.Count)." }

$port = 5090
$healthUri = 'http://127.0.0.1:5090/health'
$statusUri = 'http://127.0.0.1:5090/api/status'

$healthResponse = Invoke-WebRequest -Uri $healthUri -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
Write-Host ('HEALTH_HTTP_STATUS=' + $healthResponse.StatusCode)
Write-Host ('HEALTH_RESPONSE=' + ($healthResponse.Content.Substring(0, [Math]::Min(400, $healthResponse.Content.Length))))
if ($healthResponse.StatusCode -ne 200) { throw 'Health endpoint was not HTTP 200.' }

$statusResponse = Invoke-WebRequest -Uri $statusUri -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
Write-Host ('STATUS_HTTP_STATUS=' + $statusResponse.StatusCode)
$statusSummary = $statusResponse.Content
$statusSummary = $statusSummary.Replace("`r", '').Replace("`n", ' ')
if ($statusSummary.Length -gt 220) { $statusSummary = $statusSummary.Substring(0, 220) }
Write-Host ('STATUS_RESPONSE_SAFE_SUMMARY=' + $statusSummary)
if ($statusResponse.StatusCode -ne 200) { throw 'Status endpoint was not HTTP 200.' }

Write-Host 'BACKEND_CONNECTION_VERIFIED=TRUE'
Write-Host 'FINAL_VERIFICATION=PASS'
