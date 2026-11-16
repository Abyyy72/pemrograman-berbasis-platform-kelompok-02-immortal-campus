'use strict';

const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../../.env') });
const { Client } = require('pg');
const bcrypt = require('bcryptjs');

async function main() {
  const client = new Client({
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
  });

  await client.connect();
  console.log('Connected to PostgreSQL Supabase!');

  // 1. Alter Enum
  try {
    await client.query(`ALTER TYPE "RolePengguna" ADD VALUE IF NOT EXISTS 'admin';`);
    console.log('ALTER TYPE RolePengguna ADD VALUE admin SUCCESS');
  } catch (err) {
    console.log('Notice/Error ALTER:', err.message);
  }

  // 2. Check enum values
  const enumCheck = await client.query(`
    SELECT enumlabel FROM pg_enum 
    JOIN pg_type ON pg_enum.enumtypid = pg_type.oid 
    WHERE typname = 'RolePengguna';
  `);
  console.log('Current RolePengguna values:', enumCheck.rows.map(r => r.enumlabel));

  const pwHash = await bcrypt.hash('password123', 10);

  // 3. Insert or update Admin account
  await client.query(`
    INSERT INTO public.users (id, nama, email, password_hash, nim, nip, prodi, role)
    VALUES (
      'user-admin-001',
      'Administrator Utama Perpustakaan',
      'admin@campus.ac.id',
      $1,
      NULL,
      'ADMIN-001',
      'UPT Perpustakaan & TI',
      'admin'::"RolePengguna"
    )
    ON CONFLICT (email) DO UPDATE SET
      nama = EXCLUDED.nama,
      role = 'admin'::"RolePengguna",
      password_hash = EXCLUDED.password_hash,
      nip = EXCLUDED.nip;
  `, [pwHash]);
  console.log('Admin account created: admin@campus.ac.id (password: password123)');

  // 4. Insert or update Curator accounts
  const curators = [
    {
      id: 'user-002',
      nama: 'Dr. Rina Suryani, M.Kom.',
      email: 'rina.suryani@campus.ac.id',
      nip: '198204152008122001',
      prodi: 'UPT Perpustakaan'
    },
    {
      id: 'user-kurator-002',
      nama: 'Budi Santoso, S.Sos., M.Lib.',
      email: 'budi.santoso@campus.ac.id',
      nip: '198805122014021003',
      prodi: 'UPT Perpustakaan'
    },
    {
      id: 'user-kurator-003',
      nama: 'Dewi Rahayu, S.I.Pust.',
      email: 'dewi.rahayu@campus.ac.id',
      nip: '199203182019032008',
      prodi: 'UPT Perpustakaan'
    }
  ];

  for (const c of curators) {
    await client.query(`
      INSERT INTO public.users (id, nama, email, password_hash, nim, nip, prodi, role)
      VALUES ($1, $2, $3, $4, NULL, $5, $6, 'kurator'::"RolePengguna")
      ON CONFLICT (email) DO UPDATE SET
        nama = EXCLUDED.nama,
        role = 'kurator'::"RolePengguna",
        password_hash = EXCLUDED.password_hash,
        nip = EXCLUDED.nip,
        prodi = EXCLUDED.prodi;
    `, [c.id, c.nama, c.email, pwHash, c.nip, c.prodi]);
    console.log(`Curator account ready: ${c.email} (${c.nama})`);
  }

  // 5. List all users
  const allUsers = await client.query(`SELECT id, nama, email, nip, nim, role FROM public.users ORDER BY role, nama;`);
  console.log('\n--- ALL ACTIVE USERS IN SUPABASE ---');
  allUsers.rows.forEach(u => console.log(`[${u.role.toUpperCase()}] ${u.email} | ${u.nama} | NIP/NIM: ${u.nip || u.nim || '-'}`));

  await client.end();
}

main().catch(err => {
  console.error('Migration error:', err);
  process.exit(1);
});
