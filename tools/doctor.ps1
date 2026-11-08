Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. (Join-Path $PSScriptRoot 'ProjectOps.ps1')

$checks = [System.Collections.Generic.List[object]]::new()

function Add-Check {
    param(
        [Parameter(Mandatory = $true)] [string]$Name,
        [Parameter(Mandatory = $true)] [bool]$Passed,
        [Parameter(Mandatory = $true)] [string]$Reason
    )

    $checks.Add([pscustomobject]@{
        Name = $Name
        Passed = $Passed
        Reason = $Reason
    })
}

$dotnetCommand = Get-Command dotnet -ErrorAction SilentlyContinue
if ($dotnetCommand) {
    $sdkVersions = @(& dotnet --list-sdks 2>$null)
    $sdkText = if ($sdkVersions.Count -gt 0) { ($sdkVersions | Select-Object -First 3) -join '; ' } else { 'No SDKs found' }
    Add-Check 'NET SDK' ($sdkVersions.Count -gt 0) "SDKs: $sdkText"
}
else {
    Add-Check 'NET SDK' $false 'dotnet executable not found on PATH.'
}

$pwshVersion = $PSVersionTable.PSVersion.ToString()
Add-Check 'PowerShell' ($true) "Version: $pwshVersion"

$solutionExists = Test-Path $script:Solution
Add-Check 'Solution path' $solutionExists "Path: $script:Solution"

$apiExists = Test-Path $script:ApiProject
$testExists = Test-Path $script:TestProject
Add-Check 'API project' $apiExists "Path: $script:ApiProject"
Add-Check 'Test project' $testExists "Path: $script:TestProject"

$nugetPath = Get-NuGetGlobalPackagesPath
$isNugetCacheValid = -not [string]::IsNullOrWhiteSpace($nugetPath) -and (Test-Path $nugetPath)
Add-Check 'NuGet global cache' $isNugetCacheValid "Path: $nugetPath"

$packageNames = @('Microsoft.Data.SqlClient', 'Microsoft.EntityFrameworkCore.SqlServer', 'Microsoft.NET.Test.Sdk')
$availablePackages = @()
if ($isNugetCacheValid) {
    foreach ($package in $packageNames) {
        $candidate = Join-Path $nugetPath $package
        if (Test-Path $candidate) {
            $availablePackages += $package
        }
    }
}
$packageReason = if ($availablePackages.Count -gt 0) { "Found: $($availablePackages -join ', ')" } else { 'No known package directories detected in NuGet cache.' }
Add-Check 'Package availability' (($availablePackages.Count -ge 1)) $packageReason

$connectionInfo = Get-DatabaseConnectionInfo
$serverName = if ($connectionInfo) { $connectionInfo.Server } else { 'UNKNOWN' }
$databaseName = if ($connectionInfo) { $connectionInfo.Database } else { 'UNKNOWN' }
Add-Check 'Database identity config' ($null -ne $connectionInfo) "Server: $serverName; Database: $databaseName"

$port = Get-PreferredPort
$portHealthy = $false
$portReason = "Preferred port: $port"

try {
    $portHealthy = Test-ManagedBackendHealthy -Port $port
    if ($portHealthy) {
        $portReason = "Preferred port: $port is serving the tracked YasinWorkshop API"
    }
    elseif (Test-PortAvailable -Port $port) {
        $portHealthy = $true
        $portReason = "Preferred port: $port is available before backend startup"
    }
    else {
        try {
            $response = Invoke-WebRequest -Uri "http://127.0.0.1:$port/health" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
            $portHealthy = ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400)
            if ($portHealthy) {
                $portReason = "Preferred port: $port is serving a healthy API endpoint"
            }
        }
        catch {
            $portHealthy = $false
            $portReason = "Preferred port: $port is occupied and not serving the project API"
        }
    }
}
catch {
    $portHealthy = $false
    $portReason = "Preferred port: $port could not be validated"
}

Add-Check 'Backend port check' $portHealthy $portReason

$healthExists = Test-Path (Join-Path $script:Root 'src\YasinWorkshop.Api\Program.cs')
Add-Check 'Health endpoint config' $healthExists 'Program maps /health'

$identityExists = Test-Path (Join-Path $script:Root 'src\YasinWorkshop.Api\Program.cs')
Add-Check 'Identity endpoint config' $identityExists 'Program maps /api/identity'

$serverCheck = $false
$serverReason = 'SQL Server not reachable or sqlcmd unavailable.'
if (Get-Command sqlcmd -ErrorAction SilentlyContinue) {
    try {
        $serverQuoted = $serverName
        if ($serverQuoted -and $serverQuoted -ne 'UNKNOWN') {
            $result = & sqlcmd -S $serverQuoted -Q "SELECT 1;" -h -1 -W -s ',' 2>$null
            $serverCheck = ($LASTEXITCODE -eq 0)
            $serverReason = if ($serverCheck) { "SQL Server reachable on $serverName" } else { "SQL Server did not respond on $serverName" }
        }
    }
    catch {
        $serverReason = 'SQL Server connectivity could not be validated.'
    }
}
else {
    $serverReason = 'sqlcmd not available on PATH.'
}
Add-Check 'SQL Server availability' $serverCheck $serverReason

$failures = @($checks | Where-Object { -not $_.Passed })
foreach ($check in $checks) {
    $status = if ($check.Passed) { 'PASS' } else { 'FAIL' }
    Write-Host ("[{0}] {1} - {2}" -f $status, $check.Name, $check.Reason)
}

if ($failures.Count -gt 0) {
    Write-Host 'Doctor result: FAIL'
    exit 1
}

Write-Host 'Doctor result: PASS'
exit 0
