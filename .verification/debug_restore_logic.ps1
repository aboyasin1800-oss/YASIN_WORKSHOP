$projectPath = 'D:\YASIN_WORKSHOP\src\YasinWorkshop.Tests\YasinWorkshop.Tests.csproj'
$nugetRoot = & dotnet nuget locals global-packages --list 2>$null
$line = $nugetRoot | Where-Object { $_ -match 'global-packages' } | Select-Object -First 1
Write-Host ('LINE=' + $line)
$nugetRoot = ($line -replace '.*global-packages:\s*', '').Trim()
Write-Host ('NUGET_ROOT=' + $nugetRoot)
try {
    [xml]$projectXml = Get-Content -Path $projectPath -Raw
    Write-Host 'PARSED_OK'
    $packageReferences = @($projectXml.Project.ItemGroup.PackageReference | Where-Object { $_.Include -and $_.Version })
    Write-Host ('COUNT=' + $packageReferences.Count)
    foreach ($packageReference in $packageReferences) {
        $packageId = [string]$packageReference.Include
        $packageVersion = [string]$packageReference.Version
        Write-Host ('PKG=' + $packageId + ' ' + $packageVersion)
        $packageRoot = Join-Path $nugetRoot $packageId
        $packageVersionPath = Join-Path $packageRoot $packageVersion
        if (-not (Test-Path $packageRoot)) { Write-Host 'MISSING ROOT'; continue }
        if (-not (Test-Path $packageVersionPath)) { Write-Host 'MISSING VER'; }
    }
}
catch {
    Write-Host 'CAUGHT_EXCEPTION'
    $_ | Format-List * -Force
}
