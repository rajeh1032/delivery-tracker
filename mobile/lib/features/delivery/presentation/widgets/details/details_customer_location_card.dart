import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/helpers/customer_location_helper.dart';
import 'package:delivery_tracker/core/helpers/phone_launcher_utils.dart';
import 'package:delivery_tracker/core/helpers/snackbar_utils.dart';
import 'customer_map_preview.dart';

/// Unified customer & delivery location card with embedded map and external map launcher.
class DetailsCustomerLocationCard extends StatelessWidget {
  final String customerName;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;

  const DetailsCustomerLocationCard({
    super.key,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  void _callCustomer(BuildContext context) {
    PhoneLauncherUtils.makePhoneCall(context: context, phoneNumber: phone);
  }

  void _copyPhone(BuildContext context) {
    Clipboard.setData(ClipboardData(text: phone));
    SnackBarUtils.showSuccess(context, context.tr.phoneCopied);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            customerName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSM),
          InkWell(
            onTap: () => _callCustomer(context),
            onLongPress: () => _copyPhone(context),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      phone,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyPhone(context),
                    tooltip: context.tr.copyPhone,
                    icon: const Icon(Icons.copy_outlined, size: 18),
                    color: AppColors.textSecondary,
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_rounded, size: 20),
                    color: AppColors.primary,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.08,
                      ),
                      padding: const EdgeInsets.all(AppDimensions.spaceXS),
                      minimumSize: const Size(48, 48),
                    ),
                    tooltip: context.tr.callCustomer,
                    onPressed: () => _callCustomer(context),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spaceXS),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSM),
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          CustomerMapPreview(
            latitude: latitude,
            longitude: longitude,
            customerName: customerName,
            address: address,
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: () => CustomerLocationHelper.openInGoogleMaps(
                latitude: latitude,
                longitude: longitude,
              ),
              icon: const Icon(Icons.map_outlined, size: 18),
              iconAlignment: IconAlignment.end,
              label: Text(
                context.tr.viewOnMap,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
