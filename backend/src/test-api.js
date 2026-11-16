'use strict';

const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const http = require('http');
const app = require('./app');

const server = http.createServer(app);

server.listen(0, async () => {
  const port = server.address().port;
  const baseUrl = `http://localhost:${port}/api/v1`;
  console.log(`Test server running on port ${port}`);

  let testPassed = 0;
  let testFailed = 0;

  async function request(path, options = {}) {
    const url = `${baseUrl}${path}`;
    const headers = {
      ...(options.body instanceof FormData ? {} : { 'Content-Type': 'application/json' }),
      ...(options.headers || {})
    };
    const res = await fetch(url, {
      ...options,
      headers,
    });
    const text = await res.text();
    let json = null;
    try {
      json = JSON.parse(text);
    } catch {
      // not json
    }
    return { status: res.status, headers: res.headers, text, json };
  }

  function assert(condition, message) {
    if (condition) {
      console.log(`  ✓ ${message}`);
      testPassed++;
    } else {
      console.error(`  ✗ FAIL: ${message}`);
      testFailed++;
    }
  }

  try {
    console.log('\n--- 1. Testing Root / API Catalog (PRD Overview) ---');
    const root = await request('/');
    assert(root.status === 200, 'GET /api/v1 returns 200');
    assert(root.json && root.json.prdAlignment, 'PRD alignment details present');

    console.log('\n--- 2. Testing Auth: Login with Email & Password (FR-01) ---');
    const loginPenulis = await request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({
        email: 'amanda@campus.ac.id',
        password: 'password123'
      })
    });
    assert(loginPenulis.status === 200, 'Login penulis with email returns 200');
    assert(loginPenulis.json && loginPenulis.json.data && loginPenulis.json.data.token, 'JWT token returned');
    const penulisToken = loginPenulis.json.data.token;

    const loginKurator = await request('/auth/login', {
      method: 'POST',
      body: JSON.stringify({
        identifier: 'rina.suryani@campus.ac.id',
        password: 'password123'
      })
    });
    assert(loginKurator.status === 200, 'Login kurator returns 200');
    const kuratorToken = loginKurator.json.data.token;

    console.log('\n--- 3. Testing Auth Me (FR-02) ---');
    const meRes = await request('/auth/me', {
      headers: { Authorization: `Bearer ${penulisToken}` }
    });
    assert(meRes.status === 200 && meRes.json.data.role === 'penulis', 'GET /auth/me returns valid penulis profile');

    console.log('\n--- 4. Testing Beranda (FR-34) ---');
    const berandaRes = await request('/karya/beranda');
    assert(berandaRes.status === 200, 'GET /karya/beranda returns 200');
    assert(Array.isArray(berandaRes.json.data.terbaru), 'Beranda data contains karya terbaru');
    assert(Array.isArray(berandaRes.json.data.terpopuler), 'Beranda data contains karya terpopuler');

    console.log('\n--- 5. Testing Search, Filter & Sort (FR-30, FR-31) ---');
    const searchRes = await request('/karya?q=learning&sort=terpopuler');
    assert(searchRes.status === 200, 'GET /karya?q=... returns 200');
    assert(searchRes.json.data.length > 0, 'Search returned matching results');

    console.log('\n--- 6. Testing PDF Upload via Multer / Storage (FR-11) ---');
    const formData = new FormData();
    const fakePdfBlob = new Blob(['%PDF-1.4 Mock PDF Document Content for Immortal Campus'], { type: 'application/pdf' });
    formData.append('file', fakePdfBlob, 'naskah-skripsi-uji.pdf');

    const uploadRes = await request('/upload', {
      method: 'POST',
      headers: { Authorization: `Bearer ${penulisToken}` },
      body: formData,
    });
    assert(uploadRes.status === 200, 'POST /upload with PDF returns 200');
    assert(uploadRes.json && uploadRes.json.data && uploadRes.json.data.fileUrl, 'Upload returns valid fileUrl');
    const uploadedFileUrl = uploadRes.json.data.fileUrl;

    console.log('\n--- 7. Testing Penulis Submitting Karya (FR-10, FR-14) ---');
    const createRes = await request('/karya', {
      method: 'POST',
      headers: { Authorization: `Bearer ${penulisToken}` },
      body: JSON.stringify({
        judul: 'Rancang Bangun Sistem Informasi Repositori Kampus Immortal',
        pembimbing: 'Dr. Eng. Hendra Sucipto, S.Kom., M.T.',
        jenis: 'skripsi',
        prodi: 'Teknik Informatika',
        tahun: 2026,
        abstrak: 'Penelitian perancangan etalase digital repositori karya ilmiah terkurasi untuk institusi pendidikan tinggi.',
        kataKunci: ['Repositori', 'Arsitektur Sistem', 'Fullstack'],
        status: 'Diajukan',
        fileUrl: uploadedFileUrl,
      })
    });
    assert(createRes.status === 201, 'POST /karya (Diajukan) returns 201');
    const newKaryaId = createRes.json.data.id;

    console.log('\n--- 8. Testing Curator Queue (FR-20) ---');
    const antreanRes = await request('/karya/antrean', {
      headers: { Authorization: `Bearer ${kuratorToken}` }
    });
    assert(antreanRes.status === 200, 'GET /karya/antrean returns 200');
    assert(antreanRes.json.data.some(k => k.id === newKaryaId), 'Submitted work appears in curator queue');

    console.log('\n--- 9. Testing Curator Start Review (FR-20, Seksi 5.1) ---');
    const startRevRes = await request(`/karya/${newKaryaId}/start-review`, {
      method: 'PATCH',
      headers: { Authorization: `Bearer ${kuratorToken}` }
    });
    assert(startRevRes.status === 200, 'PATCH /karya/:id/start-review returns 200');
    assert(startRevRes.json.data.status === 'Dalam Review', 'Work status updated to "Dalam Review"');

    console.log('\n--- 10. Testing Curator Review Action: Minta Revisi (FR-23, Seksi 5.1) ---');
    const mintaRevisiRes = await request(`/karya/${newKaryaId}/review`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${kuratorToken}` },
      body: JSON.stringify({
        tindakan: 'revisi',
        catatan: 'Lengkapi lembar pengesahan dan diagram alur sistem pada bab 3.'
      })
    });
    assert(mintaRevisiRes.status === 200, 'POST /karya/:id/review (revisi) returns 200');
    assert(mintaRevisiRes.json.data.status === 'Perlu Revisi', 'Work status is now "Perlu Revisi"');

    console.log('\n--- 11. Testing Penulis Resubmission after Revision (FR-10, Seksi 5.1) ---');
    const resubmitRes = await request(`/karya/${newKaryaId}`, {
      method: 'PUT',
      headers: { Authorization: `Bearer ${penulisToken}` },
      body: JSON.stringify({
        abstrak: 'Penelitian perancangan etalase digital repositori karya ilmiah terkurasi lengkap dengan lembar pengesahan dan arsitektur.',
        submitForReview: true
      })
    });
    assert(resubmitRes.status === 200, 'PUT /karya/:id (submitForReview) returns 200');
    assert(resubmitRes.json.data.status === 'Diajukan', 'Work status returned to "Diajukan"');

    console.log('\n--- 12. Testing Curator Review Action: Terbitkan (FR-23, Seksi 5.1) ---');
    const publishRes = await request(`/karya/${newKaryaId}/review`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${kuratorToken}` },
      body: JSON.stringify({
        tindakan: 'terbitkan',
        catatan: 'Naskah telah memenuhi semua kriteria mutu repositori.'
      })
    });
    assert(publishRes.status === 200, 'POST /karya/:id/review (terbitkan) returns 200');
    assert(publishRes.json.data.status === 'Diterbitkan', 'Work status is "Diterbitkan"');
    assert(!!publishRes.json.data.doi, 'DOI auto-generated upon publication');

    console.log('\n--- 13. Testing Download Recording (FR-40, FR-41) ---');
    const dlBefore = publishRes.json.data.unduhan || 0;
    const unduhRes = await request(`/karya/${newKaryaId}/unduh`, { method: 'POST' });
    assert(unduhRes.status === 200, 'POST /karya/:id/unduh returns 200');
    assert(unduhRes.json.data.unduhan === dlBefore + 1, 'Download count incremented by 1');

    console.log('\n--- 14. Testing Statistics Dashboard & Akreditasi (FR-42) ---');
    const statRes = await request('/statistik');
    assert(statRes.status === 200, 'GET /statistik returns 200');
    assert(statRes.json.data.ringkasan.totalDiterbitkan > 0, 'Statistik contains valid summary');
    assert(Array.isArray(statRes.json.data.topUnduhan), 'Statistik contains top unduhan list');

    const akreditasiRes = await request('/statistik/akreditasi');
    assert(akreditasiRes.status === 200, 'GET /statistik/akreditasi returns 200');

    console.log(`\n========================================`);
    console.log(`  Tests Passed: ${testPassed}`);
    console.log(`  Tests Failed: ${testFailed}`);
    console.log(`========================================\n`);

    server.close();
    process.exit(testFailed > 0 ? 1 : 0);
  } catch (err) {
    console.error('Test execution error:', err);
    server.close();
    process.exit(1);
  }
});
