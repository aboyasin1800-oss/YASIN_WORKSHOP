using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Migrations;
using YasinWorkshop.Api.Data;

#nullable disable

namespace YasinWorkshop.Api.Migrations;

[DbContext(typeof(YasinWorkshopDbContext))]
[Migration("20261104000000_InitialCoreFoundation")]
public partial class InitialCoreFoundation : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "app_settings",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                Key = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                Value = table.Column<string>(type: "nvarchar(max)", nullable: false),
                ValueType = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_app_settings", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_app_settings_Key",
            table: "app_settings",
            column: "Key",
            unique: true);

        migrationBuilder.CreateTable(
            name: "audit_log",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                EntityName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                EntityId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                Action = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                ActorUserName = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                CorrelationId = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                Reason = table.Column<string>(type: "nvarchar(512)", maxLength: 512, nullable: true),
                BeforeJson = table.Column<string>(type: "nvarchar(max)", nullable: true),
                AfterJson = table.Column<string>(type: "nvarchar(max)", nullable: true),
                OperationTime = table.Column<DateTime>(type: "datetime2", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_audit_log", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_audit_log_OperationTime",
            table: "audit_log",
            column: "OperationTime");

        migrationBuilder.CreateIndex(
            name: "IX_audit_log_EntityName_EntityId_OperationTime",
            table: "audit_log",
            columns: new[] { "EntityName", "EntityId", "OperationTime" });

        migrationBuilder.CreateTable(
            name: "financial_postings",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                PostingType = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                SourceType = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                SourceReference = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                OperationDate = table.Column<DateTime>(type: "date", nullable: false),
                Year = table.Column<int>(type: "int", nullable: false),
                Month = table.Column<int>(type: "int", nullable: false),
                Amount = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                Direction = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                Status = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                ReversalReference = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_financial_postings", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_financial_postings_SourceType",
            table: "financial_postings",
            column: "SourceType");

        migrationBuilder.CreateIndex(
            name: "IX_financial_postings_SourceType_SourceReference_OperationDate",
            table: "financial_postings",
            columns: new[] { "SourceType", "SourceReference", "OperationDate" });

        migrationBuilder.CreateTable(
            name: "idempotency_keys",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                OperationScope = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                IdempotencyKeyValue = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                Status = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                RequestHash = table.Column<string>(type: "nvarchar(512)", maxLength: 512, nullable: true),
                ResponsePayload = table.Column<string>(type: "nvarchar(max)", nullable: true),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_idempotency_keys", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_idempotency_keys_OperationScope_IdempotencyKeyValue",
            table: "idempotency_keys",
            columns: new[] { "OperationScope", "IdempotencyKeyValue" },
            unique: true);

        migrationBuilder.CreateTable(
            name: "message_templates",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                TemplateCode = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                TemplateName = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                BodyTemplate = table.Column<string>(type: "nvarchar(max)", nullable: false),
                IsActive = table.Column<bool>(type: "bit", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_message_templates", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_message_templates_TemplateCode",
            table: "message_templates",
            column: "TemplateCode",
            unique: true);

        migrationBuilder.CreateTable(
            name: "message_outbox",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                MessageKey = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                TemplateCode = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                Provider = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                Status = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                MessagePayload = table.Column<string>(type: "nvarchar(max)", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_message_outbox", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_message_outbox_MessageKey",
            table: "message_outbox",
            column: "MessageKey",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_message_outbox_Status",
            table: "message_outbox",
            column: "Status");

        migrationBuilder.CreateTable(
            name: "permissions",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                Code = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                Description = table.Column<string>(type: "nvarchar(512)", maxLength: 512, nullable: true),
                IsActive = table.Column<bool>(type: "bit", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_permissions", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_permissions_Code",
            table: "permissions",
            column: "Code",
            unique: true);

        migrationBuilder.CreateTable(
            name: "roles",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                Name = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                Description = table.Column<string>(type: "nvarchar(512)", maxLength: 512, nullable: true),
                IsActive = table.Column<bool>(type: "bit", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_roles", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_roles_Name",
            table: "roles",
            column: "Name",
            unique: true);

        migrationBuilder.CreateTable(
            name: "users",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                UserName = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                DisplayName = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                Email = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                IsActive = table.Column<bool>(type: "bit", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_users", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_users_Email",
            table: "users",
            column: "Email",
            unique: true,
            filter: "[Email] IS NOT NULL");

        migrationBuilder.CreateIndex(
            name: "IX_users_UserName",
            table: "users",
            column: "UserName",
            unique: true);

        migrationBuilder.CreateTable(
            name: "message_attempts",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                MessageOutboxId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                Status = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                ProviderReference = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                ErrorMessage = table.Column<string>(type: "nvarchar(1024)", maxLength: 1024, nullable: true),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_message_attempts", x => x.Id);
                table.ForeignKey(
                    name: "FK_message_attempts_message_outbox_MessageOutboxId",
                    column: x => x.MessageOutboxId,
                    principalTable: "message_outbox",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "role_permissions",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                RoleId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                PermissionId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_role_permissions", x => x.Id);
                table.ForeignKey(
                    name: "FK_role_permissions_permissions_PermissionId",
                    column: x => x.PermissionId,
                    principalTable: "permissions",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "FK_role_permissions_roles_RoleId",
                    column: x => x.RoleId,
                    principalTable: "roles",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateTable(
            name: "user_roles",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                UserId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                RoleId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_user_roles", x => x.Id);
                table.ForeignKey(
                    name: "FK_user_roles_roles_RoleId",
                    column: x => x.RoleId,
                    principalTable: "roles",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "FK_user_roles_users_UserId",
                    column: x => x.UserId,
                    principalTable: "users",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_message_attempts_MessageOutboxId",
            table: "message_attempts",
            column: "MessageOutboxId");

        migrationBuilder.CreateIndex(
            name: "IX_role_permissions_PermissionId",
            table: "role_permissions",
            column: "PermissionId");

        migrationBuilder.CreateIndex(
            name: "IX_role_permissions_RoleId_PermissionId",
            table: "role_permissions",
            columns: new[] { "RoleId", "PermissionId" },
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_user_roles_RoleId",
            table: "user_roles",
            column: "RoleId");

        migrationBuilder.CreateIndex(
            name: "IX_user_roles_UserId_RoleId",
            table: "user_roles",
            columns: new[] { "UserId", "RoleId" },
            unique: true);

        migrationBuilder.CreateTable(
            name: "__EFMigrationsHistory",
            columns: table => new
            {
                MigrationId = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                ProductVersion = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK___EFMigrationsHistory", x => x.MigrationId);
            });

        migrationBuilder.InsertData(
            table: "__EFMigrationsHistory",
            columns: new[] { "MigrationId", "ProductVersion" },
            values: new object[] { "20261104000000_InitialCoreFoundation", "10.0.0" });
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "audit_log");

        migrationBuilder.DropTable(
            name: "financial_postings");

        migrationBuilder.DropTable(
            name: "idempotency_keys");

        migrationBuilder.DropTable(
            name: "message_attempts");

        migrationBuilder.DropTable(
            name: "message_templates");

        migrationBuilder.DropTable(
            name: "role_permissions");

        migrationBuilder.DropTable(
            name: "user_roles");

        migrationBuilder.DropTable(
            name: "message_outbox");

        migrationBuilder.DropTable(
            name: "permissions");

        migrationBuilder.DropTable(
            name: "roles");

        migrationBuilder.DropTable(
            name: "users");

        migrationBuilder.DropTable(
            name: "app_settings");

        migrationBuilder.DropTable(
            name: "__EFMigrationsHistory");
    }
}
