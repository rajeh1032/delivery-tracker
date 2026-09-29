import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/utils/enums.dart';

/// Form dropdown for selecting a structured failure reason.
class FailureReasonDropdown extends StatelessWidget {
  final FailureReason? value;
  final ValueChanged<FailureReason?>? onChanged;

  const FailureReasonDropdown({
    super.key,
    this.value,
    this.onChanged,
  });

  String _labelForReason(BuildContext context, FailureReason reason) {
    switch (reason) {
      case FailureReason.customerUnavailable:
        return context.tr.reasonCustomerUnavailable;
      case FailureReason.wrongAddress:
        return context.tr.reasonWrongAddress;
      case FailureReason.customerRefused:
        return context.tr.reasonCustomerRefused;
      case FailureReason.damagedPackage:
        return context.tr.reasonDamagedPackage;
      case FailureReason.other:
        return context.tr.reasonOther;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.failureReasonLabel,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXS),
        DropdownButtonFormField<FailureReason>(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMD,
              vertical: AppDimensions.spaceMD,
            ),
            prefixIcon: const Icon(
              Icons.warning_amber_rounded,
              size: AppDimensions.iconMD,
              color: AppColors.textMuted,
            ),
          ),
          hint: Text(
            context.tr.failureReasonRequired,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          items: FailureReason.values.map((reason) {
            return DropdownMenuItem<FailureReason>(
              value: reason,
              child: Text(
                _labelForReason(context, reason),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          validator: (val) {
            if (val == null) {
              return context.tr.failureReasonRequired;
            }
            return null;
          },
        ),
      ],
    );
  }
}
