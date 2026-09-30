import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';

/// Form text field for optional delivery notes or failure details.
class NoteField extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? initialValue;

  const NoteField({
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
          context.tr.noteLabel,
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
          maxLines: 3,
          maxLength: 500,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: context.tr.noteHint,
            alignLabelWithHint: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spaceMD,
              vertical: AppDimensions.spaceMD,
            ),
          ),
        ),
      ],
    );
  }
}
