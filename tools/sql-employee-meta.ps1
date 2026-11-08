$query = @'
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE '%employee%'
ORDER BY TABLE_NAME;
'@

Invoke-Sqlcmd -ServerInstance 'YASIN-YASIN\SQLEXPRESS' -Database 'YASIN_WORKSHOP_ES_VALIDATION' -Query $query -OutputAs DataRows | Format-Table -AutoSize
