@echo off
cd /d D:\YASIN_WORKSHOP
"C:\Program Files\dotnet\dotnet.exe" restore src\YasinWorkshop.slnx --nologo --source "https://www.nuget.org/api/v2/" > ".verification\restore_v2_stdout.txt" 2>&1
echo %ERRORLEVEL% > ".verification\restore_v2_exit.txt"
