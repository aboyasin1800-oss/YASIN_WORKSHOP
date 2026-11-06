using Microsoft.EntityFrameworkCore;

namespace YasinWorkshop.Api.Data;

public sealed class YasinWorkshopDbContext : DbContext
{
    public DbSet<AppSetting> AppSettings => Set<AppSetting>();
    public DbSet<User> Users => Set<User>();
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<Permission> Permissions => Set<Permission>();
    public DbSet<UserRole> UserRoles => Set<UserRole>();
    public DbSet<RolePermission> RolePermissions => Set<RolePermission>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
    public DbSet<IdempotencyKey> IdempotencyKeys => Set<IdempotencyKey>();
    public DbSet<FinancialPosting> FinancialPostings => Set<FinancialPosting>();
    public DbSet<Customer> Customers => Set<Customer>();
    public DbSet<Employee> Employees => Set<Employee>();
    public DbSet<Supplier> Suppliers => Set<Supplier>();
    public DbSet<CustomerMonthlyPrice> CustomerMonthlyPrices => Set<CustomerMonthlyPrice>();
    public DbSet<MessageTemplate> MessageTemplates => Set<MessageTemplate>();
    public DbSet<MessageOutboxEntry> MessageOutbox => Set<MessageOutboxEntry>();
    public DbSet<MessageAttempt> MessageAttempts => Set<MessageAttempt>();

