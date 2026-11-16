<script lang="ts">
  import type { Karya, StatusKarya } from '../types';
  import BebasPustakaModal from './BebasPustakaModal.svelte';

  interface Props {
    isOpen: boolean;
    karyaList: Karya[];
    userName?: string;
    currentUser?: any;
    onClose: () => void;
    onLogout?: () => void;
    onOpenEdit: (karya: Karya) => void;
    onOpenDetail: (karya: Karya) => void;
    onOpenUpload: () => void;
    onOpenPanduan?: () => void;
    onNavigateJelajah?: () => void;
    onNavigateHome?: () => void;
  }

  let {
    isOpen,
    karyaList,
    userName = 'Penulis Mahasiswa',
    currentUser = null,
    onClose,
    onLogout,
    onOpenEdit,
    onOpenDetail,
    onOpenUpload,
    onOpenPanduan,
    onNavigateJelajah,
    onNavigateHome
  }: Props = $props();

  function getInitials(name?: string): string {
    if (!name) return 'AP';
    const parts = name.trim().split(/\s+/);
    if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  let activeUser = $derived(
    currentUser || {
      id: 'user-001',
      nama: userName && !userName.includes('@') ? userName : 'Penulis',
      nim: '',
      prodi: 'Teknik Informatika',
      role: 'penulis'
    }
  );

  let userDisplayName = $derived(activeUser.nama || userName || 'Penulis Mahasiswa');
  let userInitials = $derived(getInitials(userDisplayName));
  let userSubLabel = $derived(`${activeUser.nim || 'NIM belum disetel'} • ${activeUser.prodi || 'Teknik Informatika'}`);

  // Active view tab inside Penulis portal
  let activeTab = $state<'beranda' | 'karya' | 'jelajah' | 'panduan' | 'bebas-pustaka'>('beranda');
  let mobileSidebarOpen = $state(false);

  // Modal Bebas Pustaka State
  let isBebasPustakaOpen = $state(false);
  let selectedBebasPustakaKarya = $state<Karya | null>(null);

  // Toast feedback state inside dashboard
  let copyToast = $state<string | null>(null);

  function showToast(msg: string) {
    copyToast = msg;
    setTimeout(() => { copyToast = null; }, 3200);
  }

  // Filter only current author's works
  let myKarya = $derived.by(() => {
    const uid = activeUser.id;
    const uName = (activeUser.nama || '').toLowerCase().trim();

    return karyaList.filter(k => {
      // 1. Cocokkan ID penulis jika ada
      if (k.penulisId && uid && k.penulisId === uid) return true;
      // 2. Cocokkan nama penulis
      if (uName && k.penulis && k.penulis.toLowerCase().includes(uName)) return true;
      // 3. Fallback jika akun demo Amanda default
      if (uid === 'user-001' && k.penulis && k.penulis.toLowerCase().includes('amanda')) return true;
      return false;
    });
  });

  let filterStatus = $state<StatusKarya | 'Semua'>('Semua');

  let filteredKarya = $derived(
    filterStatus === 'Semua' ? myKarya : myKarya.filter(k => k.status === filterStatus)
  );

  const statusConfig: Record<string, { label: string; color: string; bg: string; icon: string; dot?: string }> = {
    'Draft':        { label: 'Draft',         color: 'text-status-draft',     bg: 'bg-status-draft/10',     icon: 'edit_document' },
    'Diajukan':     { label: 'Diajukan',       color: 'text-status-submitted', bg: 'bg-status-submitted/10', icon: 'pending',       dot: 'bg-status-submitted' },
    'Dalam Review': { label: 'Dalam Review',   color: 'text-status-review',    bg: 'bg-status-review/10',    icon: 'rate_review',   dot: 'bg-status-review' },
    'Perlu Revisi': { label: 'Perlu Revisi',   color: 'text-status-revision',  bg: 'bg-status-revision/10',  icon: 'error' },
    'Diterbitkan':  { label: 'Diterbitkan',    color: 'text-status-published', bg: 'bg-status-published/10', icon: 'check_circle' },
    'Ditolak':      { label: 'Ditolak',        color: 'text-status-rejected',  bg: 'bg-status-rejected/10',  icon: 'cancel' },
  };

  let totalKarya       = $derived(myKarya.length);
  let totalDiterbitkan = $derived(myKarya.filter(k => k.status === 'Diterbitkan').length);
  let totalReview      = $derived(myKarya.filter(k => k.status === 'Dalam Review').length);
  let totalRevisi      = $derived(myKarya.filter(k => k.status === 'Perlu Revisi').length);
  let totalUnduhan     = $derived(myKarya.reduce((s, k) => s + (k.unduhan || 0), 0));

  const filterTabs: (StatusKarya | 'Semua')[] = [
    'Semua', 'Draft', 'Diajukan', 'Dalam Review', 'Perlu Revisi', 'Diterbitkan', 'Ditolak'
  ];

  function countByStatus(s: StatusKarya | 'Semua') {
    return s === 'Semua' ? myKarya.length : myKarya.filter(k => k.status === s).length;
  }

  function canEdit(karya: Karya) {
    return karya.status === 'Draft' || karya.status === 'Perlu Revisi';
  }

  function handleOpenBuktiPenyerahan(k?: Karya) {
    const target = k || myKarya.find(item => item.status === 'Diterbitkan') || myKarya[0] || null;
    selectedBebasPustakaKarya = target;
    isBebasPustakaOpen = true;
  }

  function handleCopyShareLink(karya: Karya) {
    const url = `https://portal.immortal-campus.ac.id/karya/${karya.id}`;
    navigator.clipboard.writeText(url);
    showToast(`Tautan naskah "${karya.judul.slice(0, 30)}..." berhasil disalin ke clipboard!`);
  }

  // --- Internal Jelajah state inside Penulis ---
  let exploreSearch = $state('');
  let exploreCategory = $state('all');
  let exploreProdi = $state('all');

  let internalExploreList = $derived(
    karyaList
      .filter(k => k.status === 'Diterbitkan')
      .filter(k => exploreCategory === 'all' || k.jenis === exploreCategory)
      .filter(k => exploreProdi === 'all' || k.prodiKey === exploreProdi)
      .filter(k =>
        exploreSearch === '' ||
        k.judul.toLowerCase().includes(exploreSearch.toLowerCase()) ||
        k.penulis.toLowerCase().includes(exploreSearch.toLowerCase()) ||
        k.abstrak.toLowerCase().includes(exploreSearch.toLowerCase())
      )
  );

  function copyCitation(karya: Karya, format: 'apa' | 'ieee') {
    let cit = '';
    if (format === 'apa') {
      cit = `${karya.penulis}. (${karya.tahun}). ${karya.judul}. Repositori Immortal Campus. DOI: ${karya.doi || '10.2412/imc'}.`;
    } else {
      cit = `[1] ${karya.penulis}, "${karya.judul}," Immortal Campus Repository, ${karya.tahun}.`;
    }
    navigator.clipboard.writeText(cit);
    showToast(`Sitasi format ${format.toUpperCase()} berhasil disalin!`);
  }
</script>

{#if isOpen}
  <!-- Full-screen overlay -->
  <div class="fixed inset-0 z-50 bg-[#f8faff] flex overflow-hidden">

    <!-- Toast Notification inside Dashboard -->
    {#if copyToast}
      <div class="fixed bottom-6 right-6 z-[70] animate-slideUp">
        <div class="flex items-center gap-2.5 px-4 py-3 rounded-xl bg-slate-900 text-white text-xs sm:text-sm font-semibold shadow-xl border border-slate-700">
          <span class="material-symbols-outlined text-status-published text-lg">check_circle</span>
          <span>{copyToast}</span>
        </div>
      </div>
    {/if}

    <!-- ──────────────────────── MOBILE DRAWER ──────────────────────── -->
    {#if mobileSidebarOpen}
      <!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions -->
      <div
        class="fixed inset-0 z-40 bg-slate-900/60 backdrop-blur-sm md:hidden animate-fadeIn"
        role="presentation"
        onclick={() => mobileSidebarOpen = false}
      ></div>

      <aside class="fixed inset-y-0 left-0 z-50 w-72 max-w-[85vw] bg-white shadow-2xl flex flex-col justify-between border-r border-slate-200 md:hidden animate-slideRight">
        <div class="flex flex-col overflow-y-auto">
          <div class="h-16 px-4 border-b border-slate-100 flex items-center justify-between">
            <div class="flex items-center gap-3">
              <img
                alt="Immortal Campus Logo"
                class="h-10 w-auto object-contain shrink-0"
                src="/logo.png"
              />
              <div class="flex flex-col min-w-0">
                <span class="font-bold text-slate-900 text-[14px] tracking-tight font-display-hero truncate">Immortal Campus</span>
                <span class="text-[10px] text-primary font-semibold truncate flex items-center gap-1">
                  <span class="w-1.5 h-1.5 rounded-full bg-status-published"></span>
                  Portal Penulis Mahasiswa
                </span>
              </div>
            </div>
            <button
              type="button"
              onclick={() => mobileSidebarOpen = false}
              class="p-1.5 rounded-lg text-slate-400 hover:text-slate-700 hover:bg-slate-100"
              aria-label="Tutup menu"
            >
              <span class="material-symbols-outlined text-xl">close</span>
            </button>
          </div>

          <div class="p-3.5 border-b border-slate-100">
            <div class="p-2.5 rounded-xl bg-primary/5 border border-primary/15 flex items-center gap-2.5">
              <div class="w-8 h-8 rounded-full bg-primary text-white flex items-center justify-center font-bold text-xs shrink-0 shadow-sm">
                {userInitials}
              </div>
              <div class="min-w-0">
                <p class="text-xs font-bold text-slate-900 truncate leading-tight">{userDisplayName}</p>
                <p class="text-[10px] text-slate-500 font-medium truncate mt-0.5">{userSubLabel}</p>
              </div>
            </div>
          </div>

          <nav class="p-3 space-y-1">
            <p class="px-2 py-1 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Halaman Penulis</p>

            <button
              type="button"
              class="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer text-left
                {activeTab === 'beranda' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'}"
              onclick={() => { activeTab = 'beranda'; mobileSidebarOpen = false; }}
            >
              <span class="material-symbols-outlined text-[18px]">dashboard</span>
              <span>Beranda Penulis</span>
            </button>

            <button
              type="button"
              class="w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer text-left
                {activeTab === 'karya' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'}"
              onclick={() => { activeTab = 'karya'; mobileSidebarOpen = false; }}
            >
              <div class="flex items-center gap-2.5">
                <span class="material-symbols-outlined text-[18px]">library_books</span>
                <span>Karya Saya</span>
              </div>
              {#if totalKarya > 0}
                <span class="px-2 py-0.5 rounded-full text-[10px] font-bold {activeTab === 'karya' ? 'bg-white/20 text-white' : 'bg-slate-200 text-slate-700'}">
                  {totalKarya}
                </span>
              {/if}
            </button>

            <button
              type="button"
              class="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer text-left
                {activeTab === 'jelajah' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'}"
              onclick={() => { activeTab = 'jelajah'; mobileSidebarOpen = false; }}
            >
              <span class="material-symbols-outlined text-[18px]">explore</span>
              <span>Jelajah Literatur</span>
            </button>

            <button
              type="button"
              class="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer text-left
                {activeTab === 'panduan' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'}"
              onclick={() => { activeTab = 'panduan'; mobileSidebarOpen = false; }}
            >
              <span class="material-symbols-outlined text-[18px]">menu_book</span>
              <span>Panduan Mandiri</span>
            </button>

            <button
              type="button"
              class="w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer text-left
                {activeTab === 'bebas-pustaka' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'}"
              onclick={() => { activeTab = 'bebas-pustaka'; mobileSidebarOpen = false; }}
            >
              <div class="flex items-center gap-2.5">
                <span class="material-symbols-outlined text-[18px]">workspace_premium</span>
                <span>Bebas Pustaka</span>
              </div>
              {#if totalDiterbitkan > 0}
                <span class="px-1.5 py-0.2 rounded-full text-[9px] font-bold bg-status-published/15 text-status-published">Aktif</span>
              {/if}
            </button>
          </nav>
        </div>

        <div class="p-3 border-t border-slate-100 space-y-2">
          <button
            type="button"
            onclick={() => { onClose(); mobileSidebarOpen = false; }}
            class="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:text-slate-900 hover:bg-slate-100 transition-colors cursor-pointer"
          >
            <span class="material-symbols-outlined text-base">arrow_back</span>
            <span>Lihat Repositori Publik</span>
          </button>

          {#if onLogout}
            <button
              type="button"
              onclick={() => { if (onLogout) onLogout(); mobileSidebarOpen = false; }}
              class="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-xl text-xs font-bold text-red-600 hover:text-red-700 hover:bg-red-50 border border-red-200 transition-colors cursor-pointer"
            >
              <span class="material-symbols-outlined text-base">logout</span>
              <span>Keluar dari Akun</span>
            </button>
          {/if}
        </div>
      </aside>
    {/if}

    <!-- ──────────────────────── LEFT SIDEBAR ──────────────────────── -->
    <aside class="hidden md:flex w-64 shrink-0 bg-white border-r border-slate-200/80 flex-col justify-between shadow-sm z-20">
      <div class="flex flex-col">
        <!-- Brand Header -->
        <div class="h-20 px-5 border-b border-slate-100 flex items-center">
          <div class="flex items-center gap-3">
            <img
              alt="Immortal Campus Logo"
              class="h-14 w-auto object-contain shrink-0"
              src="/logo.png"
            />
            <div class="flex flex-col min-w-0">
              <span class="font-bold text-slate-900 text-[15px] tracking-tight font-display-hero truncate">Immortal Campus</span>
              <span class="text-[11px] text-primary font-semibold truncate flex items-center gap-1">
                <span class="w-1.5 h-1.5 rounded-full bg-status-published"></span>
                Portal Penulis Mahasiswa
              </span>
            </div>
          </div>
        </div>

        <!-- Student Profile Capsule -->
        <div class="p-4 border-b border-slate-100">
          <div class="p-3 rounded-xl bg-primary/5 border border-primary/15 flex items-center gap-3">
            <div class="w-9 h-9 rounded-full bg-primary text-white flex items-center justify-center font-bold text-xs shrink-0 shadow-sm">
              {userInitials}
            </div>
            <div class="min-w-0">
              <p class="text-xs font-bold text-slate-900 truncate leading-tight">{userDisplayName}</p>
              <p class="text-[10px] text-slate-500 font-medium truncate mt-0.5">{userSubLabel}</p>
            </div>
          </div>
        </div>

        <!-- Navigation Links in Sidebar (Dedicated Penulis Pages) -->
        <nav class="p-3.5 space-y-1">
          <p class="px-2.5 py-1 text-[10px] font-bold text-slate-400 uppercase tracking-wider">Halaman Penulis</p>

          <!-- 1. Beranda Penulis -->
          <button
            type="button"
            class="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all cursor-pointer text-left
              {activeTab === 'beranda' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'}"
            onclick={() => activeTab = 'beranda'}
          >
            <span class="material-symbols-outlined text-[20px]">dashboard</span>
            <span>Beranda Penulis</span>
          </button>

          <!-- 2. Karya Saya -->
          <button
            type="button"
            class="w-full flex items-center justify-between px-3.5 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all cursor-pointer text-left
              {activeTab === 'karya' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'}"
            onclick={() => activeTab = 'karya'}
          >
            <div class="flex items-center gap-3">
              <span class="material-symbols-outlined text-[20px]">library_books</span>
              <span>Karya Saya</span>
            </div>
            {#if totalKarya > 0}
              <span class="px-2 py-0.5 rounded-full text-[10px] font-bold {activeTab === 'karya' ? 'bg-white/20 text-white' : 'bg-slate-200 text-slate-700'}">
                {totalKarya}
              </span>
            {/if}
          </button>

          <!-- 3. Jelajah Referensi Internal Mahasiswa -->
          <button
            type="button"
            class="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all cursor-pointer text-left
              {activeTab === 'jelajah' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'}"
            onclick={() => activeTab = 'jelajah'}
          >
            <span class="material-symbols-outlined text-[20px]">explore</span>
            <span>Jelajah Referensi</span>
          </button>

          <!-- 4. Panduan Unggah Mandiri -->
          <button
            type="button"
            class="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all cursor-pointer text-left
              {activeTab === 'panduan' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'}"
            onclick={() => activeTab = 'panduan'}
          >
            <span class="material-symbols-outlined text-[20px]">menu_book</span>
            <span>Panduan Unggah</span>
          </button>

          <!-- 5. Layanan Bebas Pustaka -->
          <button
            type="button"
            class="w-full flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all cursor-pointer text-left
              {activeTab === 'bebas-pustaka' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-100 hover:text-slate-900'}"
            onclick={() => activeTab = 'bebas-pustaka'}
          >
            <span class="material-symbols-outlined text-[20px] text-emerald-600">workspace_premium</span>
            <span>Bebas Pustaka</span>
          </button>
        </nav>

        <!-- Quick Stats Widget in Sidebar -->
        <div class="mx-3.5 mt-2 p-3.5 rounded-2xl bg-slate-50 border border-slate-200/70 space-y-2">
          <p class="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Statistik Naskah</p>
          <div class="space-y-1.5 text-xs">
            <div class="flex items-center justify-between text-slate-600">
              <span class="flex items-center gap-1.5"><span class="material-symbols-outlined text-sm text-primary">menu_book</span>Total Karya</span>
              <span class="font-bold text-slate-900">{totalKarya}</span>
            </div>
            <div class="flex items-center justify-between text-slate-600">
              <span class="flex items-center gap-1.5"><span class="material-symbols-outlined text-sm text-emerald-600">verified</span>Diterbitkan</span>
              <span class="font-bold text-emerald-600">{totalDiterbitkan}</span>
            </div>
            <div class="flex items-center justify-between text-slate-600">
              <span class="flex items-center gap-1.5"><span class="material-symbols-outlined text-sm text-blue-600">download</span>Unduhan</span>
              <span class="font-bold text-slate-900">{totalUnduhan.toLocaleString('id-ID')}</span>
            </div>
            {#if totalRevisi > 0}
              <div class="flex items-center justify-between text-amber-600">
                <span class="flex items-center gap-1.5"><span class="material-symbols-outlined text-sm">error</span>Perlu Revisi</span>
                <span class="font-bold">{totalRevisi}</span>
              </div>
            {/if}
          </div>
        </div>
      </div>

      <!-- Sidebar Footer (Kembali ke Publik / Keluar) -->
      <div class="p-3.5 border-t border-slate-100 space-y-2">
        <button
          type="button"
          onclick={onClose}
          class="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-xl text-xs font-semibold text-slate-600 hover:text-slate-900 hover:bg-slate-100 transition-colors cursor-pointer"
        >
          <span class="material-symbols-outlined text-base">arrow_back</span>
          <span>Lihat Repositori Publik</span>
        </button>

        {#if onLogout}
          <button
            type="button"
            onclick={onLogout}
            class="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-xl text-xs font-bold text-red-600 hover:text-red-700 hover:bg-red-50 border border-red-200 transition-colors cursor-pointer"
          >
            <span class="material-symbols-outlined text-base">logout</span>
            <span>Keluar dari Akun</span>
          </button>
        {/if}
      </div>
    </aside>

    <!-- ──────────────────────── RIGHT MAIN CONTENT ──────────────────────── -->
    <div class="flex-1 flex flex-col min-w-0 overflow-hidden">

      <!-- Top Header Bar -->
      <header class="sticky top-0 z-30 bg-white/95 backdrop-blur-xl border-b border-slate-200/80 h-16 shrink-0 px-3 sm:px-6 flex items-center justify-between gap-2">
        <div class="flex items-center gap-2 sm:gap-3 min-w-0">
          <!-- Mobile hamburger menu button -->
          <button
            type="button"
            onclick={() => mobileSidebarOpen = true}
            class="md:hidden p-2 rounded-xl text-slate-600 hover:text-slate-900 hover:bg-slate-100 shrink-0"
            aria-label="Buka menu penulis"
          >
            <span class="material-symbols-outlined text-xl">menu</span>
          </button>
          <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-primary/10 text-primary shrink-0">
            <span class="w-2 h-2 rounded-full bg-primary animate-pulse"></span>
            {#if activeTab === 'beranda'}Beranda &amp; Progres Penulis
            {:else if activeTab === 'karya'}Manajemen Karya &amp; Revisi
            {:else if activeTab === 'jelajah'}Jelajah Literatur &amp; Referensi
            {:else if activeTab === 'panduan'}Panduan Mandiri Pengunggahan
            {:else if activeTab === 'bebas-pustaka'}Layanan Bebas Perpustakaan
            {/if}
          </span>
          <span class="text-xs text-slate-400 hidden lg:inline">• Repositori Resmi UPT Perpustakaan</span>
        </div>

        <div class="flex items-center gap-2 sm:gap-3 shrink-0">
          <button
            type="button"
            onclick={onOpenUpload}
            class="inline-flex items-center gap-1.5 px-3 sm:px-4 py-2 rounded-xl bg-primary hover:bg-blue-600 text-white text-xs sm:text-sm font-bold shadow-md shadow-primary/20 transition-all active:scale-95 cursor-pointer"
          >
            <span class="material-symbols-outlined text-base">upload_file</span>
            <span class="hidden sm:inline">Unggah Karya Baru</span>
            <span class="sm:hidden">Unggah</span>
          </button>

          <button
            type="button"
            onclick={onClose}
            class="w-9 h-9 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-600 flex items-center justify-center transition-colors cursor-pointer"
            title="Tutup & Kembali ke Publik"
          >
            <span class="material-symbols-outlined text-lg">close</span>
          </button>
        </div>
      </header>

      <!-- Scrollable Body with Dynamic Views -->
      <main class="flex-1 overflow-y-auto p-4 sm:p-6 md:p-8">
        <div class="max-w-6xl mx-auto space-y-6">

          <!-- ═══════════════════════════════════════════════════════ -->
          <!-- 1. VIEW: BERANDA PENULIS (IKHTISAR LENGKAP MAHASISWA)   -->
          <!-- ═══════════════════════════════════════════════════════ -->
          {#if activeTab === 'beranda'}
            <!-- Welcome Banner -->
            <div class="relative overflow-hidden rounded-3xl bg-gradient-to-r from-blue-700 via-primary to-blue-600 text-white p-7 md:p-8 shadow-lg">
              <div class="relative z-10 flex flex-col lg:flex-row lg:items-center justify-between gap-6">
                <div class="space-y-2 max-w-2xl">
                  <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/15 text-white text-xs font-semibold backdrop-blur-sm">
                    <span class="material-symbols-outlined text-sm">verified_user</span>
                    <span>Status: Mahasiswa Aktif Semester Akhir</span>
                  </div>
                  <h1 class="text-2xl sm:text-3xl font-extrabold tracking-tight font-display-hero">
                    Selamat Datang, {userName}!
                  </h1>
                  <p class="text-xs sm:text-sm text-blue-100 leading-relaxed">
                    Portal terpadu untuk pengunggahan naskah akhir, pemantauan kurasi oleh pustakawan, serta penerbitan bukti bebas pustaka syarat kelulusan yudisium.
                  </p>
                </div>

                <div class="flex flex-wrap sm:flex-nowrap items-center gap-3 shrink-0">
                  <button
                    type="button"
                    onclick={() => handleOpenBuktiPenyerahan()}
                    class="px-4 py-2.5 rounded-xl bg-white text-primary font-bold text-xs sm:text-sm hover:bg-blue-50 transition-all shadow cursor-pointer flex items-center gap-2"
                  >
                    <span class="material-symbols-outlined text-base">workspace_premium</span>
                    <span>Cetak Bebas Pustaka</span>
                  </button>
                  <button
                    type="button"
                    onclick={onOpenUpload}
                    class="px-4 py-2.5 rounded-xl bg-blue-900/40 border border-white/25 text-white font-bold text-xs sm:text-sm hover:bg-blue-900/60 transition-all cursor-pointer flex items-center gap-2"
                  >
                    <span class="material-symbols-outlined text-base">add_circle</span>
                    <span>Ajukan Naskah</span>
                  </button>
                </div>
              </div>
            </div>

            <!-- Tracker Alur Wisuda & Penyerahan Mandiri -->
            <div class="p-6 rounded-3xl bg-white border border-slate-200/80 shadow-sm space-y-5">
              <div class="flex items-center justify-between">
                <div>
                  <h2 class="text-base font-bold text-slate-900">Alur Penyelesaian Repositori Tugas Akhir</h2>
                  <p class="text-xs text-slate-500">Tahapan wajib sebelum pengambilan Ijazah &amp; Transkrip Nilai</p>
                </div>
                <span class="px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold border border-emerald-200">
                  Progres: 100% Siap Yudisium
                </span>
              </div>

              <!-- 4-Step Flow -->
              <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <div class="p-4 rounded-2xl bg-emerald-50/70 border border-emerald-200/80 space-y-2">
                  <div class="flex items-center justify-between">
                    <span class="w-7 h-7 rounded-full bg-emerald-600 text-white font-bold text-xs flex items-center justify-center">1</span>
                    <span class="material-symbols-outlined text-emerald-600 text-lg">check_circle</span>
                  </div>
                  <h3 class="font-bold text-xs text-slate-900">Penulisan Selesai</h3>
                  <p class="text-[11px] text-slate-600 leading-snug">Sidang skripsi lulus &amp; lembar pengesahan ditandatangani penguji.</p>
                </div>

                <div class="p-4 rounded-2xl bg-emerald-50/70 border border-emerald-200/80 space-y-2">
                  <div class="flex items-center justify-between">
                    <span class="w-7 h-7 rounded-full bg-emerald-600 text-white font-bold text-xs flex items-center justify-center">2</span>
                    <span class="material-symbols-outlined text-emerald-600 text-lg">check_circle</span>
                  </div>
                  <h3 class="font-bold text-xs text-slate-900">Uji Turnitin Lolos</h3>
                  <p class="text-[11px] text-slate-600 leading-snug">Skor similarity 12% (di bawah batas toleransi kampus 20%).</p>
                </div>

                <div class="p-4 rounded-2xl bg-emerald-50/70 border border-emerald-200/80 space-y-2">
                  <div class="flex items-center justify-between">
                    <span class="w-7 h-7 rounded-full bg-emerald-600 text-white font-bold text-xs flex items-center justify-center">3</span>
                    <span class="material-symbols-outlined text-emerald-600 text-lg">check_circle</span>
                  </div>
                  <h3 class="font-bold text-xs text-slate-900">Kurasi Disetujui</h3>
                  <p class="text-[11px] text-slate-600 leading-snug">Divalidasi Dr. Rina Suryani, M.Kom. (Pustakawan Ahli).</p>
                </div>

                <div class="p-4 rounded-2xl bg-primary/10 border border-primary/25 space-y-2">
                  <div class="flex items-center justify-between">
                    <span class="w-7 h-7 rounded-full bg-primary text-white font-bold text-xs flex items-center justify-center">4</span>
                    <span class="material-symbols-outlined text-primary text-lg">workspace_premium</span>
                  </div>
                  <h3 class="font-bold text-xs text-slate-900">Bebas Pustaka Aktif</h3>
                  <p class="text-[11px] text-slate-600 leading-snug">Naskah diterbitkan, DOI diterbitkan, surat bebas pustaka siap dicetak.</p>
                </div>
              </div>
            </div>

            <!-- Quick Action Cards Grid -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
              <!-- Card 1: Karya Saya -->
              <button
                type="button"
                onclick={() => activeTab = 'karya'}
                class="p-5 rounded-2xl bg-white border border-slate-200/80 shadow-sm hover:border-primary/50 hover:shadow-md transition-all text-left group cursor-pointer space-y-3"
              >
                <div class="w-10 h-10 rounded-xl bg-primary/10 text-primary flex items-center justify-center group-hover:bg-primary group-hover:text-white transition-colors">
                  <span class="material-symbols-outlined text-xl">library_books</span>
                </div>
                <div>
                  <h3 class="font-bold text-slate-900 text-sm group-hover:text-primary transition-colors">Kelola Karya Saya ({totalKarya})</h3>
                  <p class="text-xs text-slate-500 mt-1">Periksa status telaah, revisi naskah draft, atau salin tautan naskah yang terbit.</p>
                </div>
                <span class="inline-flex items-center text-xs text-primary font-bold gap-1">
                  Buka Karya Saya <span class="material-symbols-outlined text-sm">arrow_forward</span>
                </span>
              </button>

              <!-- Card 2: Jelajah Literatur -->
              <button
                type="button"
                onclick={() => activeTab = 'jelajah'}
                class="p-5 rounded-2xl bg-white border border-slate-200/80 shadow-sm hover:border-primary/50 hover:shadow-md transition-all text-left group cursor-pointer space-y-3"
              >
                <div class="w-10 h-10 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center group-hover:bg-purple-600 group-hover:text-white transition-colors">
                  <span class="material-symbols-outlined text-xl">travel_explore</span>
                </div>
                <div>
                  <h3 class="font-bold text-slate-900 text-sm group-hover:text-purple-700 transition-colors">Cari Referensi Ilmiah</h3>
                  <p class="text-xs text-slate-500 mt-1">Telusuri ribuan skripsi, tesis, dan jurnal kampus untuk referensi penelitian Anda.</p>
                </div>
                <span class="inline-flex items-center text-xs text-purple-700 font-bold gap-1">
                  Jelajah Koleksi <span class="material-symbols-outlined text-sm">arrow_forward</span>
                </span>
              </button>

              <!-- Card 3: Panduan & Berkas -->
              <button
                type="button"
                onclick={() => activeTab = 'panduan'}
                class="p-5 rounded-2xl bg-white border border-slate-200/80 shadow-sm hover:border-primary/50 hover:shadow-md transition-all text-left group cursor-pointer space-y-3"
              >
                <div class="w-10 h-10 rounded-xl bg-amber-100 text-amber-700 flex items-center justify-center group-hover:bg-amber-600 group-hover:text-white transition-colors">
                  <span class="material-symbols-outlined text-xl">menu_book</span>
                </div>
                <div>
                  <h3 class="font-bold text-slate-900 text-sm group-hover:text-amber-700 transition-colors">Panduan &amp; Format Unggah</h3>
                  <p class="text-xs text-slate-500 mt-1">Unduh template lembar persetujuan, format penamaan file, dan syarat bebas plagiat.</p>
                </div>
                <span class="inline-flex items-center text-xs text-amber-700 font-bold gap-1">
                  Baca Panduan <span class="material-symbols-outlined text-sm">arrow_forward</span>
                </span>
              </button>
            </div>

            <!-- Naskah Utama Mahasiswa Showcase -->
            {#if myKarya.length > 0}
              <div class="p-6 rounded-3xl bg-white border border-slate-200/80 shadow-sm space-y-4">
                <div class="flex items-center justify-between flex-wrap gap-2">
                  <div class="flex items-center gap-2">
                    <span class="w-3 h-3 rounded-full bg-status-published"></span>
                    <h3 class="font-bold text-slate-900 text-sm">Naskah Terpublikasi Anda</h3>
                  </div>
                  <span class="text-xs font-mono text-slate-400">DOI: {myKarya[0].doi || '10.2412/imc.2024.089'}</span>
                </div>

                <div class="p-5 rounded-2xl bg-slate-50 border border-slate-200/60 flex flex-col md:flex-row md:items-center justify-between gap-4">
                  <div class="space-y-1.5 max-w-3xl">
                    <div class="flex items-center gap-2">
                      <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-primary text-white uppercase">{myKarya[0].jenisLabel}</span>
                      <span class="text-xs text-slate-500">Tahun {myKarya[0].tahun}</span>
                    </div>
                    <button
                      type="button"
                      onclick={() => onOpenDetail(myKarya[0])}
                      class="text-left font-bold text-slate-900 hover:text-primary transition-colors text-sm sm:text-base leading-snug cursor-pointer"
                    >
                      {myKarya[0].judul}
                    </button>
                    <p class="text-xs text-slate-600 line-clamp-2">{myKarya[0].abstrak}</p>
                  </div>

                  <div class="flex items-center gap-2 shrink-0">
                    <button
                      type="button"
                      onclick={() => handleCopyShareLink(myKarya[0])}
                      class="px-3 py-2 rounded-xl border border-slate-200 hover:bg-white text-slate-700 text-xs font-semibold flex items-center gap-1.5 transition-colors cursor-pointer"
                    >
                      <span class="material-symbols-outlined text-base">share</span>
                      <span>Bagikan</span>
                    </button>
                    <button
                      type="button"
                      onclick={() => onOpenDetail(myKarya[0])}
                      class="px-4 py-2 rounded-xl bg-primary text-white text-xs font-bold hover:bg-blue-600 transition-colors flex items-center gap-1.5 cursor-pointer"
                    >
                      <span class="material-symbols-outlined text-base">visibility</span>
                      <span>Lihat Detail</span>
                    </button>
                  </div>
                </div>
              </div>
            {/if}

          <!-- ═══════════════════════════════════════════════════════ -->
          <!-- 2. VIEW: KARYA SAYA (DAFTAR NASKAH LENGKAP & REVISI)   -->
          <!-- ═══════════════════════════════════════════════════════ -->
          {:else if activeTab === 'karya'}
            <div class="space-y-5">
              <!-- Filter status bar -->
              <div class="flex items-center justify-between flex-wrap gap-3 p-4 bg-white rounded-2xl border border-slate-200/80 shadow-sm">
                <div class="flex flex-wrap items-center gap-1.5">
                  {#each filterTabs as tab}
                    {@const count = countByStatus(tab)}
                    <button
                      type="button"
                      onclick={() => filterStatus = tab}
                      class="px-3 py-1.5 rounded-xl text-xs font-bold transition-all cursor-pointer flex items-center gap-1.5
                        {filterStatus === tab
                          ? 'bg-primary text-white shadow-sm'
                          : 'bg-slate-100 text-slate-600 hover:bg-slate-200'}"
                    >
                      <span>{tab}</span>
                      <span class="px-1.5 py-0.2 rounded-full text-[10px] {filterStatus === tab ? 'bg-white/25 text-white' : 'bg-slate-300 text-slate-800'}">
                        {count}
                      </span>
                    </button>
                  {/each}
                </div>

                <button
                  type="button"
                  onclick={onOpenUpload}
                  class="px-3.5 py-1.5 rounded-xl bg-primary hover:bg-blue-600 text-white text-xs font-bold shadow transition-all cursor-pointer flex items-center gap-1.5"
                >
                  <span class="material-symbols-outlined text-base">add</span>
                  <span>Tambah Naskah</span>
                </button>
              </div>

              <!-- Manuscripts Cards List -->
              {#if filteredKarya.length === 0}
                <div class="text-center py-16 bg-white rounded-3xl border border-dashed border-slate-300 p-8 space-y-3">
                  <span class="material-symbols-outlined text-4xl text-slate-400">folder_open</span>
                  <p class="font-bold text-slate-700 text-sm">Tidak ada karya dengan status "{filterStatus}".</p>
                  <p class="text-xs text-slate-400">Silakan pilih filter lain atau unggah karya baru.</p>
                </div>
              {:else}
                <div class="space-y-4">
                  {#each filteredKarya as karya (karya.id)}
                    {@const cfg = statusConfig[karya.status] || { label: karya.status, color: 'text-slate-600', bg: 'bg-slate-100', icon: 'info' }}
                    <article class="p-6 bg-white rounded-2xl border border-slate-200/80 shadow-sm hover:shadow transition-shadow space-y-4">
                      <div class="flex items-start justify-between gap-4 flex-wrap">
                        <div class="space-y-1.5 max-w-3xl">
                          <div class="flex items-center gap-2 flex-wrap">
                            <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-slate-100 text-slate-700 uppercase">
                              {karya.jenisLabel}
                            </span>
                            <span class="text-xs text-slate-500">• {karya.prodi} • Tahun {karya.tahun}</span>
                          </div>
                          <h3 class="text-base font-bold text-slate-900 hover:text-primary transition-colors">
                            <button type="button" onclick={() => onOpenDetail(karya)} class="text-left cursor-pointer">
                              {karya.judul}
                            </button>
                          </h3>
                        </div>

                        <!-- Status badge -->
                        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold {cfg.bg} {cfg.color} shrink-0">
                          <span class="material-symbols-outlined text-sm">{cfg.icon}</span>
                          <span>{cfg.label}</span>
                        </span>
                      </div>

                      <p class="text-xs text-slate-600 line-clamp-2 leading-relaxed">{karya.abstrak}</p>

                      <!-- Curator feedback note if revision or rejected -->
                      {#if karya.catatanKurator}
                        <div class="p-3.5 rounded-xl bg-orange-50 border border-orange-200/80 text-xs text-orange-900 space-y-1">
                          <p class="font-bold flex items-center gap-1.5">
                            <span class="material-symbols-outlined text-base text-orange-600">rate_review</span>
                            Catatan Tim Kurator:
                          </p>
                          <p class="leading-relaxed">{karya.catatanKurator}</p>
                        </div>
                      {/if}

                      <!-- Card Actions -->
                      <div class="flex items-center justify-between pt-2 border-t border-slate-100 flex-wrap gap-2 text-xs">
                        <div class="flex items-center gap-2">
                          <button
                            type="button"
                            onclick={() => onOpenDetail(karya)}
                            class="px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 text-slate-700 font-semibold cursor-pointer"
                          >
                            Lihat Detail
                          </button>

                          {#if canEdit(karya)}
                            <button
                              type="button"
                              onclick={() => onOpenEdit(karya)}
                              class="px-3 py-1.5 rounded-lg bg-primary hover:bg-blue-600 text-white font-bold flex items-center gap-1 cursor-pointer"
                            >
                              <span class="material-symbols-outlined text-sm">edit_square</span>
                              <span>{karya.status === 'Perlu Revisi' ? 'Perbaiki Revisi' : 'Edit Draft'}</span>
                            </button>
                          {/if}

                          {#if karya.status === 'Diterbitkan'}
                            <button
                              type="button"
                              onclick={() => handleOpenBuktiPenyerahan(karya)}
                              class="px-3 py-1.5 rounded-lg bg-emerald-50 text-emerald-700 hover:bg-emerald-100 font-bold flex items-center gap-1 cursor-pointer"
                            >
                              <span class="material-symbols-outlined text-sm">workspace_premium</span>
                              <span>Surat Bebas Pustaka</span>
                            </button>
                          {/if}
                        </div>

                        {#if karya.status === 'Diterbitkan'}
                          <button
                            type="button"
                            onclick={() => handleCopyShareLink(karya)}
                            class="text-slate-500 hover:text-primary font-semibold flex items-center gap-1 cursor-pointer"
                          >
                            <span class="material-symbols-outlined text-sm">share</span>
                            <span>Salin Tautan</span>
                          </button>
                        {/if}
                      </div>
                    </article>
                  {/each}
                </div>
              {/if}
            </div>

          <!-- ═══════════════════════════════════════════════════════ -->
          <!-- 3. VIEW: JELAJAH REFERENSI INTERNAL MAHASISWA           -->
          <!-- ═══════════════════════════════════════════════════════ -->
          {:else if activeTab === 'jelajah'}
            <div class="space-y-5">
              <!-- Internal Header & Search -->
              <div class="p-6 rounded-3xl bg-white border border-slate-200/80 shadow-sm space-y-4">
                <div>
                  <h2 class="text-lg font-bold text-slate-900">Jelajah Literatur &amp; Referensi Akademik</h2>
                  <p class="text-xs text-slate-500">Cari skripsi, tesis, dan artikel ilmiah terbitan sivitas akademika untuk rujukan penulisan karya Anda.</p>
                </div>

                <div class="flex flex-col sm:flex-row items-center gap-3">
                  <div class="relative flex-1 w-full">
                    <span class="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-lg">search</span>
                    <input
                      type="text"
                      bind:value={exploreSearch}
                      placeholder="Cari judul skripsi, nama penulis, topik, atau kata kunci..."
                      class="w-full pl-10 pr-4 py-2.5 rounded-xl border border-slate-200 text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/25"
                    />
                  </div>

                  <!-- Category filter -->
                  <select
                    bind:value={exploreCategory}
                    class="w-full sm:w-auto px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs sm:text-sm bg-white text-slate-700"
                  >
                    <option value="all">Semua Jenis Karya</option>
                    <option value="skripsi">Skripsi S-1</option>
                    <option value="tesis">Tesis S-2</option>
                    <option value="jurnal">Artikel Jurnal</option>
                    <option value="kp">Laporan KP</option>
                  </select>

                  <!-- Prodi filter -->
                  <select
                    bind:value={exploreProdi}
                    class="w-full sm:w-auto px-3.5 py-2.5 rounded-xl border border-slate-200 text-xs sm:text-sm bg-white text-slate-700"
                  >
                    <option value="all">Semua Program Studi</option>
                    <option value="ti">Teknik Informatika</option>
                    <option value="si">Sistem Informasi</option>
                    <option value="dkv">Desain Komunikasi Visual</option>
                    <option value="mnj">Manajemen</option>
                    <option value="ilkom">Ilmu Komunikasi</option>
                  </select>
                </div>
              </div>

              <!-- Search Results -->
              <div class="space-y-4">
                {#each internalExploreList as karya (karya.id)}
                  <div class="p-6 rounded-2xl bg-white border border-slate-200/80 shadow-sm space-y-3 hover:border-primary/40 transition-colors">
                    <div class="flex items-start justify-between gap-4 flex-wrap">
                      <div class="space-y-1 max-w-3xl">
                        <div class="flex items-center gap-2">
                          <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-primary/10 text-primary uppercase">
                            {karya.jenisLabel}
                          </span>
                          <span class="text-xs text-slate-500">• {karya.prodi} • {karya.tahun}</span>
                          <span class="text-xs text-slate-400">• Penulis: <strong>{karya.penulis}</strong></span>
                        </div>
                        <h3 class="font-bold text-slate-900 text-sm sm:text-base hover:text-primary transition-colors">
                          <button type="button" onclick={() => onOpenDetail(karya)} class="text-left cursor-pointer">
                            {karya.judul}
                          </button>
                        </h3>
                      </div>

                      <div class="flex items-center gap-2 text-xs text-slate-500">
                        <span class="flex items-center gap-1"><span class="material-symbols-outlined text-sm text-blue-600">download</span>{karya.unduhan}</span>
                        <span class="flex items-center gap-1"><span class="material-symbols-outlined text-sm text-emerald-600">verified</span>Terverifikasi</span>
                      </div>
                    </div>

                    <p class="text-xs text-slate-600 line-clamp-2 leading-relaxed">{karya.abstrak}</p>

                    <!-- Quick Citation & Detail Actions -->
                    <div class="flex items-center justify-between pt-2 border-t border-slate-100 flex-wrap gap-2 text-xs">
                      <div class="flex items-center gap-2">
                        <button
                          type="button"
                          onclick={() => onOpenDetail(karya)}
                          class="px-3 py-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold cursor-pointer"
                        >
                          Lihat Abstrak &amp; Detail
                        </button>
                        <button
                          type="button"
                          onclick={() => copyCitation(karya, 'apa')}
                          class="px-3 py-1.5 rounded-lg border border-slate-200 hover:bg-slate-50 text-slate-700 font-semibold flex items-center gap-1 cursor-pointer"
                        >
                          <span class="material-symbols-outlined text-sm text-primary">format_quote</span>
                          <span>Salin Sitasi (APA)</span>
                        </button>
                      </div>

                      <button
                        type="button"
                        onclick={() => showToast(`Mengunduh berkas lengkap: ${karya.judul.slice(0, 30)}...`)}
                        class="px-3.5 py-1.5 rounded-lg bg-primary hover:bg-blue-600 text-white font-bold flex items-center gap-1 cursor-pointer"
                      >
                        <span class="material-symbols-outlined text-sm">download</span>
                        <span>Unduh Naskah PDF</span>
                      </button>
                    </div>
                  </div>
                {/each}
              </div>
            </div>

          <!-- ═══════════════════════════════════════════════════════ -->
          <!-- 4. VIEW: PANDUAN UNGGAH MANDIRI MAHASISWA               -->
          <!-- ═══════════════════════════════════════════════════════ -->
          {:else if activeTab === 'panduan'}
            <div class="space-y-6">
              <!-- Header banner -->
              <div class="p-6 rounded-3xl bg-white border border-slate-200/80 shadow-sm space-y-2">
                <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-primary/10 text-primary text-xs font-bold">
                  <span class="material-symbols-outlined text-sm">school</span>
                  <span>Standar Pengunggahan UPT Perpustakaan</span>
                </div>
                <h2 class="text-xl font-bold text-slate-900">Panduan Penyerahan Mandiri Karya Ilmiah</h2>
                <p class="text-xs sm:text-sm text-slate-600 leading-relaxed max-w-3xl">
                  Ikuti instruksi berikut untuk memastikan naskah skripsi/tugas akhir Anda segera disetujui kurator tanpa perlu proses revisi berulang.
                </p>
              </div>

              <!-- 4 Step Cards -->
              <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                <div class="p-6 rounded-2xl bg-white border border-slate-200/80 shadow-sm space-y-3">
                  <div class="w-10 h-10 rounded-xl bg-blue-100 text-primary flex items-center justify-center font-bold text-base">
                    1
                  </div>
                  <h3 class="font-bold text-slate-900 text-sm">Format Dokumen Naskah (.PDF)</h3>
                  <p class="text-xs text-slate-600 leading-relaxed">
                    Naskah harus berformat PDF/A dengan teks yang dapat diseleksi (*text-selectable*, bukan hasil scan foto). Ukuran berkas maksimal 50 MB.
                  </p>
                  <ul class="text-xs text-slate-500 space-y-1 list-disc list-inside">
                    <li>Gunakan tata nama: <code class="bg-slate-100 px-1 py-0.5 rounded text-slate-800">NIM_Nama_Skripsi_Tahun.pdf</code></li>
                    <li>Sertakan bookmark bab lengkap pada PDF.</li>
                  </ul>
                </div>

                <div class="p-6 rounded-2xl bg-white border border-slate-200/80 shadow-sm space-y-3">
                  <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold text-base">
                    2
                  </div>
                  <h3 class="font-bold text-slate-900 text-sm">Lembar Pengesahan &amp; Bebas Plagiasi</h3>
                  <p class="text-xs text-slate-600 leading-relaxed">
                    Halaman pengesahan harus memuat tanda tangan pembimbing dan ketua penguji (dapat berupa TTD digital bersertifikat atau TTD basah).
                  </p>
                  <ul class="text-xs text-slate-500 space-y-1 list-disc list-inside">
                    <li>Surat pernyataan keaslian bermaterai Rp 10.000.</li>
                    <li>Laporan hasil uji Turnitin resmi dari fakultas.</li>
                  </ul>
                </div>

                <div class="p-6 rounded-2xl bg-white border border-slate-200/80 shadow-sm space-y-3">
                  <div class="w-10 h-10 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center font-bold text-base">
                    3
                  </div>
                  <h3 class="font-bold text-slate-900 text-sm">Ambang Batas Uji Kemiripan (Turnitin)</h3>
                  <p class="text-xs text-slate-600 leading-relaxed">
                    Toleransi indeks kesamaan (*similarity index*) adalah <strong>maksimal 20%</strong> (tidak termasuk daftar pustaka dan kutipan langsung).
                  </p>
                  <ul class="text-xs text-slate-500 space-y-1 list-disc list-inside">
                    <li>Jika $\gt 20\%$, naskah wajib diparafrase ulang.</li>
                    <li>Kurator akan memverifikasi ulang skor ke server.</li>
                  </ul>
                </div>

                <div class="p-6 rounded-2xl bg-white border border-slate-200/80 shadow-sm space-y-3">
                  <div class="w-10 h-10 rounded-xl bg-amber-100 text-amber-700 flex items-center justify-center font-bold text-base">
                    4
                  </div>
                  <h3 class="font-bold text-slate-900 text-sm">Waktu Penelaahan &amp; Bebas Pustaka</h3>
                  <p class="text-xs text-slate-600 leading-relaxed">
                    Tim kurator perpustakaan menelaah naskah dalam waktu <strong>1-3 hari kerja</strong> (SLA resmi).
                  </p>
                  <ul class="text-xs text-slate-500 space-y-1 list-disc list-inside">
                    <li>Jika disetujui, surat Bebas Pustaka langsung terbit.</li>
                    <li>Jika perlu revisi, perbaiki sesuai catatan kurator.</li>
                  </ul>
                </div>
              </div>

              <!-- Unduh Template Dokumen Resmi -->
              <div class="p-6 rounded-3xl bg-slate-900 text-white space-y-4">
                <div>
                  <h3 class="font-bold text-base">Unduh Template Dokumen Kelengkapan</h3>
                  <p class="text-xs text-slate-300">Gunakan format baku resmi UPT Perpustakaan untuk mempercepat proses persetujuan.</p>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-3 gap-3 text-xs">
                  <button
                    type="button"
                    onclick={() => showToast('Mengunduh Template Lembar Pengesahan (.DOCX)...')}
                    class="p-3.5 rounded-xl bg-white/10 hover:bg-white/20 transition-colors flex items-center justify-between text-left cursor-pointer"
                  >
                    <div>
                      <p class="font-bold">Lembar Pengesahan</p>
                      <p class="text-[10px] text-slate-400">Format Microsoft Word</p>
                    </div>
                    <span class="material-symbols-outlined text-primary">download</span>
                  </button>

                  <button
                    type="button"
                    onclick={() => showToast('Mengunduh Template Pernyataan Bebas Plagiasi (.DOCX)...')}
                    class="p-3.5 rounded-xl bg-white/10 hover:bg-white/20 transition-colors flex items-center justify-between text-left cursor-pointer"
                  >
                    <div>
                      <p class="font-bold">Surat Bebas Plagiasi</p>
                      <p class="text-[10px] text-slate-400">Materai Rp 10.000</p>
                    </div>
                    <span class="material-symbols-outlined text-primary">download</span>
                  </button>

                  <button
                    type="button"
                    onclick={() => showToast('Mengunduh Template Artikel Jurnal (.DOCX)...')}
                    class="p-3.5 rounded-xl bg-white/10 hover:bg-white/20 transition-colors flex items-center justify-between text-left cursor-pointer"
                  >
                    <div>
                      <p class="font-bold">Template Artikel Jurnal</p>
                      <p class="text-[10px] text-slate-400">2 Kolom Standar IEEE</p>
                    </div>
                    <span class="material-symbols-outlined text-primary">download</span>
                  </button>
                </div>
              </div>
            </div>

          <!-- ═══════════════════════════════════════════════════════ -->
          <!-- 5. VIEW: LAYANAN BEBAS PUSTAKA                          -->
          <!-- ═══════════════════════════════════════════════════════ -->
          {:else if activeTab === 'bebas-pustaka'}
            <div class="space-y-6">
              <div class="p-6 rounded-3xl bg-white border border-slate-200/80 shadow-sm space-y-2">
                <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-50 text-emerald-700 text-xs font-bold border border-emerald-200">
                  <span class="material-symbols-outlined text-sm">workspace_premium</span>
                  <span>Verifikasi Syarat Bebas Pustaka</span>
                </div>
                <h2 class="text-xl font-bold text-slate-900">Status Bebas Perpustakaan Mahasiswa</h2>
                <p class="text-xs sm:text-sm text-slate-600 leading-relaxed max-w-2xl">
                  Surat Keterangan Bebas Perpustakaan merupakan syarat mutlak pendaftaran yudisium dan pengambilan ijazah kelulusan.
                </p>
              </div>

              <!-- Status Checklist -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div class="p-5 rounded-2xl bg-white border border-slate-200/80 shadow-sm flex items-start gap-4">
                  <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
                    <span class="material-symbols-outlined text-xl">task_alt</span>
                  </div>
                  <div>
                    <h3 class="font-bold text-slate-900 text-sm">Penyerahan Karya Ilmiah</h3>
                    <p class="text-xs text-slate-500 mt-0.5">Naskah skripsi telah diverifikasi dan diterbitkan di repositori resmi.</p>
                    <span class="inline-block mt-2 text-[11px] font-bold text-emerald-600">✓ Lolos Verifikasi</span>
                  </div>
                </div>

                <div class="p-5 rounded-2xl bg-white border border-slate-200/80 shadow-sm flex items-start gap-4">
                  <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
                    <span class="material-symbols-outlined text-xl">auto_stories</span>
                  </div>
                  <div>
                    <h3 class="font-bold text-slate-900 text-sm">Bebas Peminjaman Buku Fisik</h3>
                    <p class="text-xs text-slate-500 mt-0.5">Tidak memiliki tanggungan peminjaman koleksi fisik perpustakaan pusat.</p>
                    <span class="inline-block mt-2 text-[11px] font-bold text-emerald-600">✓ 0 Buku Tertunggak</span>
                  </div>
                </div>

                <div class="p-5 rounded-2xl bg-white border border-slate-200/80 shadow-sm flex items-start gap-4">
                  <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
                    <span class="material-symbols-outlined text-xl">payments</span>
                  </div>
                  <div>
                    <h3 class="font-bold text-slate-900 text-sm">Bebas Denda Keterlambatan</h3>
                    <p class="text-xs text-slate-500 mt-0.5">Seluruh kewajiban denda peminjaman buku telah diselesaikan (lunas).</p>
                    <span class="inline-block mt-2 text-[11px] font-bold text-emerald-600">✓ Bebas Tanggungan (Rp 0)</span>
                  </div>
                </div>

                <div class="p-5 rounded-2xl bg-white border border-slate-200/80 shadow-sm flex items-start gap-4">
                  <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center shrink-0">
                    <span class="material-symbols-outlined text-xl">volunteer_activism</span>
                  </div>
                  <div>
                    <h3 class="font-bold text-slate-900 text-sm">Sumbangan Buku Alumni</h3>
                    <p class="text-xs text-slate-500 mt-0.5">Sumbangan 1 judul buku referensi program studi telah diterima bagian pengadaan.</p>
                    <span class="inline-block mt-2 text-[11px] font-bold text-emerald-600">✓ Tercatat di Sistem</span>
                  </div>
                </div>
              </div>

              <!-- Certificate Preview Box -->
              <div class="p-7 rounded-3xl bg-gradient-to-br from-slate-900 to-blue-950 text-white shadow-xl flex flex-col md:flex-row items-center justify-between gap-6">
                <div class="space-y-2 max-w-xl">
                  <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-emerald-500/20 text-emerald-300 text-xs font-bold border border-emerald-500/30">
                    <span class="material-symbols-outlined text-sm">verified</span>
                    <span>Surat Keterangan Siap Cetak</span>
                  </div>
                  <h3 class="text-xl font-bold font-display-hero">Surat Bebas Pustaka No. 042/BP-PUS/2026</h3>
                  <p class="text-xs text-slate-300 leading-relaxed">
                    Dokumen ini sah dilengkapi QR Code verifikasi digital dan stempel UPT Perpustakaan. Siap dicetak langsung atau diunduh format PDF.
                  </p>
                </div>

                <button
                  type="button"
                  onclick={() => handleOpenBuktiPenyerahan()}
                  class="px-6 py-3.5 rounded-2xl bg-primary hover:bg-blue-600 text-white font-bold text-sm shadow-lg shadow-primary/30 transition-all flex items-center gap-2 cursor-pointer active:scale-95 shrink-0"
                >
                  <span class="material-symbols-outlined text-xl">print</span>
                  <span>Buka &amp; Cetak Surat Resmi</span>
                </button>
              </div>
            </div>
          {/if}

        </div>
      </main>
    </div>
  </div>
{/if}

<!-- Bebas Pustaka Modal -->
<BebasPustakaModal
  isOpen={isBebasPustakaOpen}
  karya={selectedBebasPustakaKarya}
  authorName={userName}
  onClose={() => { isBebasPustakaOpen = false; selectedBebasPustakaKarya = null; }}
/>
