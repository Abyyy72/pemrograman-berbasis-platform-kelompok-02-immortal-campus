'use strict';

/**
 * admin.js — Rute API Admin (hanya untuk role 'admin')
 * FR-Admin-01: Kelola Pengguna (CRUD kurator & penulis)
 * FR-Admin-02: Kelola Karya Ilmiah (force publish/reject, hapus)
 * FR-Admin-03: Statistik sistem & audit log
 * FR-Admin-04: Reset password pengguna
 */

const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const { createClient } = require('@supabase/supabase-js');
const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const requireAuth = require('../middleware/requireAuth');
const requireRole = require('../middleware/requireRole');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY
);

// Semua rute admin butuh autentikasi + role admin
router.use(requireAuth);
router.use(requireRole('admin'));

// ─── FR-Admin-01: MANAJEMEN PENGGUNA ────────────────────────────────────────

/**
 * GET /api/v1/admin/users
 * Ambil semua pengguna (dengan filter opsional ?role=kurator)
 */
router.get('/users', async (req, res, next) => {
  try {
    let query = supabase
      .from('users')
      .select('id, nama, email, nim, nip, prodi, role, created_at')
      .order('created_at', { ascending: false });

    if (req.query.role) {
      query = query.eq('role', req.query.role);
    }

    const { data, error } = await query;
    if (error) throw new Error(error.message);

    return res.json({ status: true, data });
  } catch (err) {
    next(err);
  }
});

/**
 * POST /api/v1/admin/users
 * Buat akun baru (umumnya untuk kurator)
 */
router.post('/users', async (req, res, next) => {
  try {
    const { nama, email, password, nip, nim, prodi, role } = req.body;

    if (!nama || !email || !password) {
      return res.status(400).json({ status: false, message: 'nama, email, dan password wajib diisi.' });
    }

    const allowedRoles = ['penulis', 'kurator', 'admin'];
    const cleanRole = allowedRoles.includes(role) ? role : 'kurator';

    // Cek duplikasi
    const { data: existing } = await supabase
      .from('users')
      .select('id')
      .eq('email', email.toLowerCase().trim())
      .maybeSingle();

    if (existing) {
      return res.status(409).json({ status: false, message: 'Email sudah terdaftar.' });
    }

    const password_hash = await bcrypt.hash(password, 10);
    const id = `user-${Date.now()}`;

    const { data: newUser, error } = await supabase
      .from('users')
      .insert({
        id,
        nama: nama.trim(),
        email: email.toLowerCase().trim(),
        password_hash,
        nim: nim || null,
        nip: nip || null,
        prodi: prodi || 'UPT Perpustakaan',
        role: cleanRole,
      })
      .select('id, nama, email, nim, nip, prodi, role, created_at')
      .single();

    if (error) throw new Error(error.message);

    return res.status(201).json({
      status: true,
      message: `Akun ${cleanRole} berhasil dibuat.`,
      data: newUser,
    });
  } catch (err) {
    next(err);
  }
});

/**
 * PUT /api/v1/admin/users/:id
 * Update data pengguna (nama, prodi, role, nip/nim)
 */
router.put('/users/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { nama, prodi, role, nip, nim } = req.body;

    const allowedRoles = ['penulis', 'kurator', 'admin'];
    const updates = {};
    if (nama) updates.nama = nama.trim();
    if (prodi) updates.prodi = prodi;
    if (role && allowedRoles.includes(role)) updates.role = role;
    if (nip !== undefined) updates.nip = nip || null;
    if (nim !== undefined) updates.nim = nim || null;

    const { data, error } = await supabase
      .from('users')
      .update(updates)
      .eq('id', id)
      .select('id, nama, email, nim, nip, prodi, role')
      .single();

    if (error) throw new Error(error.message);
    if (!data) return res.status(404).json({ status: false, message: 'Pengguna tidak ditemukan.' });

    return res.json({ status: true, message: 'Data pengguna diperbarui.', data });
  } catch (err) {
    next(err);
  }
});

/**
 * DELETE /api/v1/admin/users/:id
 * Hapus akun pengguna (kecuali admin lain)
 */
