'use strict';

/**
 * db.js — Lapisan Akses Data Supabase PostgreSQL
 * Menggantikan src/data/store.js dengan query SQL via Supabase JS client.
 * Semua nama fungsi identik dengan store.js sehingga routes tidak perlu diubah.
 *
 * Kolom DB (snake_case) ↔ Fields JS (camelCase) — dikonversi di mapKarya() / mapUser()
 */

const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  throw new Error(
    '[DB] SUPABASE_URL atau SUPABASE_SERVICE_ROLE_KEY belum disetel di .env!'
  );
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: { persistSession: false, autoRefreshToken: false },
});

console.log(`[DB] Terhubung ke Supabase PostgreSQL: ${SUPABASE_URL}`);

// ── Mapper: DB row → objek JS yang kompatibel dengan routes ──────────

/**
 * Konversi baris DB karya (snake_case) ke objek JavaScript (camelCase)
 * sehingga response API tetap konsisten dengan versi local JSON.
 */
function mapKarya(row) {
  if (!row) return null;
  return {
    id: row.id,
    judul: row.judul,
    penulis: row.penulis,
    nim: row.nim,
    pembimbing: row.pembimbing,
    jenis: row.jenis,
    jenisLabel: row.jenis_label,
    prodi: row.prodi,
    prodiKey: row.prodi_key,
    tahun: row.tahun,
    abstrak: row.abstrak,
    kataKunci: row.kata_kunci || [],
    unduhan: row.unduhan || 0,
    sitasi: row.sitasi || 0,
    status: row.status,
    tanggalTerbit: row.tanggal_terbit,
    doi: row.doi,
    fileUrl: row.file_url,
    filePath: row.file_path,
    fileOriginalName: row.file_original_name,
    fileSize: row.file_size,
    catatanKurator: row.catatan_kurator,
    penulisId: row.penulis_id,
    created_at: row.created_at,
    updated_at: row.updated_at,
  };
}

/**
 * Konversi baris DB users (snake_case) ke objek JavaScript (camelCase)
 */
function mapUser(row) {
  if (!row) return null;
  return {
    id: row.id,
    nama: row.nama,
    email: row.email,
    password_hash: row.password_hash,
    nim: row.nim,
    nip: row.nip,
    prodi: row.prodi,
    role: row.role,
    created_at: row.created_at,
    updated_at: row.updated_at,
  };
}

/**
 * Konversi baris DB review_logs ke objek JavaScript
 */
function mapReviewLog(row) {
  if (!row) return null;
  return {
    id: row.id,
    karyaId: row.karya_id,
    kuratorId: row.kurator_id,
    tindakan: row.tindakan,
    catatan: row.catatan,
    timestamp: row.created_at,
  };
}

// ── Helper error handler ──────────────────────────────────────────────

function throwIfError(error, context = '') {
  if (error) {
    console.error(`[DB Error] ${context}:`, error.message);
    throw new Error(`Database error${context ? ' (' + context + ')' : ''}: ${error.message}`);
  }
}

// ── Users (FR-01, FR-02) ─────────────────────────────────────────────

/**
 * Cari pengguna berdasarkan email, NIM, atau NIP (case-insensitive)
 */
async function findUserByEmailOrNim(identifier) {
  if (!identifier) return null;
  const clean = String(identifier).trim().toLowerCase();

  const { data, error } = await supabase
    .from('users')
    .select('*')
    .or(`email.ilike.${clean},nim.ilike.${clean},nip.ilike.${clean}`)
    .maybeSingle();

  throwIfError(error, 'findUserByEmailOrNim');
  return mapUser(data);
}

/**
 * Cari pengguna berdasarkan ID
 */
async function findUserById(id) {
  if (!id) return null;

  const { data, error } = await supabase
    .from('users')
    .select('*')
    .eq('id', id)
    .maybeSingle();

  throwIfError(error, 'findUserById');
  return mapUser(data);
}

