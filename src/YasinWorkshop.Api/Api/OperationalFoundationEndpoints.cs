using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using YasinWorkshop.Api.Data;
using YasinWorkshop.Api.Security;

namespace YasinWorkshop.Api.Api;

public static class OperationalFoundationEndpoints
{
    public static WebApplication MapOperationalFoundationEndpoints(this WebApplication app)
    {
        app.MapPost("/api/auth/login", async (YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, LoginRequest request, CancellationToken cancellationToken) =>
        {
            if (string.IsNullOrWhiteSpace(request.UserName) || string.IsNullOrWhiteSpace(request.Password))
            {
                return Results.BadRequest(new { message = "Username and password are required." });
            }

            var user = await dbContext.Users.FirstOrDefaultAsync(x => x.UserName == request.UserName.Trim(), cancellationToken);
            if (user is null || !user.IsActive || !await userSecurityService.IsValidLoginAsync(request.UserName, request.Password))
            {
                return Results.Unauthorized();
            }

            user.LastLoginAt = DateTime.UtcNow;
            user.UpdatedAt = DateTime.UtcNow;
            await dbContext.SaveChangesAsync(cancellationToken);

            return Results.Ok(new
            {
                user.Id,
                user.UserName,
                user.DisplayName,
                user.Email,
                user.IsActive,
                user.LastLoginAt
            });
        });

        app.MapGet("/api/users", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "users.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var users = await dbContext.Users
                .OrderBy(x => x.UserName)
                .Select(x => new
                {
                    x.Id,
                    x.UserName,
                    x.DisplayName,
                    x.Email,
                    x.IsActive,
                    x.CreatedAt,
                    x.LastLoginAt
                })
                .ToListAsync(cancellationToken);

            return Results.Ok(users);
        });

