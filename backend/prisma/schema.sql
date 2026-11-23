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
-- DATA AWAL / SEED DATA
-- File seed terpisah ada di: backend/prisma/seed.sql (di-gitignore)
-- Jalankan seed.sql secara lokal untuk isi data demo awal
-- ====================================================================
-- (seed data tidak disertakan di sini demi keamanan — lihat seed.sql)
