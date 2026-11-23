import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimens.dart';
import '../../providers/karya_provider.dart';
import '../../providers/auth_provider.dart';
import '../widgets/karya_card.dart';
import '../detail/detail_pdf_screen.dart';

class JelajahKaryaScreen extends StatefulWidget {
  final VoidCallback onOpenUpload;

  const JelajahKaryaScreen({super.key, required this.onOpenUpload});

  @override
  State<JelajahKaryaScreen> createState() => _JelajahKaryaScreenState();
}

class _JelajahKaryaScreenState extends State<JelajahKaryaScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> prodiFilters = [
    'Semua',
    'Teknik Informatika',
    'Sistem Informasi',
    'Teknik Industri',
    'Ilmu Komputer',
    'Manajemen',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final karyaProv = context.watch<KaryaProvider>();
    final authProv = context.watch<AuthProvider>();
    final items = karyaProv.filteredKaryaList;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => karyaProv.fetchKarya(),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // Top Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.all_inclusive_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'IMMORTAL CAMPUS',
                                style: AppTypography.displayBold(size: 15, color: AppColors.primary),
                              ),
                              Text(
                                'Etalase Digital Ilmiah',
                                style: AppTypography.caption(size: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                            onPressed: () {},
                          ),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryLight,
                            child: Text(
                              authProv.currentUser?.nama.substring(0, 1).toUpperCase() ?? 'G',
                              style: AppTypography.labelBold(size: 12, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Hero Banner (Stitch)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0066FF), Color(0xFF004EC2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF34D399),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Repositori Kampus Terbuka',
                                style: AppTypography.labelBold(size: 10, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '12.450+ Karya Ilmiah\nOpen Access',
                          style: AppTypography.displayBold(size: 19, color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Akses skripsi, tesis, dan jurnal mahasiswa terkurasi perpustakaan kampus.',
                          style: AppTypography.bodyRegular(size: 12, color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search Box
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => karyaProv.setSearchQuery(val),
                    decoration: InputDecoration(
                      hintText: 'Cari judul, topik, penulis, atau kata kunci...',
                      hintStyle: AppTypography.bodyRegular(size: 12, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                karyaProv.setSearchQuery('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.surfaceWhite,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                        borderSide: const BorderSide(color: AppColors.borderLight),
                      ),
                    ),
                  ),
                ),
              ),

              // Horizontal Category Chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 42,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: prodiFilters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final item = prodiFilters[index];
                      final isSelected = karyaProv.selectedProdi == item;
                      return ChoiceChip(
                        label: Text(item),
                        selected: isSelected,
                        onSelected: (_) => karyaProv.setFilterProdi(item),
                        labelStyle: AppTypography.labelBold(
                          size: 11,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceWhite,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.borderLight,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      );
                    },
                  ),
                ),
              ),

              // Section Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Koleksi Karya Ilmiah (${items.length})',
                        style: AppTypography.headingBold(size: 15),
                      ),
                      Text(
                        'Terbaru',
                        style: AppTypography.labelBold(size: 11, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),

              // List of Karya Cards
              if (karyaProv.isLoading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  ),
                )
              else if (items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'Karya ilmiah tidak ditemukan',
                          style: AppTypography.headingBold(size: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Coba ubah kata kunci atau filter program studi.',
                          style: AppTypography.caption(size: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final karya = items[index];
                        return KaryaCard(
                          karya: karya,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailPdfScreen(karya: karya),
                              ),
                            );
                          },
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}
