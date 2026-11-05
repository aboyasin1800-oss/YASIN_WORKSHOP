# YASIN WORKSHOP - TASK 3 VERIFICATION HANDOFF
# Compatible with Windows PowerShell 5.1
# Purpose: capture real restore/build/test/startup/health/identity evidence without using the failing Terminal Adapter.

$ErrorActionPreference = 'Stop'
$Root = 'D:\YASIN_WORKSHOP'
$Solution = 'D:\YASIN_WORKSHOP\src\YasinWorkshop.slnx'
$ApiProject = 'D:\YASIN_WORKSHOP\src\YasinWorkshop.Api\YasinWorkshop.Api.csproj'
$TestProject = 'D:\YASIN_WORKSHOP\src\YasinWorkshop.Tests\YasinWorkshop.Tests.csproj'
$DotnetPath = 'C:\Program Files\dotnet\dotnet.exe'
$NuGetV2Source = 'https://www.nuget.org/api/v2/'
$LogDir = Join-Path $Root '.verification'
$VerificationLogFiles = @(
    '01_dotnet_info.stdout.txt',
    '01_dotnet_info.stderr.txt',
    '01_dotnet_info.exit.txt',
    '02_restore.stdout.txt',
    '02_restore.stderr.txt',
    '02_restore.exit.txt',
    '03_build.stdout.txt',
    '03_build.stderr.txt',
    '03_build.exit.txt',
    '04_test.stdout.txt',
    '04_test.stderr.txt',
    '04_test.exit.txt',
    '05_startup.stdout.txt',
    '05_startup.stderr.txt',
    '05_startup.pid.txt',
    '06_health.txt',
    '07_identity.txt',
    'summary.txt'
)

function Write-ExitFile([string]$path, [string]$value) {
    [System.IO.File]::WriteAllText($path, [string]$value, [System.Text.UTF8Encoding]::UTF8)
}

function Invoke-LoggedCommand([string]$name, [string[]]$command, [string]$workingDirectory) {
    $stdoutPath = Join-Path $LogDir ($name + '.stdout.txt')
    $stderrPath = Join-Path $LogDir ($name + '.stderr.txt')
    $exitPath = Join-Path $LogDir ($name + '.exit.txt')

    Push-Location $workingDirectory
    try {
        $stdout = & $command[0] $command[1..($command.Length - 1)] 2> $stderrPath
        $exitCode = $LASTEXITCODE
        $stdout | Out-File -FilePath $stdoutPath -Encoding UTF8
        Write-ExitFile $exitPath ([string]$exitCode)
        return $exitCode
    }
    finally {
        Pop-Location
    }
}

function Save-TextFile([string]$path, [string]$text) {
    if ([string]::IsNullOrEmpty($path)) {
        throw "Invalid file path passed to Save-TextFile."
    }
    [System.IO.File]::WriteAllText($path, $text, [System.Text.UTF8Encoding]::UTF8)
}

function Clear-VerificationLogs {
    foreach ($fileName in $VerificationLogFiles) {
        $fullPath = Join-Path $LogDir $fileName
        if (Test-Path $fullPath) {
            Remove-Item $fullPath -Force
        }
    }
}

New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
Clear-VerificationLogs

$runId = [System.Guid]::NewGuid().ToString('N').Substring(0, 12)
$summaryHeader = @(
    "RUN_ID=$runId",
    "NUGET_SOURCE=$NuGetV2Source",
    "TASK 3 verification started at $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))",
    "SOLUTION=$Solution",
    "API_PROJECT=$ApiProject",
    "TEST_PROJECT=$TestProject",
    "") -join [Environment]::NewLine
Save-TextFile (Join-Path $LogDir 'summary.txt') $summaryHeader

if (-not (Test-Path $DotnetPath)) {
    Save-TextFile (Join-Path $LogDir 'summary.txt') ("ERROR: .NET not found at $DotnetPath`r`n")
    throw "dotnet.exe not found at $DotnetPath"
}

if (-not (Test-Path $Solution)) {
    Save-TextFile (Join-Path $LogDir 'summary.txt') ("ERROR: Solution not found: $Solution`r`n")
    throw "Solution not found"
}

if (-not (Test-Path $ApiProject)) {
    Save-TextFile (Join-Path $LogDir 'summary.txt') ("ERROR: API project not found: $ApiProject`r`n")
    throw "API project not found"
}

if (-not (Test-Path $TestProject)) {
    Save-TextFile (Join-Path $LogDir 'summary.txt') ("ERROR: Test project not found: $TestProject`r`n")
    throw "Test project not found"
}

# 01 - dotnet info
& $DotnetPath --info 2> (Join-Path $LogDir '01_dotnet_info.stderr.txt') | Out-File -FilePath (Join-Path $LogDir '01_dotnet_info.stdout.txt') -Encoding UTF8
Write-ExitFile (Join-Path $LogDir '01_dotnet_info.exit.txt') $LASTEXITCODE
if ($LASTEXITCODE -ne 0) {
    Save-TextFile (Join-Path $LogDir 'summary.txt') ("DOTNET INFO FAILED; EXIT=$LASTEXITCODE`r`n")
    throw "dotnet --info failed"
}

