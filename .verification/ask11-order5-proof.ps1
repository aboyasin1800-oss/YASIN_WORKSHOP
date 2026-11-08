$ErrorActionPreference = 'Stop'
$log = 'd:\YASIN_WORKSHOP\.verification\ask11-order5-final.log'
Set-Content -Path $log -Value '' -Encoding UTF8

function Add-Log([string]$line) {
    Add-Content -Path $log -Value $line -Encoding UTF8
}

Add-Log '=== START ORDER 5 LIVE PROOF ==='
Add-Log ('TIME=' + (Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))
Set-Location 'd:\YASIN_WORKSHOP'

$pidFile = 'd:\YASIN_WORKSHOP\.verification\runtime\api.pid.txt'
if (Test-Path $pidFile) {
    $pidText = (Get-Content -Path $pidFile -Raw).Trim()
    if (-not [string]::IsNullOrWhiteSpace($pidText)) {
        try {
            $pid = [int]$pidText
            $proc = Get-Process -Id $pid -ErrorAction Stop
            Add-Log ('STOPPING_TRACKED_PID=' + $proc.Id)
            Stop-Process -Id $proc.Id -Force -ErrorAction Stop
        }
        catch {
            Add-Log 'NO_TRACKED_PROCESS_TO_STOP'
        }
    }
}

Add-Log '--- RUN-API START ---'
try {
    & 'powershell' -NoProfile -ExecutionPolicy Bypass -File '.\tools\run-api.ps1' 2>&1 | ForEach-Object { Add-Log $_ }
    $runExit = $LASTEXITCODE
    Add-Log ('RUN_API_EXIT=' + $runExit)
}
catch {
    Add-Log ('RUN_API_EXCEPTION=' + $_.Exception.Message)
    $runExit = 1
}

Add-Log '--- PORT CHECK ---'
try {
    $conns = Get-NetTCPConnection -LocalPort 5090 -ErrorAction SilentlyContinue
    if ($null -eq $conns) {
        Add-Log 'PORT_5090_LISTENING=FALSE'
    }
    else {
        Add-Log ('PORT_5090_LISTENING=TRUE')
        $conns | Format-Table -AutoSize | ForEach-Object { Add-Log $_.ToString() }
        $pid = $conns[0].OwningProcess
        Add-Log ('BACKEND_PROCESS_ID=' + $pid)
        $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
        if ($null -ne $proc) {
            Add-Log ('BACKEND_PROCESS_RUNNING=TRUE')
            Add-Log ('PROCESS_PATH=' + $proc.Path)
        }
        else {
            Add-Log 'BACKEND_PROCESS_RUNNING=FALSE'
        }
    }
}
catch {
    Add-Log ('PORT_CHECK_EXCEPTION=' + $_.Exception.Message)
}

Add-Log '--- HEALTH REQUEST ---'
try {
    $response = Invoke-WebRequest -Uri 'http://127.0.0.1:5090/health' -UseBasicParsing -TimeoutSec 10 -ErrorAction Stop
    Add-Log ('HEALTH_HTTP_STATUS=' + $response.StatusCode)
    Add-Log ('HEALTH_RESPONSE=' + $response.Content)
    Add-Log ('HEALTH_REQUEST_EXIT_CODE=0')
}
catch {
    Add-Log ('HEALTH_REQUEST_EXCEPTION=' + $_.Exception.Message)
    Add-Log 'HEALTH_REQUEST_EXIT_CODE=1'
}

Add-Log '=== END ORDER 5 LIVE PROOF ==='
exit 0
