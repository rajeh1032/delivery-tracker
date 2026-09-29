import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/components/bottom_sheet_scaffold.dart';
import 'package:delivery_tracker/core/components/pill_button.dart';
import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/helpers/snackbar_utils.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/delivery_action/delivery_action_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubit/delivery_action/delivery_action_state.dart';
import 'failure_reason_dropdown.dart';
import 'note_field.dart';

/// Modal bottom sheet allowing the courier to record a delivery failure.
class FailDeliverySheet extends StatefulWidget {
  final DeliveryEntity delivery;

  const FailDeliverySheet({super.key, required this.delivery});

  /// Displays the bottom sheet with an injected [DeliveryActionCubit].
  static Future<bool?> show(BuildContext context, DeliveryEntity delivery) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusBottomSheet),
        ),
      ),
      builder: (_) => BlocProvider<DeliveryActionCubit>(
        create: (_) => getIt<DeliveryActionCubit>(),
        child: FailDeliverySheet(delivery: delivery),
      ),
    );
  }

  @override
  State<FailDeliverySheet> createState() => _FailDeliverySheetState();
}

class _FailDeliverySheetState extends State<FailDeliverySheet> {
  final _formKey = GlobalKey<FormState>();

  void _handleSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<DeliveryActionCubit>().failDelivery(widget.delivery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DeliveryActionCubit, DeliveryActionState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.of(context).pop(true);
          SnackBarUtils.showWarning(
            context,
            context.tr.deliveryFailedLocally,
          );
        } else if (state.isFailure && state.errorMessage != null) {
          SnackBarUtils.showError(context, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<DeliveryActionCubit>();

        return PopScope(
          canPop: !state.isSubmitting,
          child: BottomSheetScaffold(
            title: context.tr.markFailed,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FailureReasonDropdown(
                    value: state.reason,
                    onChanged: (reason) {
                      if (reason != null) {
                        cubit.reasonChanged(reason);
                      }
                    },
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  NoteField(
                    onChanged: cubit.noteChanged,
                  ),
                  const SizedBox(height: AppDimensions.spaceLG),
                  PillButton(
                    text: context.tr.confirmFailure,
                    backgroundColor: AppColors.primary,
                    isLoading: state.isSubmitting,
                    icon: const Icon(
                      Icons.highlight_off,
                      size: AppDimensions.iconMD,
                      color: Colors.white,
                    ),
                    onPressed: () => _handleSubmit(context),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
