using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace YasinWorkshop.Api.Migrations;

public partial class AddEmployeeFinancialOperations : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.CreateTable(
            name: "employee_monthly_compensations",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                EmployeeId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                Year = table.Column<int>(type: "int", nullable: false),
                Month = table.Column<int>(type: "int", nullable: false),
                CompensationType = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                Amount = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                Currency = table.Column<string>(type: "nvarchar(16)", maxLength: 16, nullable: false),
                IsCurrent = table.Column<bool>(type: "bit", nullable: false),
                Notes = table.Column<string>(type: "nvarchar(max)", nullable: true),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_employee_monthly_compensations", x => x.Id);
                table.ForeignKey(
                    name: "FK_employee_monthly_compensations_employees_EmployeeId",
                    column: x => x.EmployeeId,
                    principalTable: "employees",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_employee_monthly_compensations_EmployeeId_Year_Month",
            table: "employee_monthly_compensations",
            columns: new[] { "EmployeeId", "Year", "Month" },
            unique: true);

        migrationBuilder.CreateTable(
            name: "employee_production_entries",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                EmployeeId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                OperationDate = table.Column<DateTime>(type: "date", nullable: false),
                Quantity = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                ResolvedUnitRate = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                CalculatedAmount = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                FirstSavedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                CreatedBy = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                Notes = table.Column<string>(type: "nvarchar(max)", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_employee_production_entries", x => x.Id);
                table.ForeignKey(
                    name: "FK_employee_production_entries_employees_EmployeeId",
                    column: x => x.EmployeeId,
                    principalTable: "employees",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_employee_production_entries_EmployeeId_OperationDate",
            table: "employee_production_entries",
            columns: new[] { "EmployeeId", "OperationDate" });

        migrationBuilder.CreateTable(
            name: "employee_expenses",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                EmployeeId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                OperationDate = table.Column<DateTime>(type: "date", nullable: false),
                Amount = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                FirstSavedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                CreatedBy = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                Notes = table.Column<string>(type: "nvarchar(max)", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_employee_expenses", x => x.Id);
                table.ForeignKey(
                    name: "FK_employee_expenses_employees_EmployeeId",
                    column: x => x.EmployeeId,
                    principalTable: "employees",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_employee_expenses_EmployeeId_OperationDate",
            table: "employee_expenses",
            columns: new[] { "EmployeeId", "OperationDate" });

        migrationBuilder.CreateTable(
            name: "employee_settlements",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                EmployeeId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                SettlementDate = table.Column<DateTime>(type: "date", nullable: false),
                TotalAmount = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                TotalAllocated = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                Currency = table.Column<string>(type: "nvarchar(16)", maxLength: 16, nullable: false),
                Status = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                CreatedBy = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                Notes = table.Column<string>(type: "nvarchar(max)", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_employee_settlements", x => x.Id);
                table.ForeignKey(
                    name: "FK_employee_settlements_employees_EmployeeId",
                    column: x => x.EmployeeId,
                    principalTable: "employees",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_employee_settlements_EmployeeId_SettlementDate",
            table: "employee_settlements",
            columns: new[] { "EmployeeId", "SettlementDate" });

        migrationBuilder.CreateTable(
            name: "employee_settlement_allocations",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                SettlementId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                EmployeeId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                SourceType = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                SourceReference = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                Amount = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                AllocationDate = table.Column<DateTime>(type: "date", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                CreatedBy = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                Notes = table.Column<string>(type: "nvarchar(max)", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_employee_settlement_allocations", x => x.Id);
                table.ForeignKey(
                    name: "FK_employee_settlement_allocations_employee_settlements_SettlementId",
                    column: x => x.SettlementId,
                    principalTable: "employee_settlements",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "FK_employee_settlement_allocations_employees_EmployeeId",
                    column: x => x.EmployeeId,
                    principalTable: "employees",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_employee_settlement_allocations_SettlementId",
            table: "employee_settlement_allocations",
            column: "SettlementId");

        migrationBuilder.CreateIndex(
            name: "IX_employee_settlement_allocations_EmployeeId_SourceType_SourceReference",
            table: "employee_settlement_allocations",
            columns: new[] { "EmployeeId", "SourceType", "SourceReference" },
            unique: true);

        migrationBuilder.CreateTable(
            name: "employee_debts",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                EmployeeId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                Amount = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                OutstandingAmount = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                DebtType = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                Status = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                Reason = table.Column<string>(type: "nvarchar(max)", nullable: true),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                CreatedBy = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_employee_debts", x => x.Id);
                table.ForeignKey(
                    name: "FK_employee_debts_employees_EmployeeId",
                    column: x => x.EmployeeId,
                    principalTable: "employees",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_employee_debts_EmployeeId_Status",
            table: "employee_debts",
            columns: new[] { "EmployeeId", "Status" });

        migrationBuilder.CreateTable(
            name: "employee_debt_recoveries",
            columns: table => new
            {
                Id = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                EmployeeId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                DebtId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                SourceType = table.Column<string>(type: "nvarchar(32)", maxLength: 32, nullable: false),
                SourceReference = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                Amount = table.Column<decimal>(type: "decimal(18,4)", nullable: false),
                RecoveryDate = table.Column<DateTime>(type: "date", nullable: false),
                CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                CreatedBy = table.Column<string>(type: "nvarchar(128)", maxLength: 128, nullable: false),
                Notes = table.Column<string>(type: "nvarchar(max)", nullable: true)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_employee_debt_recoveries", x => x.Id);
                table.ForeignKey(
                    name: "FK_employee_debt_recoveries_employee_debts_DebtId",
                    column: x => x.DebtId,
                    principalTable: "employee_debts",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
                table.ForeignKey(
                    name: "FK_employee_debt_recoveries_employees_EmployeeId",
                    column: x => x.EmployeeId,
                    principalTable: "employees",
                    principalColumn: "Id",
                    onDelete: ReferentialAction.Cascade);
            });

        migrationBuilder.CreateIndex(
            name: "IX_employee_debt_recoveries_EmployeeId_DebtId_SourceType_SourceReference",
            table: "employee_debt_recoveries",
            columns: new[] { "EmployeeId", "DebtId", "SourceType", "SourceReference" },
            unique: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropTable(name: "employee_debt_recoveries");
        migrationBuilder.DropTable(name: "employee_debts");
        migrationBuilder.DropTable(name: "employee_settlement_allocations");
        migrationBuilder.DropTable(name: "employee_settlements");
        migrationBuilder.DropTable(name: "employee_expenses");
        migrationBuilder.DropTable(name: "employee_production_entries");
        migrationBuilder.DropTable(name: "employee_monthly_compensations");
    }
}
