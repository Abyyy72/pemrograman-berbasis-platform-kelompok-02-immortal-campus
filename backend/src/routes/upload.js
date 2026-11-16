'use strict';

const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const {
  isSupabaseStorageEnabled,
  uploadToStorage,
  getSignedDownloadUrl,
} = require('../lib/supabase');
const { optionalAuth } = require('../middleware/requireAuth');

// Direktori fallback penyimpanan lokal jika Supabase Storage belum aktif
const UPLOAD_DIR = path.join(__dirname, '../../uploads');
if (!fs.existsSync(UPLOAD_DIR)) {
  fs.mkdirSync(UPLOAD_DIR, { recursive: true });
}

// Multer in-memory storage untuk streaming ke Supabase Storage atau fallback ke disk
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 50 * 1024 * 1024 }, // 50MB (PRD)
  fileFilter: (_req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    const isPdfMime = file.mimetype === 'application/pdf' || file.mimetype === 'application/x-pdf';
    if (isPdfMime || ext === '.pdf') {
      cb(null, true);
    } else {
      const err = new Error('Hanya berkas berformat PDF yang diperbolehkan!');
      err.code = 'INVALID_FILE_TYPE';
      cb(err);
    }
  },
});

/**
 * POST /api/v1/upload (FR-11: Upload File Full-Text PDF)
 * Mengunggah berkas PDF naskah ke Supabase Storage (Private Bucket) atau lokal fallback
 */
router.post('/', optionalAuth, (req, res) => {
  upload.single('file')(req, res, async (err) => {
    if (err) {
      if (err instanceof multer.MulterError && err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({
          status: false,
          message: 'Ukuran berkas melebihi batas maksimal 50 MB.',
          data: null,
        });
      }
      return res.status(400).json({
        status: false,
        message: err.message || 'Gagal memproses berkas unggahan.',
        data: null,
      });
    }

    if (!req.file) {
      return res.status(400).json({
        status: false,
        message: 'Tidak ada berkas PDF yang dipilih untuk diunggah.',
        data: null,
      });
    }

    try {
      const originalName = req.file.originalname;
      const ext = path.extname(originalName).toLowerCase() || '.pdf';
      const cleanBaseName = path.basename(originalName, ext).replace(/[^a-zA-Z0-9_-]/g, '_');
      const uniqueFilename = `naskah-${Date.now()}-${cleanBaseName}${ext}`;
      const fileSizeMB = (req.file.size / (1024 * 1024)).toFixed(1) + ' MB';

      // 1. Coba unggah ke Supabase Storage (Private Bucket sesuai PRD Seksi 14)
      if (isSupabaseStorageEnabled()) {
        try {
          const storagePath = `naskah/${uniqueFilename}`;
          await uploadToStorage(req.file.buffer, storagePath, 'application/pdf');

          // Hasilkan signed URL untuk akses aman dari private bucket
          const signedUrl = await getSignedDownloadUrl(storagePath, 7200);

          return res.status(200).json({
            status: true,
            message: 'Berkas PDF berhasil diunggah ke Supabase Storage (Private Bucket).',
            data: {
              originalName,
              filename: uniqueFilename,
              size: fileSizeMB,
              storageType: 'supabase_storage',
              storagePath,
              fileUrl: signedUrl || `/api/v1/upload/file/${uniqueFilename}`,
            },
          });
        } catch (storageError) {
          console.warn('[Supabase Storage] Unggah ke bucket gagal, beralih ke penyimpanan lokal:', storageError.message);
        }
      }

      // 2. Fallback: Simpan ke disk lokal server
      const localFilePath = path.join(UPLOAD_DIR, uniqueFilename);
      fs.writeFileSync(localFilePath, req.file.buffer);

      return res.status(200).json({
        status: true,
        message: 'Berkas PDF berhasil disimpan di penyimpanan lokal repositori.',
        data: {
          originalName,
          filename: uniqueFilename,
          size: fileSizeMB,
          storageType: 'local_disk',
          storagePath: uniqueFilename,
          fileUrl: `/uploads/${uniqueFilename}`,
        },
      });
    } catch (saveError) {
      console.error('[Upload Error]', saveError);
      return res.status(500).json({
        status: false,
        message: 'Terjadi kesalahan saat menyimpan berkas PDF.',
        data: null,
      });
    }
  });
});

/**
 * GET /api/v1/upload/file/:filename
 * Streaming atau redirect unduhan naskah PDF
 */
router.get('/file/:filename', async (req, res) => {
  const { filename } = req.params;
  const storagePath = `naskah/${filename}`;

  // Cek jika di Supabase Storage
  if (isSupabaseStorageEnabled()) {
    const signedUrl = await getSignedDownloadUrl(storagePath, 3600);
    if (signedUrl) {
      return res.redirect(signedUrl);
    }
  }

  // Cek di disk lokal
  const localFile = path.join(UPLOAD_DIR, filename);
  if (fs.existsSync(localFile)) {
    res.setHeader('Content-Type', 'application/pdf');
    return res.sendFile(localFile);
  }

  return res.status(404).json({
    status: false,
    message: 'Berkas naskah PDF tidak ditemukan.',
    data: null,
  });
});

module.exports = router;