    public YasinWorkshopDbContext(DbContextOptions<YasinWorkshopDbContext> options)
        : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<AppSetting>(entity =>
        {
            entity.ToTable("app_settings");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Key).HasMaxLength(128).IsRequired();
            entity.Property(x => x.Value).IsRequired();
            entity.Property(x => x.ValueType).HasMaxLength(64).IsRequired();
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
            entity.HasIndex(x => x.Key).IsUnique();
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("users");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.UserName).HasMaxLength(128).IsRequired();
            entity.Property(x => x.DisplayName).HasMaxLength(256).IsRequired();
            entity.Property(x => x.Email).HasMaxLength(256);
            entity.Property(x => x.PasswordHash).HasColumnType("nvarchar(512)").IsRequired();
            entity.Property(x => x.SecurityStamp).HasMaxLength(128);
            entity.Property(x => x.IsActive).IsRequired();
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
            entity.Property(x => x.LastLoginAt).HasColumnType("datetime2");
            entity.HasIndex(x => x.UserName).IsUnique();
            entity.HasIndex(x => x.Email).IsUnique();
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.ToTable("roles");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Name).HasMaxLength(128).IsRequired();
            entity.Property(x => x.Description).HasMaxLength(512);
            entity.Property(x => x.IsActive).IsRequired();
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
            entity.HasIndex(x => x.Name).IsUnique();
        });

        modelBuilder.Entity<Permission>(entity =>
        {
            entity.ToTable("permissions");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Code).HasMaxLength(128).IsRequired();
            entity.Property(x => x.Description).HasMaxLength(512);
            entity.Property(x => x.IsActive).IsRequired();
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
            entity.HasIndex(x => x.Code).IsUnique();
        });

        modelBuilder.Entity<UserRole>(entity =>
        {
            entity.ToTable("user_roles");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.HasIndex(x => new { x.UserId, x.RoleId }).IsUnique();
            entity.HasOne(x => x.User)
                .WithMany(x => x.UserRoles)
                .HasForeignKey(x => x.UserId)
                .OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(x => x.Role)
                .WithMany(x => x.UserRoles)
                .HasForeignKey(x => x.RoleId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<RolePermission>(entity =>
        {
            entity.ToTable("role_permissions");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.HasIndex(x => new { x.RoleId, x.PermissionId }).IsUnique();
            entity.HasOne(x => x.Role)
                .WithMany(x => x.RolePermissions)
                .HasForeignKey(x => x.RoleId)
                .OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(x => x.Permission)
                .WithMany(x => x.RolePermissions)
                .HasForeignKey(x => x.PermissionId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<AuditLog>(entity =>
        {
            entity.ToTable("audit_log");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.EntityName).HasMaxLength(256).IsRequired();
            entity.Property(x => x.Action).HasMaxLength(64).IsRequired();
            entity.Property(x => x.EntityId).HasMaxLength(128);
            entity.Property(x => x.ActorUserName).HasMaxLength(128);
            entity.Property(x => x.CorrelationId).HasMaxLength(128);
            entity.Property(x => x.Reason).HasMaxLength(512);
            entity.Property(x => x.OperationTime).HasColumnType("datetime2").IsRequired();
            entity.Property(x => x.BeforeJson).HasColumnType("nvarchar(max)");
            entity.Property(x => x.AfterJson).HasColumnType("nvarchar(max)");
            entity.HasIndex(x => x.OperationTime);
            entity.HasIndex(x => new { x.EntityName, x.EntityId, x.OperationTime });
        });

        modelBuilder.Entity<IdempotencyKey>(entity =>
        {
            entity.ToTable("idempotency_keys");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.OperationScope).HasMaxLength(128).IsRequired();
            entity.Property(x => x.IdempotencyKeyValue).HasMaxLength(256).IsRequired();
            entity.Property(x => x.RequestHash).HasMaxLength(512);
            entity.Property(x => x.Status).HasMaxLength(32).IsRequired();
            entity.Property(x => x.ResponsePayload).HasColumnType("nvarchar(max)");
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.HasIndex(x => new { x.OperationScope, x.IdempotencyKeyValue }).IsUnique();
        });

        modelBuilder.Entity<FinancialPosting>(entity =>
        {
            entity.ToTable("financial_postings");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.PostingType).HasMaxLength(64).IsRequired();
            entity.Property(x => x.SourceType).HasMaxLength(64).IsRequired();
            entity.Property(x => x.SourceReference).HasMaxLength(128);
            entity.Property(x => x.OperationDate).HasColumnType("date").IsRequired();
            entity.Property(x => x.Year).IsRequired();
            entity.Property(x => x.Month).IsRequired();
            entity.Property(x => x.Amount).HasColumnType("decimal(18,4)").IsRequired();
            entity.Property(x => x.Direction).HasMaxLength(32).IsRequired();
            entity.Property(x => x.Status).HasMaxLength(32).IsRequired();
            entity.Property(x => x.ReversalReference).HasMaxLength(128);
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.HasIndex(x => x.SourceType);
            entity.HasIndex(x => new { x.SourceType, x.SourceReference, x.OperationDate });
        });

        modelBuilder.Entity<Customer>(entity =>
        {
            entity.ToTable("customers");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Name).HasMaxLength(256).IsRequired();
            entity.Property(x => x.ContactName).HasMaxLength(128);
            entity.Property(x => x.Phone).HasMaxLength(64);
            entity.Property(x => x.WhatsApp).HasMaxLength(64);
            entity.Property(x => x.Email).HasMaxLength(256);
            entity.Property(x => x.RelationshipType).HasMaxLength(64).IsRequired();
            entity.Property(x => x.DeliveryLocation).HasMaxLength(512);
            entity.Property(x => x.Status).HasMaxLength(32).IsRequired();
            entity.Property(x => x.Notes).HasColumnType("nvarchar(max)");
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
            entity.HasIndex(x => x.Name).IsUnique();
            entity.HasIndex(x => x.Status);
        });

        modelBuilder.Entity<Employee>(entity =>
        {
            entity.ToTable("employees");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.EmployeeCode).HasMaxLength(64).IsRequired();
            entity.Property(x => x.Name).HasMaxLength(256).IsRequired();
            entity.Property(x => x.Phone).HasMaxLength(64);
            entity.Property(x => x.WhatsApp).HasMaxLength(64);
            entity.Property(x => x.Email).HasMaxLength(256);
            entity.Property(x => x.EmployeeType).HasMaxLength(32).IsRequired();
            entity.Property(x => x.Status).HasMaxLength(32).IsRequired();
            entity.Property(x => x.IsArchived).IsRequired();
            entity.Property(x => x.StartDate).HasColumnType("date");
            entity.Property(x => x.EndDate).HasColumnType("date");
            entity.Property(x => x.Notes).HasColumnType("nvarchar(max)");
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
            entity.HasIndex(x => x.EmployeeCode).IsUnique();
            entity.HasIndex(x => x.Name).IsUnique();
            entity.HasIndex(x => x.Status);
            entity.HasIndex(x => x.EmployeeType);
        });

        modelBuilder.Entity<Supplier>(entity =>
        {
            entity.ToTable("suppliers");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.SupplierCode).HasMaxLength(64).IsRequired();
            entity.Property(x => x.Name).HasMaxLength(256).IsRequired();
            entity.Property(x => x.ContactName).HasMaxLength(128);
            entity.Property(x => x.Phone).HasMaxLength(64);
            entity.Property(x => x.WhatsApp).HasMaxLength(64);
            entity.Property(x => x.Email).HasMaxLength(256);
            entity.Property(x => x.SupplierType).HasMaxLength(32).IsRequired();
            entity.Property(x => x.Status).HasMaxLength(32).IsRequired();
            entity.Property(x => x.IsArchived).IsRequired();
            entity.Property(x => x.Notes).HasColumnType("nvarchar(max)");
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
            entity.HasIndex(x => x.SupplierCode).IsUnique();
            entity.HasIndex(x => x.Name).IsUnique();
            entity.HasIndex(x => x.Status);
            entity.HasIndex(x => x.SupplierType);
        });

        modelBuilder.Entity<CustomerMonthlyPrice>(entity =>
        {
            entity.ToTable("customer_monthly_prices");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Year).IsRequired();
            entity.Property(x => x.Month).IsRequired();
            entity.Property(x => x.MonthlyRate).HasColumnType("decimal(18,4)").IsRequired();
            entity.Property(x => x.Currency).HasMaxLength(16).IsRequired();
            entity.Property(x => x.IsCurrent).IsRequired();
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
            entity.HasIndex(x => new { x.CustomerId, x.Year, x.Month }).IsUnique();
            entity.HasOne(x => x.Customer)
                .WithMany(x => x.MonthlyPrices)
                .HasForeignKey(x => x.CustomerId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        modelBuilder.Entity<MessageTemplate>(entity =>
        {
            entity.ToTable("message_templates");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.TemplateCode).HasMaxLength(128).IsRequired();
            entity.Property(x => x.TemplateName).HasMaxLength(128).IsRequired();
            entity.Property(x => x.BodyTemplate).HasColumnType("nvarchar(max)").IsRequired();
            entity.Property(x => x.IsActive).IsRequired();
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
            entity.HasIndex(x => x.TemplateCode).IsUnique();
        });

        modelBuilder.Entity<MessageOutboxEntry>(entity =>
        {
            entity.ToTable("message_outbox");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.MessageKey).HasMaxLength(128).IsRequired();
            entity.Property(x => x.TemplateCode).HasMaxLength(128).IsRequired();
            entity.Property(x => x.Provider).HasMaxLength(64).IsRequired();
            entity.Property(x => x.RecipientType).HasMaxLength(64).IsRequired();
            entity.Property(x => x.RecipientReference).HasMaxLength(128).IsRequired();
            entity.Property(x => x.MessageType).HasMaxLength(64).IsRequired();
            entity.Property(x => x.Status).HasMaxLength(32).IsRequired();
            entity.Property(x => x.MessagePayload).HasColumnType("nvarchar(max)").IsRequired();
            entity.Property(x => x.FailureMessage).HasMaxLength(1024);
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.Property(x => x.UpdatedAt).HasColumnType("datetime2");
            entity.Property(x => x.LastAttemptAt).HasColumnType("datetime2");
            entity.Property(x => x.SentAt).HasColumnType("datetime2");
            entity.HasIndex(x => x.MessageKey).IsUnique();
            entity.HasIndex(x => x.Status);
        });

        modelBuilder.Entity<MessageAttempt>(entity =>
        {
            entity.ToTable("message_attempts");
            entity.HasKey(x => x.Id);
            entity.Property(x => x.Status).HasMaxLength(32).IsRequired();
            entity.Property(x => x.ProviderReference).HasMaxLength(256);
            entity.Property(x => x.ErrorMessage).HasMaxLength(1024);
            entity.Property(x => x.CreatedAt).HasColumnType("datetime2").IsRequired();
            entity.HasOne(x => x.MessageOutboxEntry)
                .WithMany(x => x.Attempts)
                .HasForeignKey(x => x.MessageOutboxId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}

public sealed class AppSetting
{
    public Guid Id { get; set; }
    public string Key { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
    public string ValueType { get; set; } = "string";
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public sealed class User
{
    public Guid Id { get; set; }
    public string UserName { get; set; } = string.Empty;
    public string DisplayName { get; set; } = string.Empty;
    public string? Email { get; set; }
    public string PasswordHash { get; set; } = string.Empty;
    public string? SecurityStamp { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public DateTime? LastLoginAt { get; set; }
    public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
}

public sealed class Role
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    public ICollection<RolePermission> RolePermissions { get; set; } = new List<RolePermission>();
}

public sealed class Permission
{
    public Guid Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public ICollection<RolePermission> RolePermissions { get; set; } = new List<RolePermission>();
}

public sealed class UserRole
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid RoleId { get; set; }
    public DateTime CreatedAt { get; set; }
    public User User { get; set; } = null!;
    public Role Role { get; set; } = null!;
}

public sealed class RolePermission
{
    public Guid Id { get; set; }
    public Guid RoleId { get; set; }
    public Guid PermissionId { get; set; }
    public DateTime CreatedAt { get; set; }
    public Role Role { get; set; } = null!;
    public Permission Permission { get; set; } = null!;
}

public sealed class AuditLog
{
    public Guid Id { get; set; }
    public string EntityName { get; set; } = string.Empty;
    public string? EntityId { get; set; }
    public string Action { get; set; } = string.Empty;
    public string? ActorUserName { get; set; }
    public string? CorrelationId { get; set; }
    public string? Reason { get; set; }
    public string? BeforeJson { get; set; }
    public string? AfterJson { get; set; }
    public DateTime OperationTime { get; set; }
}

public sealed class IdempotencyKey
{
    public Guid Id { get; set; }
    public string OperationScope { get; set; } = string.Empty;
    public string IdempotencyKeyValue { get; set; } = string.Empty;
    public string Status { get; set; } = "Pending";
    public string? RequestHash { get; set; }
    public string? ResponsePayload { get; set; }
    public DateTime CreatedAt { get; set; }
}

public sealed class FinancialPosting
{
    public Guid Id { get; set; }
    public string PostingType { get; set; } = string.Empty;
    public string SourceType { get; set; } = string.Empty;
    public string? SourceReference { get; set; }
    public DateTime OperationDate { get; set; }
    public int Year { get; set; }
    public int Month { get; set; }
    public decimal Amount { get; set; }
    public string Direction { get; set; } = "Debit";
    public string Status { get; set; } = "Pending";
    public string? ReversalReference { get; set; }
    public DateTime CreatedAt { get; set; }
}

public sealed class Customer
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? ContactName { get; set; }
    public string? Phone { get; set; }
    public string? WhatsApp { get; set; }
    public string? Email { get; set; }
    public string RelationshipType { get; set; } = "Wholesale";
    public string? DeliveryLocation { get; set; }
    public string Status { get; set; } = "Active";
    public bool IsArchived { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public ICollection<CustomerMonthlyPrice> MonthlyPrices { get; set; } = new List<CustomerMonthlyPrice>();
}

public sealed class Employee
{
    public Guid Id { get; set; }
    public string EmployeeCode { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string? WhatsApp { get; set; }
    public string? Email { get; set; }
    public string EmployeeType { get; set; } = "Piece";
    public string Status { get; set; } = "Active";
    public bool IsArchived { get; set; }
    public DateTime? StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public sealed class Supplier
{
    public Guid Id { get; set; }
    public string SupplierCode { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? ContactName { get; set; }
    public string? Phone { get; set; }
    public string? WhatsApp { get; set; }
    public string? Email { get; set; }
    public string SupplierType { get; set; } = "General";
    public string Status { get; set; } = "Active";
    public bool IsArchived { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public sealed class CustomerMonthlyPrice
{
    public Guid Id { get; set; }
    public Guid CustomerId { get; set; }
    public int Year { get; set; }
    public int Month { get; set; }
    public decimal MonthlyRate { get; set; }
    public string Currency { get; set; } = "SAR";
    public bool IsCurrent { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public Customer Customer { get; set; } = null!;
}

public sealed class MessageTemplate
{
    public Guid Id { get; set; }
    public string TemplateCode { get; set; } = string.Empty;
    public string TemplateName { get; set; } = string.Empty;
    public string BodyTemplate { get; set; } = string.Empty;
    public bool IsActive { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
}

public sealed class MessageOutboxEntry
{
    public Guid Id { get; set; }
    public string MessageKey { get; set; } = string.Empty;
    public string TemplateCode { get; set; } = string.Empty;
    public string Provider { get; set; } = "default";
    public string RecipientType { get; set; } = "Customer";
    public string RecipientReference { get; set; } = string.Empty;
    public string MessageType { get; set; } = "Notification";
    public string Status { get; set; } = "Queued";
    public int AttemptCount { get; set; }
    public DateTime? LastAttemptAt { get; set; }
    public DateTime? SentAt { get; set; }
    public string? FailureMessage { get; set; }
    public string MessagePayload { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public ICollection<MessageAttempt> Attempts { get; set; } = new List<MessageAttempt>();
}

public sealed class MessageAttempt
{
    public Guid Id { get; set; }
    public Guid MessageOutboxId { get; set; }
    public string Status { get; set; } = "Pending";
    public string? ProviderReference { get; set; }
    public string? ErrorMessage { get; set; }
    public DateTime CreatedAt { get; set; }
    public MessageOutboxEntry MessageOutboxEntry { get; set; } = null!;
}
