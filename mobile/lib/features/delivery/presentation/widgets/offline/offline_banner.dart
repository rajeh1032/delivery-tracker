import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/general_cubits/connectivity_cubit.dart';
import 'package:delivery_tracker/core/general_cubits/connectivity_state.dart';

/// Top banner that slides in when offline, assuring driver that actions are saved locally.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        final isOffline = !state.isOnline;

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isOffline
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spaceMD,
                    vertical: AppDimensions.spaceSM,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.waitingToSyncBg,
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.waitingToSync,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.wifi_off_rounded,
                        color: AppColors.waitingToSync,
                        size: AppDimensions.iconMD,
                      ),
                      const SizedBox(width: AppDimensions.spaceSM),
                      Expanded(
                        child: Text(
                          context.tr.offlineBannerBody,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
    );
  }
}