        app.MapPost("/api/users", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, CreateUserRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "users.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var result = await userSecurityService.CreateUserAsync(request);
            if (!result.IsSuccess)
            {
                return Results.BadRequest(new { result.Message });
            }

            await userSecurityService.WriteAuditAsync(new WriteAuditRequest
            {
                EntityName = "users",
                EntityId = result.User!.Id.ToString(),
                Action = "create",
                ActorUserName = auth.UserName,
                Reason = "User created via operational foundation endpoint.",
                AfterJson = $"{{\"userName\":\"{result.User.UserName}\"}}"
            });

            return Results.Ok(new
            {
                result.User.Id,
                result.User.UserName,
                result.User.DisplayName,
                result.User.Email,
                result.User.IsActive,
                result.Message
            });
        });

        app.MapGet("/api/roles", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "roles.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var roles = await dbContext.Roles
                .OrderBy(x => x.Name)
                .Select(x => new
                {
                    x.Id,
                    x.Name,
                    x.Description,
                    x.IsActive,
                    x.CreatedAt
                })
                .ToListAsync(cancellationToken);

            return Results.Ok(roles);
        });

        app.MapPost("/api/roles", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, CreateRoleRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "roles.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var role = await userSecurityService.CreateRoleAsync(request);
            await userSecurityService.WriteAuditAsync(new WriteAuditRequest
            {
                EntityName = "roles",
                EntityId = role.Id.ToString(),
                Action = "create",
                ActorUserName = auth.UserName,
                Reason = "Role created via operational foundation endpoint.",
                AfterJson = $"{{\"roleName\":\"{role.Name}\"}}"
            });

            return Results.Ok(new
            {
                role.Id,
                role.Name,
                role.Description,
                role.IsActive,
                role.CreatedAt
            });
        });

        app.MapGet("/api/permissions", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "permissions.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var permissions = await dbContext.Permissions
                .OrderBy(x => x.Code)
                .Select(x => new
                {
                    x.Id,
                    x.Code,
                    x.Description,
                    x.IsActive,
                    x.CreatedAt
                })
                .ToListAsync(cancellationToken);

            return Results.Ok(permissions);
        });

        app.MapPost("/api/permissions", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, CreatePermissionRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "permissions.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var permission = await userSecurityService.CreatePermissionAsync(request);
            await userSecurityService.WriteAuditAsync(new WriteAuditRequest
            {
                EntityName = "permissions",
                EntityId = permission.Id.ToString(),
                Action = "create",
                ActorUserName = auth.UserName,
                Reason = "Permission created via operational foundation endpoint.",
                AfterJson = $"{{\"permissionCode\":\"{permission.Code}\"}}"
            });

            return Results.Ok(new
            {
                permission.Id,
                permission.Code,
                permission.Description,
                permission.IsActive,
                permission.CreatedAt
            });
        });

        app.MapGet("/api/settings", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "settings.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var settings = await dbContext.AppSettings
                .OrderBy(x => x.Key)
                .Select(x => new
                {
                    x.Id,
                    x.Key,
                    x.Value,
                    x.ValueType,
                    x.CreatedAt,
                    x.UpdatedAt
                })
                .ToListAsync(cancellationToken);

            return Results.Ok(settings);
        });

        app.MapPost("/api/settings", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, AppSettingRequest request, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "settings.write", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var key = request.Key.Trim();
            if (string.IsNullOrWhiteSpace(key))
            {
                return Results.BadRequest(new { message = "Setting key is required." });
            }

            if (request.ValueType.Equals("password", StringComparison.OrdinalIgnoreCase) ||
                request.ValueType.Equals("token", StringComparison.OrdinalIgnoreCase) ||
                request.ValueType.Equals("secret", StringComparison.OrdinalIgnoreCase))
            {
                return Results.BadRequest(new { message = "Secret values are not allowed in application settings." });
            }

            var setting = await dbContext.AppSettings.FirstOrDefaultAsync(x => x.Key == key, cancellationToken);
            var beforeValue = setting is null ? null : setting.Value;
            if (setting is null)
            {
                setting = new AppSetting
                {
                    Id = Guid.NewGuid(),
                    Key = key,
                    Value = request.Value ?? string.Empty,
                    ValueType = request.ValueType,
                    CreatedAt = DateTime.UtcNow
                };

                dbContext.AppSettings.Add(setting);
            }
            else
            {
                setting.Value = request.Value ?? string.Empty;
                setting.ValueType = request.ValueType;
                setting.UpdatedAt = DateTime.UtcNow;
            }

            await dbContext.SaveChangesAsync(cancellationToken);
            await userSecurityService.WriteAuditAsync(new WriteAuditRequest
            {
                EntityName = "app_settings",
                EntityId = setting.Id.ToString(),
                Action = "update",
                ActorUserName = auth.UserName,
                CorrelationId = Guid.NewGuid().ToString("N"),
                Reason = "Validated operational setting update.",
                BeforeJson = beforeValue is null ? null : $"{{\"value\":\"{beforeValue}\"}}",
                AfterJson = $"{{\"value\":\"{setting.Value}\"}}"
            });

            return Results.Ok(new
            {
                setting.Id,
                setting.Key,
                setting.Value,
                setting.ValueType,
                setting.CreatedAt,
                setting.UpdatedAt
            });
        });

        app.MapGet("/api/audit", async (HttpContext httpContext, YasinWorkshopDbContext dbContext, UserSecurityService userSecurityService, CancellationToken cancellationToken) =>
        {
            var auth = await AuthorizeAsync(httpContext, dbContext, userSecurityService, "audit.read", cancellationToken);
            if (!auth.IsAuthorized)
            {
                return Results.Forbid();
            }

            var auditEntries = await dbContext.AuditLogs
                .OrderByDescending(x => x.OperationTime)
                .Take(100)
                .Select(x => new
                {
                    x.Id,
                    x.EntityName,
                    x.EntityId,
                    x.Action,
                    x.ActorUserName,
                    x.CorrelationId,
                    x.Reason,
                    x.BeforeJson,
                    x.AfterJson,
                    x.OperationTime
                })
                .ToListAsync(cancellationToken);

            return Results.Ok(auditEntries);
        });

        return app;
    }

    private static async Task<(bool IsAuthorized, string UserName)> AuthorizeAsync(
        HttpContext httpContext,
        YasinWorkshopDbContext dbContext,
        UserSecurityService userSecurityService,
        string requiredPermission,
        CancellationToken cancellationToken)
    {
        var actorUserName = httpContext.Request.Headers["X-User-Name"].FirstOrDefault();
        if (string.IsNullOrWhiteSpace(actorUserName))
        {
            return (false, string.Empty);
        }

        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.UserName == actorUserName.Trim(), cancellationToken);
        if (user is null || !user.IsActive)
        {
            return (false, string.Empty);
        }

        var isAuthorized = await userSecurityService.HasPermissionAsync(user.Id, requiredPermission);
        return isAuthorized ? (true, user.UserName) : (false, string.Empty);
    }

    private sealed record LoginRequest
    {
        public string UserName { get; init; } = string.Empty;
        public string Password { get; init; } = string.Empty;
    }

    private sealed record AppSettingRequest
    {
        public string Key { get; init; } = string.Empty;
        public string? Value { get; init; }
        public string ValueType { get; init; } = "string";
    }
}
