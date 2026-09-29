import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/theme/app_theme.dart';
import 'core/di/di.dart';
import 'core/general_cubits/locale_cubit.dart';
import 'core/general_cubits/locale_state.dart';
import 'core/l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const DeliveryTrackerApp());
}

class DeliveryTrackerApp extends StatelessWidget {
  final LocaleCubit? localeCubit;

  const DeliveryTrackerApp({super.key, this.localeCubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          localeCubit ??
          (getIt.isRegistered<LocaleCubit>()
              ? getIt<LocaleCubit>()
              : LocaleCubit()),
      child: BlocBuilder<LocaleCubit, LocaleState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Delivery Tracker',
            theme: AppTheme.lightTheme,
            locale: state.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(
              body: Center(
                child: Text('Delivery Tracker Ready'),
              ),
            ),
          );
        },
      ),
    );
  }
}
