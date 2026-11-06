$commands = @(
    "ALTER TABLE [users] ADD [LastLoginAt] datetime2 NULL;",
    "ALTER TABLE [users] ADD [PasswordHash] nvarchar(512) NOT NULL CONSTRAINT DF_users_PasswordHash DEFAULT '';",
    "ALTER TABLE [users] ADD [SecurityStamp] nvarchar(128) NULL;"
)
foreach ($sql in $commands) {
    try {
        Invoke-Sqlcmd -ServerInstance 'YASIN-YASIN\SQLEXPRESS' -Database 'YASIN_WORKSHOP_ES_VALIDATION' -Query $sql | Out-Null
        Write-Host "APPLIED=$sql"
    }
    catch {
        if ($_.Exception.Message -match 'already exists') {
            Write-Host "SKIP=$sql"
            continue
        }
        throw
    }
}