/**
 * Buat akun pengguna baru (FR-01)
 */
async function createUser(userData) {
  const newId = `user-${Date.now()}`;

  const insertRow = {
    id: newId,
    nama: userData.nama,
    email: userData.email,
    password_hash: userData.password_hash,
    nim: userData.nim || null,
    nip: userData.nip || null,
    prodi: userData.prodi || 'Teknik Informatika',
    role: userData.role || 'penulis',
  };

  const { data, error } = await supabase
    .from('users')
    .insert(insertRow)
    .select()
    .single();

  throwIfError(error, 'createUser');
  return mapUser(data);
}

// ── Karya (FR-10, FR-14, FR-15, FR-20, FR-23, FR-30, FR-31, FR-34) ──

/**
 * Ambil seluruh karya lintas status (untuk kurator & statistik)
 */
async function getAllKarya() {
  const { data, error } = await supabase
    .from('karya')
    .select('*')
    .order('created_at', { ascending: false });

  throwIfError(error, 'getAllKarya');
  return (data || []).map(mapKarya);
}

/**
 * Filter dan pengurutan karya publik berstatus Diterbitkan (FR-30, FR-31)
 */
async function getPublishedKarya(filters = {}) {
  let query = supabase
    .from('karya')
    .select('*')
    .eq('status', 'Diterbitkan');

  // Filter jenis karya (FR-31)
  if (filters.jenis && filters.jenis !== 'all') {
    query = query.eq('jenis', filters.jenis);
  }

  // Filter program studi (FR-31)
  if (filters.prodi && filters.prodi !== 'all') {
    query = query.ilike('prodi_key', `%${filters.prodi.toLowerCase()}%`);
  }

  // Filter tahun (FR-31)
  if (filters.tahun) {
    const y = Number(filters.tahun);
    if (!isNaN(y)) query = query.eq('tahun', y);
  }

  // Filter pencarian full-text (FR-30)
  if (filters.q) {
    const q = filters.q.trim();
    query = query.or(
      `judul.ilike.%${q}%,penulis.ilike.%${q}%,nim.ilike.%${q}%,pembimbing.ilike.%${q}%,abstrak.ilike.%${q}%`
    );
  }

  // Pengurutan (FR-31 & FR-34)
  const sort = filters.sort || 'terbaru';
  if (sort === 'terpopuler' || sort === 'unduhan') {
    query = query.order('unduhan', { ascending: false });
  } else if (sort === 'judul_asc') {
    query = query.order('judul', { ascending: true });
  } else if (sort === 'judul_desc') {
    query = query.order('judul', { ascending: false });
  } else if (sort === 'tahun_asc') {
    query = query.order('tahun', { ascending: true });
  } else {
    // Default: terbaru (tahun DESC lalu created_at DESC)
    query = query.order('tahun', { ascending: false }).order('created_at', { ascending: false });
  }

  const { data, error } = await query;
  throwIfError(error, 'getPublishedKarya');
  return (data || []).map(mapKarya);
}

/**
 * Karya terbaru dan terpopuler untuk beranda (FR-34)
 */
async function getBerandaKarya(limit = 6) {
  const [terbaruRes, terpopulerRes] = await Promise.all([
    supabase
      .from('karya')
      .select('*')
      .eq('status', 'Diterbitkan')
      .order('tahun', { ascending: false })
      .order('created_at', { ascending: false })
      .limit(limit),

    supabase
      .from('karya')
      .select('*')
      .eq('status', 'Diterbitkan')
      .order('unduhan', { ascending: false })
      .limit(limit),
  ]);

  throwIfError(terbaruRes.error, 'getBerandaKarya/terbaru');
  throwIfError(terpopulerRes.error, 'getBerandaKarya/terpopuler');

  return {
    terbaru: (terbaruRes.data || []).map(mapKarya),
    terpopuler: (terpopulerRes.data || []).map(mapKarya),
  };
}

