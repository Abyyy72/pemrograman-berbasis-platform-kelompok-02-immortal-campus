# PRD: Immortal Campus

| | |
|---|---|
| **Nama produk** | Immortal Campus (etalase digital karya ilmiah kampus) |
| **Jenis proyek** | Tugas kelompok |
| **Platform** | Web + aplikasi mobile (Android/iOS) |
| **Versi dokumen** | 0.1 (draft) |
| **Penulis** | Abyyy |

---

## 1. Ringkasan

Immortal Campus adalah repositori digital milik kampus untuk menyimpan, mengkurasi, dan mempublikasikan karya ilmiah (skripsi, tesis, jurnal, laporan penelitian, laporan kerja praktik). Karya yang diunggah mahasiswa tidak langsung tayang: karya melewati antrean review kurator, dan hanya karya yang layak yang diterbitkan. Setelah terbit, siapa pun bisa mencari, membaca, dan mengunduhnya. Setiap unduhan tercatat sehingga kampus tahu karya apa yang paling banyak dibaca.

## 2. Latar Belakang & Masalah

- Karya menumpuk di rak pembimbing, flashdisk alumni, atau drive pribadi dosen.
- Adik tingkat tidak tahu ke mana harus mencari referensi tentang topik tertentu.
- Saat akreditasi, program studi kesulitan mengumpulkan bukti karya dalam waktu singkat.
- Tidak ada data tentang karya mana yang benar-benar dibaca.

## 3. Tujuan & Non-Tujuan

### Tujuan
1. Menyediakan satu tempat resmi untuk mengunggah, mengkurasi, dan menerbitkan karya ilmiah kampus.
2. Memastikan hanya karya yang sudah direview kurator yang tampil ke publik.
3. Memudahkan publik menemukan karya lewat pencarian dan filter.
4. Memberi data unduhan dan statistik untuk kebutuhan evaluasi dan akreditasi.
5. Menjadi proyek portofolio full-stack yang lengkap (web + mobile + backend).

### Non-Tujuan (di luar MVP)
- Deteksi plagiarisme otomatis.
- Integrasi dengan sistem eksternal (SINTA, Garuda, Google Scholar, DOI).
- Sitasi otomatis, rekomendasi karya, atau fitur sosial (komentar, like).
- Pembayaran atau akses berbayar.
- Multi-kampus (satu instalasi untuk satu kampus).

## 4. Persona / Peran Pengguna

| Peran | Deskripsi | Kebutuhan utama |
|---|---|---|
| **Penulis** | Mahasiswa atau dosen pemilik karya | Mengunggah karya, mengisi metadata, melihat status review, merevisi sesuai catatan |
| **Kurator** | Staf perpustakaan / admin prodi penjaga mutu | Memeriksa antrean, memberi catatan, meminta revisi, menerbitkan atau menolak |
| **Publik** | Siapa pun yang datang mencari referensi | Mencari, membaca detail, dan mengunduh karya yang sudah terbit |

## 5. Alur Utama

### 5.1 Status Karya

```
Draft → Diajukan → Dalam Review → Perlu Revisi → (kembali ke Diajukan)
                        │
                        ├──→ Diterbitkan
                        └──→ Ditolak
```

## 6. Kebutuhan Fungsional

### 6.1 Autentikasi & Akun
- FR-01: Pengguna dapat mendaftar dan login (email + password).
- FR-02: Sistem membedakan peran: Penulis dan Kurator. Publik tidak perlu login.

### 6.2 Upload Karya & Metadata (Penulis)
- FR-10: Penulis dapat membuat karya baru dengan metadata lengkap.
- FR-11: Penulis dapat mengunggah file full-text (PDF).
- FR-14: Penulis dapat mengajukan karya.
- FR-15: Penulis dapat melihat daftar karyanya beserta status.

### 6.3 Review Kurator
- FR-20: Kurator melihat antrean karya berstatus Diajukan/Dalam Review.
- FR-23: Kurator dapat memilih tindakan: Minta Revisi, Terbitkan, atau Tolak.

### 6.4 Pencarian & Penjelajahan (Publik)
- FR-30: Publik dapat mencari karya terbit lewat kata kunci.
- FR-31: Hasil pencarian dapat difilter (jenis karya, prodi, tahun) dan diurutkan.
- FR-32: Halaman detail karya menampilkan metadata lengkap, abstrak, dan tombol baca/unduh.
- FR-34: Halaman beranda menampilkan karya terbaru dan terpopuler.

### 6.5 Unduhan & Statistik
- FR-40: Setiap unduhan karya tercatat.
- FR-41: Halaman detail karya menampilkan jumlah unduhan.
- FR-42: Dashboard kurator menampilkan statistik ringkasan.

## 14. Tech Stack

| Lapisan | Pilihan |
|---|---|
| Backend (REST API) | Node.js (LTS) + Express 4.21.2 |
| Autentikasi | JWT (`jsonwebtoken`) + `bcryptjs` |
| ORM | Prisma |
| Database | Supabase (PostgreSQL) |
| Penyimpanan file PDF | Supabase Storage (private bucket) |
| Frontend web | Svelte 5 + TypeScript + Vite, Tailwind CSS |
| Frontend mobile | Flutter |

