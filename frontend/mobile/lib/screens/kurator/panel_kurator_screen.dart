import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimens.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karya_provider.dart';
import '../../models/karya_model.dart';
import '../widgets/badge_status.dart';
import '../detail/detail_pdf_screen.dart';
import '../admin/kelola_akun_admin_screen.dart';

class PanelKuratorScreen extends StatefulWidget {
  const PanelKuratorScreen({super.key});

  @override
  State<PanelKuratorScreen> createState() => _PanelKuratorScreenState();
}

class _PanelKuratorScreenState extends State<PanelKuratorScreen> {
  void _openDecisionModal(BuildContext context, KaryaModel karya) {
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(18, 20, 18, MediaQuery.of(ctx).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.radiusSheet)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Keputusan Kurasi Naskah', style: AppTypography.headingBold(size: 16)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                karya.judul,
                style: AppTypography.bodyMedium(size: 12, color: AppColors.textPrimary),
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              TextField(
                controller: noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Tuliskan catatan perbaikan atau alasan keputusan kurator...',
                  hintStyle: AppTypography.caption(size: 12),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.warningText),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        context.read<KaryaProvider>().updateStatus(
                              karya.id,
                              'Perlu Revisi',
                              notes: noteController.text.isNotEmpty ? noteController.text : 'Perlu perbaikan kelengkapan berkas.',
                            );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Status naskah diubah ke PERLU REVISI')),
                        );
                      },
                      child: Text('Minta Revisi', style: AppTypography.labelBold(size: 13, color: AppColors.warningText)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        context.read<KaryaProvider>().updateStatus(karya.id, 'Diterbitkan');
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Naskah DITERBITKAN secara resmi!')),
                        );
                      },
                      child: Text('Setujui & Terbitkan', style: AppTypography.labelBold(size: 13, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final karyaProv = context.watch<KaryaProvider>();
    final queue = karyaProv.curationQueue;
    final user = authProv.currentUser;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        title: Text(
          'Panel Kurasi & Review',
          style: AppTypography.displayBold(size: 17),
        ),
        actions: [
          if (user?.isAdmin == true)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KelolaAkunAdminScreen()),
                );
              },
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
            // KPI Summary Grid (from Stitch Screen 3)
            Row(
              children: [
                Expanded(child: _buildKpiCard('Antrean Validasi', '${queue.length}', Icons.hourglass_empty_rounded, AppColors.review)),
                const SizedBox(width: 10),
                Expanded(child: _buildKpiCard('Perlu Revisi', '1', Icons.edit_note_rounded, AppColors.warning)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _buildKpiCard('Terbit Bulan Ini', '142', Icons.task_alt_rounded, AppColors.success)),
                const SizedBox(width: 10),
                Expanded(child: _buildKpiCard('Integritas OAI', '99.4%', Icons.verified_rounded, AppColors.primary)),
              ],
            ),
            const SizedBox(height: 20),

            // Queue Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Antrean Naskah Masuk (${queue.length})',
                  style: AppTypography.headingBold(size: 15),
                ),
                Text(
                  'Prioritas Validasi',
                  style: AppTypography.labelBold(size: 11, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Queue List
            if (queue.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.done_all_rounded, size: 48, color: AppColors.success),
                    const SizedBox(height: 10),
                    Text('Antrean Kurasi Bersih', style: AppTypography.headingBold(size: 14)),
                    const SizedBox(height: 4),
                    Text('Semua pengajuan naskah mahasiswa telah diproses.', style: AppTypography.caption(size: 12)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: queue.length,
                itemBuilder: (context, index) {
                  final k = queue[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
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
                            if (k.skorTurnitin != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Turnitin ${k.skorTurnitin}% Lolos',
                                  style: AppTypography.labelBold(size: 10, color: AppColors.successText),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          k.judul,
                          style: AppTypography.headingBold(size: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Oleh ${k.penulis} (${k.prodi})',
                          style: AppTypography.caption(size: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => DetailPdfScreen(karya: k)),
                                  );
                                },
                                child: Text('Periksa PDF', style: AppTypography.labelBold(size: 12)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () => _openDecisionModal(context, k),
                                child: Text('Keputusan', style: AppTypography.labelBold(size: 12, color: Colors.white)),
                              ),
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

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: AppTypography.headingBold(size: 16)),
                Text(label, style: AppTypography.caption(size: 10), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
