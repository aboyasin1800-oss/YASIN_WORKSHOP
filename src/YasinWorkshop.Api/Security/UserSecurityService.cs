using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;

namespace YasinWorkshop.Api.Security;

public sealed record CreateUserRequest
{
    public string UserName { get; init; } = string.Empty;
    public string DisplayName { get; init; } = string.Empty;
    public string? Email { get; init; }
    public string Password { get; init; } = string.Empty;
    public bool IsActive { get; init; } = true;
}

public sealed record CreateUserResult
{
    public bool IsSuccess { get; init; }
    public string Message { get; init; } = string.Empty;
    public User? User { get; init; }
    public string? PasswordHash { get; init; }
}

public sealed record CreateRoleRequest
{
    public string Name { get; init; } = string.Empty;
    public string? Description { get; init; }
    public bool IsActive { get; init; } = true;
}

public sealed record CreatePermissionRequest
{
    public string Code { get; init; } = string.Empty;
    public string? Description { get; init; }
    public bool IsActive { get; init; } = true;
}

public sealed record WriteAuditRequest
{
    public string EntityName { get; init; } = string.Empty;
    public string? EntityId { get; init; }
    public string Action { get; init; } = string.Empty;
    public string? ActorUserName { get; init; }
    public string? CorrelationId { get; init; }
    public string? Reason { get; init; }
    public string? BeforeJson { get; init; }
    public string? AfterJson { get; init; }
}

public sealed class UserSecurityService
{
    private readonly YasinWorkshopDbContext _dbContext;
    private readonly PasswordHasher<string> _passwordHasher = new();

    public UserSecurityService(YasinWorkshopDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<CreateUserResult> CreateUserAsync(CreateUserRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.UserName))
        {
            return new CreateUserResult { IsSuccess = false, Message = "Username is required." };
        }

        if (string.IsNullOrWhiteSpace(request.Password) || request.Password.Length < 8)
        {
            return new CreateUserResult { IsSuccess = false, Message = "Password must be at least 8 characters." };
        }

        var normalizedUserName = request.UserName.Trim();
        if (await _dbContext.Users.AnyAsync(x => x.UserName == normalizedUserName))
        {
            return new CreateUserResult { IsSuccess = false, Message = $"User '{normalizedUserName}' already exists." };
        }

        var user = new User
        {
            Id = Guid.NewGuid(),
            UserName = normalizedUserName,
            DisplayName = string.IsNullOrWhiteSpace(request.DisplayName) ? normalizedUserName : request.DisplayName.Trim(),
            Email = string.IsNullOrWhiteSpace(request.Email) ? null : request.Email.Trim(),
            PasswordHash = HashPassword(request.Password),
            SecurityStamp = Guid.NewGuid().ToString("N"),
            IsActive = request.IsActive,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _dbContext.Users.Add(user);
        await _dbContext.SaveChangesAsync();

        return new CreateUserResult
        {
            IsSuccess = true,
            Message = "User created successfully.",
            User = user,
            PasswordHash = user.PasswordHash
        };
    }

