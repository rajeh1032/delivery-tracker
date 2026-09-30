import 'package:flutter/material.dart';
import '../../../../../config/theme/app_dimensions.dart';
import '../../../../../config/theme/colors.dart';
import '../../../../../core/extensions/context_extensions.dart';

/// Search bar widget for deliveries filtering with clear button.
class DeliveriesSearchBar extends StatefulWidget {
  const DeliveriesSearchBar({
    super.key,
    required this.onChanged,
    this.initialQuery = '',
  });

  final ValueChanged<String> onChanged;
  final String initialQuery;

  @override
  State<DeliveriesSearchBar> createState() => _DeliveriesSearchBarState();
}

class _DeliveriesSearchBarState extends State<DeliveriesSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onClear() {
    _controller.clear();
    widget.onChanged('');
    _focusNode.unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onTapOutside: (_) => _focusNode.unfocus(),
        onChanged: (value) {
          widget.onChanged(value);
          setState(() {});
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: context.tr.searchHint,
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: AppDimensions.iconMD,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.cancel_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                  onPressed: _onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMD,
            vertical: AppDimensions.spaceMD,
          ),
        ),
      ),
    );
  }
}
