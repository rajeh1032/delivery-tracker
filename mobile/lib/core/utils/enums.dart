/// Represents the server-side lifecycle state of a delivery order.
enum DeliveryStatus {
  pending,
  delivered,
  failed;

  String toApiKey() {
    switch (this) {
      case DeliveryStatus.pending:
        return 'pending';
      case DeliveryStatus.delivered:
        return 'delivered';
      case DeliveryStatus.failed:
        return 'failed';
    }
  }

  static DeliveryStatus? fromApiKeyOrNull(String? key) {
    if (key == null || key.trim().isEmpty) return null;
    switch (key.toLowerCase().trim()) {
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'failed':
        return DeliveryStatus.failed;
      case 'pending':
        return DeliveryStatus.pending;
      default:
        return null;
    }
  }

  static DeliveryStatus fromApiKey(String? key) {
    return fromApiKeyOrNull(key) ?? DeliveryStatus.pending;
  }
}

/// Represents the client-side synchronization state of a delivery record or queued action.
enum SyncStatus {
  synced,
  waitingToSync,
  syncing,
  failed;

  bool get isPendingSync =>
      this == SyncStatus.waitingToSync || this == SyncStatus.syncing;
}

/// Defines the mutation intent stored in the offline persistent action queue.
enum DeliveryActionType {
  complete,
  fail;

  String toApiKey() {
    switch (this) {
      case DeliveryActionType.complete:
        return 'complete';
      case DeliveryActionType.fail:
        return 'fail';
    }
  }

  static DeliveryActionType? fromApiKeyOrNull(String? key) {
    if (key == null || key.trim().isEmpty) return null;
    switch (key.toLowerCase().trim()) {
      case 'complete':
        return DeliveryActionType.complete;
      case 'fail':
        return DeliveryActionType.fail;
      default:
        return null;
    }
  }

  static DeliveryActionType fromApiKey(String? key) {
    return fromApiKeyOrNull(key) ?? DeliveryActionType.fail;
  }
}

/// Structured machine-readable reasons when marking a delivery as failed.
enum FailureReason {
  customerUnavailable,
  wrongAddress,
  customerRefused,
  damagedPackage,
  other;

  String toApiKey() {
    switch (this) {
      case FailureReason.customerUnavailable:
        return 'customer_unavailable';
      case FailureReason.wrongAddress:
        return 'wrong_address';
      case FailureReason.customerRefused:
        return 'customer_refused';
      case FailureReason.damagedPackage:
        return 'damaged_package';
      case FailureReason.other:
        return 'other';
    }
  }

  static FailureReason? fromApiKeyOrNull(String? key) {
    if (key == null || key.trim().isEmpty) return null;
    switch (key.toLowerCase().trim()) {
      case 'customer_unavailable':
        return FailureReason.customerUnavailable;
      case 'wrong_address':
        return FailureReason.wrongAddress;
      case 'customer_refused':
        return FailureReason.customerRefused;
      case 'damaged_package':
        return FailureReason.damagedPackage;
      case 'other':
      default:
        return FailureReason.other;
    }
  }

  static FailureReason fromApiKey(String? key) {
    return fromApiKeyOrNull(key) ?? FailureReason.other;
  }
}
