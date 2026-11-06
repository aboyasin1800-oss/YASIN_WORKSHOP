using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using YasinWorkshop.Api.Data;

#nullable disable

namespace YasinWorkshop.Api.Migrations;

[DbContext(typeof(YasinWorkshopDbContext))]
[Migration("20261108000000_AddMessagingOperationalFoundation")]
public partial class AddMessagingOperationalFoundation : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "RecipientType",
            table: "message_outbox",
            type: "nvarchar(64)",
            maxLength: 64,
            nullable: false,
            defaultValue: "Customer");

        migrationBuilder.AddColumn<string>(
            name: "RecipientReference",
            table: "message_outbox",
            type: "nvarchar(128)",
            maxLength: 128,
            nullable: false,
            defaultValue: "");

        migrationBuilder.AddColumn<string>(
            name: "MessageType",
            table: "message_outbox",
            type: "nvarchar(64)",
            maxLength: 64,
            nullable: false,
            defaultValue: "Notification");

        migrationBuilder.AddColumn<int>(
            name: "AttemptCount",
            table: "message_outbox",
            type: "int",
            nullable: false,
            defaultValue: 0);

        migrationBuilder.AddColumn<DateTime>(
            name: "LastAttemptAt",
            table: "message_outbox",
            type: "datetime2",
            nullable: true);

        migrationBuilder.AddColumn<DateTime>(
            name: "SentAt",
            table: "message_outbox",
            type: "datetime2",
            nullable: true);

        migrationBuilder.AddColumn<string>(
            name: "FailureMessage",
            table: "message_outbox",
            type: "nvarchar(1024)",
            maxLength: 1024,
            nullable: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropColumn(name: "FailureMessage", table: "message_outbox");
        migrationBuilder.DropColumn(name: "SentAt", table: "message_outbox");
        migrationBuilder.DropColumn(name: "LastAttemptAt", table: "message_outbox");
        migrationBuilder.DropColumn(name: "AttemptCount", table: "message_outbox");
        migrationBuilder.DropColumn(name: "MessageType", table: "message_outbox");
        migrationBuilder.DropColumn(name: "RecipientReference", table: "message_outbox");
        migrationBuilder.DropColumn(name: "RecipientType", table: "message_outbox");
    }
}
