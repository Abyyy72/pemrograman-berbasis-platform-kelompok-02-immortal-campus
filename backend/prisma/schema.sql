-- ====================================================================
-- IMMORTAL CAMPUS — SUPABASE POSTGRESQL SCHEMA (PRD SEKSI 14)
-- Jalankan skrip ini di SQL Editor Dashboard Supabase Anda
-- ====================================================================

-- 1. ENUM TIPE DATA
DO $$ BEGIN
  CREATE TYPE "RolePengguna" AS ENUM ('penulis', 'kurator');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "JenisKarya" AS ENUM ('skripsi', 'tesis', 'jurnal', 'kp', 'penelitian');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
  CREATE TYPE "StatusKarya" AS ENUM ('Draft', 'Diajukan', 'Dalam Review', 'Perlu Revisi', 'Diterbitkan', 'Ditolak');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- 2. TABEL PENGGUNA (USERS)
CREATE TABLE IF NOT EXISTS public.users (
  id VARCHAR(64) PRIMARY KEY,
  nama VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  nim VARCHAR(64) UNIQUE,
  nip VARCHAR(64) UNIQUE,
  prodi VARCHAR(128) DEFAULT 'Teknik Informatika',
  role "RolePengguna" DEFAULT 'penulis',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. TABEL KARYA ILMIAH (KARYA)
CREATE TABLE IF NOT EXISTS public.karya (
  id VARCHAR(64) PRIMARY KEY,
  judul TEXT NOT NULL,
  penulis VARCHAR(255) NOT NULL,
  nim VARCHAR(64),
  pembimbing VARCHAR(255) NOT NULL,
  jenis "JenisKarya" DEFAULT 'skripsi',
  jenis_label VARCHAR(128) NOT NULL,
  prodi VARCHAR(128) DEFAULT 'Teknik Informatika',
  prodi_key VARCHAR(32) DEFAULT 'ti',
  tahun INT DEFAULT 2026,
  abstrak TEXT NOT NULL,
  kata_kunci TEXT[] DEFAULT '{}',
  unduhan INT DEFAULT 0,
  sitasi INT DEFAULT 0,
  status "StatusKarya" DEFAULT 'Diajukan',
  tanggal_terbit VARCHAR(64),
  doi VARCHAR(128),
  file_url TEXT,
  file_path TEXT,
  file_original_name VARCHAR(255),
  file_size VARCHAR(64) DEFAULT '4.5 MB',
  catatan_kurator TEXT,
  penulis_id VARCHAR(64) REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. TABEL LOG REVIEW KURATOR
CREATE TABLE IF NOT EXISTS public.review_logs (
  id VARCHAR(64) PRIMARY KEY,
  karya_id VARCHAR(64) NOT NULL REFERENCES public.karya(id) ON DELETE CASCADE,
  kurator_id VARCHAR(64) NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  tindakan VARCHAR(32) NOT NULL,
  catatan TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. TABEL LOG UNDUHAN KARYA
CREATE TABLE IF NOT EXISTS public.download_logs (
  id VARCHAR(64) PRIMARY KEY,
  karya_id VARCHAR(64) NOT NULL REFERENCES public.karya(id) ON DELETE CASCADE,
  ip_address VARCHAR(128),
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. INDEXING QUERY
CREATE INDEX IF NOT EXISTS idx_karya_status ON public.karya(status);
CREATE INDEX IF NOT EXISTS idx_karya_prodi_key ON public.karya(prodi_key);
CREATE INDEX IF NOT EXISTS idx_karya_tahun ON public.karya(tahun);
CREATE INDEX IF NOT EXISTS idx_karya_unduhan ON public.karya(unduhan DESC);


-- ====================================================================
-- DATA AWAL RINGKAS (2 AKUN PENGGUNA & 2 KARYA SAMPEL)
-- Kata sandi kedua akun: password123
-- ====================================================================

-- A. Data Akun Penulis & Kurator
INSERT INTO public.users (id, nama, email, password_hash, nim, nip, prodi, role)
VALUES 
  -- Akun Penulis (Mahasiswa)
  ('user-001', 'Amanda Putri Wibowo', 'amanda@campus.ac.id', '$2a$10$c2KZK2Obi02jLO3waJeBKuXahTJ8mDNiuyuPLHMluO5AwqJ.He8Lm', '2110512034', null, 'Teknik Informatika', 'penulis'),
  
  -- Akun Kurator (Perpustakaan)
  ('user-002', 'Dr. Rina Suryani, M.Kom.', 'rina.suryani@campus.ac.id', '$2a$10$c2KZK2Obi02jLO3waJeBKuXahTJ8mDNiuyuPLHMluO5AwqJ.He8Lm', null, '198204152008122001', 'UPT Perpustakaan', 'kurator')
ON CONFLICT (id) DO NOTHING;

-- B. Sampel Karya Ilmiah (1 Terbit untuk publik, 1 Diajukan untuk antrean kurator)
INSERT INTO public.karya (id, judul, penulis, nim, pembimbing, jenis, jenis_label, prodi, prodi_key, tahun, abstrak, kata_kunci, unduhan, sitasi, status, tanggal_terbit, doi, file_size, penulis_id)
VALUES
  -- 1. Karya Terbit (Tampil di Beranda & Pencarian Publik)
  ('karya-001', 'Penerapan Deep Learning CNN untuk Deteksi Dini Penyakit Padi Berbasis Mobile', 'Amanda Putri Wibowo', '2110512034', 'Dr. Eng. Hendra Sucipto, S.Kom., M.T.', 'skripsi', 'Skripsi S-1', 'Teknik Informatika', 'ti', 2024, 'Rancang bangun MobileNetV3 terkompresi INT8 quantization untuk deteksi penyakit daun padi tropis dengan akurasi 96,8%.', ARRAY['Teknik Informatika', 'Computer Vision', 'Deep Learning'], 1420, 18, 'Diterbitkan', '14 Juli 2024', '10.2412/imc.2024.089', '6.4 MB', 'user-001'),
  
  -- 2. Karya Masuk Antrean Kurasi (Untuk Uji Coba Review Kurator)
  ('karya-002', 'Implementasi Edge AI pada Raspberry Pi untuk Pengawasan Lab Kampus', 'Amanda Putri Wibowo', '2110512034', 'Dr. Eng. Hendra Sucipto, S.Kom., M.T.', 'skripsi', 'Skripsi S-1', 'Teknik Informatika', 'ti', 2026, 'Sistem pengawasan laboratorium pintar dan deteksi anomali kehadiran menggunakan arsitektur YOLOv8 secara real-time.', ARRAY['Edge AI', 'Raspberry Pi', 'YOLOv8'], 0, 0, 'Diajukan', '28 Oktober 2026', null, '5.1 MB', 'user-001')
ON CONFLICT (id) DO NOTHING;
