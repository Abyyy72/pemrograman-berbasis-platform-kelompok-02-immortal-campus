'use strict';

const express = require('express');
const router = express.Router();

const {
  getAllKarya,
  getPublishedKarya,
  getBerandaKarya,
  getKaryaById,
  getKaryaByAuthor,
  getKuratorQueue,
  createKarya,
  updateKarya,
  incrementDownload,
  addReviewLog,
  getReviewLogsByKarya,
} = require('../lib/db');

const {
  isSupabaseStorageEnabled,
  getSignedDownloadUrl,
} = require('../lib/supabase');

const requireAuth = require('../middleware/requireAuth');
const requireRole = require('../middleware/requireRole');
const {
  PRODI_KEY_MAP,
  JENIS_LABEL_MAP,
  createKaryaSchema,
  updateKaryaSchema,
  reviewKaryaSchema,
} = require('../schemas/karyaSchema');

/**
 * GET /api/v1/karya/beranda (FR-34)
 * Menampilkan ringkasan karya terbaru dan terpopuler untuk beranda publik
 */
router.get('/beranda', async (req, res, next) => {
  try {
    const limit = req.query.limit ? Number(req.query.limit) : 6;
    const berandaData = await getBerandaKarya(limit);

    return res.status(200).json({
      status: true,
      message: 'Karya beranda (terbaru dan terpopuler) berhasil diambil.',
      data: berandaData,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/v1/karya/saya (FR-15)
 * Penulis melihat daftar seluruh karyanya beserta status review masing-masing
 */
router.get('/saya', requireAuth, requireRole('penulis'), async (req, res, next) => {
  try {
    const { status } = req.query;
    const authorWorks = await getKaryaByAuthor(req.user.id, req.user.nama, status);

    return res.status(200).json({
      status: true,
      message: 'Daftar naskah karya saya berhasil diambil.',
      total: authorWorks.length,
      data: authorWorks,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/v1/karya/antrean (FR-20)
 * Kurator memeriksa antrean karya yang berstatus 'Diajukan' atau 'Dalam Review'
 */
router.get('/antrean', requireAuth, requireRole('kurator'), async (req, res, next) => {
  try {
    const { status } = req.query;
    const queue = await getKuratorQueue(status);

    return res.status(200).json({
      status: true,
      message: 'Antrean kurasi karya ilmiah berhasil diambil.',
      total: queue.length,
      data: queue,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/v1/karya/semua
 * Seluruh naskah repositori lintas status untuk etalase dan kurator
 */
router.get('/semua', async (_req, res, next) => {
  try {
    const all = await getAllKarya();
    return res.status(200).json({
      status: true,
      message: 'Seluruh repositori naskah berhasil diambil.',
      total: all.length,
      data: all,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/v1/karya (FR-30, FR-31, FR-34)
 * Publik mencari dan menjelajahi karya berstatus 'Diterbitkan' dengan filter & urutan
 */
router.get('/', async (req, res, next) => {
  try {
    const { q, jenis, prodi, tahun, sort } = req.query;
    const list = await getPublishedKarya({ q, jenis, prodi, tahun, sort });

    return res.status(200).json({
      status: true,
      message: 'Daftar karya terbit berhasil diambil.',
      total: list.length,
      filter: { q, jenis, prodi, tahun, sort: sort || 'terbaru' },
      data: list,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/v1/karya/:id (FR-32, FR-41)
 * Detail lengkap satu karya ilmiah, mencakup metadata, abstrak, jumlah unduhan, dan tautan PDF
 */
router.get('/:id', async (req, res, next) => {
  try {
    const karya = await getKaryaById(req.params.id);
    if (!karya) {
      return res.status(404).json({
        status: false,
        message: 'Karya ilmiah tidak ditemukan.',
        data: null,
      });
    }

    // Jika karya memiliki file di Supabase Storage, generate fresh signed URL
    let fileDownloadUrl = karya.fileUrl;
    if (karya.filePath && isSupabaseStorageEnabled()) {
      const signed = await getSignedDownloadUrl(karya.filePath, 3600);
      if (signed) {
        fileDownloadUrl = signed;
      }
    }

    const reviewHistory = await getReviewLogsByKarya(karya.id);

    return res.status(200).json({
      status: true,
      message: 'Detail karya berhasil diambil.',
      data: {
        ...karya,
        fileDownloadUrl: fileDownloadUrl || karya.fileUrl,
        reviewHistory,
      },
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/v1/karya (FR-10, FR-14)
 * Penulis membuat karya baru (bisa disimpan sebagai 'Draft' atau diajukan langsung 'Diajukan')
 */
router.post('/', requireAuth, requireRole('penulis'), async (req, res, next) => {
  try {
    const body = { ...req.body };
    if (typeof body.tahun === 'string') body.tahun = Number(body.tahun);
    if (typeof body.kataKunci === 'string') {
      body.kataKunci = body.kataKunci.split(',').map((s) => s.trim()).filter(Boolean);
    }

    const result = createKaryaSchema.safeParse(body);
    if (!result.success) {
      return res.status(400).json({
        status: false,
        message: 'Data pengajuan karya tidak valid.',
        errors: result.error.flatten().fieldErrors,
      });
    }

    const payload = result.data;
    const user = req.user || {
      id: 'user-001',
      nama: 'Amanda Putri Wibowo',
      nim: '2110512034',
      prodi: 'Teknik Informatika',
    };

    const userProdi = user.prodi || 'Teknik Informatika';
    const prodiClean = (payload.prodi || userProdi).toLowerCase();
    const prodiKey = payload.prodiKey || PRODI_KEY_MAP[prodiClean] || 'ti';
    const jenisLabel = payload.jenisLabel || JENIS_LABEL_MAP[payload.jenis] || 'Skripsi S-1';

    // Alur Seksi 5.1: Penulis dapat menyimpan draft atau mengajukan
    const status = payload.status === 'Draft' ? 'Draft' : 'Diajukan';

    const newKarya = await createKarya({
      judul: payload.judul,
      penulis: user.nama || payload.penulis || 'Mahasiswa Penulis',
      nim: user.nim || payload.nim || '2110512034',
      pembimbing: payload.pembimbing,
      jenis: payload.jenis,
      jenisLabel,
      prodi: payload.prodi || userProdi,
      prodiKey,
      tahun: payload.tahun,
      abstrak: payload.abstrak,
      kataKunci: Array.isArray(payload.kataKunci) ? payload.kataKunci : [],
      status,
      penulisId: user.id,
      fileUrl: payload.fileUrl || undefined,
      filePath: payload.filePath || undefined,
      fileOriginalName: payload.fileOriginalName || undefined,
      fileSize: payload.fileSize || '4.5 MB',
    });

    return res.status(201).json({
      status: true,
      message: newKarya.status === 'Draft'
        ? 'Draft naskah berhasil disimpan.'
        : 'Naskah karya ilmiah berhasil diajukan ke antrean kurasi perpustakaan!',
      data: newKarya,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * PUT /api/v1/karya/:id (FR-10, FR-14)
 * Penulis memperbarui naskah 'Draft' atau menindaklanjuti naskah 'Perlu Revisi'
 */
router.put('/:id', requireAuth, requireRole('penulis'), async (req, res, next) => {
  try {
    const existing = await getKaryaById(req.params.id);
    if (!existing) {
      return res.status(404).json({
        status: false,
        message: 'Karya tidak ditemukan.',
      });
    }

    // Toleransi hak akses jika menggunakan sesi demo atau id sama
    const isDemo = req.headers.authorization && req.headers.authorization.includes('demo-token');
    if (!isDemo && existing.penulisId && req.user && existing.penulisId !== req.user.id && req.user.role !== 'kurator') {
      return res.status(403).json({
        status: false,
        message: 'Anda tidak memiliki hak akses untuk mengubah naskah milik penulis lain.',
      });
    }

    // PRD Seksi 5.1: Hanya status Draft atau Perlu Revisi yang dapat diedit penulis
    if (existing.status !== 'Draft' && existing.status !== 'Perlu Revisi') {
      return res.status(400).json({
        status: false,
        message: `Naskah berstatus "${existing.status}" tidak dapat diedit langsung.`,
      });
    }

    const body = { ...req.body };
    if (typeof body.tahun === 'string') body.tahun = Number(body.tahun);
    if (typeof body.kataKunci === 'string') {
      body.kataKunci = body.kataKunci.split(',').map((s) => s.trim()).filter(Boolean);
    }

    const result = updateKaryaSchema.safeParse(body);
    if (!result.success) {
      return res.status(400).json({
        status: false,
        message: 'Data perbaikan karya tidak valid.',
        errors: result.error.flatten().fieldErrors,
      });
    }

    const payload = result.data;
    const updateFields = { ...payload };

    // Alur PRD Seksi 5.1: Perlu Revisi -> Diajukan kembali
    if (payload.submitForReview) {
      updateFields.status = 'Diajukan';
      // Hapus catatan kurator setelah perbaikan diajukan kembali
      updateFields.catatanKurator = '';
    }
    delete updateFields.submitForReview;

    if (payload.jenis) {
      updateFields.jenisLabel = JENIS_LABEL_MAP[payload.jenis] || existing.jenisLabel;
    }
    if (payload.prodi) {
      const clean = payload.prodi.toLowerCase();
      updateFields.prodiKey = PRODI_KEY_MAP[clean] || existing.prodiKey;
    }

    const updated = await updateKarya(req.params.id, updateFields);

    return res.status(200).json({
      status: true,
      message: updateFields.status === 'Diajukan'
        ? 'Revisi naskah berhasil diajukan kembali ke antrean kurator!'
        : 'Perubahan karya berhasil disimpan.',
      data: updated,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * PATCH /api/v1/karya/:id/start-review (FR-20, Alur Seksi 5.1)
 * Kurator mengambil naskah 'Diajukan' untuk diproses menjadi 'Dalam Review'
 */
router.patch('/:id/start-review', requireAuth, requireRole('kurator'), async (req, res, next) => {
  try {
    const existing = await getKaryaById(req.params.id);
    if (!existing) {
      return res.status(404).json({
        status: false,
        message: 'Karya tidak ditemukan.',
      });
    }

    if (existing.status !== 'Diajukan') {
      return res.status(400).json({
        status: false,
        message: `Hanya naskah berstatus "Diajukan" yang dapat diubah menjadi "Dalam Review". Status saat ini: "${existing.status}".`,
      });
    }

    const kuratorId = req.user ? req.user.id : 'user-002';
    const updated = await updateKarya(req.params.id, {
      status: 'Dalam Review',
    });

    await addReviewLog(req.params.id, kuratorId, 'start-review', 'Kurator memulai proses review naskah.');

    return res.status(200).json({
      status: true,
      message: 'Naskah kini berstatus "Dalam Review".',
      data: updated,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/v1/karya/:id/review (FR-23, Alur Seksi 5.1)
 * Kurator menentukan keputusan: Terbitkan, Minta Revisi, atau Tolak
 */
router.post('/:id/review', requireAuth, requireRole('kurator'), async (req, res, next) => {
  try {
    const existing = await getKaryaById(req.params.id);
    if (!existing) {
      return res.status(404).json({
        status: false,
        message: 'Karya tidak ditemukan.',
      });
    }

    const result = reviewKaryaSchema.safeParse(req.body);
    if (!result.success) {
      return res.status(400).json({
        status: false,
        message: 'Data keputusan review tidak valid.',
        errors: result.error.flatten().fieldErrors,
      });
    }

    const { tindakan } = result.data;
    let catatan = (result.data.catatan || '').trim();

    let nextStatus = 'Diterbitkan';
    let doi = existing.doi;

    if (tindakan === 'terbitkan') {
      nextStatus = 'Diterbitkan';
      if (!doi) {
        const year = new Date().getFullYear();
        const rand = Math.floor(100 + Math.random() * 900);
        doi = `10.2412/imc.${year}.${rand}`;
      }
    } else if (tindakan === 'revisi') {
      nextStatus = 'Perlu Revisi';
      if (!catatan) {
        catatan = 'Mohon perbaiki dan lengkapi naskah sesuai catatan kurasi repositori.';
      }
    } else if (tindakan === 'tolak') {
      nextStatus = 'Ditolak';
      if (!catatan) {
        catatan = 'Naskah belum memenuhi kriteria penerbitan repositori karya ilmiah.';
      }
    }

    const updated = await updateKarya(req.params.id, {
      status: nextStatus,
      catatanKurator: catatan || undefined,
      doi,
      tanggalTerbit: nextStatus === 'Diterbitkan'
        ? new Date().toLocaleDateString('id-ID', { day: '2-digit', month: 'long', year: 'numeric' })
        : existing.tanggalTerbit,
    });

    const kuratorId = req.user ? req.user.id : 'user-002';
    await addReviewLog(req.params.id, kuratorId, tindakan, catatan || '');

    return res.status(200).json({
      status: true,
      message: `Keputusan kurator berhasil ditetapkan: "${nextStatus}".`,
      data: updated,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * PATCH /api/v1/karya/:id/status
 * Kurator memperbarui status naskah secara manual
 */
router.patch('/:id/status', requireAuth, requireRole('kurator'), async (req, res, next) => {
  try {
    const { status, catatanKurator } = req.body;
    if (!status) {
      return res.status(400).json({
        status: false,
        message: 'Parameter status wajib disertakan.',
      });
    }

    const validStatuses = ['Draft', 'Diajukan', 'Dalam Review', 'Perlu Revisi', 'Diterbitkan', 'Ditolak'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        status: false,
        message: `Status tidak valid. Nilai yang diperbolehkan: ${validStatuses.join(', ')}`,
      });
    }

    const updated = await updateKarya(req.params.id, {
      status,
      catatanKurator: catatanKurator || undefined,
    });

    if (!updated) {
      return res.status(404).json({
        status: false,
        message: 'Karya tidak ditemukan.',
      });
    }

    return res.status(200).json({
      status: true,
      message: `Status naskah berhasil diubah menjadi "${status}".`,
      data: updated,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/v1/karya/:id/unduh (FR-40, FR-41)
 * Mencatat metrik unduhan karya ilmiah
 */
router.post('/:id/unduh', async (req, res, next) => {
  try {
    const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
    const userAgent = req.headers['user-agent'];
    const karya = await incrementDownload(req.params.id, ip, userAgent);

    if (!karya) {
      return res.status(404).json({
        status: false,
        message: 'Karya tidak ditemukan.',
      });
    }

    return res.status(200).json({
      status: true,
      message: 'Unduhan berhasil dicatat.',
      data: {
        id: karya.id,
        unduhan: karya.unduhan,
        fileUrl: karya.fileUrl,
      },
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/v1/karya/:id/unduh (FR-40, FR-41)
 * Unduh langsung berkas naskah serta catat metrik unduhan
 */
router.get('/:id/unduh', async (req, res, next) => {
  try {
    const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress;
    const userAgent = req.headers['user-agent'];
    const karya = await incrementDownload(req.params.id, ip, userAgent);

    if (!karya) {
      return res.status(404).json({
        status: false,
        message: 'Karya tidak ditemukan.',
      });
    }

    // Jika file di Supabase Storage, alihkan ke signed URL
    if (karya.filePath && isSupabaseStorageEnabled()) {
      const signedUrl = await getSignedDownloadUrl(karya.filePath, 3600);
      if (signedUrl) {
        return res.redirect(signedUrl);
      }
    }

    if (karya.fileUrl) {
      return res.redirect(karya.fileUrl);
    }

    return res.status(200).json({
      status: true,
      message: 'Unduhan berhasil dicatat.',
      data: {
        id: karya.id,
        unduhan: karya.unduhan,
      },
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
