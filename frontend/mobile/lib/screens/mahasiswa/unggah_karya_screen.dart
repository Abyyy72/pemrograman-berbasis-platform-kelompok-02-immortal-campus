import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/app_dimens.dart';
import '../../providers/auth_provider.dart';
import '../../providers/karya_provider.dart';
import '../../models/karya_model.dart';

class UnggahKaryaScreen extends StatefulWidget {
  const UnggahKaryaScreen({super.key});

  @override
  State<UnggahKaryaScreen> createState() => _UnggahKaryaScreenState();
}

class _UnggahKaryaScreenState extends State<UnggahKaryaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _advisorController = TextEditingController();
  final _abstractController = TextEditingController();

  String _selectedJenis = 'Skripsi S-1';
  String _selectedProdi = 'Teknik Informatika';
  bool _isOriginalChecked = false;
  final bool _isFileUploaded = true; // Simulated uploaded file
  final String _fileName = 'Draf_Skripsi_Final_Amanda_v1.pdf';
  bool _isSubmitting = false;

  final List<String> jenisOptions = ['Skripsi S-1', 'Tesis S-2', 'Disertasi S-3', 'Artikel Jurnal'];
  final List<String> prodiOptions = [
    'Teknik Informatika',
    'Sistem Informasi',
    'Teknik Industri',
    'Ilmu Komputer',
    'Manajemen',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _advisorController.dispose();
    _abstractController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_isOriginalChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap centang pernyataan orisinalitas karya!')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final authProv = context.read<AuthProvider>();
      final karyaProv = context.read<KaryaProvider>();

      final newKarya = KaryaModel(
        id: 'karya-new-${DateTime.now().millisecondsSinceEpoch}',
        judul: _titleController.text,
        penulis: authProv.currentUser?.nama ?? 'Amanda Putri Wibowo',
        nim: authProv.currentUser?.nim ?? '2110512034',
        pembimbing: _advisorController.text.isNotEmpty ? _advisorController.text : 'Dr. Eng. Hendra Sucipto, M.T.',
        jenis: _selectedJenis.toLowerCase().contains('tesis') ? 'tesis' : 'skripsi',
        jenisLabel: _selectedJenis,
        prodi: _selectedProdi,
        tahun: DateTime.now().year,
        abstrak: _abstractController.text,
        kataKunci: ['Informatika', 'Riset Ilmiah', 'Repositori'],
        unduhan: 0,
        sitasi: 0,
        status: 'Diajukan',
        tanggalTerbit: 'Hari ini',
        fileSize: '5.4 MB',
        skorTurnitin: 12,
      );

      karyaProv.addKarya(newKarya);

      setState(() => _isSubmitting = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Naskah berhasil diajukan ke antrean kurator!'),
          backgroundColor: AppColors.success,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
          'Unggah Naskah Ilmiah',
          style: AppTypography.displayBold(size: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.pagePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stepper Pill (from Stitch Screen 7)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Format berkas wajib PDF/A, ukuran maks 20 MB, dan telah disahkan pembimbing.',
                        style: AppTypography.caption(size: 11, color: AppColors.primaryDark),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // File Dropzone Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppDimens.radiusCard),
                  border: Border.all(
                    color: _isFileUploaded ? AppColors.primary : AppColors.borderLight,
                    width: _isFileUploaded ? 1.5 : 1,
                  ),
                ),
                child: _isFileUploaded
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _fileName,
                                      style: AppTypography.headingBold(size: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text('6.4 MB • PDF/A Terverifikasi', style: AppTypography.caption(size: 11)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle_rounded, color: AppColors.success),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          const Icon(Icons.cloud_upload_outlined, size: 40, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text('Pilih Berkas PDF Naskah', style: AppTypography.headingBold(size: 14)),
                          const SizedBox(height: 4),
                          Text('Ketuk di sini untuk memilih dokumen dari HP', style: AppTypography.caption(size: 11)),
                        ],
                      ),
              ),
              const SizedBox(height: 18),

              // Jenis Publikasi Chips
              Text('Jenis Karya Ilmiah', style: AppTypography.headingBold(size: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: jenisOptions.map((opt) {
                  final isSelected = _selectedJenis == opt;
                  return ChoiceChip(
                    label: Text(opt),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedJenis = opt),
                    labelStyle: AppTypography.labelBold(
                      size: 11,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surfaceWhite,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Title Field
              Text('Judul Lengkap Naskah', style: AppTypography.headingBold(size: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                maxLines: 2,
                validator: (v) => (v == null || v.isEmpty) ? 'Judul naskah wajib diisi' : null,
                decoration: InputDecoration(
                  hintText: 'Masukkan judul naskah skripsi / tugas akhir sesuai lembar pengesahan...',
                  hintStyle: AppTypography.caption(size: 12),
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Program Studi Dropdown
              Text('Program Studi', style: AppTypography.headingBold(size: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedProdi,
                items: prodiOptions.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                onChanged: (val) => setState(() => _selectedProdi = val ?? _selectedProdi),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Advisor Field
              Text('Dosen Pembimbing Utama', style: AppTypography.headingBold(size: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _advisorController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Dr. Eng. Hendra Sucipto, M.T.',
                  hintStyle: AppTypography.caption(size: 12),
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Abstract Field
              Text('Abstrak Naskah', style: AppTypography.headingBold(size: 13)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _abstractController,
                maxLines: 4,
                validator: (v) => (v == null || v.isEmpty) ? 'Abstrak wajib diisi' : null,
                decoration: InputDecoration(
                  hintText: 'Salin teks ringkasan/abstrak naskah karya ilmiah Anda di sini...',
                  hintStyle: AppTypography.caption(size: 12),
                  filled: true,
                  fillColor: AppColors.surfaceWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.borderLight),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Integrity Agreement Checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _isOriginalChecked,
                onChanged: (val) => setState(() => _isOriginalChecked = val ?? false),
                title: Text(
                  'Saya menyatakan naskah ini adalah karya orisinal bebas dari plagiasi dan mematuhi etika akademik kampus.',
                  style: AppTypography.caption(size: 11, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusButton)),
                  ),
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text('Ajukan Naskah ke Kurator', style: AppTypography.labelBold(size: 14, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