# 02 - restore
& $DotnetPath restore $Solution --nologo --source $NuGetV2Source 2> (Join-Path $LogDir '02_restore.stderr.txt') | Out-File -FilePath (Join-Path $LogDir '02_restore.stdout.txt') -Encoding UTF8
$restoreExitCode = $LASTEXITCODE
Write-ExitFile (Join-Path $LogDir '02_restore.exit.txt') $restoreExitCode
if ($restoreExitCode -ne 0) {
    $summaryText = @(
        "RUN_ID=$runId",
        "NUGET_SOURCE=$NuGetV2Source",
        "RESTORE_EXIT_CODE=$restoreExitCode",
        "BUILD_EXIT_CODE=",
        "TEST_EXIT_CODE=",
        "FINAL_STAGE_REACHED=RESTORE_FAILED",
        "") -join [Environment]::NewLine
    Save-TextFile (Join-Path $LogDir 'summary.txt') $summaryText
    throw "dotnet restore failed"
}

# 03 - build
& $DotnetPath build $Solution --nologo -v minimal 2> (Join-Path $LogDir '03_build.stderr.txt') | Out-File -FilePath (Join-Path $LogDir '03_build.stdout.txt') -Encoding UTF8
$buildExitCode = $LASTEXITCODE
Write-ExitFile (Join-Path $LogDir '03_build.exit.txt') $buildExitCode
if ($buildExitCode -ne 0) {
    $summaryText = @(
        "RUN_ID=$runId",
        "NUGET_SOURCE=$NuGetV2Source",
        "RESTORE_EXIT_CODE=$restoreExitCode",
        "BUILD_EXIT_CODE=$buildExitCode",
        "TEST_EXIT_CODE=",
        "FINAL_STAGE_REACHED=BUILD_FAILED",
        "") -join [Environment]::NewLine
    Save-TextFile (Join-Path $LogDir 'summary.txt') $summaryText
    throw "dotnet build failed"
}

# 04 - test
& $DotnetPath test $TestProject --nologo --logger "console;verbosity=minimal" 2> (Join-Path $LogDir '04_test.stderr.txt') | Out-File -FilePath (Join-Path $LogDir '04_test.stdout.txt') -Encoding UTF8
$testExitCode = $LASTEXITCODE
Write-ExitFile (Join-Path $LogDir '04_test.exit.txt') $testExitCode
if ($testExitCode -ne 0) {
    $testLogText = @(
        "RUN_ID=$runId",
        "NUGET_SOURCE=$NuGetV2Source",
        "RESTORE_EXIT_CODE=$restoreExitCode",
        "BUILD_EXIT_CODE=$buildExitCode",
        "TEST_EXIT_CODE=$testExitCode",
        "TESTS_FAILED=SEE 04_test.stdout.txt",
        "FINAL_STAGE_REACHED=TEST_FAILED",
        "") -join [Environment]::NewLine
    Save-TextFile (Join-Path $LogDir 'summary.txt') $testLogText
    throw "dotnet test failed"
}

# 05 - startup
# No code changes; this is a verification-only script.
$startupStdout = Join-Path $LogDir '05_startup.stdout.txt'
$startupStderr = Join-Path $LogDir '05_startup.stderr.txt'
$startupProcess = Start-Process -FilePath $DotnetPath -ArgumentList @('run', '--project', $ApiProject, '--urls', 'http://127.0.0.1:5252') -WorkingDirectory $Root -RedirectStandardOutput $startupStdout -RedirectStandardError $startupStderr -PassThru
Write-ExitFile (Join-Path $LogDir '05_startup.pid.txt') $startupProcess.Id
Start-Sleep -Seconds 10
if ($startupProcess.HasExited) {
    Save-TextFile (Join-Path $LogDir 'summary.txt') ("STARTUP FAILED TO STAY RUNNING; EXIT=$($startupProcess.ExitCode)`r`n")
    throw "Backend did not stay running"
}

# 06 health
try {
    $health = Invoke-WebRequest -Uri 'http://127.0.0.1:5252/health' -UseBasicParsing -TimeoutSec 20
    Save-TextFile (Join-Path $LogDir '06_health.txt') $health.Content
} catch {
    Save-TextFile (Join-Path $LogDir '06_health.txt') ("HEALTH_CHECK_ERROR: " + $_.Exception.Message)
    throw
}

# 07 identity
try {
    $identity = Invoke-WebRequest -Uri 'http://127.0.0.1:5252/api/identity' -UseBasicParsing -TimeoutSec 20
    Save-TextFile (Join-Path $LogDir '07_identity.txt') $identity.Content
} catch {
    Save-TextFile (Join-Path $LogDir '07_identity.txt') ("IDENTITY_CHECK_ERROR: " + $_.Exception.Message)
    throw
}

# Stop only the process started by this script
if ($startupProcess -and -not $startupProcess.HasExited) {
    Stop-Process -Id $startupProcess.Id -Force
}

Save-TextFile (Join-Path $LogDir 'summary.txt') ("All verification steps completed successfully.`r`n")
Write-Host "Verification runner completed. Please review logs in D:\YASIN_WORKSHOP\.verification"
