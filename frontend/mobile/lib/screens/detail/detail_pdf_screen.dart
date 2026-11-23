import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimens.dart';
import '../../models/karya_model.dart';
import '../widgets/badge_status.dart';

class DetailPdfScreen extends StatefulWidget {
  final KaryaModel karya;

  const DetailPdfScreen({super.key, required this.karya});

  @override
  State<DetailPdfScreen> createState() => _DetailPdfScreenState();
}

class _DetailPdfScreenState extends State<DetailPdfScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _downloadCount = 0;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _downloadCount = widget.karya.unduhan;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleDownload() {
    setState(() {
      _isDownloading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _downloadCount += 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Naskah ${widget.karya.judul} berhasil diunduh!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
          'Detail Dokumen Karya',
          style: AppTypography.headingBold(size: 15),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border_rounded, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Row
                  Row(
                    children: [
                      BadgeStatus(status: k.status),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          k.jenisLabel ?? 'Skripsi S-1',
                          style: AppTypography.labelBold(size: 10, color: AppColors.primary),
                        ),
                      ),
                      const Spacer(),
                      if (k.skorTurnitin != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Text(
                            'Turnitin ${k.skorTurnitin}% Lolos',
                            style: AppTypography.labelBold(size: 10, color: AppColors.successText),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    k.judul,
                    style: AppTypography.displayBold(size: 17),
                  ),
                  const SizedBox(height: 12),

                  // Metadata Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        _buildMetaItem('Penulis', '${k.penulis} (NIM: ${k.nim ?? '-'})'),
                        const Divider(height: 14, color: AppColors.borderLight),
                        _buildMetaItem('Dosen Pembimbing', k.pembimbing ?? '-'),
                        const Divider(height: 14, color: AppColors.borderLight),
                        _buildMetaItem('Program Studi', k.prodi),
                        const Divider(height: 14, color: AppColors.borderLight),
                        _buildMetaItem('Tahun / Terbit', '${k.tahun} • ${k.tanggalTerbit}'),
                        if (k.doi != null) ...[
                          const Divider(height: 14, color: AppColors.borderLight),
                          _buildMetaItem('DOI Identifier', k.doi!),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Simulated Embedded PDF Viewer (from Stitch Screen 2)
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.picture_as_pdf_rounded, size: 48, color: Colors.white70),
                              const SizedBox(height: 8),
                              Text(
                                'Pratinjau Naskah Digital PDF',
                                style: AppTypography.headingBold(size: 13, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Watermark Resmi Perpustakaan Aktif',
                                style: AppTypography.caption(size: 11, color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.zoom_in_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text('100%', style: AppTypography.caption(size: 10, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tabs: Abstrak, Sitasi, Riwayat
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2.5,
                    tabs: const [
                      Tab(text: 'Abstrak'),
                      Tab(text: 'Sitasi'),
                      Tab(text: 'Kata Kunci'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 200,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: Abstrak
                        SingleChildScrollView(
                          child: Text(
                            k.abstrak.isNotEmpty
                                ? k.abstrak
                                : 'Abstrak tidak tersedia untuk dokumen karya ilmiah ini.',
                            style: AppTypography.bodyRegular(size: 13),
                          ),
                        ),
                        // Tab 2: Sitasi
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Format APA 7th Edition:', style: AppTypography.labelBold(size: 11)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWhite,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Text(
                                  '${k.penulis}. (${k.tahun}). ${k.judul}. Repositori Immortal Campus. https://doi.org/${k.doi ?? "10.2412/imc.2024.089"}',
                                  style: AppTypography.caption(size: 11, color: AppColors.textPrimary),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Tab 3: Kata Kunci
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: k.kataKunci.map((tag) {
                            return Chip(
                              label: Text('#$tag'),
                              labelStyle: AppTypography.labelBold(size: 10, color: AppColors.primary),
                              backgroundColor: AppColors.primaryLight,
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sticky Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              border: const Border(top: BorderSide(color: AppColors.borderLight)),
              boxShadow: AppDimens.bottomNavShadow,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_downloadCount Unduhan',
                      style: AppTypography.headingBold(size: 14),
                    ),
                    Text(
                      'Ukuran: ${k.fileSize ?? "4.8 MB"}',
                      style: AppTypography.caption(size: 11),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: _isDownloading ? null : _handleDownload,
                    icon: _isDownloading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.download_rounded, size: 18),
                    label: Text(
                      _isDownloading ? 'Mengunduh...' : 'Unduh Dokumen PDF',
                      style: AppTypography.labelBold(size: 13, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: AppTypography.caption(size: 11)),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodyMedium(size: 12, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
