import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/di/di.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/delivery_details/delivery_details_cubit.dart';
import 'package:delivery_tracker/features/delivery/presentation/cubits/delivery_details/delivery_details_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/action_sheets/complete_delivery_sheet.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/action_sheets/fail_delivery_sheet.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/delivery_details_error_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/delivery_details_not_found_state.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/delivery_details_skeleton.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_actions_bar.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_address_card.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_amount_card.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_customer_card.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_map_header.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_note_card.dart';
import 'package:delivery_tracker/features/delivery/presentation/widgets/details/details_status_chips.dart';

/// Full delivery details screen presenting order data and status transitions.
class DeliveryDetailsPage extends StatelessWidget {
  final int deliveryId;
  final DeliveryEntity? preloaded;

  const DeliveryDetailsPage({
    super.key,
    required this.deliveryId,
    this.preloaded,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DeliveryDetailsCubit>(
      create: (_) => getIt<DeliveryDetailsCubit>()
        ..loadDelivery(deliveryId, preloaded: preloaded),
      child: const _DeliveryDetailsView(),
    );
  }
}

class _DeliveryDetailsView extends StatelessWidget {
  const _DeliveryDetailsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DeliveryDetailsCubit, DeliveryDetailsState>(
        builder: (context, state) {
          if (state.isLoading && state.delivery == null) {
            return const DeliveryDetailsSkeleton();
          }

          if (state.isNotFound && state.delivery == null) {
            return DeliveryDetailsNotFoundState(
              onBack: () => Navigator.maybePop(context),
            );
          }

          if (state.isError && state.delivery == null) {
            final cubit = context.read<DeliveryDetailsCubit>();
            return DeliveryDetailsErrorState(
              errorMessage: state.errorMessage,
              onRetry: () {
                final id = cubit.state.delivery?.id;
                if (id != null) cubit.loadDelivery(id);
              },
            );
          }

          final delivery = state.delivery;
          if (delivery == null) {
            return const DeliveryDetailsSkeleton();
          }

          return Column(
            children: [
              DetailsMapHeader(
                orderNumber: delivery.orderNumber,
                onBack: () => Navigator.maybePop(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.spaceMD,
                    AppDimensions.spaceMD,
                    AppDimensions.spaceMD,
                    AppDimensions.spaceXL,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DetailsStatusChips(
                        deliveryStatus: delivery.status,
                        syncStatus: delivery.syncStatus,
                      ),
                      const SizedBox(height: AppDimensions.spaceMD),
                      DetailsCustomerCard(
                        customerName: delivery.customerName,
                        phone: delivery.phone,
                      ),
                      const SizedBox(height: AppDimensions.spaceMD),
                      DetailsAddressCard(address: delivery.address),
                      const SizedBox(height: AppDimensions.spaceMD),
                      DetailsAmountCard(
                        amountDue: delivery.amountDue,
                        paymentMethod: delivery.paymentMethod,
                      ),
                      if (delivery.recipientName != null ||
                          delivery.failureReason != null ||
                          delivery.note != null ||
                          delivery.proofUrl != null) ...[
                        const SizedBox(height: AppDimensions.spaceMD),
                        DetailsNoteCard(
                          recipientName: delivery.recipientName,
                          failureReason: delivery.failureReason,
                          note: delivery.note,
                          proofUrl: delivery.proofUrl,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              DetailsActionsBar(
                delivery: delivery,
                onMarkDelivered: () {
                  CompleteDeliverySheet.show(context, delivery);
                },
                onMarkFailed: () {
                  FailDeliverySheet.show(context, delivery);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
