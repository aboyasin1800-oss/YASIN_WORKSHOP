Set-Location 'D:\YASIN_WORKSHOP'
$log = 'D:\YASIN_WORKSHOP\.verification\test_after_fix.txt'
& dotnet test "src\YasinWorkshop.Tests\YasinWorkshop.Tests.csproj" --nologo --logger "console;verbosity=minimal" -p:NuGetAudit=false *> $log
Add-Content -Path $log -Value ("EXIT:$LASTEXITCODE")
