import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'letter_badge.dart';

/// Single delivery stop address row with a letter badge ('A') and 2-line wrapped address.
class DeliveryAddressRow extends StatelessWidget {
  const DeliveryAddressRow({
    super.key,
    required this.address,
    this.letter = 'A',
    this.badgeColor = AppColors.pickupColor,
  });

  final String address;
  final String letter;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: LetterBadge(
            label: letter,
            backgroundColor: badgeColor,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSM),
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
      ],
    );
  }
}
