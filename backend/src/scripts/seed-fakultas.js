'use strict';

/**
 * seed-fakultas.js
 * Tambah 1 karya representative per fakultas ke Supabase PostgreSQL.
 * Juga membersihkan duplikat "Rancang Bangun..." yang terlalu banyak.
 */

const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_KEY) {
  console.error('SUPABASE_URL atau SUPABASE_KEY tidak ditemukan di .env!');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_KEY, {
  auth: { persistSession: false, autoRefreshToken: false },
});

// Karya representatif tiap Fakultas — 1 karya per prodi/fakultas
const karyaFakultas = [
  // FTI — Teknik Informatika (sudah ada banyak, skip)
  // FTI — Sistem Informasi (sudah ada 1 dari sebelumnya)

  // FEB — Manajemen (sudah ada tesis, tambah skripsi baru)
  {
    id: 'karya-feb-s1-001',
    judul: 'Analisis Faktor-Faktor yang Mempengaruhi Kepuasan Pelanggan Digital Banking di Era Post-Pandemic',
    penulis: 'Rizky Amelia Putri',
    nim: '2111101057',
    pembimbing: 'Dr. Bambang Irawan, M.M.',
    jenis: 'skripsi',
    jenis_label: 'Skripsi S-1',
    prodi: 'Manajemen',
    prodi_key: 'mnj',
    tahun: 2024,
    abstrak: 'Studi ini menganalisis 7 faktor penentu kepuasan nasabah layanan mobile banking (keamanan, kemudahan, fitur, respons, transparansi, personalisasi, dan layanan pelanggan) menggunakan structural equation modeling (SEM) pada 320 responden nasabah Bank Digital generasi Z dan Milenial di Surabaya. Hasil menunjukkan faktor keamanan dan personalisasi berpengaruh signifikan terhadap loyalitas jangka panjang.',
    kata_kunci: ['Manajemen', 'Digital Banking', 'SEM', 'Kepuasan Pelanggan', 'Loyalitas'],
    unduhan: 467,
    sitasi: 12,
    status: 'Diterbitkan',
    tanggal_terbit: '20 Agustus 2024',
    doi: '10.3301/feb.2024.054',
    file_size: '4.2 MB',
    penulis_id: null,
  },

  // FEB — tambah Akuntansi
  {
    id: 'karya-feb-akn-001',
    judul: 'Implementasi SAK ETAP dan Dampaknya terhadap Kualitas Laporan Keuangan UMKM Sektor Kuliner di Kota Malang',
    penulis: 'Dinda Maharani Kusuma',
    nim: '2111102089',
    pembimbing: 'Dr. Hj. Sri Wahyuningsih, M.Si., Ak.',
    jenis: 'skripsi',
    jenis_label: 'Skripsi S-1',
    prodi: 'Akuntansi',
    prodi_key: 'mnj',
    tahun: 2025,
    abstrak: 'Penelitian kualitatif-deskriptif mengevaluasi kesiapan 45 UMKM kuliner Kota Malang dalam menerapkan Standar Akuntansi Keuangan Entitas Tanpa Akuntabilitas Publik (SAK ETAP) pasca pandemi. Temuan menunjukkan 68% UMKM masih menggunakan pencatatan sederhana dan hanya 24% yang telah menerapkan SAK ETAP secara konsisten.',
    kata_kunci: ['Akuntansi', 'SAK ETAP', 'UMKM', 'Laporan Keuangan'],
    unduhan: 312,
    sitasi: 8,
    status: 'Diterbitkan',
    tanggal_terbit: '15 Maret 2025',
    doi: '10.3301/feb.2025.021',
    file_size: '3.8 MB',
    penulis_id: null,
  },

  // FDS — DKV (sudah ada 1, tambah 1 lagi berbeda)
  {
    id: 'karya-fds-dkv-002',
    judul: 'Perancangan Kampanye Visual "Laut Bersih 2026" Berbasis Motion Graphics untuk Platform Media Sosial Generasi Z',
    penulis: 'Naufal Ardiansyah',
    nim: '2112201063',
    pembimbing: 'Ardi Cahyono, M.Ds.',
    jenis: 'skripsi',
    jenis_label: 'Skripsi S-1',
    prodi: 'Desain Komunikasi Visual',
    prodi_key: 'dkv',
    tahun: 2025,
    abstrak: 'Perancangan kampanye visual lingkungan bertema pembersihan laut menggunakan pendekatan motion graphics dengan gaya flat illustration dan tipografi ekspresif untuk menjangkau audiens Gen Z di platform TikTok dan Instagram Reels. Proses perancangan mencakup studi semiotika visual, uji keterbacaan, dan A/B testing terhadap 200 responden kelompok usia 17-25 tahun.',
    kata_kunci: ['DKV', 'Motion Graphics', 'Kampanye Lingkungan', 'Media Sosial', 'Gen Z'],
    unduhan: 298,
    sitasi: 6,
    status: 'Diterbitkan',
    tanggal_terbit: '10 Januari 2025',
    doi: '10.4412/fds.2025.017',
    file_size: '8.1 MB',
    penulis_id: null,
  },

  // FIKOM — Ilmu Komunikasi (sudah ada 1, tambah 1 Hubungan Masyarakat)
  {
    id: 'karya-fikom-humas-001',
    judul: 'Strategi Personal Branding Pemimpin Daerah melalui Instagram: Studi Kasus Walikota Surabaya 2020-2024',
    penulis: 'Aulia Rahmawati',
    nim: '2113301094',
    pembimbing: 'Dr. Farida Hanum, M.I.Kom.',
    jenis: 'skripsi',
    jenis_label: 'Skripsi S-1',
    prodi: 'Ilmu Komunikasi',
    prodi_key: 'ilkom',
    tahun: 2024,
    abstrak: 'Penelitian kualitatif menganalisis strategi personal branding Walikota Surabaya di Instagram menggunakan teori ekuitas merek Keller. Analisis konten terhadap 1.240 unggahan dalam rentang 4 tahun menunjukkan pola komunikasi yang konsisten dalam membangun citra pemimpin muda, inovatif, dan dekat rakyat dengan engagement rate rata-rata 3,2% di atas benchmark nasional.',
    kata_kunci: ['Ilmu Komunikasi', 'Personal Branding', 'Media Sosial', 'Pemimpin Daerah', 'Instagram'],
    unduhan: 345,
    sitasi: 9,
    status: 'Diterbitkan',
    tanggal_terbit: '05 November 2024',
    doi: '10.5523/fikom.2024.088',
    file_size: '5.3 MB',
    penulis_id: null,
  },

  // Pascasarjana — Magister Ilmu Komputer (tesis)
  {
    id: 'karya-pasca-mik-001',
    judul: 'Arsitektur Hybrid Cloud-Edge untuk Pemrosesan Data IoT Kesehatan dengan Jaminan Privasi Diferensial',
    penulis: 'Hendra Prakoso, S.Kom.',
    nim: null,
    pembimbing: 'Prof. Dr. Ir. Achmad Zaini, M.Eng.',
    jenis: 'tesis',
    jenis_label: 'Tesis S-2',
    prodi: 'Magister Ilmu Komputer',
    prodi_key: 'ti',
    tahun: 2025,
    abstrak: 'Tesis ini mengusulkan arsitektur hybrid cloud-edge untuk sistem kesehatan IoT yang mengintegrasikan mekanisme differential privacy (ε-DP) langsung di lapisan edge node sebelum data dikirimkan ke cloud. Evaluasi pada dataset EHR real-world dari 3 klinik menunjukkan kompromi privasi-akurasi yang optimal pada ε=0.5 dengan degradasi akurasi model prediksi hanya 1.8%.',
    kata_kunci: ['Cloud Computing', 'Edge AI', 'IoT Kesehatan', 'Differential Privacy', 'Tesis'],
    unduhan: 203,
    sitasi: 15,
    status: 'Diterbitkan',
    tanggal_terbit: '28 Juli 2025',
    doi: '10.2412/mik.2025.003',
    file_size: '7.6 MB',
    penulis_id: null,
  },

  // LPPM — Jurnal Penelitian Dosen
  {
    id: 'karya-lppm-jurnal-001',
    judul: 'Penerapan Gamifikasi Berbasis Blockchain untuk Sistem Reward Mahasiswa Berprestasi: Pendekatan Desain Partisipatif',
    penulis: 'Dr. Wahyu Tri Handoyo, M.Kom.',
    nim: null,
    pembimbing: null,
    jenis: 'jurnal',
    jenis_label: 'Artikel Jurnal (SINTA 2)',
    prodi: 'Teknik Informatika',
    prodi_key: 'ti',
    tahun: 2025,
    abstrak: 'Artikel ini memaparkan perancangan dan evaluasi sistem gamifikasi berbasis smart contract Ethereum untuk program penghargaan mahasiswa di perguruan tinggi. Prototype diuji pada 150 mahasiswa selama satu semester akademik. Hasil menunjukkan peningkatan signifikan pada keterlibatan akademik (engagement +42%) dan transparansi distribusi reward dibandingkan sistem konvensional.',
    kata_kunci: ['Gamifikasi', 'Blockchain', 'Smart Contract', 'Pendidikan Tinggi', 'SINTA'],
    unduhan: 521,
    sitasi: 23,
    status: 'Diterbitkan',
    tanggal_terbit: '15 April 2025',
    doi: '10.2412/jti.2025.011',
    file_size: '3.1 MB',
    penulis_id: null,
  },
];

