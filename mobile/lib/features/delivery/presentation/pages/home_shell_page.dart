import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme/app_dimensions.dart';
import '../../../../config/theme/colors.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/general_cubits/connectivity_cubit.dart';
import '../../../../core/general_cubits/connectivity_state.dart';
import '../../../../core/general_cubits/locale_cubit.dart';
import '../../../../core/helpers/snackbar_utils.dart';
import '../widgets/offline/connectivity_pill.dart';
import '../widgets/offline/offline_banner.dart';
import 'deliveries_list_page.dart';
import 'sync_queue_page.dart';

/// Root shell page hosting the bottom navigation bar and reactive offline banner.
class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listenWhen: (previous, current) => current.justCameOnline,
      listener: (context, state) {
        SnackBarUtils.showSuccess(context, context.tr.backOnline);
      },
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: Text(
            context.tr.appTitle,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          actions: [
            const Padding(
              padding: EdgeInsetsDirectional.only(end: AppDimensions.spaceSM),
              child: ConnectivityPill(),
            ),
            IconButton(
              tooltip: context.tr.syncQueueTitle,
              icon: const Icon(Icons.sync_rounded),
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: AppColors.surface,
                  clipBehavior: Clip.antiAlias,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppDimensions.radiusBottomSheet),
                    ),
                  ),
                  builder: (_) => const SizedBox(
                    height: 520,
                    child: SyncQueuePage(),
                  ),
                );
              },
            ),
            IconButton(
              tooltip: context.tr.language,
              icon: const Icon(Icons.language_rounded),
              onPressed: () => context.read<LocaleCubit>().toggleLocale(),
            ),
            const SizedBox(width: AppDimensions.spaceXS),
          ],
        ),
        body: const SafeArea(
          top: false,
          child: Column(
            children: [
              OfflineBanner(),
              Expanded(
                child: DeliveriesListPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
