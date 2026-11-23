import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

class BadgeStatus extends StatelessWidget {
  final String status;

  const BadgeStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'diterbitkan':
      case 'terbit':
        bg = AppColors.successBg;
        textColor = AppColors.successText;
        icon = Icons.check_circle_rounded;
        break;
      case 'perlu revisi':
      case 'revisi':
        bg = AppColors.warningBg;
        textColor = AppColors.warningText;
        icon = Icons.error_rounded;
        break;
      case 'dalam review':
      case 'diajukan':
        bg = AppColors.reviewBg;
        textColor = AppColors.reviewText;
        icon = Icons.hourglass_top_rounded;
        break;
      case 'ditolak':
        bg = AppColors.errorBg;
        textColor = AppColors.errorText;
        icon = Icons.cancel_rounded;
        break;
      default:
        bg = AppColors.draftBg;
        textColor = AppColors.draftText;
        icon = Icons.edit_note_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: AppTypography.labelBold(size: 10, color: textColor),
          ),
        ],
      ),
    );
  }
}
