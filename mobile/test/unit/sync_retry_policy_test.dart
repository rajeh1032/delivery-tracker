import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/network/failures.dart';
import 'package:delivery_tracker/core/services/sync_manager.dart';
import 'package:delivery_tracker/core/services/sync_retry_policy.dart';
import 'sync_test_fixtures.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'sync_retry_fixture.dart';

void main() {
  late RetryFixture fixture;
  setUp(() => fixture = RetryFixture());
  tearDown(() => fixture.manager.dispose());
  test(
    'permanent rejection is retained but never automatically resent',
    () async {
      fixture.response = const ApiErrorResult(
        'Invalid name',
        statusCode: 400,
        failure: PermanentFailure(errorMessage: 'Invalid name'),
      );
      await fixture.manager.processQueue();
      await fixture.manager.processQueue();
      expect(fixture.calls, 1);
      expect(fixture.queue.single.status, SyncStatus.failed);
    },
  );
  test('exhausted retry budget survives manager recreation', () async {
    fixture.queue = [
      fixture.action.copyWith(status: SyncStatus.failed, retryCount: 4),
    ];
    await fixture.manager.processQueue();
    fixture.manager.dispose();
    fixture.manager = SyncManager(
      fixture.local,
      fixture.remote,
      fixture.connectivity,
      fixture.proofs,
    );
    await fixture.manager.processQueue();
    expect(fixture.calls, 0);
    expect(fixture.queue, hasLength(1));
  });
  test('new drain does not immediately resend a transient failure', () async {
    await fixture.manager.processQueue();
    await fixture.manager.processQueue();
    expect(fixture.calls, 1);
    expect(fixture.queue.single.retryCount, 1);
  });
  testWidgets(
    'automatic retries wait 2, 4, 8 seconds then stop at four attempts',
    (tester) async {
      fixture.manager.dispose();
      fixture = RetryFixture(
        policy: SyncRetryPolicy(now: tester.binding.clock.now, jitter: () => 0),
      );
      await fixture.manager.processQueue();
      expect(fixture.calls, 1);
      for (final seconds in [2, 4, 8]) {
        final before = fixture.calls;
        await tester.pump(Duration(seconds: seconds - 1));
        expect(fixture.calls, before);
        await tester.pump(const Duration(seconds: 1));
        expect(fixture.calls, before + 1);
      }
      await tester.pump(const Duration(minutes: 1));
      await fixture.manager.processQueue();
      expect(fixture.calls, 4);
      expect(fixture.queue.single.retryCount, 4);
      expect(fixture.queue.single.nextRetryAt, isNull);
      expect(fixture.sentIds, everyElement('stable-id'));
    },
  );

  testWidgets('success on automatic retry clears queue and marks synced', (
    tester,
  ) async {
    fixture.manager.dispose();
    fixture = RetryFixture(
      policy: SyncRetryPolicy(now: tester.binding.clock.now, jitter: () => 0),
    );
    await fixture.manager.processQueue();
    fixture.response = ApiSuccessResult(syncSuccess(7));
    await tester.pump(const Duration(seconds: 2));
    expect(fixture.calls, 2);
    expect(fixture.queue, isEmpty);
    expect(fixture.delivery.syncStatus, SyncStatus.synced);
    await tester.pump(const Duration(minutes: 1));
    expect(fixture.calls, 2);
  });

  test('offline leaves budget untouched', () async {
    fixture.reachable = false;
    await fixture.manager.processQueue();
    expect(fixture.calls, 0);
    expect(fixture.queue.single.retryCount, 0);
  });

  test(
    'manual retry restarts exhausted transient budget with same ID',
    () async {
      fixture.queue = [
        fixture.action.copyWith(status: SyncStatus.failed, retryCount: 4),
      ];
      fixture.response = ApiSuccessResult(syncSuccess(7));
      expect(await fixture.manager.retryAction('stable-id'), isTrue);
      expect(fixture.queue, isEmpty);
      expect(fixture.sentIds, ['stable-id']);
    },
  );

  test('manual retry cannot resend a permanent rejection', () async {
    fixture.response = const ApiErrorResult(
      'Invalid',
      statusCode: 400,
      failure: PermanentFailure(errorMessage: 'Invalid'),
    );
    await fixture.manager.processQueue();
    expect(await fixture.manager.retryAction('stable-id'), isFalse);
    expect(fixture.calls, 1);
  });

  testWidgets(
    'recreated manager respects persisted deadline and schedules it',
    (tester) async {
      fixture.manager.dispose();
      final policy = SyncRetryPolicy(
        now: tester.binding.clock.now,
        jitter: () => 0,
      );
      fixture = RetryFixture(policy: policy);
      await fixture.manager.processQueue();
      fixture.manager.dispose();
      fixture.manager = SyncManager(
        fixture.local,
        fixture.remote,
        fixture.connectivity,
        fixture.proofs,
        retryPolicy: policy,
      );
      await fixture.manager.processQueue();
      expect(fixture.calls, 1);
      await tester.pump(const Duration(seconds: 2));
      expect(fixture.calls, 2);
      fixture.manager.dispose();
    },
  );
}
