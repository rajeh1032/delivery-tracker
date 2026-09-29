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
import 'package:delivery_tracker/features/delivery/presentation/cubits/complete_delivery/complete_delivery_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/complete_delivery/complete_delivery_state.dart';
import 'image_source_sheet.dart';
import 'note_field.dart';
import 'photo_proof_picker.dart';
import 'recipient_name_field.dart';

/// Modal bottom sheet allowing the courier to record a successful delivery.
class CompleteDeliverySheet extends StatefulWidget {
  final DeliveryEntity delivery;

  const CompleteDeliverySheet({super.key, required this.delivery});

  /// Displays the bottom sheet with an injected [CompleteDeliveryCubit].
  static Future<bool?> show(BuildContext context, DeliveryEntity delivery) {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => BlocProvider<CompleteDeliveryCubit>(
        create: (_) => getIt<CompleteDeliveryCubit>(),
        child: CompleteDeliverySheet(delivery: delivery),
      ),
    );
  }

  @override
  State<CompleteDeliverySheet> createState() => _CompleteDeliverySheetState();
}

class _CompleteDeliverySheetState extends State<CompleteDeliverySheet> {
  final _formKey = GlobalKey<FormState>();

  Future<void> _handlePickPhoto(BuildContext context) async {
    final source = await ImageSourceSheet.show(context);
    if (source != null && context.mounted) {
      await context.read<CompleteDeliveryCubit>().pickPhoto(source);
    }
  }

  void _handleSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<CompleteDeliveryCubit>().confirm(widget.delivery);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CompleteDeliveryCubit, CompleteDeliveryState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.of(context).pop(true);
          SnackBarUtils.showSuccess(
            context,
            context.tr.deliveryCompletedLocally,
          );
        } else if (state.isFailure && state.submissionError != null) {
          SnackBarUtils.showError(context, state.submissionError!);
        }
      },
      builder: (context, state) {
        final cubit = context.read<CompleteDeliveryCubit>();

        return PopScope(
          canPop: !state.isSubmitting,
          child: BottomSheetScaffold(
            title: context.tr.markDelivered,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RecipientNameField(
                    onChanged: cubit.recipientNameChanged,
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  NoteField(
                    onChanged: cubit.noteChanged,
                  ),
                  const SizedBox(height: AppDimensions.spaceMD),
                  PhotoProofPicker(
                    photoPath: state.photoPath,
                    isLoading: state.isPickingPhoto,
                    error: state.photoError,
                    onPickPhoto: () => _handlePickPhoto(context),
                    onRemovePhoto: cubit.removePhoto,
                  ),
                  const SizedBox(height: AppDimensions.spaceLG),
                  PillButton(
                    text: context.tr.confirmDelivery,
                    backgroundColor: AppColors.synced,
                    isLoading: state.isSubmitting,
                    icon: const Icon(
                      Icons.check_circle_outline,
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
