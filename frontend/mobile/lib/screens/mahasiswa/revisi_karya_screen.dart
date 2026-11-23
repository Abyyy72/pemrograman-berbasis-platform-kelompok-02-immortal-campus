import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimens.dart';
import '../../providers/karya_provider.dart';
import '../../models/karya_model.dart';

class RevisiKaryaScreen extends StatefulWidget {
  final KaryaModel karya;

  const RevisiKaryaScreen({super.key, required this.karya});

  @override
  State<RevisiKaryaScreen> createState() => _RevisiKaryaScreenState();
}

class _RevisiKaryaScreenState extends State<RevisiKaryaScreen> {
  final _responseController = TextEditingController();
  bool _checkLembarPengesahan = true;
  bool _checkFormatAbstrak = true;
  bool _checkSitasi = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _responseController.dispose();
    super.dispose();
  }

  void _handleSubmitRevision() {
    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      context.read<KaryaProvider>().submitRevision(
            widget.karya.id,
            _responseController.text,
          );

      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisi naskah berhasil dikirim ulang ke Kurator!'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.karya;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Perbaikan & Revisi Karya',
          style: AppTypography.displayBold(size: 16),
        ),
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
            // Status Header
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningBg,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warningText, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('STATUS: PERLU REVISI', style: AppTypography.labelBold(size: 12, color: AppColors.warningText)),
                        Text('Tenggat waktu perbaikan: 8 hari kalender', style: AppTypography.caption(size: 11)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Curator Note Card (from Stitch Screen 6)
            Container(
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
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryLight,
                        child: const Icon(Icons.school_rounded, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Catatan Resmi Kurator', style: AppTypography.headingBold(size: 13)),
                          Text('Pustakawan UPT Perpustakaan', style: AppTypography.caption(size: 10)),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 18, color: AppColors.borderLight),
                  Text(
                    k.catatanRevisi ??
                        '1. Lampirkan lembar pengesahan TTE Dekan resmi.\n2. Tambahkan abstrak bahasa Inggris.\n3. Sesuaikan format sitasi APA edisi ke-7.',
                    style: AppTypography.bodyRegular(size: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Checklist Mandiri
            Text('Checklist Verifikasi Mandiri (2/3)', style: AppTypography.headingBold(size: 14)),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: _checkLembarPengesahan,
                    onChanged: (v) => setState(() => _checkLembarPengesahan = v ?? false),
                    title: Text('Lembar pengesahan bertanda tangan basah / TTE tersemat', style: AppTypography.bodyMedium(size: 12)),
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  CheckboxListTile(
                    value: _checkFormatAbstrak,
                    onChanged: (v) => setState(() => _checkFormatAbstrak = v ?? false),
                    title: Text('Abstrak bahasa Inggris telah disertakan', style: AppTypography.bodyMedium(size: 12)),
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  CheckboxListTile(
                    value: _checkSitasi,
                    onChanged: (v) => setState(() => _checkSitasi = v ?? false),
                    title: Text('Daftar pustaka disesuaikan standar APA 7th Edition', style: AppTypography.bodyMedium(size: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Upload Revised PDF Card
            Text('Berkas PDF Pengganti (Versi 1.1)', style: AppTypography.headingBold(size: 14)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Draf_Revisi_Final_Amanda_v1.1.pdf', style: AppTypography.headingBold(size: 12)),
                        Text('Baru diunggah • 6.8 MB • TTE Terverifikasi', style: AppTypography.caption(size: 10, color: AppColors.successText)),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Ganti', style: AppTypography.labelBold(size: 11, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Response Text Field
            Text('Tanggapan Penulis kepada Kurator', style: AppTypography.headingBold(size: 14)),
            const SizedBox(height: 6),
            TextField(
              controller: _responseController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Jelaskan butir revisi yang telah Anda perbaiki...',
                hintStyle: AppTypography.caption(size: 12),
                filled: true,
                fillColor: AppColors.surfaceWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warningText,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusButton)),
                ),
                onPressed: _isSubmitting ? null : _handleSubmitRevision,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Kirim Ulang Revisi ke Kurator', style: AppTypography.labelBold(size: 14, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
