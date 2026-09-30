import 'package:flutter/material.dart';
import 'package:delivery_tracker/config/theme/app_dimensions.dart';
import 'package:delivery_tracker/config/theme/colors.dart';
import 'package:delivery_tracker/core/extensions/context_extensions.dart';
import 'package:delivery_tracker/core/utils/enums.dart';
import 'details_metadata_row.dart';
import 'details_proof_thumbnail.dart';

/// Card showing delivery resolution metadata (recipient, failure reason, note, photo proof).
class DetailsNoteCard extends StatelessWidget {
  final String? recipientName;
  final FailureReason? failureReason;
  final String? note;
  final String? proofUrl;

  const DetailsNoteCard({
    super.key,
    this.recipientName,
    this.failureReason,
    this.note,
    this.proofUrl,
  });

  String _resolveFailureReason(BuildContext context, FailureReason reason) {
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
    final hasRecipient =
        recipientName != null && recipientName!.trim().isNotEmpty;
    final hasReason = failureReason != null;
    final hasNote = note != null && note!.trim().isNotEmpty;
    final hasProof = proofUrl != null && proofUrl!.trim().isNotEmpty;

    if (!hasRecipient && !hasReason && !hasNote && !hasProof) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spaceLG),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXXL),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasRecipient) ...[
            DetailsMetadataRow(
              icon: Icons.person_outline,
              label: context.tr.deliveredBy,
              value: recipientName!,
              valueColor: AppColors.synced,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
          ],
          if (hasReason) ...[
            DetailsMetadataRow(
              icon: Icons.error_outline,
              label: context.tr.failureReasonLabel,
              value: _resolveFailureReason(context, failureReason!),
              valueColor: AppColors.failed,
            ),
            const SizedBox(height: AppDimensions.spaceMD),
          ],
          if (hasNote) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.spaceMD),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.format_quote_rounded,
                    size: AppDimensions.iconSM,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: AppDimensions.spaceXS),
                  Expanded(
                    child: Text(
                      note!,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hasProof) const SizedBox(height: AppDimensions.spaceMD),
          ],
          if (hasProof) ...[
            Text(
              context.tr.photoTitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: AppDimensions.spaceSM),
            DetailsProofThumbnail(proofUrl: proofUrl!),
          ],
        ],
      ),
    );
  }
}
