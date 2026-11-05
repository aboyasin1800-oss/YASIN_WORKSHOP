Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:Root = Split-Path -Parent $PSScriptRoot
$script:Solution = Join-Path $script:Root 'src\YasinWorkshop.slnx'
$script:ApiProject = Join-Path $script:Root 'src\YasinWorkshop.Api\YasinWorkshop.Api.csproj'
$script:TestProject = Join-Path $script:Root 'src\YasinWorkshop.Tests\YasinWorkshop.Tests.csproj'
$script:LogRoot = Join-Path $script:Root '.verification'
$script:RuntimePidFile = Join-Path $script:LogRoot 'api.pid'
$script:RuntimeLogDir = Join-Path $script:LogRoot 'runtime'

New-Item -ItemType Directory -Path $script:LogRoot -Force | Out-Null
New-Item -ItemType Directory -Path $script:RuntimeLogDir -Force | Out-Null

function Write-ToolLog {
    param(
        [Parameter(Mandatory = $true)] [string]$Path,
        [Parameter(Mandatory = $true)] [string[]]$Lines
    )

    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    $content = ($Lines -join [Environment]::NewLine) + [Environment]::NewLine
    [System.IO.File]::WriteAllText($Path, $content, [System.Text.UTF8Encoding]::UTF8)
}

function Get-PreferredPort {
    $path = Join-Path $script:Root 'tools\project-port-registry.json'
    if (-not (Test-Path $path)) {
        return 5090
    }

    try {
        $config = Get-Content -Path $path -Raw | ConvertFrom-Json
        if ($config.PreferredBackendPort) {
            return [int]$config.PreferredBackendPort
        }
    }
    catch {
        return 5090
    }

    return 5090
}

function Get-ProjectPortConfig {
    $path = Join-Path $script:Root 'tools\project-port-registry.json'
    if (Test-Path $path) {
        try {
            return Get-Content -Path $path -Raw | ConvertFrom-Json
        }
        catch {
            return $null
        }
    }

    return $null
}

function Get-NuGetGlobalPackagesPath {
    $raw = & dotnet nuget locals global-packages --list 2>$null
    $line = $raw | Where-Object { $_ -match 'global-packages' } | Select-Object -First 1
    if (-not $line) {
        return $null
    }

    return ($line -replace '.*global-packages:\s*', '').Trim()
}

function Test-RestoreRequired {
    param(
        [string[]]$ProjectPaths = @($script:ApiProject, $script:TestProject)
    )

    $reasons = [System.Collections.Generic.List[string]]::new()
    $nugetRoot = Get-NuGetGlobalPackagesPath

    foreach ($projectPath in $ProjectPaths) {
        if (-not (Test-Path $projectPath)) {
            $reasons.Add("Project file missing: $projectPath")
            continue
        }

        $projectDirectory = Split-Path -Parent $projectPath
        $assetsPath = Join-Path $projectDirectory 'obj\project.assets.json'
        if (-not (Test-Path $assetsPath)) {
            $reasons.Add("Missing assets file: $assetsPath")
            continue
        }

        $projectFile = Get-Item -Path $projectPath
        $assetsFile = Get-Item -Path $assetsPath
        if ($projectFile.LastWriteTimeUtc -gt $assetsFile.LastWriteTimeUtc) {
            $reasons.Add("Project is newer than assets: $projectPath")
            continue
        }

        if (-not $nugetRoot) {
            $reasons.Add("NuGet global packages path could not be resolved.")
            continue
        }

        try {
            [xml]$projectXml = Get-Content -Path $projectPath -Raw
            $packageReferences = [System.Collections.Generic.List[pscustomobject]]::new()

            foreach ($packageReference in @($projectXml.SelectNodes('//PackageReference'))) {
                $packageId = [string]$packageReference.GetAttribute('Include')
                $packageVersion = [string]$packageReference.GetAttribute('Version')
                if ([string]::IsNullOrWhiteSpace($packageId) -or [string]::IsNullOrWhiteSpace($packageVersion)) {
                    continue
                }

                $packageReferences.Add([pscustomobject]@{
                    Id = $packageId.Trim()
                    Version = $packageVersion.Trim()
                })
            }

            foreach ($packageReference in $packageReferences) {
                $packageId = $packageReference.Id
                $packageVersion = $packageReference.Version

                $packageRoot = Join-Path $nugetRoot $packageId
                $packageRootLower = Join-Path $nugetRoot $packageId.ToLowerInvariant()
                $packageVersionPath = Join-Path $packageRoot $packageVersion
                $packageVersionPathLower = Join-Path $packageRootLower $packageVersion

                if (-not (Test-Path $packageRoot) -and -not (Test-Path $packageRootLower)) {
                    $reasons.Add("Missing NuGet package folder: $packageId")
                    continue
                }

                $resolvedVersionPath = if (Test-Path $packageVersionPath) { $packageVersionPath } elseif (Test-Path $packageVersionPathLower) { $packageVersionPathLower } else { $null }
                if (-not $resolvedVersionPath) {
                    $reasons.Add("Missing NuGet package version: $packageId/$packageVersion")
                }
            }
        }
        catch {
            $reasons.Add("Unable to inspect package references in $projectPath")
        }
    }

    return [pscustomobject]@{
        Required = ($reasons.Count -gt 0)
        Reasons = @($reasons)
    }
}

