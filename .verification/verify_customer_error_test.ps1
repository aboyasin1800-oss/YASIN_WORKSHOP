$p = 'D:\YASIN_WORKSHOP\src\yasin_workshop_mobile\build\native_assets\windows\sqlite3.dll'
$ids = @(Get-CimInstance Win32_Process | Where-Object {
  $_.Name -match 'flutter_tester|dart.exe|dartaotruntime|dartvm.exe' -and $_.CommandLine -match 'flutter|yasin_workshop_mobile|dart'
} | Select-Object -ExpandProperty ProcessId)

if ($ids.Count -gt 0) {
  Write-Host "KILLING=$($ids -join ',')"
  Stop-Process -Id $ids -Force -ErrorAction SilentlyContinue
}

if (Test-Path $p) {
  Write-Host 'TARGET_EXISTS=TRUE'
  try {
    Remove-Item -Force $p -ErrorAction Stop
    Write-Host 'TARGET_REMOVED=TRUE'
  } catch {
    Write-Host "TARGET_REMOVED=FALSE: $($_.Exception.Message)"
  }
} else {
  Write-Host 'TARGET_EXISTS=FALSE'
}

Set-Location 'D:\YASIN_WORKSHOP\src\yasin_workshop_mobile'
& 'C:\src\flutter\bin\flutter.bat' test test/widget_test.dart --plain-name "Customer error state hides raw backend details and offers retry" --reporter expanded
exit $LASTEXITCODE
