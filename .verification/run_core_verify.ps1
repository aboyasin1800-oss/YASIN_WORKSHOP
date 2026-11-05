$ErrorActionPreference = 'Stop'
$root = 'D:\YASIN_WORKSHOP'
$solution = Join-Path $root 'src\YasinWorkshop.slnx'
$dotnet = 'C:\Program Files\dotnet\dotnet.exe'

New-Item -ItemType Directory -Force -Path (Join-Path $root '.verification') | Out-Null

& $dotnet --info *>&1 | Set-Content -Path (Join-Path $root '.verification\dotnet_info.stdout.txt')
[System.IO.File]::WriteAllText((Join-Path $root '.verification\dotnet_info.exit.txt'), $LASTEXITCODE.ToString())

try {
  & $dotnet restore $solution --nologo *>&1 | Set-Content -Path (Join-Path $root '.verification\restore.stdout.txt')
  [System.IO.File]::WriteAllText((Join-Path $root '.verification\restore.exit.txt'), $LASTEXITCODE.ToString())
}
catch {
  [System.IO.File]::WriteAllText((Join-Path $root '.verification\restore.exit.txt'), '-1')
  throw
}

try {
  & $dotnet build $solution --nologo -v minimal *>&1 | Set-Content -Path (Join-Path $root '.verification\build.stdout.txt')
  [System.IO.File]::WriteAllText((Join-Path $root '.verification\build.exit.txt'), $LASTEXITCODE.ToString())
}
catch {
  [System.IO.File]::WriteAllText((Join-Path $root '.verification\build.exit.txt'), '-1')
  throw
}

try {
  & $dotnet test $solution --nologo --logger "console;verbosity=minimal" *>&1 | Set-Content -Path (Join-Path $root '.verification\test.stdout.txt')
  [System.IO.File]::WriteAllText((Join-Path $root '.verification\test.exit.txt'), $LASTEXITCODE.ToString())
}
catch {
  [System.IO.File]::WriteAllText((Join-Path $root '.verification\test.exit.txt'), '-1')
  throw
}
