import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'delivery_customer_summary.dart';
import 'delivery_fare_summary.dart';

/// Header of the delivery card containing customer summary and fare summary.
class DeliveryCardHeader extends StatelessWidget {
  const DeliveryCardHeader({
    super.key,
    required this.customerName,
    required this.orderNumber,
    required this.amountDue,
    required this.paymentMethod,
  });

  final String customerName;
  final String orderNumber;
  final double amountDue;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DeliveryCustomerSummary(
                customerName: customerName,
                orderNumber: orderNumber,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSM),
            DeliveryFareSummary(
              amountDue: amountDue,
              paymentMethod: paymentMethod,
              isCompact: isCompact,
            ),
          ],
        );
      },
    );
  }
}
