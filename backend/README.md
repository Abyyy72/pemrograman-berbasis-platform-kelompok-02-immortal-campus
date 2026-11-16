# Backend REST API — Immortal Campus

Backend REST API untuk repositori karya ilmiah institusional **Immortal Campus** (etalase digital karya ilmiah kampus), dibangun sesuai spesifikasi penuh dokumen **[PRD.md](../docs/PRD.md)**.

---

## 1. Teknologi & Arsitektur (PRD Seksi 14)

| Lapisan | Pilihan Teknologi | Implementasi |
|---|---|---|
| **Backend (REST API)** | Node.js (LTS) + Express 4.21.2 | Modular router, async middleware, error handling |
| **Autentikasi** | JWT (`jsonwebtoken`) + `bcryptjs` | Bearer token authentication & role-based authorization |
| **ORM** | Prisma (`@prisma/client`) | Schema `prisma/schema.prisma` PostgreSQL |
| **Database** | Supabase (PostgreSQL) | Persistence layer via Prisma / fallback persistent store |
| **Penyimpanan Berkas PDF** | Supabase Storage (Private Bucket) | `@supabase/supabase-js` dengan signed download URL + fallback lokal |
| **Validasi Skema** | Zod | Validasi ketat request body & filter query |

---

## 2. Alur Status Karya Ilmiah (PRD Seksi 5.1)

```
Draft → Diajukan → Dalam Review → Perlu Revisi → (kembali ke Diajukan)
                        │
                        ├──→ Diterbitkan
                        └──→ Ditolak
```

- **Draft:** Naskah disimpan sementara oleh penulis sebelum siap diajukan.
- **Diajukan:** Naskah masuk ke antrean meja kurasi perpustakaan.
- **Dalam Review:** Kurator sedang memeriksa berkas & metadata naskah.
- **Perlu Revisi:** Kurator meminta perbaikan dengan melampirkan catatan revisi. Penulis dapat memperbaiki dan mengajukannya kembali.
- **Diterbitkan:** Naskah disetujui kurator, mendapat nomor DOI/registrasi repositori, dan tayang ke publik.
- **Ditolak:** Naskah tidak memenuhi standar kelayakan repositori kampus.

---

## 3. Katalog Endpoint API (PRD Seksi 6)

Base URL: `http://localhost:3000/api/v1`

### 3.1 Autentikasi & Akun (FR-01, FR-02)
| Method | Endpoint | Hak Akses | Deskripsi |
|---|---|---|---|
| `POST` | `/api/v1/auth/register` | Publik | Mendaftar akun Penulis atau Kurator |
| `POST` | `/api/v1/auth/login` | Publik | Masuk dengan Email / NIM / NIP + Password |
| `GET` | `/api/v1/auth/me` | Penulis/Kurator | Mengambil profil pengguna yang sedang login |
| `POST` | `/api/v1/auth/logout` | Publik | Mengakhiri sesi login |

### 3.2 Karya Ilmiah & Alur Kurasi (FR-10, FR-14, FR-15, FR-20, FR-23)
| Method | Endpoint | Hak Akses | Deskripsi |
|---|---|---|---|
| `GET` | `/api/v1/karya` | Publik | (FR-30, FR-31) Jelajah karya terbit (filter `q`, `jenis`, `prodi`, `tahun`, `sort`) |
| `GET` | `/api/v1/karya/beranda` | Publik | (FR-34) Karya terbaru dan terpopuler untuk beranda |
| `GET` | `/api/v1/karya/saya` | Penulis | (FR-15) Naskah milik penulis yang sedang login (bisa filter `status`) |
| `GET` | `/api/v1/karya/antrean` | Kurator | (FR-20) Antrean naskah masuk (*Diajukan* & *Dalam Review*) |
| `GET` | `/api/v1/karya/semua` | Publik/Kurator | Seluruh naskah repositori lintas status |
| `GET` | `/api/v1/karya/:id` | Publik | (FR-32, FR-41) Detail naskah, abstrak, metrik unduhan & tautan PDF |
| `POST` | `/api/v1/karya` | Penulis | (FR-10, FR-14) Simpan Draft atau Ajukan naskah baru |
| `PUT` | `/api/v1/karya/:id` | Penulis | (FR-10, FR-14) Perbarui draft atau ajukan ulang naskah revisi |
| `PATCH` | `/api/v1/karya/:id/start-review` | Kurator | (FR-20) Mulai kurasi (ubah status ke *Dalam Review*) |
| `POST` | `/api/v1/karya/:id/review` | Kurator | (FR-23) Berikan keputusan kurator (*terbitkan*, *revisi*, *tolak*) |
| `PATCH` | `/api/v1/karya/:id/status` | Kurator | Ubah status naskah secara manual |
| `POST` | `/api/v1/karya/:id/unduh` | Publik | (FR-40, FR-41) Catat metrik unduhan karya |
| `GET` | `/api/v1/karya/:id/unduh` | Publik | Unduh berkas PDF dan catat penambahan unduhan |

### 3.3 Berkas Naskah PDF & Supabase Storage (FR-11, Seksi 14)
| Method | Endpoint | Hak Akses | Deskripsi |
|---|---|---|---|
| `POST` | `/api/v1/upload` | Penulis | Unggah berkas naskah PDF (ke Supabase Storage Private Bucket atau disk lokal) |
| `GET` | `/api/v1/upload/file/:filename` | Publik | Streaming berkas PDF lokal / redirect signed URL private bucket |

### 3.4 Unduhan & Statistik (FR-40, FR-41, FR-42)
| Method | Endpoint | Hak Akses | Deskripsi |
|---|---|---|---|
| `GET` | `/api/v1/statistik` | Publik | (FR-42) Dashboard kurator & publik (total karya, unduhan, antrean, distribusi prodi & jenis) |
| `GET` | `/api/v1/statistik/akreditasi` | Publik/Kurator | Rekapitulasi borang akreditasi Kriteria 9 BAN-PT |

---

## 4. Konfigurasi Lingkungan (.env)

Buat berkas `.env` di folder `backend/` berdasarkan template `.env.example`:

```env
PORT=3000
NODE_ENV=development
JWT_SECRET=immortal_campus_super_secret_jwt_key_2026
JWT_EXPIRES_IN=7d
CORS_ORIGIN=*

# Supabase PostgreSQL via Prisma (PRD Seksi 14)
DATABASE_URL=postgresql://postgres.your-project-ref:your-db-password@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true

# Supabase Storage - Private Bucket PDF (PRD Seksi 14)
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_STORAGE_BUCKET=immortal-karya
```

> **Catatan Reliabilitas:** Jika variabel `DATABASE_URL` atau `SUPABASE_URL` belum disetel (misal saat pengembangan offline lokal), sistem secara otomatis beralih ke penyimpanan persisten lokal aman tanpa mengalami crash.

---

## 5. Menjalankan Server

```bash
# Masuk ke folder backend
cd backend

# Jalankan dalam mode pengembangan
npm run dev

# Jalankan dalam mode produksi
npm start
```

---

## 6. Akun Uji Coba Bawaan (Demo Credentials)

| Peran | Identifier (Email / Identitas) | Kata Sandi | Deskripsi |
|---|---|---|---|
| **Penulis** | `amanda@campus.ac.id` atau `2110512034` | `password123` | Mahasiswa Teknik Informatika |
| **Penulis** | `fajar@campus.ac.id` atau `2108561023` | `password123` | Mahasiswa Sistem Informasi |
| **Kurator** | `rina.suryani@campus.ac.id` atau `198204152008122001` | `password123` | Dr. Rina Suryani, M.Kom. (Perpustakaan) |
