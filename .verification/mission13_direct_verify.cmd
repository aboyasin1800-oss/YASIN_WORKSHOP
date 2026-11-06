@echo off
cd /d D:\YASIN_WORKSHOP\src\yasin_workshop_mobile
echo WORKSPACE_ROOT=%CD% > D:\YASIN_WORKSHOP\.verification\mission13_summary.txt
C:\src\flutter\bin\flutter.bat --version > D:\YASIN_WORKSHOP\.verification\mission13-version.log 2>&1
echo FLUTTER_VERSION_EXIT_CODE=%ERRORLEVEL% >> D:\YASIN_WORKSHOP\.verification\mission13_summary.txt
C:\src\flutter\bin\flutter.bat pub get > D:\YASIN_WORKSHOP\.verification\mission13-pubget.log 2>&1
echo PUB_GET_EXIT_CODE=%ERRORLEVEL% >> D:\YASIN_WORKSHOP\.verification\mission13_summary.txt
C:\src\flutter\bin\flutter.bat analyze > D:\YASIN_WORKSHOP\.verification\mission13-analyze.log 2>&1
echo ANALYZE_EXIT_CODE=%ERRORLEVEL% >> D:\YASIN_WORKSHOP\.verification\mission13_summary.txt
C:\src\flutter\bin\flutter.bat test test\widget_test.dart --reporter expanded > D:\YASIN_WORKSHOP\.verification\mission13-widget-test.log 2>&1
echo WIDGET_TEST_EXIT_CODE=%ERRORLEVEL% >> D:\YASIN_WORKSHOP\.verification\mission13_summary.txt
C:\src\flutter\bin\flutter.bat test --reporter expanded > D:\YASIN_WORKSHOP\.verification\mission13-full-test.log 2>&1
echo FLUTTER_TEST_EXIT_CODE=%ERRORLEVEL% >> D:\YASIN_WORKSHOP\.verification\mission13_summary.txt
C:\src\flutter\bin\flutter.bat build web > D:\YASIN_WORKSHOP\.verification\mission13-build.log 2>&1
echo BUILD_EXIT_CODE=%ERRORLEVEL% >> D:\YASIN_WORKSHOP\.verification\mission13_summary.txt
