Set-Location 'D:\YASIN_WORKSHOP\src\yasin_workshop_mobile'
& 'C:\src\flutter\bin\flutter.bat' test test/widget_test.dart --plain-name 'Customer error state hides raw backend details and offers retry' --reporter expanded --timeout 30s > 'D:\YASIN_WORKSHOP\.verification\customer_hang_trace_run.txt' 2>&1
Write-Output "EXIT:$LASTEXITCODE"
