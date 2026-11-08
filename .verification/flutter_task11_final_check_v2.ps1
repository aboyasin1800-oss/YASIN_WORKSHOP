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

cmd /c "cd /d \"D:\YASIN_WORKSHOP\src\yasin_workshop_mobile\" && \"C:\src\flutter\bin\flutter.bat\" pub get > \"$pubGetLog\" 2>&1"
Write-Host ('PUB_GET_EXIT_CODE=' + $LASTEXITCODE)
if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed.' }
Get-Content $pubGetLog -Raw | Write-Host

cmd /c "cd /d \"D:\YASIN_WORKSHOP\src\yasin_workshop_mobile\" && \"C:\src\flutter\bin\flutter.bat\" analyze > \"$analyzeLog\" 2>&1"
Write-Host ('ANALYZE_EXIT_CODE=' + $LASTEXITCODE)
if ($LASTEXITCODE -ne 0) { throw 'flutter analyze failed.' }
Get-Content $analyzeLog -Raw | Write-Host

cmd /c "cd /d \"D:\YASIN_WORKSHOP\src\yasin_workshop_mobile\" && \"C:\src\flutter\bin\flutter.bat\" test > \"$testLog\" 2>&1"
$flutterTestExit = $LASTEXITCODE
Write-Host ('FLUTTER_TEST_EXIT_CODE=' + $flutterTestExit)
Get-Content $testLog -Raw | Write-Host
# Try parse test summary from output if available
$testOutput = Get-Content -Path $testLog -Raw
$passedMatch = [regex]::Match($testOutput, '(?is)(\d+)\s+passed')
$failedMatch = [regex]::Match($testOutput, '(?is)(\d+)\s+failed')
$passed = if ($passedMatch.Success) { [int]$passedMatch.Groups[1].Value } else { 0 }
$failed = if ($failedMatch.Success) { [int]$failedMatch.Groups[1].Value } else { 0 }
Write-Host ('FLUTTER_TESTS_TOTAL=' + ($passed + $failed))
Write-Host ('FLUTTER_TESTS_PASSED=' + $passed)
Write-Host ('FLUTTER_TESTS_FAILED=' + $failed)
if ($flutterTestExit -ne 0 -or $failed -ne 0) { throw 'flutter test failed.' }

cmd /c "cd /d \"D:\YASIN_WORKSHOP\src\yasin_workshop_mobile\" && \"C:\src\flutter\bin\flutter.bat\" build web > \"$buildLog\" 2>&1"
$buildExit = $LASTEXITCODE
Write-Host ('BUILD_EXIT_CODE=' + $buildExit)
Get-Content $buildLog -Raw | Write-Host
if ($buildExit -ne 0) { throw 'flutter build web failed.' }

# Start backend cleanly
$apiScript = 'D:\YASIN_WORKSHOP\tools\run-api.ps1'
$apiProcesses = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'YasinWorkshop.Api.exe' })
foreach ($apiProcess in $apiProcesses) {
    try { Stop-Process -Id $apiProcess.ProcessId -Force -ErrorAction Stop; Write-Host ('STOPPED_OLD_API_PID=' + $apiProcess.ProcessId) } catch { }
}
& $apiScript
Write-Host ('BACKEND_START_EXIT_CODE=' + $LASTEXITCODE)
if ($LASTEXITCODE -ne 0) { throw 'run-api.ps1 failed.' }
$runningApi = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -eq 'YasinWorkshop.Api.exe' })
Write-Host ('YASIN_WORKSHOP_API_INSTANCES_RUNNING=' + $runningApi.Count)
if ($runningApi.Count -ne 1) { throw "Expected 1 API instance but found $($runningApi.Count)." }

$healthResponse = Invoke-WebRequest -Uri 'http://127.0.0.1:5090/health' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
Write-Host ('HEALTH_HTTP_STATUS=' + $healthResponse.StatusCode)
Write-Host ('HEALTH_RESPONSE=' + ($healthResponse.Content.Substring(0, [Math]::Min(400,$healthResponse.Content.Length))))
if ($healthResponse.StatusCode -ne 200) { throw 'Health endpoint failed.' }

$statusResponse = Invoke-WebRequest -Uri 'http://127.0.0.1:5090/api/status' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
Write-Host ('STATUS_HTTP_STATUS=' + $statusResponse.StatusCode)
$statusSummary = $statusResponse.Content.Replace("`r", ' ').Replace("`n", ' ')
if ($statusSummary.Length -gt 220) { $statusSummary = $statusSummary.Substring(0,220) }
Write-Host ('STATUS_RESPONSE_SAFE_SUMMARY=' + $statusSummary)
if ($statusResponse.StatusCode -ne 200) { throw 'Status endpoint failed.' }

Write-Host 'BACKEND_CONNECTION_VERIFIED=TRUE'
Write-Host 'FINAL_VERIFICATION=PASS'
