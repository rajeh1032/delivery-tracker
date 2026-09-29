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

/// Root shell page hosting the bottom navigation bar and reactive offline banner.
class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key});

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listenWhen: (previous, current) => current.justCameOnline,
      listener: (context, state) {
        SnackBarUtils.showSuccess(context, context.tr.backOnline);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _resolveTitle(context),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            const Padding(
              padding: EdgeInsetsDirectional.only(end: AppDimensions.spaceSM),
              child: ConnectivityPill(),
            ),
            IconButton(
              tooltip: context.tr.language,
              icon: const Icon(Icons.language_rounded),
              onPressed: () => context.read<LocaleCubit>().toggleLocale(),
            ),
            const SizedBox(width: AppDimensions.spaceXS),
          ],
        ),
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildDeliveriesTabPlaceholder(context),
                  _buildSyncQueueTabPlaceholder(context),
                  _buildSettingsTab(context),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.local_shipping_outlined),
              selectedIcon: const Icon(Icons.local_shipping),
              label: context.tr.navDeliveries,
            ),
            NavigationDestination(
              icon: const Icon(Icons.sync_outlined),
              selectedIcon: const Icon(Icons.sync),
              label: context.tr.navSyncQueue,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: context.tr.navSettings,
            ),
          ],
        ),
      ),
    );
  }

  String _resolveTitle(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return context.tr.appTitle;
      case 1:
        return context.tr.syncQueueTitle;
      case 2:
        return context.tr.settingsTitle;
      default:
        return context.tr.appTitle;
    }
  }

  Widget _buildDeliveriesTabPlaceholder(BuildContext context) {
    return Center(
      child: Text(
        context.tr.navDeliveries,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSyncQueueTabPlaceholder(BuildContext context) {
    return Center(
      child: Text(
        context.tr.syncQueueTitle,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.language_rounded, color: AppColors.primary),
            title: Text(context.tr.language),
            trailing: Text(
              context.isRtl ? context.tr.arabic : context.tr.english,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            onTap: () => context.read<LocaleCubit>().toggleLocale(),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMD),
        Center(
          child: Text(
            context.tr.aboutVersion,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