    public async Task<Role> CreateRoleAsync(CreateRoleRequest request)
    {
        var normalized = (request.Name ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(normalized))
        {
            throw new InvalidOperationException("Role name is required.");
        }

        var existing = await _dbContext.Roles.FirstOrDefaultAsync(x => x.Name == normalized);
        if (existing is not null)
        {
            return existing;
        }

        var role = new Role
        {
            Id = Guid.NewGuid(),
            Name = normalized,
            Description = request.Description,
            IsActive = request.IsActive,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _dbContext.Roles.Add(role);
        await _dbContext.SaveChangesAsync();
        return role;
    }

    public async Task<Permission> CreatePermissionAsync(CreatePermissionRequest request)
    {
        var normalized = (request.Code ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(normalized))
        {
            throw new InvalidOperationException("Permission code is required.");
        }

        var existing = await _dbContext.Permissions.FirstOrDefaultAsync(x => x.Code == normalized);
        if (existing is not null)
        {
            return existing;
        }

        var permission = new Permission
        {
            Id = Guid.NewGuid(),
            Code = normalized,
            Description = request.Description,
            IsActive = request.IsActive,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        _dbContext.Permissions.Add(permission);
        await _dbContext.SaveChangesAsync();
        return permission;
    }

    public async Task AssignRoleToUserAsync(Guid userId, Guid roleId)
    {
        var existing = await _dbContext.UserRoles.AnyAsync(x => x.UserId == userId && x.RoleId == roleId);
        if (existing)
        {
            return;
        }

        _dbContext.UserRoles.Add(new UserRole
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            RoleId = roleId,
            CreatedAt = DateTime.UtcNow
        });

        await _dbContext.SaveChangesAsync();
    }

    public async Task AssignPermissionToRoleAsync(Guid roleId, Guid permissionId)
    {
        var existing = await _dbContext.RolePermissions.AnyAsync(x => x.RoleId == roleId && x.PermissionId == permissionId);
        if (existing)
        {
            return;
        }

        _dbContext.RolePermissions.Add(new RolePermission
        {
            Id = Guid.NewGuid(),
            RoleId = roleId,
            PermissionId = permissionId,
            CreatedAt = DateTime.UtcNow
        });

        await _dbContext.SaveChangesAsync();
    }

    public async Task<bool> HasPermissionAsync(Guid userId, string permissionCode)
    {
        var userPermissions = await _dbContext.UserRoles
            .Where(x => x.UserId == userId)
            .Join(_dbContext.RolePermissions,
                userRole => userRole.RoleId,
                rolePermission => rolePermission.RoleId,
                (userRole, rolePermission) => rolePermission.PermissionId)
            .Join(_dbContext.Permissions,
                permissionId => permissionId,
                permission => permission.Id,
                (_, permission) => permission.Code)
            .ToListAsync();

        return userPermissions.Contains(permissionCode, StringComparer.OrdinalIgnoreCase);
    }

    public async Task<bool> IsUserAuthorizedAsync(string userName, string permissionCode)
    {
        var normalizedUserName = userName.Trim();
        var user = await _dbContext.Users
            .FirstOrDefaultAsync(x => x.UserName == normalizedUserName);

        if (user is null || !user.IsActive)
        {
            return false;
        }

        return await HasPermissionAsync(user.Id, permissionCode);
    }

    public async Task<bool> IsValidLoginAsync(string userName, string password)
    {
        var normalizedUserName = userName.Trim();
        var user = await _dbContext.Users.FirstOrDefaultAsync(x => x.UserName == normalizedUserName);
        if (user is null || !user.IsActive)
        {
            return false;
        }

        var verification = _passwordHasher.VerifyHashedPassword(user.UserName, user.PasswordHash, password);
        return verification == PasswordVerificationResult.Success || verification == PasswordVerificationResult.SuccessRehashNeeded;
    }

    public async Task<AuditLog> WriteAuditAsync(WriteAuditRequest request)
    {
        var audit = new AuditLog
        {
            Id = Guid.NewGuid(),
            EntityName = string.IsNullOrWhiteSpace(request.EntityName) ? "unknown" : request.EntityName.Trim(),
            EntityId = request.EntityId,
            Action = string.IsNullOrWhiteSpace(request.Action) ? "unknown" : request.Action.Trim(),
            ActorUserName = request.ActorUserName,
            CorrelationId = request.CorrelationId,
            Reason = request.Reason,
            BeforeJson = request.BeforeJson,
            AfterJson = request.AfterJson,
            OperationTime = DateTime.UtcNow
        };

        _dbContext.AuditLogs.Add(audit);
        await _dbContext.SaveChangesAsync();
        return audit;
    }

    public static string HashPassword(string input)
    {
        var passwordHasher = new PasswordHasher<string>();
        return passwordHasher.HashPassword(Guid.NewGuid().ToString(), input);
    }
}
