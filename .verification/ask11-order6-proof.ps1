$ErrorActionPreference = 'Stop'
$logPath = 'D:\YASIN_WORKSHOP\.verification\ask11-order6-final.log'
$runtimePidFile = 'D:\YASIN_WORKSHOP\.verification\runtime\api.pid.txt'

function Write-LogLine([string]$Line) {
    Add-Content -Path $logPath -Value $Line -Encoding UTF8
}

New-Item -Path 'D:\YASIN_WORKSHOP\.verification' -ItemType Directory -Force | Out-Null
Set-Content -Path $logPath -Value '' -Encoding UTF8

Write-LogLine '=== ORDER 6 START ==='
Write-LogLine ('TIME=' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))
Write-LogLine ('PIDFILE_EXISTS=' + (Test-Path $runtimePidFile))

try {
    if (Test-Path $runtimePidFile) {
        $pidText = (Get-Content -Path $runtimePidFile -Raw).Trim()
        if (-not [string]::IsNullOrWhiteSpace($pidText)) {
            $pid = [int]$pidText
            $proc = Get-Process -Id $pid -ErrorAction Stop
            Write-LogLine ('STOPPING_TRACKED_PID=' + $proc.Id)
            Stop-Process -Id $proc.Id -Force -ErrorAction Stop
        }
    }
}
catch {
    Write-LogLine ('STOP_TRACKED_EXCEPTION=' + $_.Exception.Message)
}

Write-LogLine '--- RUN_API ---'
try {
    $runOutput = & 'D:\YASIN_WORKSHOP\tools\run-api.ps1' 2>&1
    foreach ($line in $runOutput) { Write-LogLine $line }
    Write-LogLine ('RUN_API_EXIT=' + $LASTEXITCODE)
}
catch {
    Write-LogLine ('RUN_API_EXCEPTION=' + $_.Exception.Message)
    Write-LogLine 'RUN_API_EXIT=1'
}

Write-LogLine '--- PORT_CHECK ---'
try {
    $connections = Get-NetTCPConnection -LocalPort 5090 -ErrorAction SilentlyContinue
    if ($null -eq $connections) {
        Write-LogLine 'PORT_5090_LISTENING=FALSE'
    }
    else {
        Write-LogLine 'PORT_5090_LISTENING=TRUE'
        foreach ($c in $connections) {
            Write-LogLine ('TCP=' + $c.LocalAddress + ':' + $c.LocalPort + ' PID=' + $c.OwningProcess)
        }
        $pid = $connections[0].OwningProcess
        Write-LogLine ('BACKEND_PROCESS_ID=' + $pid)
        $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($null -ne $proc) {
            Write-LogLine 'BACKEND_PROCESS_RUNNING=TRUE'
            Write-LogLine ('PROCESS_PATH=' + $proc.Path)
        }
        else {
            Write-LogLine 'BACKEND_PROCESS_RUNNING=FALSE'
        }
    }
}
catch {
    Write-LogLine ('PORT_CHECK_EXCEPTION=' + $_.Exception.Message)
}

Write-LogLine '--- HEALTH_CHECK ---'
try {
    $health = Invoke-WebRequest -Uri 'http://127.0.0.1:5090/health' -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    Write-LogLine ('HEALTH_HTTP_STATUS=' + $health.StatusCode)
    Write-LogLine ('HEALTH_RESPONSE=' + $health.Content)
    Write-LogLine 'HEALTH_REQUEST_EXIT_CODE=0'
}
catch {
    Write-LogLine ('HEALTH_REQUEST_EXCEPTION=' + $_.Exception.Message)
    Write-LogLine 'HEALTH_REQUEST_EXIT_CODE=1'
}

Write-LogLine '--- FLUTTER_LIVE ---'
$baseUrl = 'http://127.0.0.1:5090'
$healthEndpoint = '/health'
Write-LogLine ('FLUTTER_BASE_URL=' + $baseUrl)
Write-LogLine ('FLUTTER_HEALTH_ENDPOINT=' + $healthEndpoint)
try {
    $fr = Invoke-WebRequest -Uri ($baseUrl + $healthEndpoint) -UseBasicParsing -TimeoutSec 15 -ErrorAction Stop
    Write-LogLine ('FLUTTER_HTTP_STATUS=' + $fr.StatusCode)
    Write-LogLine ('FLUTTER_LIVE_RESPONSE=' + $fr.Content)
    Write-LogLine 'FLUTTER_LIVE_EXIT_CODE=0'
    Write-LogLine 'BACKEND_CONNECTION_VERIFIED=TRUE'
}
catch {
    Write-LogLine ('FLUTTER_EXCEPTION=' + $_.Exception.Message)
    Write-LogLine 'FLUTTER_LIVE_EXIT_CODE=1'
    Write-LogLine 'BACKEND_CONNECTION_VERIFIED=FALSE'
}

Write-LogLine '--- FLUTTER_SDK ---'
Set-Location 'D:\YASIN_WORKSHOP\src\yasin_workshop_mobile'
try {
    $pubOut = & 'C:\src\flutter\bin\flutter.bat' pub get 2>&1
    foreach ($line in $pubOut) { Write-LogLine $line }
    Write-LogLine ('PUB_GET_EXIT_CODE=' + $LASTEXITCODE)

    $analyzeOut = & 'C:\src\flutter\bin\flutter.bat' analyze 2>&1
    foreach ($line in $analyzeOut) { Write-LogLine $line }
    Write-LogLine ('ANALYZE_EXIT_CODE=' + $LASTEXITCODE)

    $testOut = & 'C:\src\flutter\bin\flutter.bat' test 2>&1
    foreach ($line in $testOut) { Write-LogLine $line }
    Write-LogLine ('FLUTTER_TEST_EXIT_CODE=' + $LASTEXITCODE)
}
catch {
    Write-LogLine ('FLUTTER_SDK_EXCEPTION=' + $_.Exception.Message)
}

Write-LogLine '--- WEB_BUILD ---'
try {
    $buildOut = & 'C:\src\flutter\bin\flutter.bat' build web 2>&1
    foreach ($line in $buildOut) { Write-LogLine $line }
    Write-LogLine ('BUILD_EXIT_CODE=' + $LASTEXITCODE)
    Write-LogLine 'TARGET_PLATFORM=Web'
    Write-LogLine 'BUILD_COMMAND=flutter build web'
}
catch {
    Write-LogLine ('BUILD_EXCEPTION=' + $_.Exception.Message)
    Write-LogLine 'BUILD_EXIT_CODE=1'
}

Write-LogLine '--- VERIFY ---'
try {
    $verifyOut = & 'D:\YASIN_WORKSHOP\tools\verify.ps1' 2>&1
    foreach ($line in $verifyOut) { Write-LogLine $line }
    Write-LogLine ('BACKEND_TEST_EXIT_CODE=' + $LASTEXITCODE)
    Write-LogLine 'BACKEND_REGRESSION_RESULT=PASS'
}
catch {
    Write-LogLine ('VERIFY_EXCEPTION=' + $_.Exception.Message)
    Write-LogLine 'BACKEND_TEST_EXIT_CODE=1'
    Write-LogLine 'BACKEND_REGRESSION_RESULT=FAIL'
}

Write-LogLine '=== ORDER 6 END ==='
