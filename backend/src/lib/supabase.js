'use strict';

const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const { createClient } = require('@supabase/supabase-js');

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY;
const STORAGE_BUCKET = process.env.SUPABASE_STORAGE_BUCKET || 'immortal-karya';

let supabaseClient = null;

if (SUPABASE_URL && SUPABASE_KEY) {
  try {
    supabaseClient = createClient(SUPABASE_URL, SUPABASE_KEY, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });
    console.log(`[Supabase Storage] Terhubung ke ${SUPABASE_URL} (Bucket: ${STORAGE_BUCKET})`);
  } catch (err) {
    console.warn('[Supabase Storage] Gagal inisialisasi klien Supabase:', err.message);
    supabaseClient = null;
  }
} else {
  console.log('[Supabase Storage] SUPABASE_URL / SUPABASE_KEY belum disetel. Menggunakan local disk storage fallback.');
}

/**
 * Cek apakah Supabase Storage aktif
 */
function isSupabaseStorageEnabled() {
  return !!supabaseClient;
}

/**
 * Unggah berkas buffer ke private bucket Supabase Storage
 * @param {Buffer} buffer - Konten berkas
 * @param {string} destinationPath - Jalur berkas di bucket
 * @param {string} contentType - Tipe konten (mis. application/pdf)
 */
async function uploadToStorage(buffer, destinationPath, contentType = 'application/pdf') {
  if (!supabaseClient) {
    throw new Error('Supabase Storage tidak terkonfigurasi');
  }

  const { data, error } = await supabaseClient.storage
    .from(STORAGE_BUCKET)
    .upload(destinationPath, buffer, {
      contentType,
      upsert: true,
    });

  if (error) {
    throw error;
  }

  return data;
}

/**
 * Buat signed download URL untuk berkas dari private bucket (PRD Seksi 14)
 * @param {string} filePath - Jalur berkas di bucket
 * @param {number} expiresIn - Durasi masa berlaku token dalam detik (default: 3600 = 1 jam)
 */
async function getSignedDownloadUrl(filePath, expiresIn = 3600) {
  if (!supabaseClient) return null;

  try {
    const { data, error } = await supabaseClient.storage
      .from(STORAGE_BUCKET)
      .createSignedUrl(filePath, expiresIn);

    if (error || !data) {
      console.warn('[Supabase Storage] Gagal membuat signed URL:', error?.message);
      return null;
    }

    return data.signedUrl;
  } catch (err) {
    console.warn('[Supabase Storage] Error saat generate signed URL:', err.message);
    return null;
  }
}

module.exports = {
  supabaseClient,
  STORAGE_BUCKET,
  isSupabaseStorageEnabled,
  uploadToStorage,
  getSignedDownloadUrl,
};