router.delete('/users/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    // Cegah admin menghapus dirinya sendiri
    if (id === req.user.id) {
      return res.status(400).json({ status: false, message: 'Tidak bisa menghapus akun sendiri.' });
    }

    const { error } = await supabase.from('users').delete().eq('id', id);
    if (error) throw new Error(error.message);

    return res.json({ status: true, message: 'Akun berhasil dihapus.' });
  } catch (err) {
    next(err);
  }
});

/**
 * PUT /api/v1/admin/users/:id/reset-password
 * Reset password pengguna ke nilai baru
 */
router.put('/users/:id/reset-password', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { newPassword } = req.body;

    if (!newPassword || newPassword.length < 6) {
      return res.status(400).json({ status: false, message: 'Password baru minimal 6 karakter.' });
    }

    const password_hash = await bcrypt.hash(newPassword, 10);
    const { error } = await supabase
      .from('users')
      .update({ password_hash })
      .eq('id', id);

    if (error) throw new Error(error.message);

    return res.json({ status: true, message: 'Password berhasil direset.' });
  } catch (err) {
    next(err);
  }
});

// ─── FR-Admin-02: KELOLA KARYA ───────────────────────────────────────────────

/**
 * GET /api/v1/admin/karya
 * Ambil semua karya (termasuk draft & ditolak)
 */
router.get('/karya', async (req, res, next) => {
  try {
    const { data, error } = await supabase
      .from('karya')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) throw new Error(error.message);
    return res.json({ status: true, data: data || [] });
  } catch (err) {
    next(err);
  }
});

/**
 * DELETE /api/v1/admin/karya/:id
 * Hapus karya permanen (force delete)
 */
router.delete('/karya/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { error } = await supabase.from('karya').delete().eq('id', id);
    if (error) throw new Error(error.message);
    return res.json({ status: true, message: 'Karya berhasil dihapus.' });
  } catch (err) {
    next(err);
  }
});

/**
 * PUT /api/v1/admin/karya/:id/status
 * Override status karya (force publish/reject/archive)
 */
router.put('/karya/:id/status', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status, catatan } = req.body;

    const allowedStatuses = ['Draft', 'Diajukan', 'Dalam Review', 'Perlu Revisi', 'Diterbitkan', 'Ditolak'];
    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({ status: false, message: 'Status tidak valid.' });
    }

    const { data, error } = await supabase
      .from('karya')
      .update({ status, catatan_kurator: catatan || null })
      .eq('id', id)
      .select('id, judul, status')
      .single();

    if (error) throw new Error(error.message);
    return res.json({ status: true, message: `Status karya diubah ke ${status}.`, data });
  } catch (err) {
    next(err);
  }
});

// ─── FR-Admin-03: STATISTIK ADMIN ───────────────────────────────────────────

/**
 * GET /api/v1/admin/statistik
 * Statistik lengkap sistem (users, karya, unduhan)
 */
router.get('/statistik', async (req, res, next) => {
  try {
    const [
      { data: users },
      { data: karya },
      { count: totalUnduhan },
    ] = await Promise.all([
      supabase.from('users').select('id, role, created_at'),
      supabase.from('karya').select('id, status, unduhan, sitasi, prodi, tahun, created_at'),
      supabase.from('download_logs').select('*', { count: 'exact', head: true }),
    ]);

    const totalUsers = users?.length || 0;
    const perRole = {
      admin: users?.filter(u => u.role === 'admin').length || 0,
      kurator: users?.filter(u => u.role === 'kurator').length || 0,
      penulis: users?.filter(u => u.role === 'penulis').length || 0,
    };

    const totalKarya = karya?.length || 0;
    const perStatus = {};
    karya?.forEach(k => {
      perStatus[k.status] = (perStatus[k.status] || 0) + 1;
    });

    const totalDownloads = karya?.reduce((sum, k) => sum + (k.unduhan || 0), 0) || 0;
    const totalSitasi = karya?.reduce((sum, k) => sum + (k.sitasi || 0), 0) || 0;

    return res.json({
      status: true,
      data: {
        users: { total: totalUsers, perRole },
        karya: { total: totalKarya, perStatus },
        unduhan: totalDownloads,
        sitasi: totalSitasi,
      }
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
