import 'dart:io';

import 'package:dio/dio.dart';

import 'network_constants.dart';

Duration? parseRetryAfter(Response response) {
  final value = response.headers.value(NetworkConstants.retryAfter);
  if (value == null) return null;
  final seconds = int.tryParse(value.trim());
  if (seconds != null) return Duration(seconds: seconds < 0 ? 0 : seconds);
  try {
    final remaining = HttpDate.parse(value).difference(DateTime.now().toUtc());
    return remaining.isNegative ? Duration.zero : remaining;
  } on HttpException {
    return null;
  }
}
