<script lang="ts">
  import { onMount } from 'svelte';
  import { subscribeRoute, navigate, type RouteState } from './router';

  import Navbar from './components/Navbar.svelte';
  import Footer from './components/Footer.svelte';
  import DetailModal from './components/DetailModal.svelte';
  import UploadModal from './components/UploadModal.svelte';
  import KuratorModal from './components/KuratorModal.svelte';
  import LoginModal from './components/LoginModal.svelte';
  import EditRevisiModal from './components/EditRevisiModal.svelte';

  // Dedicated Pages (Multi-Page Client-Side Routing)
  import BerandaPage from './pages/BerandaPage.svelte';
  import JelajahPage from './pages/JelajahPage.svelte';
  import PanduanPage from './pages/PanduanPage.svelte';
  import LoginPage from './pages/LoginPage.svelte';
  import DashboardPenulisPage from './pages/DashboardPenulisPage.svelte';
  import DashboardKuratorPage from './pages/DashboardKuratorPage.svelte';
  import DashboardAdminPage from './pages/DashboardAdminPage.svelte';

  import { initialKaryaList } from './data/karyaData';
  import type { Karya, RolePengguna, StatusKarya } from './types';
  import {
    apiFetchAllKarya,
    apiFetchStatistik,
    apiCreateKarya,
    apiReviewKarya,
    apiSubmitRevisi,
    apiRecordDownload,
    setAuthSession,
    clearAuthSession,
    getAuthUser,
    type StatistikData
  } from './lib/api';

  // Load saved session from localStorage so session doesn't get lost on navigation
  const savedRole = (typeof localStorage !== 'undefined' ? localStorage.getItem('immortal_role') : null) as RolePengguna | null;
  const savedEmail = typeof localStorage !== 'undefined' ? localStorage.getItem('immortal_email') : null;
  const savedUser = getAuthUser();

  // App State with Svelte 5 Runes
  let karyaList = $state<Karya[]>(initialKaryaList);
  let statistikData = $state<StatistikData | null>(null);
  let activeRole = $state<RolePengguna>(savedRole || 'publik');
  let userEmail = $state(savedEmail || '');
  let currentUser = $state<any>(savedUser || null);

  let searchQuery = $state('');
  let selectedCategory = $state('all');
  let selectedProdiKey = $state<'all' | 'ti' | 'si' | 'dkv' | 'mnj' | 'ilkom'>('all');

  // Router state
  let route = $state<RouteState>({ path: 'beranda', params: {}, hash: '' });

  onMount(() => {
    // Sync with backend API (with graceful local fallback)
    apiFetchAllKarya().then((data) => {
      if (data && data.length > 0) {
        karyaList = data;
      }
    });

    apiFetchStatistik().then((s) => {
      if (s) {
        statistikData = s;
      }
    });

    return subscribeRoute((r) => {
      route = r;
      window.scrollTo({ top: 0, behavior: 'instant' });
    });
  });

  // Modals state
  let selectedDetailKarya = $state<Karya | null>(null);
  let selectedReviewKarya = $state<Karya | null>(null);
  let selectedEditKarya = $state<Karya | null>(null);
  let isUploadOpen = $state(false);
  let isLoginOpen = $state(false);

  // Toast feedback state
  let toastMessage = $state<string | null>(null);
  let toastType = $state<'success' | 'info'>('success');

  function showToast(msg: string, type: 'success' | 'info' = 'success') {
    toastMessage = msg;
    toastType = type;
    setTimeout(() => {
      toastMessage = null;
    }, 3500);
  }

  // Route Guard: pastikan hanya role yang terautentikasi yang bisa akses dashboard masing-masing
  $effect(() => {
    if (route.path === 'dashboard-penulis' && activeRole !== 'penulis') {
      showToast('Akses dibatasi. Silakan login terlebih dahulu sebagai Penulis / Mahasiswa.', 'info');
      navigate('/login');
    } else if (route.path === 'dashboard-kurator' && activeRole !== 'kurator') {
      showToast('Akses dibatasi. Silakan login terlebih dahulu sebagai Tim Kurator Perpustakaan.', 'info');
      navigate('/login');
    } else if (route.path === 'dashboard-admin' && activeRole !== 'admin') {
      showToast('Akses dibatasi. Hanya Administrator Sistem yang dapat mengakses panel ini.', 'info');
      navigate('/login');
    }
  });

  function triggerUpload() {
    if (activeRole === 'publik') {
      showToast('Silakan masuk terlebih dahulu untuk mengunggah karya ilmiah.', 'info');
      navigate('/login');
    } else {
      isUploadOpen = true;
    }
  }

  let pendingReviews = $derived(
    karyaList.filter((k) => k.status === 'Diajukan' || k.status === 'Dalam Review').length
  );

  function handleDownloadKarya(karya: Karya) {
    karya.unduhan += 1;
    apiRecordDownload(karya.id);

    if (karya.fileUrl) {
      window.open(karya.fileUrl, '_blank');
    } else {
      // Trigger unduhan berkas naskah resmi ke peramban
      try {
        const fileContent = `======================================================
REPOSITORI RESMI IMMORTAL CAMPUS
Dokumen Naskah Akademik Terverifikasi
======================================================
ID Naskah   : ${karya.id}
Judul       : ${karya.judul}
Penulis     : ${karya.penulis} (NIM: ${karya.nim || '-'})
Pembimbing  : ${karya.pembimbing}
Program Studi: ${karya.prodi}
Tahun       : ${karya.tahun}
Status      : ${karya.status} (Terverifikasi Kurator)
DOI         : ${karya.doi || '10.2412/imc.' + karya.tahun + '.001'}
Ukuran File : ${karya.fileSize || 'PDF Resmi'}
Tanggal Unduh: ${new Date().toLocaleDateString('id-ID', { dateStyle: 'full' })}

------------------------------------------------------
ABSTRAK PENELITIAN:
------------------------------------------------------
${karya.abstrak}

Kata Kunci  : ${(karya.kataKunci || []).join(', ')}

======================================================
Hak Cipta Dilindungi Undang-Undang. Lisensi CC BY-NC 4.0.
Sirkulasi resmi Perpustakaan Immortal Campus.
======================================================`;

        const blob = new Blob([fileContent], { type: 'text/plain;charset=utf-8' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        const cleanTitle = (karya.judul || 'karya').replace(/[^a-zA-Z0-9_-]/g, '_').slice(0, 40);
        a.download = `Naskah_${karya.id}_${cleanTitle}.txt`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);
      } catch (err) {
        console.warn('Gagal memicu unduhan berkas:', err);
      }
    }

    showToast(`Naskah "${karya.judul.slice(0, 42)}..." berhasil diunduh. Tercatat di repositori.`, 'success');
  }

  function handleCreateKarya(newKarya: Karya) {
    karyaList = [newKarya, ...karyaList];
    apiCreateKarya(newKarya).catch((e) => console.warn(e));

    if (newKarya.status === 'Diajukan') {
      showToast(`Karya "${newKarya.judul.slice(0, 35)}..." berhasil diajukan ke antrean kurator!`, 'success');
    } else {
      showToast(`Karya berhasil disimpan sebagai Draft.`, 'info');
    }
  }

  function handleUpdateKuratorStatus(karyaId: string, newStatus: StatusKarya, catatan?: string) {
    karyaList = karyaList.map((k) => {
      if (k.id === karyaId) {
        return {
          ...k,
          status: newStatus,
          catatanKurator: catatan,
          tanggalTerbit: newStatus === 'Diterbitkan' ? '31 Oktober 2026' : k.tanggalTerbit
        };
      }
      return k;
    });

    const tindakan = newStatus === 'Diterbitkan' ? 'terbitkan' : newStatus === 'Perlu Revisi' ? 'revisi' : 'tolak';
    apiReviewKarya(karyaId, tindakan, catatan).catch((e) => console.warn(e));

    const statusLabel =
      newStatus === 'Diterbitkan'
        ? 'diterbitkan ke publik'
        : newStatus === 'Perlu Revisi'
          ? 'dikembalikan dengan catatan revisi'
          : 'ditolak';
    showToast(`Status karya berhasil diperbarui: ${statusLabel}.`, 'success');
  }

  function handleSubmitRevisi(karyaId: string, updatedFields: Partial<Karya>, submitForReview: boolean) {
    karyaList = karyaList.map((k) => {
      if (k.id === karyaId) {
        return {
          ...k,
          ...updatedFields,
          status: submitForReview ? 'Diajukan' : 'Draft',
          catatanKurator: submitForReview ? undefined : k.catatanKurator,
        };
      }
      return k;
    });

    apiSubmitRevisi(karyaId, updatedFields, submitForReview).catch((e) => console.warn(e));

    selectedEditKarya = null;
    showToast(
      submitForReview
        ? 'Revisi naskah berhasil diajukan kembali ke meja kurator!'
        : 'Perubahan draft naskah berhasil disimpan.',
      'success'
    );
  }

  function handleLoginSuccess(role: RolePengguna, email: string, token?: string, userData?: any) {
    activeRole = role;
    userEmail = email;
    currentUser = userData || null;
    const finalToken = token || ('demo-token-' + Date.now());
    setAuthSession(finalToken, role, email, userData);

    const displayName = userData?.nama || email;
    showToast(`Berhasil masuk sebagai ${role.toUpperCase()} (${displayName}).`, 'success');
    if (role === 'admin') {
      navigate('/dashboard-admin');
    } else if (role === 'penulis') {
      navigate('/dashboard-penulis');
    } else if (role === 'kurator') {
      navigate('/dashboard-kurator');
    } else {
      navigate('/');
    }
  }

  function handleLogout() {
    activeRole = 'publik';
    userEmail = '';
    currentUser = null;
    clearAuthSession();
    showToast('Anda telah keluar dari akun dan diarahkan ke repositori publik.', 'info');
    navigate('/');
  }

  function handleSelectRole(role: RolePengguna) {
    activeRole = role;
    if (typeof localStorage !== 'undefined') {
      localStorage.setItem('immortal_role', role);
    }
    if (role === 'admin') {
      navigate('/dashboard-admin');
    } else if (role === 'penulis') {
      navigate('/dashboard-penulis');
    } else if (role === 'kurator') {
      navigate('/dashboard-kurator');
    } else {
      navigate('/');
    }
  }

  function handleProdiFilterSelect(fakultasOrProdiName: string) {
    const nameLower = fakultasOrProdiName.toLowerCase();
    if (nameLower.includes('teknologi informasi') || nameLower.includes('informatika') || nameLower.includes('fti')) {
      selectedProdiKey = 'ti';
    } else if (nameLower.includes('sistem informasi')) {
      selectedProdiKey = 'si';
    } else if (nameLower.includes('desain') || nameLower.includes('dkv') || nameLower.includes('fds')) {
      selectedProdiKey = 'dkv';
    } else if (nameLower.includes('ekonomi') || nameLower.includes('manajemen') || nameLower.includes('feb')) {
      selectedProdiKey = 'mnj';
    } else if (nameLower.includes('komunikasi') || nameLower.includes('fikom')) {
      selectedProdiKey = 'ilkom';
    } else {
      selectedProdiKey = 'all';
    }
    searchQuery = '';
    selectedCategory = 'all';
    const el = document.getElementById('jelajah-karya');
    if (el) el.scrollIntoView({ behavior: 'smooth' });
    showToast(`Menampilkan koleksi: ${fakultasOrProdiName}`, 'info');
  }

  function handleLeaderboardDownload(title: string) {
    const match =
      karyaList.find((k) => k.judul.toLowerCase() === title.toLowerCase()) ||
      karyaList.find((k) => k.judul.toLowerCase().includes(title.toLowerCase().slice(0, 25)));
    if (match) {
      handleDownloadKarya(match);
    } else {
      showToast(`Mengunduh naskah unggulan: "${title.slice(0, 40)}..."`, 'success');
    }
  }
</script>

<div class="min-h-screen flex flex-col bg-surface font-body-md text-on-surface antialiased">
  <!-- Toast Feedback Notification -->
  {#if toastMessage}
    <div class="fixed bottom-6 right-6 z-50 animate-slideUp">
      <div
        class="flex items-center gap-3 px-5 py-3.5 rounded-2xl shadow-xl text-xs sm:text-sm font-semibold {toastType === 'success' ? 'bg-status-published text-white' : 'bg-primary text-white'}"
      >
        <span class="material-symbols-outlined text-lg">{toastType === 'success' ? 'check_circle' : 'info'}</span>
        <span>{toastMessage}</span>
        <button onclick={() => toastMessage = null} class="ml-2 hover:opacity-80">
          <span class="material-symbols-outlined text-sm">close</span>
        </button>
      </div>
    </div>
  {/if}

  <!-- 1. NAVBAR (Tampilan dinamis: Publik vs Penulis vs Kurator, tanpa bar switcher) -->
  <Navbar
    {activeRole}
    currentPath={route.path}
    userName={currentUser?.nama || userEmail}
    {currentUser}
    onOpenUpload={triggerUpload}
    onOpenLogin={() => navigate('/login')}
    onLogout={handleLogout}
    pendingReviewCount={pendingReviews}
  />

  <!-- MAIN VIEW ROUTER -->
  <main class="w-full pt-16 bg-surface min-h-[calc(100vh-4rem)] flex-1">
    {#if route.path === 'beranda'}
      <BerandaPage
        {karyaList}
        {statistikData}
        {activeRole}
        {searchQuery}
        {selectedCategory}
        {selectedProdiKey}
        onSearchChange={(q) => searchQuery = q}
        onProdiSelect={(k) => selectedProdiKey = k}
        onCategoryChange={(c) => selectedCategory = c}
        onOpenUpload={triggerUpload}
        onOpenDetail={(k) => selectedDetailKarya = k}
        onDownloadKarya={handleDownloadKarya}
        onOpenReviewModal={(k) => selectedReviewKarya = k}
        onOpenEdit={(k) => selectedEditKarya = k}
        onOpenPanduanModal={() => {
          const el = document.getElementById('panduan');
          if (el) el.scrollIntoView({ behavior: 'smooth' });
        }}
        onProdiFilterSelect={handleProdiFilterSelect}
        onDownloadLeaderboard={handleLeaderboardDownload}
      />
    {:else if route.path === 'jelajah'}
      <JelajahPage
        {karyaList}
        {activeRole}
        onOpenDetail={(k) => selectedDetailKarya = k}
        onDownloadKarya={handleDownloadKarya}
        onOpenReview={(k) => selectedReviewKarya = k}
        onOpenEdit={(k) => selectedEditKarya = k}
        onOpenUpload={triggerUpload}
      />
    {:else if route.path === 'panduan'}
      <PanduanPage
        onOpenUpload={triggerUpload}
      />
    {:else if route.path === 'login'}
      <LoginPage
        onLoginSuccess={handleLoginSuccess}
      />
    {:else if route.path === 'dashboard-penulis'}
      <DashboardPenulisPage
        {karyaList}
        userName={currentUser?.nama || userEmail || 'Penulis'}
        {currentUser}
        onClose={() => navigate('/')}
        onLogout={handleLogout}
        onOpenEdit={(k) => selectedEditKarya = k}
        onOpenDetail={(k) => selectedDetailKarya = k}
        onOpenUpload={() => isUploadOpen = true}
        onOpenPanduan={() => {
          navigate('/');
          setTimeout(() => {
            const el = document.getElementById('panduan');
            if (el) el.scrollIntoView({ behavior: 'smooth' });
          }, 150);
        }}
        onNavigateJelajah={() => navigate('/jelajah')}
        onNavigateHome={() => navigate('/')}
      />
    {:else if route.path === 'dashboard-kurator'}
      <DashboardKuratorPage
        {karyaList}
        pendingCount={pendingReviews}
        {currentUser}
        onClose={() => navigate('/')}
        onLogout={handleLogout}
        onOpenReview={(k) => selectedReviewKarya = k}
        onOpenDetail={(k) => selectedDetailKarya = k}
        onDownloadKarya={handleDownloadKarya}
        onNavigateHome={() => navigate('/')}
        onNavigateJelajah={() => navigate('/jelajah')}
      />
    {:else if route.path === 'dashboard-admin'}
      <DashboardAdminPage
        {karyaList}
        {currentUser}
        onClose={() => navigate('/')}
        onLogout={handleLogout}
        onOpenDetail={(k) => selectedDetailKarya = k}
        onNavigateHome={() => navigate('/')}
        onNavigateJelajah={() => navigate('/jelajah')}
      />
    {/if}
  </main>

  <!-- 10. FOOTER KOMPREHENSIF (Hanya tampil di halaman publik: Beranda, Jelajah, Panduan) -->
  {#if route.path === 'beranda' || route.path === 'jelajah' || route.path === 'panduan'}
    <Footer />
  {/if}

  <!-- Interactive Modals -->
  <DetailModal
    karya={selectedDetailKarya}
    {activeRole}
    onClose={() => selectedDetailKarya = null}
    onDownload={handleDownloadKarya}
    onOpenReview={(k) => { selectedReviewKarya = k; selectedDetailKarya = null; }}
  />

  <UploadModal
    isOpen={isUploadOpen}
    onClose={() => isUploadOpen = false}
    onSubmitKarya={handleCreateKarya}
    {currentUser}
  />

  <KuratorModal
    karya={selectedReviewKarya}
    onClose={() => selectedReviewKarya = null}
    onUpdateStatus={handleUpdateKuratorStatus}
  />

  <LoginModal
    isOpen={isLoginOpen}
    onClose={() => isLoginOpen = false}
    onLoginSuccess={handleLoginSuccess}
  />

  <EditRevisiModal
    karya={selectedEditKarya}
    onClose={() => selectedEditKarya = null}
    onSubmitRevisi={handleSubmitRevisi}
  />
</div>