function Get-ConfigValue {
    param(
        [Parameter(Mandatory = $true)] [string]$ConfigPath,
        [Parameter(Mandatory = $true)] [string]$Key
    )

    if (-not (Test-Path $ConfigPath)) {
        return $null
    }

    try {
        $config = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
        $value = $config.$Key
        if ($null -ne $value) {
            return $value
        }
    }
    catch {
        return $null
    }

    return $null
}

function Get-DatabaseConnectionInfo {
    $candidates = @(
        (Join-Path $script:Root 'src\YasinWorkshop.Api\appsettings.json'),
        (Join-Path $script:Root 'src\YasinWorkshop.Api\appsettings.Development.json')
    )

    foreach ($file in $candidates) {
        if (-not (Test-Path $file)) {
            continue
        }

        try {
            $json = Get-Content -Path $file -Raw | ConvertFrom-Json
            $conn = $json.ConnectionStrings.DevelopmentDatabase
            if ($conn) {
                return [pscustomobject]@{
                    File = $file
                    ConnectionString = $conn
                    Server = if ($conn -match 'Server=([^;]+)') { $Matches[1] } else { $null }
                    Database = if ($conn -match 'Database=([^;]+)') { $Matches[1] } else { $null }
                }
            }
        }
        catch {
            continue
        }
    }

    return $null
}

function Test-PortAvailable {
    param([Parameter(Mandatory = $true)][int]$Port)

    try {
        $inUse = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
        if ($null -ne $inUse) {
            return $false
        }
    }
    catch {
        return $false
    }

    return $true
}

function Test-ManagedBackendHealthy {
    param([Parameter(Mandatory = $true)][int]$Port)

    $pidFile = Join-Path $script:RuntimeLogDir 'api.pid.txt'
    if (-not (Test-Path $pidFile)) {
        return $false
    }

    try {
        $pidText = (Get-Content -Path $pidFile -Raw).Trim()
        if ([string]::IsNullOrWhiteSpace($pidText)) {
            return $false
        }

        $managedPid = [int]$pidText
        $process = Get-Process -Id $managedPid -ErrorAction SilentlyContinue
        if ($null -eq $process) {
            return $false
        }

        $response = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/health" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400)
    }
    catch {
        return $false
    }
}

function Start-ProjectApi {
    param(
        [Parameter(Mandatory = $true)][int]$Port,
        [Parameter()][string]$LogPrefix = 'api'
    )

    $stdout = Join-Path $script:RuntimeLogDir ($LogPrefix + '.stdout.log')
    $stderr = Join-Path $script:RuntimeLogDir ($LogPrefix + '.stderr.log')
    $pidFile = Join-Path $script:RuntimeLogDir ($LogPrefix + '.pid.txt')

    $proc = Start-Process -FilePath 'dotnet' -ArgumentList @('run', '--project', $script:ApiProject, '--urls', "http://127.0.0.1:$Port", '--no-restore', '-p:NuGetAudit=false', '-p:RestoreIgnoreFailedSources=true') -RedirectStandardOutput $stdout -RedirectStandardError $stderr -PassThru -NoNewWindow
    $proc.Id | Set-Content -Path $pidFile
    return $proc
}

function Wait-ForHealth {
    param(
        [Parameter(Mandatory = $true)][int]$Port,
        [Parameter()][int]$TimeoutSeconds = 60
    )

    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    while ((Get-Date) -lt $deadline) {
        try {
            $response = Invoke-WebRequest -Uri "http://127.0.0.1:$Port/health" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop
            if ($response.StatusCode -ge 200 -and $response.StatusCode -lt 400) {
                return $true
            }
        }
        catch {
            Start-Sleep -Seconds 1
        }
    }

    return $false
}

function Stop-TrackedProjectApi {
    $pidFile = Join-Path $script:RuntimeLogDir 'api.pid.txt'
    if (-not (Test-Path $pidFile)) {
        return $false
    }

    $managedPid = [int](Get-Content -Path $pidFile -Raw).Trim()
    if ($managedPid -le 0) {
        return $false
    }

    $process = Get-Process -Id $managedPid -ErrorAction SilentlyContinue
    if ($null -eq $process) {
        return $false
    }

    Stop-Process -Id $managedPid -Force
    return $true
}

function Get-ProjectIdentitySummary {
    $conn = Get-DatabaseConnectionInfo
    $server = if ($conn) { $conn.Server } else { 'UNKNOWN' }
    $db = if ($conn) { $conn.Database } else { 'UNKNOWN' }

    return [pscustomobject]@{
        Server = $server
        Database = $db
        ConfigFile = if ($conn) { $conn.File } else { 'NOT_FOUND' }
        ExpectedDatabase = 'YASIN_WORKSHOP_ES_VALIDATION'
    }
}
