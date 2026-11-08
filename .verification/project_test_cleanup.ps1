$project = 'D:\YASIN_WORKSHOP\src\yasin_workshop_mobile'
$names = @('flutter_tester','dart','dartvm','dartaotruntime')
$before = Get-CimInstance Win32_Process | Where-Object {
    $names -contains $_.Name -and $_.CommandLine -and $_.CommandLine.Contains($project)
}
$before | Select-Object ProcessId,Name,CommandLine | Format-Table -AutoSize
$stopped = @()
foreach ($p in $before) {
    Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
    $stopped += $p.ProcessId
}
$after = Get-CimInstance Win32_Process | Where-Object {
    $names -contains $_.Name -and $_.CommandLine -and $_.CommandLine.Contains($project)
}
Write-Output ("PROJECT_TEST_PROCESSES_BEFORE=" + $before.Count)
Write-Output ("PROJECT_TEST_PROCESSES_STOPPED=" + $stopped.Count)
Write-Output ("PROJECT_TEST_PROCESSES_AFTER=" + $after.Count)
if ($stopped.Count -gt 0) {
    Write-Output ("STOPPED_PIDS=" + ($stopped -join ','))
}
