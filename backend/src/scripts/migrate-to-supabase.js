'use strict';

/**
 * migrate-to-supabase.js
 * Memindahkan semua data dari seed.js & database.json ke Supabase PostgreSQL.
 * Menggunakan upsert agar tidak menimpa duplikasi sembarangan.
 */

const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('SUPABASE_URL atau SUPABASE_KEY tidak ditemukan di .env!');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY);

const { initialUsers, initialKaryaList } = require('../data/seed');

let jsonUsers = [];
let jsonKarya = [];
const dbJsonPath = path.resolve(__dirname, '../../data/database.json');
if (fs.existsSync(dbJsonPath)) {
  try {
    const raw = JSON.parse(fs.readFileSync(dbJsonPath, 'utf8'));
    jsonUsers = raw.users || [];
    jsonKarya = raw.karya || [];
  } catch (e) {
    console.warn('Gagal membaca database.json:', e.message);
  }
}

async function migrate() {
  console.log('=== MEMULAI MIGRASI DATA KE SUPABASE POSTGRESQL ===');

  // 1. Migrasi Pengguna (Users)
  const allUsersMap = new Map();
  [...initialUsers, ...jsonUsers].forEach(u => {
    if (u && u.email && !allUsersMap.has(u.email.toLowerCase())) {
      allUsersMap.set(u.email.toLowerCase(), u);
    }
  });

  const usersToInsert = [];
  for (const u of allUsersMap.values()) {
    usersToInsert.push({
      id: u.id || `user-${Date.now()}-${Math.floor(Math.random() * 1000)}`,
      nama: u.nama,
      email: u.email.toLowerCase().trim(),
      password_hash: u.password_hash,
      nim: u.nim || null,
      nip: u.nip || null,
      prodi: u.prodi || 'Teknik Informatika',
      role: u.role || 'penulis',
    });
  }

  console.log(`Mengunggah ${usersToInsert.length} data pengguna ke Supabase...`);
  for (const u of usersToInsert) {
    const { error } = await supabase
      .from('users')
      .upsert(u, { onConflict: 'email' });
    if (error) {
      console.warn(`Peringatan insert user (${u.email}):`, error.message);
    }
  }
  console.log('✓ Pengguna berhasil dimigrasikan.');

  // 2. Migrasi Karya Ilmiah (Karya)
  const allKaryaMap = new Map();
  [...initialKaryaList, ...jsonKarya].forEach(k => {
    if (k && k.id && !allKaryaMap.has(k.id)) {
      allKaryaMap.set(k.id, k);
    }
  });

  const validProdiKeyMap = {
    'teknik informatika': 'ti',
    'sistem informasi': 'si',
    'desain komunikasi visual': 'dkv',
    'manajemen': 'mnj',
    'manajemen bisnis': 'mnj',
    'ilmu komunikasi': 'ilkom'
  };

  const validJenisLabelMap = {
    'skripsi': 'Skripsi S-1',
    'tesis': 'Tesis Magister S-2',
    'jurnal': 'Jurnal Ilmiah',
    'kp': 'Laporan Kerja Praktik',
    'penelitian': 'Laporan Riset Dosen'
  };

  const karyaToInsert = [];
  for (const k of allKaryaMap.values()) {
    const prodiClean = (k.prodi || 'Teknik Informatika').toLowerCase();
    const prodiKey = k.prodiKey || validProdiKeyMap[prodiClean] || 'ti';
    const jenis = (k.jenis || 'skripsi').toLowerCase();
    const jenisLabel = k.jenisLabel || validJenisLabelMap[jenis] || 'Skripsi S-1';

    // Pastikan jenis valid ENUM: 'skripsi', 'tesis', 'jurnal', 'kp', 'penelitian'
    const allowedJenis = ['skripsi', 'tesis', 'jurnal', 'kp', 'penelitian'];
    const safeJenis = allowedJenis.includes(jenis) ? jenis : 'skripsi';

    // Pastikan status valid ENUM: 'Draft', 'Diajukan', 'Dalam Review', 'Perlu Revisi', 'Diterbitkan', 'Ditolak'
    const allowedStatus = ['Draft', 'Diajukan', 'Dalam Review', 'Perlu Revisi', 'Diterbitkan', 'Ditolak'];
    const safeStatus = allowedStatus.includes(k.status) ? k.status : 'Diterbitkan';

    karyaToInsert.push({
      id: k.id,
      judul: k.judul,
      penulis: k.penulis,
      nim: k.nim || null,
      pembimbing: k.pembimbing || 'Tim Dosen Pembimbing',
      jenis: safeJenis,
      jenis_label: jenisLabel,
      prodi: k.prodi || 'Teknik Informatika',
      prodi_key: prodiKey,
      tahun: Number(k.tahun) || 2026,
      abstrak: k.abstrak || 'Abstrak naskah karya ilmiah repositori kampus.',
      kata_kunci: Array.isArray(k.kataKunci) ? k.kataKunci : ['Karya Ilmiah', k.prodi || 'Kampus'],
      unduhan: Number(k.unduhan) || 0,
      sitasi: Number(k.sitasi) || 0,
      status: safeStatus,
      tanggal_terbit: k.tanggalTerbit || '24 Oktober 2026',
      doi: k.doi || (safeStatus === 'Diterbitkan' ? `10.2412/imc.${k.tahun || 2026}.${Math.floor(100 + Math.random() * 900)}` : null),
      file_url: k.fileUrl || null,
      file_path: k.filePath || null,
      file_size: k.fileSize || '4.5 MB',
      catatan_kurator: k.catatanKurator || null,
      penulis_id: k.penulisId || null,
    });
  }

  console.log(`Mengunggah ${karyaToInsert.length} naskah karya ilmiah ke Supabase...`);
  for (const row of karyaToInsert) {
    const { error } = await supabase
      .from('karya')
      .upsert(row, { onConflict: 'id' });
    if (error) {
      console.warn(`Peringatan insert karya (${row.id}):`, error.message);
    }
  }

  console.log('✓ Seluruh data karya ilmiah berhasil dimigrasikan ke Supabase PostgreSQL!');

  // Ambil total karya sekarang di Supabase
  const { data: countData } = await supabase.from('karya').select('id, judul, prodi, unduhan, status');
  console.log(`\nTotal karya aktif di Supabase sekarang: ${countData?.length || 0} naskah.`);
}

migrate().then(() => {
  console.log('Selesai!');
  process.exit(0);
}).catch(err => {
  console.error('Migrasi gagal:', err);
  process.exit(1);
});

