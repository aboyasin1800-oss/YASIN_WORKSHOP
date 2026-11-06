using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace YasinWorkshop.Api.Migrations;

public partial class AddSupplierOperationalFoundation : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "suppliers",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                SupplierCode = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                Name = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                ContactName = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: true),
                Phone = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: true),
                WhatsApp = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: true),
                Email = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                SupplierType = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                Status = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                IsArchived = table.Column<bool>(type: "bit", nullable: false),
                Notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_suppliers", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_suppliers_SupplierCode",
            table: "suppliers",
            column: "SupplierCode",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_suppliers_Name",
            table: "suppliers",
            column: "Name",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_suppliers_Status",
            table: "suppliers",
            column: "Status");

        migrationBuilder.CreateIndex(
            name: "IX_suppliers_SupplierType",
            table: "suppliers",
            column: "SupplierType");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "suppliers");
    }
}
