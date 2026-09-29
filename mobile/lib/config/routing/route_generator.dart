import 'package:flutter/material.dart';
import '../../features/delivery/presentation/pages/home_shell_page.dart';
import 'app_routes.dart';

/// Centralized route generator resolving path names to corresponding screen widgets.
abstract final class RouteGenerator {
  /// Resolves the requested [RouteSettings] to a [MaterialPageRoute].
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.homeShell:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeShellPage(),
          settings: settings,
        );

      case AppRoutes.deliveryDetails:
        // Will be wired to DeliveryDetailsPage in Phase C
        return MaterialPageRoute<void>(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Delivery Details Placeholder')),
          ),
          settings: settings,
        );

      default:
        return MaterialPageRoute<void>(
          builder: (_) => const HomeShellPage(),
          settings: settings,
        );
    }
  }
}
