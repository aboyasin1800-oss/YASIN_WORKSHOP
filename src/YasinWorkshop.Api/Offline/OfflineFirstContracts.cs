namespace YasinWorkshop.Api.Offline;

public enum SyncState
{
    Pending,
    InFlight,
    Synced,
    Failed,
    Conflict,
    Tombstoned
}

public enum SyncOperationType
{
    Create,
    Update,
    Delete,
    Upsert,
    MessageSend
}

public sealed record SyncOutboxOperation(
    Guid OperationId,
    Guid ClientId,
    string EntityType,
    string EntityId,
    SyncOperationType OperationType,
    string Payload,
    DateTime CreatedAt,
    int AttemptCount,
    SyncState SyncState,
    string IdempotencyKey,
    string? CorrelationId = null,
    string? LastError = null);

public sealed record SyncConflict(
    string EntityType,
    string EntityId,
    string LocalVersion,
    string ServerVersion,
    string ConflictDetails,
    DateTime CreatedAt);

public enum ConnectivityState
{
    Online,
    Offline,
    Degraded
}

public interface IOfflineLocalStore
{
    Task SaveOutboxOperationAsync(SyncOutboxOperation operation, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<SyncOutboxOperation>> GetPendingOperationsAsync(CancellationToken cancellationToken = default);
    Task MarkOperationStateAsync(Guid operationId, SyncState state, string? lastError = null, CancellationToken cancellationToken = default);
    Task SaveConflictAsync(SyncConflict conflict, CancellationToken cancellationToken = default);
    Task<ConnectivityState> GetConnectivityStateAsync(CancellationToken cancellationToken = default);
}

public interface IOfflineSyncEngine
{
    Task PushPendingAsync(CancellationToken cancellationToken = default);
    Task PullRemoteAsync(CancellationToken cancellationToken = default);
    Task RetryFailedAsync(CancellationToken cancellationToken = default);
    Task<SyncConflict?> DetectConflictAsync(string entityType, string entityId, string localVersion, string serverVersion, CancellationToken cancellationToken = default);
}
