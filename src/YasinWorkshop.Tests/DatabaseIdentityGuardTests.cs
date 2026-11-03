using Microsoft.Extensions.Options;
using YasinWorkshop.Api.Database;

namespace YasinWorkshop.Tests;

public sealed class DatabaseIdentityGuardTests
{
    [Theory]
    [InlineData("YASIN_WORKSHOP_ES_VALIDATION", true)]
    [InlineData("YASIN_WORKSHOP_GOLDEN_1", false)]
    [InlineData("LUMAR_SOMETHING", false)]
    [InlineData("OTHER_DATABASE", false)]
    public void ValidateIdentityDatabaseName_RejectsGoldenAndLumar(string databaseName, bool expected)
    {
        var options = Options.Create(new DatabaseIdentityOptions
        {
            DevelopmentDatabase = "YASIN_WORKSHOP_ES_VALIDATION",
            GoldenDatabase = "YASIN_WORKSHOP_GOLDEN_1",
            ForbiddenDatabasePrefixes = new List<string> { "LUMAR" }
        });

        var guard = new DatabaseIdentityGuard(options);
        var result = guard.ValidateIdentityDatabaseName(databaseName);

        Assert.Equal(expected, result.IsAllowed);
    }
}
