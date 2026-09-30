import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/general_cubits/connectivity_cubit.dart';
import 'package:delivery_tracker/core/general_cubits/connectivity_state.dart';
import 'package:delivery_tracker/core/general_cubits/locale_cubit.dart';

/// Settings screen for managing application preferences and language selection.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.spaceLG),
        children: [
          _SettingsTile(
            icon: Icons.language_rounded,
            title: context.tr.language,
            trailingText:
                context.isRtl ? context.tr.arabic : context.tr.english,
            onTap: () => context.read<LocaleCubit>().toggleLocale(),
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          BlocBuilder<ConnectivityCubit, ConnectivityState>(
            builder: (context, state) {
              return _SettingsTile(
                icon: state.isOnline
                    ? Icons.wifi_rounded
                    : Icons.wifi_off_rounded,
                iconColor:
                    state.isOnline ? AppColors.synced : AppColors.failed,
                title: state.isOnline
                    ? context.tr.online
                    : context.tr.offline,
                trailingText: state.isOnline
                    ? context.tr.online
                    : context.tr.offline,
                trailingColor:
                    state.isOnline ? AppColors.synced : AppColors.failed,
              );
            },
          ),
          const SizedBox(height: AppDimensions.spaceXL),
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
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String trailingText;
  final Color trailingColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    this.iconColor = AppColors.primary,
    required this.title,
    required this.trailingText,
    this.trailingColor = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLG,
            vertical: AppDimensions.spaceMD,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: AppDimensions.iconMD),
              const SizedBox(width: AppDimensions.spaceMD),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                trailingText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: trailingColor,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: AppDimensions.spaceSM),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppDimensions.iconSM,
                  color: AppColors.textMuted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
