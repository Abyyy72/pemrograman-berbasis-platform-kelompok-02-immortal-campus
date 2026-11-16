'use strict';

const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const { findUserByEmailOrNim, createUser } = require('../lib/db');
const { registerSchema, loginSchema } = require('../schemas/authSchema');
const requireAuth = require('../middleware/requireAuth');

const JWT_SECRET = process.env.JWT_SECRET || 'immortal_campus_super_secret_jwt_key_2026';
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d';

/**
 * POST /api/v1/auth/register (FR-01, FR-02)
 * Mendaftar akun baru (Penulis mahasiswa/dosen atau Kurator perpustakaan)
 */
router.post('/register', async (req, res, next) => {
  try {
    const result = registerSchema.safeParse(req.body);
    if (!result.success) {
      const fieldErrors = result.error.flatten().fieldErrors;
      const firstErrorMessage = Object.values(fieldErrors).flat()[0] || 'Validasi registrasi gagal.';
      return res.status(400).json({
        status: false,
        message: firstErrorMessage,
        errors: fieldErrors,
      });
    }

    const { nama, email, password, nim, nip, prodi, role } = result.data;
    const cleanEmail = email.trim().toLowerCase();
    const cleanNim = nim && nim.trim() ? nim.trim() : undefined;
    const cleanNip = nip && nip.trim() ? nip.trim() : undefined;

    // Cek duplikasi akun
    const existingEmail = await findUserByEmailOrNim(cleanEmail);
    const existingNim = cleanNim ? await findUserByEmailOrNim(cleanNim) : null;
    const existingNip = cleanNip ? await findUserByEmailOrNim(cleanNip) : null;

    if (existingEmail || existingNim || existingNip) {
      return res.status(409).json({
        status: false,
        message: 'Akun dengan email, NIM, atau NIP tersebut sudah terdaftar.',
      });
    }

    const password_hash = await bcrypt.hash(password, 10);
    const newUser = await createUser({
      nama: nama.trim(),
      email: cleanEmail,
      password_hash,
      nim: cleanNim,
      nip: cleanNip,
      prodi: prodi || 'Teknik Informatika',
      role: role || 'penulis'
    });

    const token = jwt.sign(
      { id: newUser.id, role: newUser.role, email: newUser.email, nama: newUser.nama },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    return res.status(201).json({
      status: true,
      message: `Registrasi berhasil sebagai ${newUser.role.toUpperCase()}. Akun Anda telah aktif.`,
      data: {
        token,
        user: {
          id: newUser.id,
          nama: newUser.nama,
          email: newUser.email,
          nim: newUser.nim,
          nip: newUser.nip,
          prodi: newUser.prodi,
          role: newUser.role,
        }
      }
    });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/v1/auth/login (FR-01, FR-02)
 * Masuk dengan email/NIM/NIP + kata sandi
 */
router.post('/login', async (req, res, next) => {
  try {
    const result = loginSchema.safeParse(req.body);
    if (!result.success) {
      return res.status(400).json({
        status: false,
        message: 'Email atau kata sandi tidak boleh kosong.',
        errors: result.error.flatten().fieldErrors,
      });
    }

    const identifier = (result.data.email || result.data.identifier || '').trim();
    const { password, role } = result.data;
    const user = await findUserByEmailOrNim(identifier);

    if (!user) {
      return res.status(401).json({
        status: false,
        message: 'Kredensial tidak valid. Akun dengan email/identitas tersebut belum terdaftar.',
      });
    }

    const validPassword = await bcrypt.compare(password, user.password_hash);
    if (!validPassword) {
      return res.status(401).json({
        status: false,
        message: 'Kata sandi salah. Silakan periksa kembali kata sandi Anda.',
      });
    }

    // Gunakan peran resmi dari database pengguna
    const token = jwt.sign(
      { id: user.id, role: user.role, email: user.email, nama: user.nama },
      JWT_SECRET,
      { expiresIn: JWT_EXPIRES_IN }
    );

    return res.status(200).json({
      status: true,
      message: `Berhasil masuk sebagai ${user.nama} (${user.role.toUpperCase()})`,
      data: {
        token,
        user: {
          id: user.id,
          nama: user.nama,
          email: user.email,
          nim: user.nim,
          nip: user.nip,
          prodi: user.prodi,
          role: user.role,
        }
      }
    });
  } catch (err) {
    next(err);
  }
});

/**
 * GET /api/v1/auth/me (FR-01, FR-02)
 * Mengambil informasi profil akun yang sedang login
 */
router.get('/me', requireAuth, (req, res) => {
  const { password_hash, ...safeUser } = req.user;
  return res.status(200).json({
    status: true,
    message: 'Profil pengguna berhasil dimuat.',
    data: safeUser,
  });
});

/**
 * POST /api/v1/auth/logout
 * Keluar dari sesi akun
 */
router.post('/logout', (_req, res) => {
  return res.status(200).json({
    status: true,
    message: 'Berhasil keluar (logout) dari sesi.',
  });
});

module.exports = router;
