import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';

/// Delivery address with its location icon at the reading-order end.
class DeliveryAddressRow extends StatelessWidget {
  const DeliveryAddressRow({super.key, required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.35,
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
    );
  }
}
