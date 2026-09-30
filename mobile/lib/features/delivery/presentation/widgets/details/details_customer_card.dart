import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/helpers/phone_launcher_utils.dart';
import 'package:delivery_tracker/core/helpers/snackbar_utils.dart';

/// Card presenting customer name, phone number, and quick copy/call action triggers.
class DetailsCustomerCard extends StatelessWidget {
  final String customerName;
  final String phone;

  const DetailsCustomerCard({
    super.key,
    required this.customerName,
    required this.phone,
  });

  void _copyPhone(BuildContext context) {
    Clipboard.setData(ClipboardData(text: phone));
    SnackBarUtils.showSuccess(context, context.tr.phoneCopied);
  }

  void _callCustomer(BuildContext context) {
    PhoneLauncherUtils.makePhoneCall(
      context: context,
      phoneNumber: phone,
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr.customerInfo,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppDimensions.spaceXXS),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _copyPhone(context),
                icon: const Icon(
                  Icons.copy_rounded,
                  size: AppDimensions.iconMD,
                  color: AppColors.primary,
                ),
                tooltip: context.tr.copyPhone,
              ),
              IconButton(
                onPressed: () => _callCustomer(context),
                icon: const Icon(
                  Icons.phone_outlined,
                  size: AppDimensions.iconMD,
                  color: AppColors.synced,
                ),
                tooltip: context.tr.callCustomer,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
