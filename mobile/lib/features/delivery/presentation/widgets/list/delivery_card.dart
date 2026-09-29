import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/features/delivery/domain/entities/delivery_entity.dart';
import '../../extensions/delivery_ui_extensions.dart';
import '../action_sheets/fail_delivery_sheet.dart';
import 'delivery_address_row.dart';
import 'delivery_card_footer.dart';
import 'delivery_card_header.dart';

/// Complete responsive delivery order card ported from done_app driver offers.
class DeliveryCard extends StatelessWidget {
  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onTap,
    this.onRetrySync,
  });

  final DeliveryEntity delivery;
  final VoidCallback? onTap;
  final VoidCallback? onRetrySync;

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(
      padding: const EdgeInsets.all(AppDimensions.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeliveryCardHeader(
            customerName: delivery.customerName,
            orderNumber: delivery.orderNumber,
            amountDue: delivery.amountDue,
            paymentMethod: delivery.paymentMethod,
          ),
          const SizedBox(height: AppDimensions.spaceMD),
          DeliveryAddressRow(address: delivery.address),
          const SizedBox(height: AppDimensions.spaceMD),
          DeliveryCardFooter(
            customerPhone: delivery.phone,
            deliveryStatus: delivery.status,
            syncStatus: delivery.syncStatus,
            onRetrySync: onRetrySync,
          ),
          if (delivery.isPending) ...[
            const SizedBox(height: AppDimensions.spaceMD),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: delivery.canAct
                          ? () => FailDeliverySheet.show(context, delivery)
                          : null,
                      child: Text(
                        context.tr.markFailed,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spaceSM),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonDark,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: onTap,
                      child: Text(
                        context.tr.viewDetails,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );

    final cardBody = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
          onTap: onTap,
          child: cardContent,
        ),
      ),
    );

    return Dismissible(
      key: ValueKey('dismiss_card_${delivery.id}'),
      direction: delivery.isPending && delivery.canAct
          ? DismissDirection.endToStart
          : DismissDirection.none,
      confirmDismiss: (_) async {
        final res = await FailDeliverySheet.show(context, delivery);
        return res ?? false;
      },
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: AppDimensions.spaceLG),
        decoration: BoxDecoration(
          color: AppColors.failed.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
        child: const Icon(
          Icons.close_rounded,
          color: AppColors.failed,
          size: AppDimensions.iconLG,
        ),
      ),
      child: cardBody,
    );
  }
}
