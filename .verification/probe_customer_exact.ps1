$log = 'D:\YASIN_WORKSHOP\.verification\probe_customer_exact_log.txt'
$process = Start-Process -FilePath 'C:\src\flutter\bin\flutter.bat' -ArgumentList 'test','test/widget_test.dart','--plain-name','Customer error state hides raw backend details and offers retry','--reporter','expanded' -WorkingDirectory 'D:\YASIN_WORKSHOP\src\yasin_workshop_mobile' -PassThru -NoNewWindow -RedirectStandardOutput $log -RedirectStandardError $log
Start-Sleep -Seconds 10
Get-CimInstance Win32_Process | Where-Object { $_.ProcessId -eq $process.Id } | Select-Object ProcessId,Name,CommandLine | Format-Table -AutoSize
Write-Output "STATUS=$($process.HasExited)"
if (-not $process.HasExited) { Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue }
