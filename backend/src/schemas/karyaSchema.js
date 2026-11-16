'use strict';

const { z } = require('zod');

const PRODI_KEY_MAP = {
  'teknik informatika': 'ti',
  'sistem informasi': 'si',
  'desain komunikasi visual': 'dkv',
  'manajemen': 'mnj',
  'manajemen bisnis': 'mnj',
  'ilmu komunikasi': 'ilkom'
};

const JENIS_LABEL_MAP = {
  'skripsi': 'Skripsi S-1',
  'tesis': 'Tesis S-2',
  'jurnal': 'Artikel Jurnal Ilmiah',
  'kp': 'Laporan Kerja Praktik',
  'penelitian': 'Laporan Penelitian',
  'laporan_penelitian': 'Laporan Penelitian'
};

// Skema Validasi Pengajuan / Penyimpanan Karya (FR-10, FR-14)
const createKaryaSchema = z.object({
  judul: z.string().min(3, 'Judul minimal 3 karakter'),
  abstrak: z.string().min(10, 'Abstrak minimal 10 karakter'),
  pembimbing: z.string().min(2, 'Nama pembimbing wajib diisi'),
  jenis: z.enum(['skripsi', 'tesis', 'jurnal', 'kp', 'penelitian', 'laporan_penelitian']),
  jenisLabel: z.string().optional(),
  prodi: z.string().default('Teknik Informatika'),
  prodiKey: z.enum(['all', 'ti', 'si', 'dkv', 'mnj', 'ilkom']).optional(),
  tahun: z.number().int().min(1990).max(2035).default(new Date().getFullYear()),
  kataKunci: z.array(z.string()).or(z.string()).default([]),
  status: z.enum(['Draft', 'Diajukan', 'Dalam Review', 'Perlu Revisi', 'Diterbitkan', 'Ditolak']).default('Diajukan'),
  nim: z.string().optional(),
  penulis: z.string().optional(),
  fileUrl: z.string().optional(),
  filePath: z.string().optional(),
  fileOriginalName: z.string().optional(),
  fileSize: z.string().optional(),
});

// Skema Validasi Update Draft / Revisi Penulis (FR-10, FR-14)
const updateKaryaSchema = z.object({
  judul: z.string().min(3, 'Judul minimal 3 karakter').optional(),
  abstrak: z.string().min(10, 'Abstrak minimal 10 karakter').optional(),
  pembimbing: z.string().min(2, 'Nama pembimbing wajib diisi').optional(),
  jenis: z.enum(['skripsi', 'tesis', 'jurnal', 'kp', 'penelitian', 'laporan_penelitian']).optional(),
  jenisLabel: z.string().optional(),
  prodi: z.string().optional(),
  prodiKey: z.enum(['all', 'ti', 'si', 'dkv', 'mnj', 'ilkom']).optional(),
  tahun: z.number().int().min(1990).max(2035).optional(),
  kataKunci: z.array(z.string()).or(z.string()).optional(),
  fileUrl: z.string().optional(),
  filePath: z.string().optional(),
  fileOriginalName: z.string().optional(),
  fileSize: z.string().optional(),
  submitForReview: z.boolean().optional(),
});

// Skema Keputusan Review Kurator (FR-23)
const reviewKaryaSchema = z.object({
  tindakan: z.enum(['terbitkan', 'revisi', 'tolak']),
  catatan: z.string().optional().default(''),
});

module.exports = {
  PRODI_KEY_MAP,
  JENIS_LABEL_MAP,
  createKaryaSchema,
  updateKaryaSchema,
  reviewKaryaSchema,
};
