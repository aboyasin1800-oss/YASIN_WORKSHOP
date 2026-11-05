param(
    [Parameter(Position = 0)]
    [ValidateSet(
        'doctor','restore','build','build-full','test','test-focused','test-full',
        'flutter-doctor','flutter-deps','flutter-analyze','flutter-analyze-full','flutter-test','flutter-test-focused','flutter-run',
        'run','run-api','stop','stop-api','smoke','db','db-verify','verify','verify-fast','verify-full','status','logs'
    )]
    [string]$Action = 'status',

    [string]$Target = '',
    [string]$Filter = '',
    [switch]$NoBuild
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent $PSScriptRoot

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "==== $Title ===="
}

function Invoke-Tool {
    param(
        [string]$Name,
        [string]$File,
        [string[]]$Args = @()
    )

    Write-Host ("Running {0} ..." -f $Name)
    & 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -NoProfile -ExecutionPolicy Bypass -File $File @Args
    if ($LASTEXITCODE -ne 0) {
        throw "Tool failed: $Name"
    }
}

switch ($Action) {
    'doctor' {
        Invoke-Tool -Name 'Doctor' -File (Join-Path $PSScriptRoot 'doctor.ps1')
    }
    'restore' {
        Invoke-Tool -Name 'Restore' -File (Join-Path $PSScriptRoot 'restore.ps1')
    }
    'build' {
        Invoke-Tool -Name 'Fast Build' -File (Join-Path $PSScriptRoot 'build-fast.ps1') -Args @('-Mode', 'FAST')
    }
    'build-full' {
        Invoke-Tool -Name 'Full Build' -File (Join-Path $PSScriptRoot 'build-fast.ps1') -Args @('-Mode', 'FULL')
    }
    'test' {
        Invoke-Tool -Name 'Focused Test' -File (Join-Path $PSScriptRoot 'test-fast.ps1') -Args @('-NoBuild')
    }
    'test-focused' {
        Invoke-Tool -Name 'Focused Test' -File (Join-Path $PSScriptRoot 'test-fast.ps1') -Args @('-NoBuild')
    }
    'test-full' {
        Invoke-Tool -Name 'Full Test' -File (Join-Path $PSScriptRoot 'test-fast.ps1')
    }
    'flutter-doctor' {
        Invoke-Tool -Name 'Flutter Doctor' -File (Join-Path $PSScriptRoot 'flutter-doctor.ps1')
    }
    'flutter-deps' {
        Invoke-Tool -Name 'Flutter Dependencies' -File (Join-Path $PSScriptRoot 'flutter-deps.ps1')
    }
    'flutter-analyze' {
        Invoke-Tool -Name 'Flutter Analyze' -File (Join-Path $PSScriptRoot 'flutter-analyze.ps1')
    }
    'flutter-analyze-full' {
        Invoke-Tool -Name 'Flutter Full Analyze' -File (Join-Path $PSScriptRoot 'flutter-analyze.ps1') -Args @('-Full')
    }
    'flutter-test' {
        Invoke-Tool -Name 'Flutter Focused Test' -File (Join-Path $PSScriptRoot 'flutter-test.ps1')
    }
    'flutter-test-focused' {
        Invoke-Tool -Name 'Flutter Focused Test' -File (Join-Path $PSScriptRoot 'flutter-test.ps1')
    }
    'flutter-run' {
        if (-not (Test-Path (Join-Path $root 'pubspec.yaml'))) {
            Write-Host 'FLUTTER_STATUS=NOT_CREATED_YET'
            exit 0
        }

        Write-Host 'Flutter run is project-specific and is not yet configured for this project state.'
    }
    'run' {
        Invoke-Tool -Name 'Run API' -File (Join-Path $PSScriptRoot 'run-api.ps1')
    }
    'run-api' {
        Invoke-Tool -Name 'Run API' -File (Join-Path $PSScriptRoot 'run-api.ps1')
    }
    'stop' {
        Invoke-Tool -Name 'Stop API' -File (Join-Path $PSScriptRoot 'stop-api.ps1')
    }
    'stop-api' {
        Invoke-Tool -Name 'Stop API' -File (Join-Path $PSScriptRoot 'stop-api.ps1')
    }
    'smoke' {
        Invoke-Tool -Name 'Smoke' -File (Join-Path $PSScriptRoot 'smoke.ps1')
    }
    'db' {
        Invoke-Tool -Name 'DB Verify' -File (Join-Path $PSScriptRoot 'db-verify.ps1')
    }
    'db-verify' {
        Invoke-Tool -Name 'DB Verify' -File (Join-Path $PSScriptRoot 'db-verify.ps1')
    }
    'verify' {
        Invoke-Tool -Name 'Fast Verify' -File (Join-Path $PSScriptRoot 'verify.ps1') -Args @('-Mode', 'FAST')
    }
    'verify-fast' {
        Invoke-Tool -Name 'Fast Verify' -File (Join-Path $PSScriptRoot 'verify.ps1') -Args @('-Mode', 'FAST')
    }
    'verify-full' {
        Invoke-Tool -Name 'Full Verify' -File (Join-Path $PSScriptRoot 'verify.ps1') -Args @('-Mode', 'FULL')
    }
    'status' {
        Write-Section 'Project Status'
        Write-Host ("PROJECT_ROOT={0}" -f $root)
        Write-Host ("SOLUTION_PATH={0}" -f (Join-Path $root 'src\YasinWorkshop.slnx'))
        Write-Host ("BACKEND_ROOT={0}" -f (Join-Path $root 'src\YasinWorkshop.Api'))
        Write-Host ("TEST_PROJECTS={0}" -f (Join-Path $root 'src\YasinWorkshop.Tests'))
        $flutterStatus = if (Test-Path (Join-Path $root 'pubspec.yaml')) { 'AVAILABLE' } else { 'NOT_CREATED_YET' }
        Write-Host ("FLUTTER_STATUS={0}" -f $flutterStatus)
        Write-Host ("RUNTIME_MANAGER_READY=YES")
        Write-Host ("SAFE_STOP_READY=YES")
        Write-Host ("DOCTOR_READY=YES")
    }
    'logs' {
        $logRoot = Join-Path $root '.verification'
        if (Test-Path $logRoot) {
            Write-Host ("LOG_ROOT={0}" -f $logRoot)
            Get-ChildItem -Path $logRoot -File | Select-Object Name, LastWriteTime | Format-Table -AutoSize
        }
        else {
            Write-Host 'LOG_ROOT=NOT_FOUND'
        }
    }
    default {
        Write-Host 'Unknown action.'
        exit 1
    }
}
