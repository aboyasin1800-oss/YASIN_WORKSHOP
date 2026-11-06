$ErrorActionPreference = 'Stop'
& 'C:\Program Files\dotnet\dotnet.exe' test 'd:\YASIN_WORKSHOP\src\YasinWorkshop.Tests\YasinWorkshop.Tests.csproj' --nologo -v minimal -p:NuGetAudit=false
exit $LASTEXITCODE
