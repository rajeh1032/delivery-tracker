import 'dart:math';

import '../../features/delivery/domain/entities/delivery_action.dart';
import '../network/api_results.dart';
import '../network/failures.dart';
import '../utils/enums.dart';

/// One initial attempt and three retries, with durable eligibility deadlines.
class SyncRetryPolicy {
  static const maxAttempts = 4;
  final DateTime Function() now;
  final double Function() jitter;

  SyncRetryPolicy({DateTime Function()? now, double Function()? jitter})
    : now = now ?? DateTime.now,
      jitter = jitter ?? Random().nextDouble;

  bool canAttempt(DeliveryAction action) =>
      action.autoRetryAllowed &&
      (!action.isFailed || action.nextRetryAt != null) &&
      action.retryCount < maxAttempts &&
      (action.nextRetryAt == null || !action.nextRetryAt!.isAfter(now()));

  DateTime? nextDeadline(Iterable<DeliveryAction> actions) {
    DateTime? earliest;
    for (final action in actions) {
      final due = action.nextRetryAt;
      if (!action.autoRetryAllowed ||
          action.retryCount >= maxAttempts ||
          due == null) {
        continue;
      }
      if (earliest == null || due.isBefore(earliest)) earliest = due;
    }
    return earliest;
  }

  bool isTransient<T>(ApiErrorResult<T> error) {
    if (error.failure is PermanentFailure) return false;
    final status = error.statusCode;
    return error.failure.isRetryable ||
        status == 429 ||
        (status != null && status >= 500);
  }

  DeliveryAction afterFailure<T>(
    DeliveryAction action,
    ApiErrorResult<T> error,
  ) {
    final transient = isTransient(error);
    final failures = transient ? action.retryCount + 1 : action.retryCount;
    final schedule =
        transient &&
        (failures < maxAttempts || error.failure.retryAfter != null);
    return action.copyWith(
      retryCount: failures,
      autoRetryAllowed: transient,
      nextRetryAt: schedule
          ? nextAttempt(failures, retryAfter: error.failure.retryAfter)
          : null,
      clearNextRetryAt: !schedule,
      status: SyncStatus.failed,
      lastError: error.message,
    );
  }

  DateTime nextAttempt(int failures, {Duration? retryAfter}) {
    final base = Duration(seconds: 2 * (1 << (failures - 1)));
    final delay =
        base +
        Duration(milliseconds: (base.inMilliseconds * .25 * jitter()).round());
    return now().add(
      retryAfter != null && retryAfter > delay ? retryAfter : delay,
    );
  }
}
