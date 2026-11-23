# Panduan Handoff Desain ke Flutter: Immortal Campus Mobile
**Design System: Academic Modernism**  
Target Platform: Flutter (Android & iOS)  
State Management Sesuai PRD: `Provider` & Paket HTTP / Supabase

---

## 1. Design Tokens (ThemeData & Styles)

### 1.1 Palet Warna (`AppColors`)

```dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accents
  static const Color primary = Color(0xFF0066FF); // Electric Blue Brand
  static const Color primaryDark = Color(0xFF004EC2);
  static const Color primaryLight = Color(0xFFEFF4FF);
  
  // Neutral & Surfaces
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // Status & Badges (Semantik PRD 5.1)
  static const Color success = Color(0xFF10B981); // Diterbitkan / Valid
  static const Color successBg = Color(0xFFECFDF5);
  static const Color successText = Color(0xFF047857);

  static const Color warning = Color(0xFFF59E0B); // Perlu Revisi / Menunggu
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningText = Color(0xFFB45309);

  static const Color review = Color(0xFF0284C7); // Dalam Review / Diajukan
  static const Color reviewBg = Color(0xFFF0F9FF);
  static const Color reviewText = Color(0xFF0369A1);

  static const Color error = Color(0xFFEF4444); // Ditolak
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color errorText = Color(0xFFB91C1C);
}
```

---

### 1.2 Tipografi (`AppTypography`)

> **Catatan Font:**
> - Display / Headlines / Judul Skripsi: Gunakan **Cabinet Grotesk** (`assets/fonts/CabinetGrotesk-Bold.otf`).
> - UI, Body, Form, & Label: Gunakan **Plus Jakarta Sans** (Google Fonts `google_fonts: ^6.1.0`).

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  // Headings - Cabinet Grotesk
  static TextStyle displayBold({double size = 20, Color color = AppColors.textPrimary}) {
    return TextStyle(
      fontFamily: 'Cabinet Grotesk',
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: color,
    );
  }

  // Subheadings & Card Titles
  static TextStyle headingBold({double size = 16, Color color = AppColors.textPrimary}) {
    return TextStyle(
      fontFamily: 'Cabinet Grotesk',
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
      color: color,
    );
  }

  // UI & Body - Plus Jakarta Sans
  static TextStyle bodyMedium({double size = 13, Color color = AppColors.textSecondary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.45,
    );
  }

  static TextStyle bodyRegular({double size = 13, Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w400,
      color: color,
      height: 1.5,
    );
  }

  static TextStyle labelBold({double size = 11, Color color = AppColors.textPrimary}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
      color: color,
    );
  }
}
```

---

### 1.3 Radii & Elevation Tokens

```dart
import 'package:flutter/material.dart';