/**
 * Ambil satu karya berdasarkan ID
 */
async function getKaryaById(id) {
  const { data, error } = await supabase
    .from('karya')
    .select('*')
    .eq('id', id)
    .maybeSingle();

  throwIfError(error, 'getKaryaById');
  return mapKarya(data);
}

/**
 * Daftar karya milik penulis tertentu (FR-15)
 */
async function getKaryaByAuthor(authorId, authorName, statusFilter) {
  let query = supabase
    .from('karya')
    .select('*');

  if (authorId) {
    query = query.eq('penulis_id', authorId);
  } else if (authorName) {
    query = query.ilike('penulis', `%${authorName}%`);
  }

  if (statusFilter && statusFilter !== 'all') {
    query = query.eq('status', statusFilter);
  }

  query = query.order('created_at', { ascending: false });

  const { data, error } = await query;
  throwIfError(error, 'getKaryaByAuthor');
  return (data || []).map(mapKarya);
}

/**
 * Antrean kurator: status Diajukan & Dalam Review (FR-20)
 */
async function getKuratorQueue(statusFilter) {
  let query = supabase
    .from('karya')
    .select('*');

  if (statusFilter === 'Diajukan' || statusFilter === 'Dalam Review') {
    query = query.eq('status', statusFilter);
  } else {
    query = query.in('status', ['Diajukan', 'Dalam Review']);
  }

  query = query.order('created_at', { ascending: true }); // FIFO antrean

  const { data, error } = await query;
  throwIfError(error, 'getKuratorQueue');
  return (data || []).map(mapKarya);
}

/**
 * Buat karya baru (FR-10, FR-14)
 */
async function createKarya(karyaData) {
  const newId = `karya-${Date.now()}`;

  const insertRow = {
    id: newId,
    judul: karyaData.judul,
    penulis: karyaData.penulis,
    nim: karyaData.nim || null,
    pembimbing: karyaData.pembimbing,
    jenis: karyaData.jenis || 'skripsi',
    jenis_label: karyaData.jenisLabel || 'Skripsi S-1',
    prodi: karyaData.prodi || 'Teknik Informatika',
    prodi_key: karyaData.prodiKey || 'ti',
    tahun: karyaData.tahun || new Date().getFullYear(),
    abstrak: karyaData.abstrak,
    kata_kunci: Array.isArray(karyaData.kataKunci) ? karyaData.kataKunci : [],
    unduhan: 0,
    sitasi: 0,
    status: karyaData.status || 'Diajukan',
    tanggal_terbit: karyaData.tanggalTerbit || new Date().toLocaleDateString('id-ID', { day: '2-digit', month: 'long', year: 'numeric' }),
    doi: karyaData.doi || null,
    file_url: karyaData.fileUrl || null,
    file_path: karyaData.filePath || null,
    file_original_name: karyaData.fileOriginalName || null,
    file_size: karyaData.fileSize || '4.5 MB',
    catatan_kurator: karyaData.catatanKurator || null,
    penulis_id: karyaData.penulisId || null,
  };

  const { data, error } = await supabase
    .from('karya')
    .insert(insertRow)
    .select()
    .single();

  throwIfError(error, 'createKarya');
  return mapKarya(data);
}

/**
 * Perbarui data karya (FR-10, FR-14, FR-23)
 */
