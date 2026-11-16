'use strict';

const { z } = require('zod');

// FR-01 & FR-02: Registrasi Penulis & Kurator
const registerSchema = z.object({
  nama: z.string().min(3, 'Nama lengkap minimal 3 karakter'),
  email: z.string().email('Format email tidak valid'),
  password: z.string().min(6, 'Kata sandi minimal 6 karakter'),
  nim: z.string().optional(),
  nip: z.string().optional(),
  prodi: z.string().default('Teknik Informatika'),
  role: z.string().optional().transform((val) => {
    if (!val) return 'penulis';
    const clean = val.toLowerCase().trim();
    if (clean === 'curator' || clean === 'kurator') return 'kurator';
    return 'penulis';
  }),
});

// FR-01: Login dengan Email (atau NIM/NIP) + Password
const loginSchema = z.object({
  email: z.string().optional(),
  identifier: z.string().optional(),
  password: z.string().min(1, 'Kata sandi wajib diisi'),
  role: z.string().optional().transform((val) => {
    if (!val) return undefined;
    const clean = val.toLowerCase().trim();
    if (clean === 'curator' || clean === 'kurator') return 'kurator';
    if (clean === 'student' || clean === 'penulis') return 'penulis';
    return undefined;
  }),
}).refine((data) => data.email || data.identifier, {
  message: 'Email atau NIM/NIP wajib diisi.',
  path: ['email']
});

module.exports = {
  registerSchema,
  loginSchema,
};
