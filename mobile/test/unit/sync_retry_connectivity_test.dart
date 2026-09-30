import 'dart:async';

import 'package:delivery_tracker/core/network/api_results.dart';
import 'package:delivery_tracker/core/services/sync_retry_policy.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'sync_retry_fixture.dart';
import 'sync_test_fixtures.dart';

void main() {
  testWidgets(
    'connection recovery resumes a retry without charging offline time',
    (tester) async {
      final fixture = RetryFixture(
        policy: SyncRetryPolicy(now: tester.binding.clock.now, jitter: () => 0),
      );
      final events = StreamController<bool>();
      when(
        () => fixture.connectivity.onConnectivityChanged,
      ).thenAnswer((_) => events.stream);
      fixture.manager.startListening();
      await tester.pump();
      expect(fixture.calls, 1);
      fixture.reachable = false;
      events.add(false);
      await tester.pump(const Duration(seconds: 2));
      expect(fixture.calls, 1);
      expect(fixture.queue.single.retryCount, 1);
      fixture.reachable = true;
      fixture.response = ApiSuccessResult(syncSuccess(7));
      events.add(true);
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      expect(fixture.sentIds, ['stable-id', 'stable-id']);
      expect(fixture.queue, isEmpty);
      fixture.manager.dispose();
      unawaited(events.close());
      await tester.pump();
    },
  );

  test(
    'legacy failed action awaits manual retry and remains recoverable',
    () async {
      final fixture = RetryFixture();
      fixture.queue = [
        fixture.action.copyWith(status: SyncStatus.failed, retryCount: 1),
      ];
      await fixture.manager.processQueue();
      expect(fixture.calls, 0);
      fixture.response = ApiSuccessResult(syncSuccess(7));
      expect(await fixture.manager.retryAction('stable-id'), isTrue);
      expect(fixture.queue, isEmpty);
      fixture.manager.dispose();
    },
  );
}
