import 'package:flutter/material.dart';
import '../../features/delivery/domain/entities/delivery_entity.dart';
import '../../features/delivery/presentation/pages/delivery_details_page.dart';
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
        final args = settings.arguments;
        final int id = args is int
            ? args
            : (args is DeliveryEntity ? args.id : 0);
        final DeliveryEntity? preloaded = args is DeliveryEntity ? args : null;

        return MaterialPageRoute<void>(
          builder: (_) => DeliveryDetailsPage(
            deliveryId: id,
            preloaded: preloaded,
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
