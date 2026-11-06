$server = 'YASIN-YASIN\SQLEXPRESS'
$database = 'YASIN_WORKSHOP_ES_VALIDATION'

$permissionCode = 'development.operational_reset'
$permissionExists = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT Id FROM permissions WHERE Code = '$permissionCode';"
if (-not $permissionExists) {
    $permissionId = [Guid]::NewGuid().ToString()
    Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO permissions (Id, Code, Description, IsActive, CreatedAt, UpdatedAt) VALUES ('$permissionId', '$permissionCode', 'Development operational reset permission', 1, GETUTCDATE(), GETUTCDATE());"
} else {
    $permissionId = $permissionExists.Id
}

$roleExists = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT Id FROM roles WHERE Name = 'Reset Operators';"
if (-not $roleExists) {
    $roleId = [Guid]::NewGuid().ToString()
    Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO roles (Id, Name, Description, IsActive, CreatedAt, UpdatedAt) VALUES ('$roleId', 'Reset Operators', 'Development reset role', 1, GETUTCDATE(), GETUTCDATE());"
} else {
    $roleId = $roleExists.Id
}

$rolePermissionExists = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT Id FROM role_permissions WHERE RoleId = '$roleId' AND PermissionId = '$permissionId';"
if (-not $rolePermissionExists) {
    Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO role_permissions (Id, RoleId, PermissionId, CreatedAt) VALUES ('$( [Guid]::NewGuid() )', '$roleId', '$permissionId', GETUTCDATE());"
}

$userExists = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT Id FROM users WHERE UserName = 'live-reset-operator';"
if (-not $userExists) {
    $userId = [Guid]::NewGuid().ToString()
    Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO users (Id, UserName, DisplayName, Email, PasswordHash, SecurityStamp, IsActive, CreatedAt, UpdatedAt, LastLoginAt) VALUES ('$userId', 'live-reset-operator', 'Live Reset Operator', 'live-reset@example.com', 'placeholder-hash', 'reset-stamp', 1, GETUTCDATE(), GETUTCDATE(), NULL);"
    $userRoleExists = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT Id FROM user_roles WHERE UserId = '$userId' AND RoleId = '$roleId';"
    if (-not $userRoleExists) {
        Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO user_roles (Id, UserId, RoleId, CreatedAt) VALUES ('$( [Guid]::NewGuid() )', '$userId', '$roleId', GETUTCDATE());"
    }
}
else {
    $userId = $userExists.Id
    $userRoleExists = Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "SELECT Id FROM user_roles WHERE UserId = '$userId' AND RoleId = '$roleId';"
    if (-not $userRoleExists) {
        Invoke-Sqlcmd -ServerInstance $server -Database $database -Query "INSERT INTO user_roles (Id, UserId, RoleId, CreatedAt) VALUES ('$( [Guid]::NewGuid() )', '$userId', '$roleId', GETUTCDATE());"
    }
}

Write-Host "SETUP_COMPLETE=YES"
Write-Host "USER=live-reset-operator"
Write-Host "PERMISSION=$permissionCode"
