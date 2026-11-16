'use strict';

/**
 * Middleware otorisasi berbasis peran (Role-Based Access Control)
 * Sesuai PRD Seksi 4: Persona Penulis & Kurator
 */
function requireRole(...allowedRoles) {
  return (req, res, next) => {
    // Jika req.user belum terisi, coba cek header 'x-user-role' dalam mode dev
    if (!req.user && req.headers['x-user-role']) {
      req.user = {
        id: req.headers['x-user-role'] === 'kurator' ? 'user-002' : 'user-001',
        nama: req.headers['x-user-role'] === 'kurator' ? 'Dr. Rina Suryani, M.Kom.' : 'Amanda Putri Wibowo',
        role: req.headers['x-user-role'],
      };
    }

    if (!req.user) {
      return res.status(401).json({
        status: false,
        message: 'Akses ditolak. Pengguna belum diautentikasi.',
        data: null,
      });
    }

    const normalizedUserRole = (req.user.role || '').toLowerCase();
    const isAllowed = allowedRoles.some((role) => role.toLowerCase() === normalizedUserRole);

    if (!isAllowed) {
      return res.status(403).json({
        status: false,
        message: `Akses ditolak. Peran "${req.user.role}" tidak memiliki izin untuk melakukan tindakan ini. Diperlukan peran: ${allowedRoles.join(', ')}.`,
        data: null,
      });
    }

    next();
  };
}

module.exports = requireRole;