async function cleanDuplicates() {
  console.log('\n[1] Membersihkan karya duplikat "Rancang Bangun Sistem Informasi Repositori"...');
  const { data: dupes } = await supabase
    .from('karya')
    .select('id, judul, created_at, unduhan')
    .ilike('judul', '%Rancang Bangun Sistem Informasi Repositori Kampus%')
    .order('created_at', { ascending: true });

  if (!dupes || dupes.length <= 1) {
    console.log('   Tidak ada duplikat yang perlu dihapus.');
    return;
  }

  // Simpan 1 yang paling awal (index 0), hapus sisanya
  const toDelete = dupes.slice(1).map(d => d.id);
  console.log(`   Duplikat ditemukan: ${dupes.length}. Menyimpan 1, menghapus ${toDelete.length}...`);

  for (const id of toDelete) {
    const { error } = await supabase.from('karya').delete().eq('id', id);
    if (error) {
      console.warn(`   Gagal hapus ${id}:`, error.message);
    } else {
      console.log(`   ✓ Dihapus: ${id}`);
    }
  }
}

async function seedFakultas() {
  console.log('\n[2] Menambahkan karya representatif per fakultas...');
  for (const karya of karyaFakultas) {
    // Cek apakah ID sudah ada
    const { data: existing } = await supabase
      .from('karya')
      .select('id')
      .eq('id', karya.id)
      .maybeSingle();

    if (existing) {
      console.log(`   ⏭ Skip (sudah ada): ${karya.id} — ${karya.judul.slice(0, 50)}`);
      continue;
    }

    const { error } = await supabase.from('karya').insert(karya);
    if (error) {
      console.error(`   ✗ Gagal insert ${karya.id}:`, error.message);
    } else {
      console.log(`   ✓ Ditambahkan: [${karya.prodi_key}/${karya.jenis}] ${karya.judul.slice(0, 55)}`);
    }
  }
}

