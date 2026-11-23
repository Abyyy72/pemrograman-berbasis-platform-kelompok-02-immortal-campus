import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimens.dart';
import '../../providers/admin_provider.dart';

class KelolaAkunAdminScreen extends StatefulWidget {
  const KelolaAkunAdminScreen({super.key});

  @override
  State<KelolaAkunAdminScreen> createState() => _KelolaAkunAdminScreenState();
}

class _KelolaAkunAdminScreenState extends State<KelolaAkunAdminScreen> {
  String _selectedRoleFilter = 'Semua';

  void _openAddKuratorModal(BuildContext context) {
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    final nipController = TextEditingController();
    final prodiController = TextEditingController(text: 'UPT Perpustakaan');

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
              Text('Tambah Akun Kurator Baru', style: AppTypography.headingBold(size: 16)),
              const SizedBox(height: 12),
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap & Gelar'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Alamat Email Institusi (@campus.ac.id)'),
              ),
              TextField(
                controller: nipController,
                decoration: const InputDecoration(labelText: 'NIP / NIDN Kurator'),
              ),
              TextField(
                controller: prodiController,
                decoration: const InputDecoration(labelText: 'Unit / Program Studi'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () {
                    if (namaController.text.isNotEmpty && emailController.text.isNotEmpty) {
                      context.read<AdminProvider>().addKurator(
                            nama: namaController.text,
                            email: emailController.text,
                            nip: nipController.text,
                            prodi: prodiController.text,
                          );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Akun Kurator berhasil didaftarkan!')),
                      );
                    }
                  },
                  child: Text('Simpan Akun Kurator', style: AppTypography.labelBold(size: 13, color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminProv = context.watch<AdminProvider>();
    final users = adminProv.users.where((u) {
      if (_selectedRoleFilter == 'Kurator') return u.isKurator;
      if (_selectedRoleFilter == 'Penulis') return u.isPenulis;
      if (_selectedRoleFilter == 'Admin') return u.isAdmin;
      return true;
    }).toList();

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
          'Kelola Akun & Hak Akses',
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
            // Admin Hero Storage Card (from Stitch Screen 8)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppDimens.radiusCard),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Repositori Storage Quota', style: AppTypography.caption(size: 11, color: Colors.white70)),
                      Text('48.2 GB / 100 GB', style: AppTypography.labelBold(size: 11, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const LinearProgressIndicator(
                      value: 0.48,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryItem('Total Akun', '${adminProv.totalUsers}'),
                      _buildSummaryItem('Kurator', '${adminProv.totalKurator}'),
                      _buildSummaryItem('Penulis', '${adminProv.totalPenulis}'),
                      _buildSummaryItem('Admin', '${adminProv.totalAdmin}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Button: Add Curator
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusButton)),
                ),
                onPressed: () => _openAddKuratorModal(context),
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: Text('+ Tambah Akun Kurator Baru', style: AppTypography.labelBold(size: 13, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),

            // Role Filter Chips
            Row(
              children: ['Semua', 'Kurator', 'Penulis', 'Admin'].map((role) {
                final isSelected = _selectedRoleFilter == role;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(role),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedRoleFilter = role),
                    labelStyle: AppTypography.labelBold(
                      size: 11,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceWhite,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),

            // User Cards List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: u.isAdmin
                            ? const Color(0xFFFEE2E2)
                            : (u.isKurator ? AppColors.primaryLight : const Color(0xFFF0FDF4)),
                        child: Icon(
                          u.isAdmin
                              ? Icons.admin_panel_settings_rounded
                              : (u.isKurator ? Icons.verified_user_rounded : Icons.person_rounded),
                          size: 20,
                          color: u.isAdmin ? AppColors.error : (u.isKurator ? AppColors.primary : AppColors.success),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(u.nama, style: AppTypography.headingBold(size: 13)),
                            Text(u.email, style: AppTypography.caption(size: 11)),
                            Text(
                              '${u.role.toUpperCase()} • ${u.nip ?? u.nim ?? "-"}',
                              style: AppTypography.labelBold(size: 9, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (val) {
                          if (val == 'delete') {
                            adminProv.deleteUser(u.id);
                          }
                        },
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: 'reset', child: Text('Reset Password')),
                          const PopupMenuItem(value: 'delete', child: Text('Hapus Akun', style: TextStyle(color: Colors.red))),
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

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: AppTypography.headingBold(size: 16, color: Colors.white)),
        Text(label, style: AppTypography.caption(size: 10, color: Colors.white60)),
      ],
    );
  }
}
