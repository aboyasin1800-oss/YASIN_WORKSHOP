@echo off
cd /d "D:\YASIN_WORKSHOP\src\yasin_workshop_mobile"
"C:\src\flutter\bin\flutter.bat" test test/widget_test.dart --plain-name "Customer error state hides raw backend details and offers retry" --reporter expanded > "D:\YASIN_WORKSHOP\.verification\customer_exact_cmd_log.txt" 2>&1
echo EXIT:%ERRORLEVEL%
