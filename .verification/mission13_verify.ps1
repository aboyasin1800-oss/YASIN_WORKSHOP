$ErrorActionPreference = 'Stop'

New-Item -ItemType Directory -Path 'D:\YASIN_WORKSHOP\.verification' -Force | Out-Null
Set-Location 'D:\YASIN_WORKSHOP\src\yasin_workshop_mobile'
Write-Host 'WORKING_DIRECTORY:'
Get-Location

& 'C:\src\flutter\bin\flutter.bat' --version
Write-Host "FLUTTER_VERSION_EXIT_CODE=$LASTEXITCODE"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& 'C:\src\flutter\bin\flutter.bat' pub get
Write-Host "PUB_GET_EXIT_CODE=$LASTEXITCODE"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

& 'C:\src\flutter\bin\flutter.bat' analyze *> 'D:\YASIN_WORKSHOP\.verification\mission13-analyze.log'
$code = $LASTEXITCODE
Write-Host "ANALYZE_EXIT_CODE=$code"
Get-Content 'D:\YASIN_WORKSHOP\.verification\mission13-analyze.log' -Tail 80
if ($code -ne 0) { exit $code }

& 'C:\src\flutter\bin\flutter.bat' test 'test\widget_test.dart' --reporter expanded *> 'D:\YASIN_WORKSHOP\.verification\mission13-widget-test.log'
$code = $LASTEXITCODE
Write-Host "WIDGET_TEST_EXIT_CODE=$code"
Get-Content 'D:\YASIN_WORKSHOP\.verification\mission13-widget-test.log' -Tail 160
if ($code -ne 0) { exit $code }

& 'C:\src\flutter\bin\flutter.bat' test --reporter expanded *> 'D:\YASIN_WORKSHOP\.verification\mission13-full-test.log'
$code = $LASTEXITCODE
Write-Host "FLUTTER_TEST_EXIT_CODE=$code"
Get-Content 'D:\YASIN_WORKSHOP\.verification\mission13-full-test.log' -Tail 200
if ($code -ne 0) { exit $code }

& 'C:\src\flutter\bin\flutter.bat' build web *> 'D:\YASIN_WORKSHOP\.verification\mission13-build.log'
$code = $LASTEXITCODE
Write-Host "BUILD_EXIT_CODE=$code"
Get-Content 'D:\YASIN_WORKSHOP\.verification\mission13-build.log' -Tail 120
exit $code
