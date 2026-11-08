$server = 'YASIN-YASIN\SQLEXPRESS'
$db = 'YASIN_WORKSHOP_ES_VALIDATION'

$joinQuery = @'
SELECT u.UserName, u.IsActive, r.Name AS RoleName, p.Code AS PermissionCode
FROM dbo.users u
LEFT JOIN dbo.user_roles ur ON ur.UserId = u.Id
LEFT JOIN dbo.roles r ON r.Id = ur.RoleId
LEFT JOIN dbo.role_permissions rp ON rp.RoleId = r.Id
LEFT JOIN dbo.permissions p ON p.Id = rp.PermissionId
ORDER BY u.UserName, r.Name, p.Code;
'@

Write-Host '=== USERS + PERMISSIONS ==='
try {
    $rows = Invoke-Sqlcmd -ServerInstance $server -Database $db -Query $joinQuery -OutputAs DataRows
    $rows | ForEach-Object {
        $user = $_.UserName
        $active = $_.IsActive
        $role = if ($_.RoleName) { $_.RoleName } else { '<none>' }
        $perm = if ($_.PermissionCode) { $_.PermissionCode } else { '<none>' }
        Write-Host ("USER={0}; ACTIVE={1}; ROLE={2}; PERMISSION={3}" -f $user, $active, $role, $perm)
    }
}
catch {
    Write-Host "USER_PERMISSION_QUERY_FAILED: $($_.Exception.Message)"
    exit 1
}
