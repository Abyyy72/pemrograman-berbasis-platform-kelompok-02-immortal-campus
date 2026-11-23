import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimens.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karya_provider.dart';
import '../widgets/badge_status.dart';
import '../detail/detail_pdf_screen.dart';
import 'unggah_karya_screen.dart';
import 'revisi_karya_screen.dart';

class KaryaSayaScreen extends StatefulWidget {
  const KaryaSayaScreen({super.key});

  @override
  State<KaryaSayaScreen> createState() => _KaryaSayaScreenState();
}

class _KaryaSayaScreenState extends State<KaryaSayaScreen> {
  String _activeTab = 'Semua';

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final karyaProv = context.watch<KaryaProvider>();
    final user = authProv.currentUser;

    final myKarya = karyaProv.myWorks.where((k) {
      if (_activeTab == 'Perlu Revisi') return k.status == 'Perlu Revisi';
      if (_activeTab == 'Dalam Review') return k.status == 'Dalam Review' || k.status == 'Diajukan';
      if (_activeTab == 'Diterbitkan') return k.status == 'Diterbitkan';
      return true;
    }).toList();

    // Check if there is revision needed
    final revisionItem = karyaProv.myWorks.firstWhere(
      (k) => k.status == 'Perlu Revisi',
      orElse: () => karyaProv.myWorks.first,
    );
    final hasRevision = karyaProv.myWorks.any((k) => k.status == 'Perlu Revisi');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        title: Text(
          'Karya Saya',
          style: AppTypography.displayBold(size: 17),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Profile Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: AppDimens.cardShadow,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      user?.nama.substring(0, 1).toUpperCase() ?? 'A',
                      style: AppTypography.displayBold(size: 20, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nama ?? 'Amanda Putri Wibowo',
                          style: AppTypography.headingBold(size: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'NIM: ${user?.nim ?? "2110512034"} • ${user?.prodi ?? "Teknik Informatika"}',
                          style: AppTypography.caption(size: 11),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Penulis Aktif',
                                style: AppTypography.labelBold(size: 9, color: AppColors.successText),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '1.720 Total Unduhan',
                              style: AppTypography.caption(size: 10, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Big CTA: Unggah Naskah Baru
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusButton),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UnggahKaryaScreen()),
                  );
                },
                icon: const Icon(Icons.cloud_upload_rounded, size: 20),
                label: Text(
                  '+ Unggah Naskah Baru (PDF)',
                  style: AppTypography.labelBold(size: 14, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority Revision Banner (from Stitch Screen 4)
            if (hasRevision)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.warningText),
                        const SizedBox(width: 8),
                        Text(
                          'Perhatian: Perlu Tindakan Revisi',
                          style: AppTypography.labelBold(size: 12, color: AppColors.warningText),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '8 Hari Lagi',
                            style: AppTypography.labelBold(size: 10, color: AppColors.warningText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      revisionItem.judul,
                      style: AppTypography.headingBold(size: 13, color: AppColors.textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.warningText),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RevisiKaryaScreen(karya: revisionItem),
                            ),
                          );
                        },
                        child: Text(
                          'Buka Catatan Kurator & Perbaiki',
                          style: AppTypography.labelBold(size: 12, color: AppColors.warningText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Segmented Status Filter Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Perlu Revisi', 'Dalam Review', 'Diterbitkan'].map((tab) {
                  final isSelected = _activeTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(tab),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _activeTab = tab),
                      labelStyle: AppTypography.labelBold(
                        size: 11,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.surfaceWhite,
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.borderLight,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Works List
            if (myKarya.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    'Tidak ada naskah pada status ini.',
                    style: AppTypography.caption(size: 12),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: myKarya.length,
                itemBuilder: (context, index) {
                  final k = myKarya[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: AppDimens.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            BadgeStatus(status: k.status),
                            Text(k.tanggalTerbit, style: AppTypography.caption(size: 10)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          k.judul,
                          style: AppTypography.headingBold(size: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pembimbing: ${k.pembimbing ?? "-"}',
                          style: AppTypography.caption(size: 11),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (k.status == 'Perlu Revisi') ...[
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RevisiKaryaScreen(karya: k),
                                    ),
                                  );
                                },
                                child: Text('Revisi Sekarang', style: AppTypography.labelBold(size: 12, color: AppColors.warningText)),
                              ),
                              const SizedBox(width: 8),
                            ],
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryLight,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailPdfScreen(karya: k),
                                  ),
                                );
                              },
                              child: Text('Detail Naskah', style: AppTypography.labelBold(size: 11, color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
