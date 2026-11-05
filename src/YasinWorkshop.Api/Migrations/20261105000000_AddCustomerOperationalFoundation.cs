using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace YasinWorkshop.Api.Migrations;

public partial class AddCustomerOperationalFoundation : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "customers",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                Name = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                ContactName = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                Phone = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: true),
                WhatsApp = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: true),
                Email = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                RelationshipType = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                DeliveryLocation = table.Column<string>(type: "nvarchar(512)", maxLength: 512, nullable: true),
                Status = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                IsArchived = table.Column<bool>(type: "bit", nullable: false),
                Notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_customers", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_customers_Name",
            table: "customers",
            column: "Name",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_customers_Status",
            table: "customers",
            column: "Status");

        migrationBuilder.CreateTable(
            name: "customer_monthly_prices",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                CustomerId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                Year = table.Column<int>(type: "int", nullable: false),
                Month = table.Column<int>(type: "int", nullable: false),
                MonthlyRate = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                Currency = table.Column<string>(type: "nvarchar(16)", maxLength: 16, nullable: false),
                IsCurrent = table.Column<bool>(type: "bit", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_customer_monthly_prices", x => x.Id);
                table.ForeignKey(
                    name: "FK_customer_monthly_prices_customers_CustomerId",
                    column: x => x.CustomerId,
                    principalTable: "customers",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_customer_monthly_prices_CustomerId_Year_Month",
            table: "customer_monthly_prices",
            columns: new[] { "CustomerId", "Year", "Month" },
            unique: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "customer_monthly_prices");

        migrationBuilder.DropTable(
            name: "customers");
    }
}
