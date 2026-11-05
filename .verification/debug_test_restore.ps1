. 'D:\YASIN_WORKSHOP\tools\ProjectOps.ps1'
$res = Test-RestoreRequired -ProjectPaths @('D:\YASIN_WORKSHOP\src\YasinWorkshop.Tests\YasinWorkshop.Tests.csproj','D:\YASIN_WORKSHOP\src\YasinWorkshop.Api\YasinWorkshop.Api.csproj')
Write-Host ('REQUIRED=' + $res.Required)
foreach ($r in $res.Reasons) { Write-Host ('REASON=' + $r) }
