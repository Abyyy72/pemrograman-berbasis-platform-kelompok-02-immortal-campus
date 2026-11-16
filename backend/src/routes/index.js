'use strict';

const express = require('express');
const router = express.Router();

const authRouter = require('./auth');
const karyaRouter = require('./karya');
const statistikRouter = require('./statistik');
const uploadRouter = require('./upload');
const adminRouter = require('./admin');

// ── GET /api/v1 — Health & API Catalog (PRD Immortal Campus) ─────
router.get('/', (_req, res) => {
  res.status(200).json({
    status: true,
    message: 'Selamat datang di REST API Immortal Campus - Etalase Digital Karya Ilmiah Kampus',
    version: '1.0.0',
    prdAlignment: {
      platform: 'Web (Svelte 5) + Mobile (Flutter) + Backend (Node.js Express + Supabase/Prisma)',
      auth: 'JWT (jsonwebtoken) + bcryptjs',
      storage: 'Supabase Storage (Private Bucket) dengan fallback lokal',
      database: 'Supabase PostgreSQL via Prisma ORM',
    },
    documentation: {
      auth: [
        'POST   /api/v1/auth/register          - (FR-01, FR-02) Registrasi Penulis & Kurator',
        'POST   /api/v1/auth/login             - (FR-01, FR-02) Masuk dengan Email/NIM/NIP + Password',
        'GET    /api/v1/auth/me                - Profil pengguna yang sedang terautentikasi',
        'POST   /api/v1/auth/logout            - Keluar dari sesi login',
      ],
      karya: [
        'GET    /api/v1/karya/beranda          - (FR-34) Karya terbaru dan terpopuler untuk beranda',
        'GET    /api/v1/karya                  - (FR-30, FR-31) Jelajah karya terbit (filter q, jenis, prodi, tahun, sort)',
        'GET    /api/v1/karya/saya             - (FR-15) Naskah milik penulis yang sedang login',
        'GET    /api/v1/karya/antrean          - (FR-20) Antrean kurator (Diajukan & Dalam Review)',
        'GET    /api/v1/karya/semua            - Seluruh naskah repositori lintas status',
        'GET    /api/v1/karya/:id              - (FR-32, FR-41) Detail naskah, abstrak, & unduhan',
        'POST   /api/v1/karya                  - (FR-10, FR-14) Simpan Draft atau Ajukan naskah',
        'PUT    /api/v1/karya/:id              - (FR-10, FR-14) Edit Draft atau perbaiki & ajukan ulang naskah revisi',
        'PATCH  /api/v1/karya/:id/start-review - (FR-20) Kurator memulai review (status -> Dalam Review)',
        'POST   /api/v1/karya/:id/review       - (FR-23) Keputusan kurator: terbitkan, revisi, tolak',
        'PATCH  /api/v1/karya/:id/status       - Kurator mengubah status karya langsung',
        'POST   /api/v1/karya/:id/unduh        - (FR-40, FR-41) Catat metrik unduhan karya',
        'GET    /api/v1/karya/:id/unduh        - Unduh berkas PDF naskah & catat unduhan',
      ],
      upload: [
        'POST   /api/v1/upload                 - (FR-11) Unggah PDF naskah ke Supabase Storage (Private Bucket)',
        'GET    /api/v1/upload/file/:filename  - Streaming / unduh berkas naskah PDF',
      ],
      statistik: [
        'GET    /api/v1/statistik              - (FR-42) Dashboard kurator & publik (ringkasan, distribusi jenis, prodi, top)',
        'GET    /api/v1/statistik/akreditasi   - Rekapitulasi borang Kriteria 9 BAN-PT',
      ],
    },
  });
});

router.use('/auth', authRouter);
router.use('/karya', karyaRouter);
router.use('/statistik', statistikRouter);
router.use('/upload', uploadRouter);
router.use('/admin', adminRouter);

// 404 Route handler
router.use((req, res) => {
  res.status(404).json({
    status: false,
    message: `Endpoint tidak ditemukan: ${req.method} ${req.originalUrl}`,
    data: null,
  });
});

module.exports = router;