async function updateKarya(id, updateData) {
  // Konversi camelCase → snake_case untuk kolom yang mungkin diupdate
  const updateRow = {};
  if (updateData.judul !== undefined)           updateRow.judul = updateData.judul;
  if (updateData.pembimbing !== undefined)       updateRow.pembimbing = updateData.pembimbing;
  if (updateData.jenis !== undefined)            updateRow.jenis = updateData.jenis;
  if (updateData.jenisLabel !== undefined)       updateRow.jenis_label = updateData.jenisLabel;
  if (updateData.prodi !== undefined)            updateRow.prodi = updateData.prodi;
  if (updateData.prodiKey !== undefined)         updateRow.prodi_key = updateData.prodiKey;
  if (updateData.tahun !== undefined)            updateRow.tahun = updateData.tahun;
  if (updateData.abstrak !== undefined)          updateRow.abstrak = updateData.abstrak;
  if (updateData.kataKunci !== undefined)        updateRow.kata_kunci = updateData.kataKunci;
  if (updateData.status !== undefined)           updateRow.status = updateData.status;
  if (updateData.tanggalTerbit !== undefined)    updateRow.tanggal_terbit = updateData.tanggalTerbit;
  if (updateData.doi !== undefined)              updateRow.doi = updateData.doi;
  if (updateData.fileUrl !== undefined)          updateRow.file_url = updateData.fileUrl;
  if (updateData.filePath !== undefined)         updateRow.file_path = updateData.filePath;
  if (updateData.fileOriginalName !== undefined) updateRow.file_original_name = updateData.fileOriginalName;
  if (updateData.fileSize !== undefined)         updateRow.file_size = updateData.fileSize;
  if (updateData.catatanKurator !== undefined)   updateRow.catatan_kurator = updateData.catatanKurator;
  if (updateData.unduhan !== undefined)          updateRow.unduhan = updateData.unduhan;
  if (updateData.sitasi !== undefined)           updateRow.sitasi = updateData.sitasi;
  updateRow.updated_at = new Date().toISOString();

  const { data, error } = await supabase
    .from('karya')
    .update(updateRow)
    .eq('id', id)
    .select()
    .single();

  if (error) {
    if (error.code === 'PGRST116') return null; // Baris tidak ditemukan
    throwIfError(error, 'updateKarya');
  }

  return mapKarya(data);
}

/**
 * Catat unduhan karya dan tambah counter (FR-40, FR-41)
 */
async function incrementDownload(id, ipAddress = null, userAgent = null) {
  // Ambil data karya terlebih dahulu
  const karya = await getKaryaById(id);
  if (!karya) return null;

  const newCount = (karya.unduhan || 0) + 1;

  // Update counter unduhan
  const { error: updateError } = await supabase
    .from('karya')
    .update({ unduhan: newCount, updated_at: new Date().toISOString() })
    .eq('id', id);

  throwIfError(updateError, 'incrementDownload/update');

  // Insert log unduhan
  const logId = `dl-${Date.now()}`;
  const { error: logError } = await supabase
    .from('download_logs')
    .insert({
      id: logId,
      karya_id: id,
      ip_address: ipAddress,
      user_agent: userAgent,
    });

  // Log error tidak fatal — unduhan tetap tercatat di counter
  if (logError) {
    console.warn('[DB] Gagal menyimpan log unduhan:', logError.message);
  }

  return { ...karya, unduhan: newCount };
}

/**
 * Simpan log keputusan review kurator (FR-23)
 */
async function addReviewLog(karyaId, kuratorId, tindakan, catatan) {
  const logId = `rev-${Date.now()}`;

  const { data, error } = await supabase
    .from('review_logs')
    .insert({
      id: logId,
      karya_id: karyaId,
      kurator_id: kuratorId,
      tindakan,
      catatan: catatan || null,
    })
    .select()
    .single();

  throwIfError(error, 'addReviewLog');
  return mapReviewLog(data);
}

/**
 * Ambil seluruh log review untuk satu karya
 */
async function getReviewLogsByKarya(karyaId) {
  const { data, error } = await supabase
    .from('review_logs')
    .select('*')
    .eq('karya_id', karyaId)
    .order('created_at', { ascending: true });

  throwIfError(error, 'getReviewLogsByKarya');
  return (data || []).map(mapReviewLog);
}

module.exports = {
  findUserByEmailOrNim,
  findUserById,
  createUser,
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
};