class AppDimens {
  static const double radiusButton = 10.0;
  static const double radiusCard = 16.0;
  static const double radiusSheet = 24.0;
  static const double pagePadding = 16.0;

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withOpacity(0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}
```

---

## 2. Pemetaan Komponen Layar Mobile (Slicing Guide)

### 2.1 Layar 1: Jelajah Karya Ilmiah (`Mobile - Jelajah Karya Ilmiah`)
- **App Bar**:
  - Logo `Academic Repository` + Tombol Notifikasi + Avatar Profil.
- **Search Header**:
  - `TextField` rounded search bar dengan suffix icon *QR Scan* dan *Filter Slider*.
  - Horisontal `ListView` filter chip (*Semua, Skripsi, Tesis, Jurnal Ilmiah*).
- **Hero KPI Banner**:
  - Gradient container (`0xFF0066FF` ke `0xFF0052CC`) menampilkan `12.450+ Karya Ilmiah Open Access`.
- **Rekomendasi Populer**:
  - Horizontal carousel card naskah berbayang halus dengan thumbnail riset, badge tahun, prodi, dan download badge.
- **Feed Naskah Realtime**:
  - Infinite scroll list kartu karya ilmiah dengan tombol aksi cepat `Buka` (mengarahkan ke Layar Detail).

---

### 2.2 Layar 2: Detail Karya & PDF Reader (`Mobile - Detail Karya & Pembaca PDF`)
- **Navigasi Stack**:
  - `AppBar` minimalis dengan tombol `Back`, `Bookmark`, dan `Share`.
- **Header Karya**:
  - Badge jenis & status naskah (`Skripsi S1 • Terverifikasi & Diterbitkan`).
  - Judul besar (`displayBold`), metadata penulis, NIM, dosen pembimbing, dan badge skor Turnitin (`14% Lolos`).
- **Pratinjau PDF Embedded**:
  - Widget pratinjau halaman PDF resmi dengan watermark universitas dan kontrol zoom slider.
- **Segmented Tab**:
  - `TabBar` beralih antara: `Abstrak` (dwibahasa Indonesia & English), `Metadata & Sitasi`, dan `Riwayat Unduhan`.
- **Bottom Fixed CTA**:
  - Sticky bottom container dengan tombol aksi `Unduh (4.8 MB)` dan `Layar Penuh` (mencatat log unduhan ke API).

---

### 2.3 Layar 3: Karya Saya / Dashboard Mahasiswa (`Mobile - Karya Saya (Dashboard Mahasiswa)`)
- **Profil Kartu Penulis**:
  - Foto profil mahasiswa, nama, status *Penulis Aktif*, NIM, dan grafik analitik jangkauan unduhan (`1.729 Unduhan`).
- **CTA Hero Button**:
  - Tombol aksi utama **"+ Unggah Naskah Baru (PDF)"** yang membuka pemilih berkas dokumen mobile.
- **Notifikasi Revisi Prioritas**:
  - Banner oranye `AppColors.warningBg` saat ada naskah yang membutuhkan perbaikan kurator.
- **Filter Status Pengajuan**:
  - Segmented pills: `Semua (3)`, `Perlu Revisi (1)`, `Dalam Review (1)`.
- **Kartu Naskah Penulis**:
  - Menampilkan badge status, deadline perbaikan, tombol `Riwayat Catatan` dan `Edit Naskah`.

---

### 2.4 Layar 4: Panel Kurator & Admin Sistem (`Mobile - Panel Kurator & Admin Sistem`)
- **Header Staf**:
  - Profil kurator/admin dengan chip versi sistem repositori.
- **Role Switcher**:
  - Segmented toggle **[ Mode Kurasi ]** vs **[ Mode Admin Sistem ]**.
- **Ringkasan KPI Antrean**:
  - Grid 2x2: *Antrean Validasi (18)*, *Perlu Revisi (4)*, *Terbit Bulan Ini (142)*, *Integritas OAI (99.4%)*.
- **Quick Review Swipe Card**:
  - Naskah antrean aktif dengan hasil verifikasi otomatis (Turnitin 11%, format PDF/A, TTE Pembimbing).
  - Aksi instan: `Setujui & Terbitkan` (Hijau) dan `Minta Revisi` (Oranye dengan input modal catatan).

---

### 2.5 Layar 5: Unggah Karya Ilmiah (`Mobile - Unggah Karya Ilmiah`)
- **Navigasi Stack & Stepper**:
  - `AppBar` dengan tombol `Back` dan judul *Upload Form*.
  - Progress bar langkah (`Langkah 1/2 • 50% Selesai`) dengan indikator *1. Berkas & Data Inti* dan *2. Metadata Lanjutan*.
- **Dropzone Berkas PDF**:
  - Container dashed-border dengan `file_picker` untuk memilih PDF (maks. 20 MB, standar ISO 19005).
  - Preview file terpilih (`Draf_Skripsi_Final_Amanda_v1.pdf`, `6.4 MB`, badge `Tervalidasi PDF/A`) dan tombol hapus.
- **Formulir Spesifikasi Naskah**:
  - `TextFormField` judul karya ilmiah dengan character counter (`84 / 200 karakter`).
  - Grid `ChoiceChip` jenis publikasi (*Skripsi S1, Tesis S2, Disertasi S3, Artikel Jurnal*).
  - `DropdownButtonFormField` Program Studi & Unit Akademik, serta *DatePicker* untuk Tahun Akademik dan Tanggal Sidang.
- **Afiliasi & Kata Kunci**:
  - Card otomatis Penulis Utama (read-only) dan input/autocomplete Dosen Pembimbing I & II.
  - `Wrap` chips kata kunci (`#WebServices`, `#Repository`) dengan tombol `+ Tambah Kata Kunci`.
- **Pernyataan Integritas & Sticky Bottom Bar**:
  - `CheckboxListTile` pernyataan karya orisinal bebas plagiasi.
  - Sticky bottom container dengan tombol `Simpan Draf` (Outlined) dan `Lanjut ke Kurator` (Primary Elevated).

---

### 2.6 Layar 6: Perbaikan & Revisi Karya (`Mobile - Perbaikan & Revisi Karya`)
- **Navigasi Stack & Status Header**:
  - `AppBar` dengan tombol `Back` dan judul *Revision Screen*.
  - Baris metadata referensi (`Ref: TA-2024-TI-089`) dan badge status `PERLU REVISI` (`AppColors.warningBg`).
- **Kartu Catatan Resmi Kurator**:
  - Profil kurator (*Drs. Supriyadi, M.Lib*) dengan badge tenggat waktu (`8 Hari Lagi`).
  - List bernomor catatan perbaikan resmi (1. Lembar Pengesahan, 2. Format Abstrak, 3. Kata Kunci).
- **Checklist Verifikasi Mandiri Penulis**:
  - Progress pill (`2/3 Selesai`).
  - Daftar `CheckboxListTile` interaktif untuk memverifikasi butir perbaikan sebelum dikirim ulang.
- **Dokumen Pengganti & Tanggapan**:
  - Card berkas revisi (`Versi 1.1`, badge `Baru Diunggah`, `TTE Dekan Terverifikasi`) dengan tombol `Pratinjau PDF` dan `Ganti dengan Berkas PDF Lain`.
  - `TextFormField` multi-line untuk tanggapan penulis kepada kurator (maks. 500 kata).
- **Sticky Bottom Action**:
  - Tombol `Draf` (Outlined) dan `Kirim Ulang Revisi` (Primary / Warning Elevated).

---

### 2.7 Layar 7: Kelola Akun & Hak Akses Admin (`Mobile - Kelola Akun & Hak Akses Admin`)
- **Navigasi Stack & Hero Ringkasan Sistem**:
  - `AppBar` dengan tombol `Back` dan judul *Mode Admin Kelola Pengguna*.
  - Gradient card biru (`AppColors.primary`) menampilkan total akun terdaftar (`2.840 Pengguna Aktif`), breakdown 4 kolom (*2.710 Mhs, 112 Dosen, 15 Kurator, 3 Admin*), serta `LinearProgressIndicator` kuota *Supabase Storage* (`48.2 GB / 100 GB`).
- **Segmented Sub-Navigation & Aksi Cepat**:
  - `TabBar` 3 tab: *Akun & Peran*, *Master Prodi*, dan *Log Audit*.
  - Tombol utama `+ Tambah Kurator Baru` dan tombol ekspor data.
  - `TextField` pencarian akun (Nama, NIM, NIDN, Email) + horizontal filter chips (*Semua, Kurator, Pengajuan, Dosen*).
- **Daftar Kartu Pengguna & Persetujuan**:
  - Kartu akun dengan avatar/inisial, badge peran, metadata NIDN/NIM/NIP, serta tombol aksi kontekstual (`Reset Akses`, `Edit Hak`, `Detail Profil`).
  - Kartu highlight kuning (`AppColors.warningBg`) untuk pengajuan hak kurator baru dengan tombol aksi instan `Setujui Kurator` (Hijau) dan `Tolak` (Merah).
- **Master Kategori Naskah & Audit Trail**:
  - Card konfigurasi jenis naskah aktif (*Skripsi, Tesis, Disertasi, Jurnal, KP, Prosiding*) dan footer tautan `Lihat Log` audit real-time.

---

## 3. Struktur Folder Flutter Rekomendasi

```
lib/
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── typography.dart
│   │   └── dimensions.dart
│   ├── network/
│   │   └── api_client.dart          // REST API Express backend
│   └── theme/
│       └── app_theme.dart
├── models/
│   ├── karya_model.dart             // Skripsi, Tesis, Jurnal
│   ├── review_model.dart            // Catatan kurasi & checklist
│   └── user_model.dart              // Penulis, Kurator, Admin
├── providers/
│   ├── auth_provider.dart
│   ├── karya_provider.dart
│   ├── review_provider.dart
│   └── admin_provider.dart          // Manajemen akun, peran & storage
└── screens/
    ├── home/
    │   └── jelajah_karya_screen.dart
    ├── detail/
    │   └── detail_pdf_screen.dart
    ├── mahasiswa/
    │   ├── karya_saya_screen.dart
    │   ├── unggah_karya_screen.dart
    │   └── revisi_karya_screen.dart
    ├── kurator/
    │   └── panel_kurator_screen.dart
    ├── admin/
    │   └── kelola_akun_admin_screen.dart
    └── widgets/
        ├── badge_status.dart
        ├── karya_card.dart
        └── custom_bottom_nav.dart
```
