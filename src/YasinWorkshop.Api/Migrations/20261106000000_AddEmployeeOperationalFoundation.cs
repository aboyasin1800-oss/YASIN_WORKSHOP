using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace YasinWorkshop.Api.Migrations;

public partial class AddEmployeeOperationalFoundation : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "employees",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                EmployeeCode = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: false),
                Name = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                Phone = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: true),
                WhatsApp = table.Column<string>(type: "nvarchar(64)", maxLength: 64, nullable: true),
                Email = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                EmployeeType = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                Status = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                IsArchived = table.Column<bool>(type: "bit", nullable: false),
                StartDate = table.Column<DateTime>(type: "date", nullable: true),
                EndDate = table.Column<DateTime>(type: "date", nullable: true),
                Notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_employees", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_employees_EmployeeCode",
            table: "employees",
            column: "EmployeeCode",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_employees_Name",
            table: "employees",
            column: "Name",
            unique: true);

        migrationBuilder.CreateIndex(
            name: "IX_employees_Status",
            table: "employees",
            column: "Status");

        migrationBuilder.CreateIndex(
            name: "IX_employees_EmployeeType",
            table: "employees",
            column: "EmployeeType");
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(
            name: "employees");
    }
}
