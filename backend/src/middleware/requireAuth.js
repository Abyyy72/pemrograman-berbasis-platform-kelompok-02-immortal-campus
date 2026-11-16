'use strict';

const jwt = require('jsonwebtoken');
const { findUserById, findUserByEmailOrNim } = require('../lib/db');

const JWT_SECRET = process.env.JWT_SECRET || 'immortal_campus_super_secret_jwt_key_2026';

/**
 * Helper untuk mendapatkan demo user default
 */
async function getDemoUser(role = 'penulis') {
  if (role === 'kurator') {
    try {
      const dbUser = await findUserById('user-002');
      if (dbUser) return dbUser;
    } catch {}
    return {
      id: 'user-002',
      nama: 'Dr. Rina Suryani, M.Kom.',
      email: 'rina.suryani@campus.ac.id',
      nip: '198204152008122001',
      prodi: 'UPT Perpustakaan',
      role: 'kurator',
    };
  }
  try {
    const dbUser = await findUserById('user-001');
    if (dbUser) return dbUser;
  } catch {}
  return {
    id: 'user-001',
    nama: 'Amanda Putri Wibowo',
    email: 'amanda@campus.ac.id',
    nim: '2110512034',
    prodi: 'Teknik Informatika',
    role: 'penulis',
  };
}

/**
 * Middleware autentikasi wajib (requireAuth)
 * Mendukung JWT token resmi maupun demo-token dari sesi UI
 */
async function requireAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  const userRoleHeader = req.headers['x-user-role'];

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({
      status: false,
      message: 'Akses ditolak. Token otentikasi tidak ditemukan.',
      data: null,
    });
  }

  const token = authHeader.split(' ')[1];

  // 1. Tangani demo token (misal dari UI demo frontend: 'demo-token-...')
  if (token && token.startsWith('demo-token')) {
    const role = userRoleHeader === 'kurator' || token.includes('kurator') ? 'kurator' : 'penulis';
    req.user = await getDemoUser(role);
    return next();
  }

  // 2. Tangani JWT standar
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = (decoded.id ? await findUserById(decoded.id) : null) || 
                 (decoded.email ? await findUserByEmailOrNim(decoded.email) : null);

    if (!user) {
      // Jika user id lama, fallback ke decoded payload
      req.user = {
        id: decoded.id,
        nama: decoded.nama || 'Pengguna Repositori',
        email: decoded.email,
        role: decoded.role || 'penulis',
      };
      return next();
    }

    req.user = user;
    next();
  } catch (err) {
    // Jika format JWT invalid tetapi request dari development / demo
    if (process.env.NODE_ENV === 'development' && userRoleHeader) {
      req.user = await getDemoUser(userRoleHeader);
      return next();
    }

    return res.status(401).json({
      status: false,
      message: 'Token otentikasi tidak valid atau telah kadaluarsa.',
      data: null,
    });
  }
}

/**
 * Middleware autentikasi opsional (optionalAuth)
 * Jika token ada dan valid, mengisi req.user. Jika tidak ada, tetap melanjutkan request.
 */
async function optionalAuth(req, _res, next) {
  const authHeader = req.headers.authorization;
  const userRoleHeader = req.headers['x-user-role'];

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    if (userRoleHeader) {
      req.user = await getDemoUser(userRoleHeader);
    }
    return next();
  }

  const token = authHeader.split(' ')[1];

  if (token.startsWith('demo-token')) {
    const role = userRoleHeader === 'kurator' || token.includes('kurator') ? 'kurator' : 'penulis';
    req.user = await getDemoUser(role);
    return next();
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    const user = (decoded.id ? await findUserById(decoded.id) : null) || 
                 (decoded.email ? await findUserByEmailOrNim(decoded.email) : null);
    req.user = user || {
      id: decoded.id,
      nama: decoded.nama,
      email: decoded.email,
      role: decoded.role,
    };
  } catch {
    if (userRoleHeader) {
      req.user = await getDemoUser(userRoleHeader);
    }
  }

  next();
}

module.exports = requireAuth;
module.exports.requireAuth = requireAuth;
module.exports.optionalAuth = optionalAuth;
