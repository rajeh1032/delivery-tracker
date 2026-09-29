import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';

/// Form text field for entering and validating the recipient's name.
class RecipientNameField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? initialValue;

  const RecipientNameField({
    super.key,
    this.controller,
    this.onChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.recipientNameLabel,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceXS),
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          onChanged: onChanged,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            hintText: context.tr.recipientNameHint,
            prefixIcon: const Icon(
              Icons.person_outline,
              size: AppDimensions.iconMD,
              color: AppColors.textMuted,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMD,
              vertical: AppDimensions.spaceMD,
            ),
          ),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.length < 2) {
              return context.tr.recipientNameRequired;
            }
            return null;
          },
        ),
      ],
    );
  }
}
