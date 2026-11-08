using System.Security.Claims;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using YasinWorkshop.Api.Data;

namespace YasinWorkshop.Api.Security;

public sealed class XUserNameAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    private readonly YasinWorkshopDbContext _dbContext;

    public XUserNameAuthenticationHandler(
        IOptionsMonitor<AuthenticationSchemeOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder,
        ISystemClock clock,
        YasinWorkshopDbContext dbContext)
        : base(options, logger, encoder, clock)
    {
        _dbContext = dbContext;
    }

    protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        var userName = Request.Headers["X-User-Name"].FirstOrDefault();
        if (string.IsNullOrWhiteSpace(userName))
        {
            return AuthenticateResult.NoResult();
        }

        var normalizedUserName = userName.Trim();
        var user = await _dbContext.Users.FirstOrDefaultAsync(x => x.UserName == normalizedUserName);
        if (user is null || !user.IsActive)
        {
            return AuthenticateResult.Fail("Unknown or inactive user.");
        }

        var claims = new[]
        {
            new Claim(ClaimTypes.Name, user.UserName),
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim("user_name", user.UserName)
        };

        var identity = new ClaimsIdentity(claims, Scheme.Name);
        var principal = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principal, Scheme.Name);

        return AuthenticateResult.Success(ticket);
    }
}
