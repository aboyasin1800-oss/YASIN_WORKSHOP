$p = 'D:\YASIN_WORKSHOP\src\yasin_workshop_mobile\build\native_assets\windows\sqlite3.dll'
Write-Host "TARGET_EXISTS=$((Test-Path $p))"
if (Test-Path $p) {
  Remove-Item -Force $p
  Write-Host 'REMOVED=1'
} else {
  Write-Host 'REMOVED=0'
}

Get-CimInstance Win32_Process | Where-Object { $_.Name -match 'flutter_tester|dartaotruntime|dart' } | Select-Object Name, ProcessId, CommandLine | Format-Table -AutoSize

$ids = @(Get-CimInstance Win32_Process | Where-Object { $_.Name -match 'flutter_tester|dartaotruntime|dart' -and $_.CommandLine -match 'yasin_workshop_mobile|flutter' } | Select-Object -ExpandProperty ProcessId)
if ($ids.Count -gt 0) {
  Stop-Process -Id $ids -Force -ErrorAction SilentlyContinue
  Write-Host "KILLED_IDS=$($ids -join ',')"
}

if (Test-Path $p) {
  Remove-Item -Force $p
  Write-Host 'SECOND_REMOVAL_ATTEMPT=FAILED'
} else {
  Write-Host 'SECOND_REMOVAL_ATTEMPT=SUCCESS'
}
