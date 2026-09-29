import 'package:flutter/material.dart';

/// Context extensions for idiomatic, type-safe navigation.
extension NavigationX on BuildContext {
  /// Pushes a named route onto the navigator.
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Replaces the current route with a named route.
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.of(this).pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  /// Pops the topmost route off the navigator.
  void pop<T extends Object?>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }
}
