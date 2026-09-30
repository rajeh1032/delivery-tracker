import 'dart:io';

import 'package:delivery_tracker/core/network/failures.dart';
import 'package:delivery_tracker/core/services/sync_retry_policy.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026);
  test('jitter adds up to 25 percent to exponential delays', () {
    for (final jitter in [0.0, 1.0]) {
      final policy = SyncRetryPolicy(now: () => now, jitter: () => jitter);
      expect(
        policy.nextAttempt(1).difference(now).inMilliseconds,
        jitter == 0 ? 2000 : 2500,
      );
      expect(
        policy.nextAttempt(2).difference(now).inMilliseconds,
        jitter == 0 ? 4000 : 5000,
      );
      expect(
        policy.nextAttempt(3).difference(now).inMilliseconds,
        jitter == 0 ? 8000 : 10000,
      );
    }
  });

  test('429 parses Retry-After seconds', () {
    final failure = ServerFailure.fromResponse(
      Response(
        requestOptions: RequestOptions(),
        statusCode: 429,
        headers: Headers.fromMap({
          'retry-after': ['30'],
        }),
      ),
    );
    expect(failure.isRetryable, isTrue);
    expect(failure.retryAfter, const Duration(seconds: 30));
  });

  test('429 parses HTTP date and ignores invalid Retry-After', () {
    final future = DateTime.now().toUtc().add(const Duration(seconds: 60));
    final failure = ServerFailure.fromResponse(
      Response(
        requestOptions: RequestOptions(),
        statusCode: 429,
        headers: Headers.fromMap({
          'retry-after': [HttpDate.format(future)],
        }),
      ),
    );
    expect(failure.retryAfter!.inSeconds, inInclusiveRange(58, 60));
    final invalid = ServerFailure.fromResponse(
      Response(
        requestOptions: RequestOptions(),
        statusCode: 429,
        headers: Headers.fromMap({
          'retry-after': ['invalid'],
        }),
      ),
    );
    expect(invalid.retryAfter, isNull);
    expect(invalid.isRetryable, isTrue);
  });
}
