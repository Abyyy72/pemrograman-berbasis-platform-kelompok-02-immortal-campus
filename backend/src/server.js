'use strict';

const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const app = require('./app');

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  console.log(`===================================================`);
  console.log(`  Immortal Campus API Server Running`);
  console.log(`  Port       : ${PORT}`);
  console.log(`  Health URL : http://localhost:${PORT}/api`);
  console.log(`===================================================`);
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`\n[Server Error] Port ${PORT} sedang digunakan oleh proses lain!`);
    console.error(`Silakan hentikan proses yang memakai port ${PORT} atau jalankan:`);
    console.error(`  powershell: Stop-Process -Id (Get-NetTCPConnection -LocalPort ${PORT}).OwningProcess -Force\n`);
    process.exit(1);
  } else {
    console.error('[Server Error]', err);
    process.exit(1);
  }
});

// Graceful shutdown
function shutdown() {
  console.log('\n[Server] Menutup koneksi server...');
  server.close(() => {
    console.log('[Server] Server berhasil dihentikan dengan aman.');
    process.exit(0);
  });
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
