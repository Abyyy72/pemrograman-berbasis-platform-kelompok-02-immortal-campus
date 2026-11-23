import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimens.dart';
import '../../models/karya_model.dart';
import 'badge_status.dart';

class KaryaCard extends StatelessWidget {
  final KaryaModel karya;
  final VoidCallback onTap;

  const KaryaCard({
    super.key,
    required this.karya,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppDimens.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusCard),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Meta Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        karya.prodi,
                        style: AppTypography.labelBold(size: 10, color: AppColors.primary),
                      ),
                    ),
                    BadgeStatus(status: karya.status),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  karya.judul,
                  style: AppTypography.headingBold(size: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Author & Advisor
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Oleh ${karya.penulis} (${karya.tahun})',
                        style: AppTypography.bodyMedium(size: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Footer Row: Turnitin, Downloads, Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (karya.skorTurnitin != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFBBF7D0)),
                            ),
                            child: Text(
                              'Turnitin ${karya.skorTurnitin}%',
                              style: AppTypography.labelBold(size: 10, color: AppColors.successText),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Row(
                          children: [
                            const Icon(Icons.download_rounded, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 2),
                            Text(
                              '${karya.unduhan}',
                              style: AppTypography.caption(size: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Baca Naskah',
                          style: AppTypography.labelBold(size: 11, color: AppColors.primary),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_forward_rounded, size: 13, color: AppColors.primary),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