async function printSummary() {
  console.log('\n[3] Ringkasan akhir database...');
  const { data } = await supabase
    .from('karya')
    .select('prodi_key, jenis, status, unduhan')
    .order('prodi_key');

  const summary = {};
  data.forEach(k => {
    const key = k.prodi_key || 'unknown';
    if (!summary[key]) summary[key] = { total: 0, terbit: 0, unduhan: 0 };
    summary[key].total++;
    if (k.status === 'Diterbitkan') {
      summary[key].terbit++;
      summary[key].unduhan += k.unduhan || 0;
    }
  });

  Object.entries(summary).forEach(([prodi, s]) => {
    console.log(`   ${prodi.padEnd(8)}: ${s.total} karya total, ${s.terbit} terbit, ${s.unduhan.toLocaleString('id-ID')} unduhan`);
  });

  const totalUnduhan = data.reduce((s, k) => s + (k.unduhan || 0), 0);
  console.log(`\n   Total karya DB: ${data.length}`);
  console.log(`   Total unduhan DB: ${totalUnduhan.toLocaleString('id-ID')}`);
}

(async () => {
  try {
    await cleanDuplicates();
    await seedFakultas();
    await printSummary();
    console.log('\n✅ Seeding selesai!');
  } catch (err) {
    console.error('Error saat seeding:', err.message);
    process.exit(1);
  }
})();

