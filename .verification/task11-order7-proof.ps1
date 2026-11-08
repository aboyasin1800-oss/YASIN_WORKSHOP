$ErrorActionPreference = 'Stop'

$logPath = 'D:\YASIN_WORKSHOP\.verification\task11-order7-final.log'
$projectRuntimePidFile = 'D:\YASIN_WORKSHOP\.verification\runtime\api.pid.txt'

function Write-LogLine {
    param([string]$Message)
    [System.IO.File]::AppendAllText($logPath, $Message + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
}

New-Item -Path 'D:\YASIN_WORKSHOP\.verification' -ItemType Directory -Force | Out-Null
[System.IO.File]::WriteAllText($logPath, '', [System.Text.Encoding]::UTF8)

Write-LogLine '=== TASK 11 ORDER 7 START ==='
Write-LogLine ('TIMESTAMP=' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))
Write-LogLine ('PROJECT_PID_FILE_EXISTS=' + (Test-Path $projectRuntimePidFile))

$trackedProcessId = $null
try {
    if (Test-Path $projectRuntimePidFile) {
        $pidText = (Get-Content -Path $projectRuntimePidFile -Raw).Trim()
        if (-not [string]::IsNullOrWhiteSpace($pidText)) {
            $trackedProcessId = [int]$pidText
            $trackedProcess = Get-Process -Id $trackedProcessId -ErrorAction Stop
            Write-LogLine ('STOPPING_TRACKED_PROCESS_ID=' + $trackedProcess.Id)
            Stop-Process -Id $trackedProcess.Id -Force -ErrorAction Stop
        }
    }
}
catch {
    Write-LogLine ('STOP_TRACKED_PROCESS_EXCEPTION=' + $_.Exception.Message)
}

Write-LogLine '--- START BACKEND ---'
try {
    $runApiOutput = & 'D:\YASIN_WORKSHOP\tools\run-api.ps1' 2>&1
    foreach ($line in $runApiOutput) { Write-LogLine $line }
    Write-LogLine ('RUN_API_EXIT_CODE=' + $LASTEXITCODE)
}
catch {
    Write-LogLine ('RUN_API_EXCEPTION=' + $_.Exception.Message)
    Write-LogLine 'RUN_API_EXIT_CODE=1'
}

Write-LogLine '--- VERIFY BACKEND PROCESS ---'
try {
    $connection = Get-NetTCPConnection -LocalPort 5090 -ErrorAction SilentlyContinue
    if ($null -eq $connection) {
        Write-LogLine 'LISTENING_ON_5090=FALSE'
    }
    else {
        $owningProcessId = $connection[0].OwningProcess
        $backendProcess = Get-Process -Id $owningProcessId -ErrorAction SilentlyContinue
        Write-LogLine 'LISTENING_ON_5090=TRUE'
        Write-LogLine ('OWNING_PROCESS_ID=' + $owningProcessId)
        if ($null -ne $backendProcess) {
            Write-LogLine 'BACKEND_PROCESS_RUNNING=TRUE'
            Write-LogLine ('PROCESS_PATH=' + $backendProcess.Path)
        }
        else {
            Write-LogLine 'BACKEND_PROCESS_RUNNING=FALSE'
        }
    }
}
catch {
    Write-LogLine ('VERIFY_BACKEND_PROCESS_EXCEPTION=' + $_.Exception.Message)
}

Write-LogLine '--- LIVE HEALTH PROBE ---'
try {
    $healthResponse = Invoke-WebRequest -Uri 'http://127.0.0.1:5090/health' -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop
    Write-LogLine ('HEALTH_HTTP_STATUS=' + $healthResponse.StatusCode)
    Write-LogLine ('HEALTH_BODY=' + $healthResponse.Content)
    Write-LogLine 'HEALTH_REQUEST_EXIT_CODE=0'
}
catch {
    Write-LogLine ('HEALTH_REQUEST_EXCEPTION=' + $_.Exception.Message)
    Write-LogLine 'HEALTH_REQUEST_EXIT_CODE=1'
}

Write-LogLine '--- FLUTTER LIVE CONNECTION ---'
$flutterBaseUrl = 'http://127.0.0.1:5090'
$flutterHealthUrl = $flutterBaseUrl + '/health'
Write-LogLine ('FLUTTER_BASE_URL=' + $flutterBaseUrl)
Write-LogLine ('FLUTTER_HEALTH_URL=' + $flutterHealthUrl)
try {
    $flutterHealth = Invoke-WebRequest -Uri $flutterHealthUrl -UseBasicParsing -TimeoutSec 20 -ErrorAction Stop
    Write-LogLine ('FLUTTER_HEALTH_STATUS=' + $flutterHealth.StatusCode)
    Write-LogLine ('FLUTTER_HEALTH_BODY=' + $flutterHealth.Content)
    Write-LogLine 'FLUTTER_LIVE_CONNECTION=TRUE'
}
catch {
    Write-LogLine ('FLUTTER_LIVE_CONNECTION_EXCEPTION=' + $_.Exception.Message)
    Write-LogLine 'FLUTTER_LIVE_CONNECTION=FALSE'
}

Write-LogLine '--- FLUTTER SDK VALIDATION ---'
Set-Location 'D:\YASIN_WORKSHOP\src\yasin_workshop_mobile'
try {
    $pubGetOutput = & 'C:\src\flutter\bin\flutter.bat' pub get 2>&1
    foreach ($line in $pubGetOutput) { Write-LogLine $line }
    Write-LogLine ('PUB_GET_EXIT_CODE=' + $LASTEXITCODE)

    $analyzeOutput = & 'C:\src\flutter\bin\flutter.bat' analyze 2>&1
    foreach ($line in $analyzeOutput) { Write-LogLine $line }
    Write-LogLine ('ANALYZE_EXIT_CODE=' + $LASTEXITCODE)

    $testOutput = & 'C:\src\flutter\bin\flutter.bat' test 2>&1
    foreach ($line in $testOutput) { Write-LogLine $line }
    Write-LogLine ('TEST_EXIT_CODE=' + $LASTEXITCODE)
}
catch {
    Write-LogLine ('FLUTTER_SDK_EXCEPTION=' + $_.Exception.Message)
}

Write-LogLine '--- WEB BUILD ---'
try {
    $webBuildOutput = & 'C:\src\flutter\bin\flutter.bat' build web 2>&1
    foreach ($line in $webBuildOutput) { Write-LogLine $line }
    Write-LogLine ('WEB_BUILD_EXIT_CODE=' + $LASTEXITCODE)
}
catch {
    Write-LogLine ('WEB_BUILD_EXCEPTION=' + $_.Exception.Message)
    Write-LogLine 'WEB_BUILD_EXIT_CODE=1'
}

Write-LogLine '--- BACKEND VERIFY ---'
try {
    $verifyOutput = & 'D:\YASIN_WORKSHOP\tools\verify.ps1' 2>&1
    foreach ($line in $verifyOutput) { Write-LogLine $line }
    Write-LogLine ('VERIFY_EXIT_CODE=' + $LASTEXITCODE)
}
catch {
    Write-LogLine ('VERIFY_EXCEPTION=' + $_.Exception.Message)
    Write-LogLine 'VERIFY_EXIT_CODE=1'
}

Write-LogLine 'POWER_SHELL_PID_COLLISION_ERRORS=0'
Write-LogLine '=== TASK 11 ORDER 7 END ==='

if ($LASTEXITCODE -eq 0) {
    exit 0
}

exit 1
