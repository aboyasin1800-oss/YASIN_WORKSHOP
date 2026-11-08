$ErrorActionPreference = 'Stop'

Write-Host 'Stopping stale dotnet processes...'
Get-CimInstance Win32_Process |
    Where-Object { $_.Name -eq 'dotnet.exe' -or $_.Name -eq 'dotnet' } |
    ForEach-Object { Stop-Process -Id $_.ProcessId -Force }

Write-Host 'Starting YasinWorkshop.Api on http://127.0.0.1:5200...'
Set-Location 'D:\YASIN_WORKSHOP\src\YasinWorkshop.Api'
dotnet run --urls http://127.0.0.1:5200
