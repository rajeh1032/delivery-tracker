import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routing/app_routes.dart';
import 'config/routing/route_generator.dart';
import 'config/theme/app_theme.dart';
import 'core/database/local_storage_service.dart';
import 'core/di/di.dart';
import 'core/general_cubits/connectivity_cubit.dart';
import 'core/general_cubits/locale_cubit.dart';
import 'core/general_cubits/locale_state.dart';
import 'core/l10n/generated/app_localizations.dart';
import 'core/services/sync_manager.dart';
import 'features/delivery/data_sources/sources/local/delivery_local_ds.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await getIt<LocalStorageService>().init();
  await getIt<DeliveryLocalDataSource>().reconcileStrandedSyncStates();
  getIt<SyncManager>().startListening();
  runApp(const DeliveryTrackerApp());
}

class DeliveryTrackerApp extends StatelessWidget {
  final LocaleCubit? localeCubit;
  final ConnectivityCubit? connectivityCubit;

  const DeliveryTrackerApp({
    super.key,
    this.localeCubit,
    this.connectivityCubit,
  });

  @override
  Widget build(BuildContext context) {
    final activeLocaleCubit = localeCubit ??
        (getIt.isRegistered<LocaleCubit>()
            ? getIt<LocaleCubit>()
            : LocaleCubit());

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: activeLocaleCubit),
        if (connectivityCubit != null)
          BlocProvider.value(value: connectivityCubit!)
        else if (getIt.isRegistered<ConnectivityCubit>())
          BlocProvider(create: (_) => getIt<ConnectivityCubit>())
        else
          BlocProvider(create: (_) => ConnectivityCubit(getIt())),
      ],
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Delivery Tracker',
            theme: AppTheme.lightTheme,
            locale: state.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: AppRoutes.homeShell,
            onGenerateRoute: RouteGenerator.onGenerateRoute,
          );
        },
      ),
    );
  }
}
