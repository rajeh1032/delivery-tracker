import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/network/failures.dart';
import 'package:delivery_tracker/core/services/sync_retry_policy.dart';
import 'sync_test_fixtures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'sync_retry_fixture.dart';

void main() {
  late RetryFixture fixture;
  setUp(() => fixture = RetryFixture());
  tearDown(() => fixture.manager.dispose());
  testWidgets('429 cooldown cannot be bypassed by drains or manual retry', (
    tester,
  ) async {
    fixture.manager.dispose();
    fixture = RetryFixture(
      policy: SyncRetryPolicy(now: tester.binding.clock.now, jitter: () => 0),
    );
    fixture.response = const ApiErrorResult(
      'Rate limited',
      statusCode: 429,
      failure: TransientFailure(
        errorMessage: 'Rate limited',
        retryAfter: Duration(seconds: 30),
      ),
    );
    await fixture.manager.processQueue();
    await fixture.manager.processQueue();
    expect(await fixture.manager.retryAction('stable-id'), isFalse);
    await tester.pump(const Duration(seconds: 29));
    expect(fixture.calls, 1);
    fixture.response = ApiSuccessResult(syncSuccess(7));
    await tester.pump(const Duration(seconds: 1));
    expect(fixture.calls, 2);
    expect(fixture.queue, isEmpty);
  });
  testWidgets(
    'exhausted 429 still prevents manual retry during server cooldown',
    (tester) async {
      fixture.manager.dispose();
      final policy = SyncRetryPolicy(
        now: tester.binding.clock.now,
        jitter: () => 0,
      );
      fixture = RetryFixture(policy: policy);
      fixture.queue = [fixture.action.copyWith(retryCount: 3)];
      fixture.response = const ApiErrorResult(
        'Rate limited',
        statusCode: 429,
        failure: TransientFailure(
          errorMessage: 'Rate limited',
          retryAfter: Duration(seconds: 30),
        ),
      );
      await fixture.manager.processQueue();
      expect(fixture.queue.single.retryCount, 4);
      expect(await fixture.manager.retryAction('stable-id'), isFalse);
      expect(fixture.calls, 1);
      await tester.pump(const Duration(seconds: 30));
      fixture.response = ApiSuccessResult(syncSuccess(7));
      expect(await fixture.manager.retryAction('stable-id'), isTrue);
      expect(fixture.queue, isEmpty);
    },
  );
}
