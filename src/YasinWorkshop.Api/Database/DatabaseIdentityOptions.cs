namespace YasinWorkshop.Api.Database;

public sealed class DatabaseIdentityOptions
{
    public const string SectionName = "DatabaseIdentity";

    public string DevelopmentDatabase { get; set; } = "YASIN_WORKSHOP_ES_VALIDATION";

    public string GoldenDatabase { get; set; } = "YASIN_WORKSHOP_GOLDEN_1";

    public List<string> ForbiddenDatabasePrefixes { get; set; } = new() { "LUMAR" };
}
