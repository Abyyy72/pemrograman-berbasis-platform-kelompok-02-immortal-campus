'use strict';

/**
 * add-admin-role.js
 * Strategi: Ubah kolom role dari ENUM ke VARCHAR(32)
 * lalu masukkan akun admin & kurator baru.
 * 
 * Jalankan: node backend/src/scripts/add-admin-role.js
 */

const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const { createClient } = require('@supabase/supabase-js');
const bcrypt = require('bcryptjs');

const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.SUPABASE_ANON_KEY
);

async function main() {
  console.log('=== SETUP ADMIN ROLE ===\n');

  // Strategi: pakai RPC yang bisa dibuat via Supabase SQL Editor,
  // atau gunakan pg_net/pg_cron. Karena tidak ada RPC, kita gunakan
  // UPDATE langsung dengan casting ke text dulu, lalu alter enum.
  
  // LANGKAH 1: Cek apakah admin sudah ada di enum dengan mencoba insert dummy dulu
  const passwordHash = await bcrypt.hash('password123', 10);
  
  // Test apakah 'admin' sudah bisa dipakai (mungkin sudah ditambah manual)
  const testResult = await supabase
    .from('users')
    .select('role')
    .eq('role', 'admin')
    .limit(1);
  
  if (testResult.error && testResult.error.message.includes('invalid input value for enum')) {
    console.log('[!] Enum "admin" belum ada di database.');
    console.log('[!] Kamu perlu jalankan SQL ini di Supabase SQL Editor:');
    console.log('');
    console.log('    ALTER TYPE "RolePengguna" ADD VALUE \'admin\';');
    console.log('');
    console.log('    Lalu jalankan ulang script ini.');
    console.log('');
    console.log('    URL SQL Editor: https://supabase.com/dashboard/project/iedelnwtbbfqbtwwtyis/sql/new');
    process.exit(1);
  }
  
  console.log('[1] Enum "admin" sudah ada. Melanjutkan...\n');

  const usersToInsert = [
    {
      id: 'user-admin-001',
      nama: 'Super Admin Immortal Campus',
      email: 'admin@campus.ac.id',
      password_hash: passwordHash,
      nim: null,
      nip: 'ADMIN001',
      prodi: 'UPT Perpustakaan & IT',
      role: 'admin',
    },
    {
      id: 'user-kurator-002',
      nama: 'Budi Santoso, M.Lib.',
      email: 'budi.santoso@campus.ac.id',
      password_hash: passwordHash,
      nim: null,
      nip: '197812102005011002',
      prodi: 'UPT Perpustakaan',
      role: 'kurator',
    },
    {
      id: 'user-kurator-003',
      nama: 'Dewi Rahayu, S.Sos.',
      email: 'dewi.rahayu@campus.ac.id',
      password_hash: passwordHash,
      nim: null,
      nip: '199003202019032001',
      prodi: 'UPT Perpustakaan',
      role: 'kurator',
    }
  ];

  for (const user of usersToInsert) {
    const { data, error } = await supabase
      .from('users')
      .upsert(user, { onConflict: 'email' })
      .select('email, nama, role');
    
    if (error) {
      console.error(`[ERR] ${user.email}:`, error.message);
    } else {
      console.log(`[OK] ${user.email} (${user.role})`);
    }
  }

  // Verifikasi
  const { data: allUsers } = await supabase
    .from('users')
    .select('email, nama, role, nip')
    .order('role');
  
  console.log('\n=== DAFTAR AKUN SAAT INI ===');
  for (const u of (allUsers || [])) {
    console.log(`  [${u.role.toUpperCase().padEnd(7)}] ${u.email} — ${u.nama}`);
  }
  console.log('\nSemua password: password123');
}

main().catch(console.error);
