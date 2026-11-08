$ErrorActionPreference = 'Stop'

$baseUrl = 'http://127.0.0.1:5200'
$userName = 'customer-sync-proof-user'
$unique = [Guid]::NewGuid().ToString('N').Substring(0, 8)
$employeeCode = 'EMP-LIVE-' + $unique

Write-Host '=== EMPLOYEE LIVE PROOF ==='
Write-Host ('USER=' + $userName)
Write-Host ('EMPLOYEE_CODE=' + $employeeCode)

$employeeBody = @{ employeeCode = $employeeCode; name = 'Employee Live Proof ' + $unique; employeeType = 'Piece'; status = 'Active' } | ConvertTo-Json -Compress
$headers = @{ 'X-User-Name' = $userName }

$employee = Invoke-RestMethod -Method Post -UseBasicParsing -Uri ($baseUrl + '/api/employees') -Headers $headers -ContentType 'application/json' -Body $employeeBody
Write-Host ('EMPLOYEE_ID=' + $employee.id)
Write-Host ('EMPLOYEE_CODE_RESPONSE=' + $employee.employeeCode)

$year = (Get-Date).Year
$month = (Get-Date).Month
$contractSql = @"
IF NOT EXISTS (
    SELECT 1
    FROM dbo.employee_monthly_compensations
    WHERE EmployeeId = '$($employee.id)' AND Year = $year AND Month = $month
)
BEGIN
    INSERT INTO dbo.employee_monthly_compensations (
        Id, EmployeeId, Year, Month, CompensationType, Amount, Currency, IsCurrent, Notes, CreatedAt, UpdatedAt
    )
    VALUES (
        NEWID(), '$($employee.id)', $year, $month, 'Piece', 5000.0000, 'SAR', 1, 'LIVE CONTRACT PROOF $unique', SYSUTCDATETIME(), SYSUTCDATETIME()
    );
END;
"@
Invoke-Sqlcmd -ServerInstance 'YASIN-YASIN\SQLEXPRESS' -Database 'YASIN_WORKSHOP_ES_VALIDATION' -Query $contractSql
Write-Host ('MONTHLY_CONTRACT_YEAR=' + $year)
Write-Host ('MONTHLY_CONTRACT_MONTH=' + $month)

$productionBody = @{ operationDate = (Get-Date).ToString('yyyy-MM-dd'); quantity = 12; resolvedUnitRate = 18.50; createdBy = $userName; notes = 'LIVE PRODUCTION PROOF ' + $unique } | ConvertTo-Json -Compress
$production = Invoke-RestMethod -Method Post -UseBasicParsing -Uri ($baseUrl + '/api/employees/' + $employee.id + '/production') -Headers $headers -ContentType 'application/json' -Body $productionBody
Write-Host ('PRODUCTION_ID=' + $production.production.id)
Write-Host ('PRODUCTION_CALCULATED_AMOUNT=' + $production.production.calculatedAmount)
Write-Host ('PRODUCTION_FIRST_SAVED_AT=' + $production.production.firstSavedAt)

$expenseBody = @{ operationDate = (Get-Date).ToString('yyyy-MM-dd'); amount = 185.75; createdBy = $userName; notes = 'LIVE EXPENSE PROOF ' + $unique } | ConvertTo-Json -Compress
$expense = Invoke-RestMethod -Method Post -UseBasicParsing -Uri ($baseUrl + '/api/employees/' + $employee.id + '/expenses') -Headers $headers -ContentType 'application/json' -Body $expenseBody
Write-Host ('EXPENSE_ID=' + $expense.expense.id)
Write-Host ('EXPENSE_AMOUNT=' + $expense.expense.amount)
Write-Host ('EXPENSE_FIRST_SAVED_AT=' + $expense.expense.firstSavedAt)

$sql = @"
SELECT e.Id AS EmployeeId, e.EmployeeCode,
       p.Id AS ProductionId, p.OperationDate, p.Quantity, p.ResolvedUnitRate, p.CalculatedAmount, p.FirstSavedAt AS ProductionFirstSavedAt,
       x.Id AS ExpenseId, x.OperationDate AS ExpenseOperationDate, x.Amount AS ExpenseAmount, x.FirstSavedAt AS ExpenseFirstSavedAt
FROM dbo.employees e
LEFT JOIN dbo.employee_production_entries p ON p.EmployeeId = e.Id
LEFT JOIN dbo.employee_expenses x ON x.EmployeeId = e.Id
WHERE e.EmployeeCode = '$employeeCode'
ORDER BY p.CreatedAt, x.CreatedAt;
"@

$rows = Invoke-Sqlcmd -ServerInstance 'YASIN-YASIN\SQLEXPRESS' -Database 'YASIN_WORKSHOP_ES_VALIDATION' -Query $sql -OutputAs DataRows
$rows | Format-Table -AutoSize

Write-Host '=== EMPLOYEE LIVE PROOF COMPLETE ==='
