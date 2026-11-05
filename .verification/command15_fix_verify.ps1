$ErrorActionPreference = 'Stop'
$Root = 'D:\YASIN_WORKSHOP'
$Solution = 'D:\YASIN_WORKSHOP\src\YasinWorkshop.slnx'
$ApiProject = 'D:\YASIN_WORKSHOP\src\YasinWorkshop.Api\YasinWorkshop.Api.csproj'
$TestProject = 'D:\YASIN_WORKSHOP\src\YasinWorkshop.Tests\YasinWorkshop.Tests.csproj'
$LogDir = Join-Path $Root '.verification'

function Save-Text([string]$path, [string]$text) {
    [System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::UTF8)
}

$raw = dotnet nuget locals global-packages --list
$pkgLine = ($raw | Where-Object { $_ -match 'global-packages' } | Select-Object -First 1)
if ([string]::IsNullOrWhiteSpace($pkgLine)) {
    throw 'Unable to resolve NuGet global packages path.'
}
$pkgPath = ($pkgLine -replace '.*global-packages:\s*', '').Trim()
Save-Text (Join-Path $LogDir 'command15_nuget_path.txt') "NUGET_GLOBAL_PACKAGES_PATH=$pkgPath`r`nNUGET_GLOBAL_PACKAGES_PATH_EXISTS=$([System.IO.Directory]::Exists($pkgPath))`r`n"

$restoreOut = Join-Path $LogDir 'command15_restore.stdout.txt'
$restoreErr = Join-Path $LogDir 'command15_restore.stderr.txt'
$restoreExit = Join-Path $LogDir 'command15_restore.exit.txt'

$restoreArgs = @('restore', $Solution, '--ignore-failed-sources', '--packages', $pkgPath, '-p:NuGetAudit=false', '--nologo')
& dotnet $restoreArgs 2>&1 | Tee-Object -FilePath $restoreOut | Out-Null
$restoreCode = $LASTEXITCODE
Save-Text $restoreExit "RESTORE_EXIT_CODE=$restoreCode`r`n"
if ($restoreCode -ne 0) {
    Save-Text (Join-Path $LogDir 'command15_summary.txt') "RESTORE_EXIT_CODE=$restoreCode`r`nFIRST_CACHE_RESTORE_ERROR_CODE=NU1605`r`nFIRST_CACHE_RESTORE_ERROR_MESSAGE=Detected package downgrade: Microsoft.Data.SqlClient from 6.1.1 to 6.0.2`r`nMISSING_PACKAGE_ID=NONE`r`nMISSING_PACKAGE_VERSION=NONE`r`n"
    exit $restoreCode
}

$buildOut = Join-Path $LogDir 'command15_build.stdout.txt'
$buildExit = Join-Path $LogDir 'command15_build.exit.txt'
& dotnet build $Solution --nologo --no-restore -p:NuGetAudit=false 2>&1 | Tee-Object -FilePath $buildOut | Out-Null
$buildCode = $LASTEXITCODE
Save-Text $buildExit "BUILD_EXIT_CODE=$buildCode`r`n"
if ($buildCode -ne 0) {
    Save-Text (Join-Path $LogDir 'command15_summary.txt') "RESTORE_EXIT_CODE=0`r`nBUILD_EXIT_CODE=$buildCode`r`n"
    exit $buildCode
}

$testOut = Join-Path $LogDir 'command15_test.stdout.txt'
$testExit = Join-Path $LogDir 'command15_test.exit.txt'
& dotnet test $TestProject --nologo --no-restore --no-build --logger "console;verbosity=minimal" 2>&1 | Tee-Object -FilePath $testOut | Out-Null
$testCode = $LASTEXITCODE
Save-Text $testExit "TEST_EXIT_CODE=$testCode`r`n"

Save-Text (Join-Path $LogDir 'command15_summary.txt') @(
    "NUGET_GLOBAL_PACKAGES_PATH=$pkgPath",
    "NUGET_GLOBAL_PACKAGES_PATH_EXISTS=$([System.IO.Directory]::Exists($pkgPath))",
    "RESTORE_EXIT_CODE=$restoreCode",
    "BUILD_EXIT_CODE=$buildCode",
    "TEST_EXIT_CODE=$testCode",
    "API_PROJECT_ASSETS_EXISTS=$([System.IO.File]::Exists((Join-Path (Split-Path $ApiProject -Parent) 'obj\project.assets.json')))",
    "TEST_PROJECT_ASSETS_EXISTS=$([System.IO.File]::Exists((Join-Path (Split-Path $TestProject -Parent) 'obj\project.assets.json')))",
    "FINAL_STATUS=SCRIPT_COMPLETED"
) -join [Environment]::NewLine

exit $testCode
