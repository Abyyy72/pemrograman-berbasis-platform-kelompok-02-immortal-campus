# Frontend Web - Immortal Campus

Aplikasi frontend web untuk **Immortal Campus** (Etalase Digital Karya Ilmiah Kampus).

## Tech Stack
- **Framework:** Svelte 5 (Runes: `$state`, `$derived`, `$effect`)
- **Language:** TypeScript
- **Bundler:** Vite
- **Styling:** Tailwind CSS (dengan Design Tokens & Palet dari Stitch Design)
- **Typography:** Plus Jakarta Sans & JetBrains Mono

## Fitur yang Diimplementasikan Sesuai PRD
1. **Beranda & Direktori Terpadu (FR-34):**
   - Showcase karya terkurasi dengan DOI dan lencana verifikasi kurator.
   - Metrik repositori institusi realtime (Total karya, unduhan, sivitas akademika).
2. **Pencarian & Penjelajahan Publik (FR-30, FR-31, FR-32):**
   - Pencarian real-time berdasarkan judul, penulis, abstrak, pembimbing, dan kata kunci.
   - Filter cepat kategori dan program studi (Teknik Informatika, Sistem Informasi, DKV, Manajemen Bisnis, Ilmu Komunikasi).
   - Pengurutan karya: Terbaru, Paling Banyak Diunduh, dan Abjad (A-Z).
3. **Pencatatan & Simulasi Unduhan (FR-40, FR-41):**
   - Setiap klik unduh mencatat penambahan unduhan secara real-time.
4. **Modal Detail & Generator Sitasi (FR-32, FR-35):**
   - Pratinjau dokumen PDF, abstrak lengkap, kata kunci, dan generator sitasi 1-klik (APA 7th, IEEE, Harvard).
5. **Formulir Pengajuan Karya untuk Penulis (FR-10, FR-11, FR-12, FR-13, FR-14):**
   - Form metadata lengkap, validasi file PDF (maks. 20 MB), simpan Draft, serta pengajuan ke kurator.
6. **Panel Kurasi & Review Kurator (FR-20, FR-21, FR-22, FR-23):**
   - Kurator dapat memeriksa berkas, memberikan catatan wajib, dan memilih tindakan: Terbitkan, Minta Revisi, atau Tolak.
7. **Simulasi Multi-Peran (FR-02):**
   - Pengalih peran instan di navbar: Publik, Penulis, dan Kurator untuk mempermudah demonstrasi dan evaluasi tugas.

## Cara Menjalankan

```bash
# Masuk ke folder web
cd frontend/web

# Install dependencies (jika belum)
npm install

# Jalankan development server
npm run dev

# Build untuk produksi
npm run build
```
