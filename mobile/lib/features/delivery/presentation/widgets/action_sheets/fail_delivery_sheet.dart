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
import 'package:delivery_tracker/features/delivery/presentation/cubits/fail_delivery/fail_delivery_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/fail_delivery/fail_delivery_state.dart';
import 'failure_reason_dropdown.dart';
import 'note_field.dart';

/// Modal bottom sheet allowing the courier to record a delivery failure.
class FailDeliverySheet extends StatefulWidget {
  final DeliveryEntity delivery;

  const FailDeliverySheet({super.key, required this.delivery});

  /// Displays the bottom sheet with an injected [FailDeliveryCubit].
  static Future<bool?> show(BuildContext context, DeliveryEntity delivery) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider<FailDeliveryCubit>(
        create: (_) => getIt<FailDeliveryCubit>(),
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
      context.read<FailDeliveryCubit>().confirm(widget.delivery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FailDeliveryCubit, FailDeliveryState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.of(context).pop(true);
          SnackBarUtils.showWarning(
            context,
            context.tr.deliveryFailedLocally,
          );
        } else if (state.isFailure && state.submissionError != null) {
          SnackBarUtils.showError(context, state.submissionError!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<FailDeliveryCubit>();

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
                    backgroundColor: AppColors.failed,
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
