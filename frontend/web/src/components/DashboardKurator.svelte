<script lang="ts">
  import type { Karya } from '../types';

  interface Props {
    isOpen: boolean;
    karyaList: Karya[];
    currentUser?: any;
    onClose: () => void;
    onLogout?: () => void;
    onOpenReview: (karya: Karya) => void;
    onOpenDetail: (karya: Karya) => void;
    onDownloadKarya?: (karya: Karya) => void;
    onNavigateHome?: () => void;
    onNavigateJelajah?: () => void;
    pendingCount: number;
  }

  let {
    isOpen,
    karyaList,
    currentUser = null,
    onClose,
    onLogout,
    onOpenReview,
    onOpenDetail,
    onDownloadKarya,
    onNavigateHome,
    onNavigateJelajah,
    pendingCount
  }: Props = $props();

  function getInitials(name?: string): string {
    if (!name) return 'RS';
    const parts = name.trim().split(/\s+/);
    if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  let kuratorUser = $derived(
    currentUser || {
      id: 'user-002',
      nama: 'Kurator Perpustakaan',
      nip: '',
      prodi: 'UPT Perpustakaan',
      role: 'kurator'
    }
  );

  let kuratorName = $derived(kuratorUser.nama || 'Kurator Perpustakaan');
  let kuratorInitials = $derived(getInitials(kuratorName));

  // Active view: beranda | antrean | akreditasi | katalog | sop
  let activeView = $state<'beranda' | 'antrean' | 'akreditasi' | 'katalog' | 'sop'>('beranda');
  let mobileSidebarOpen = $state(false);

  let antreanReview = $derived(karyaList.filter(k => k.status === 'Diajukan' || k.status === 'Dalam Review'));
  let sudahDiproses = $derived(karyaList.filter(k => k.status === 'Diterbitkan' || k.status === 'Ditolak' || k.status === 'Perlu Revisi'));

  let activeTab = $state<'antrean' | 'diproses'>('antrean');
  let filterJenis = $state('all');
  let filterProdi = $state('all');
  let filterSubStatus = $state<'all' | 'Diterbitkan' | 'Perlu Revisi' | 'Ditolak'>('all');
  let searchQuery = $state('');

  let toastMsg = $state<string | null>(null);
  function showToast(m: string) {
    toastMsg = m;
    setTimeout(() => { toastMsg = null; }, 3200);
  }

  let displayList = $derived(
    (activeTab === 'antrean' ? antreanReview : sudahDiproses)
      .filter(k => filterJenis === 'all' || k.jenis === filterJenis)
      .filter(k => filterProdi === 'all' || k.prodiKey === filterProdi)
      .filter(k => {
        if (activeTab === 'diproses' && filterSubStatus !== 'all') {
          return k.status === filterSubStatus;
        }
        return true;
      })
      .filter(k =>
        searchQuery === '' ||
        k.judul.toLowerCase().includes(searchQuery.toLowerCase()) ||
        k.penulis.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (k.nim ?? '').toLowerCase().includes(searchQuery.toLowerCase()) ||
        k.prodi.toLowerCase().includes(searchQuery.toLowerCase())
      )
  );

  let diterbitkanCount = $derived(karyaList.filter(k => k.status === 'Diterbitkan').length);
  let revisiCount      = $derived(karyaList.filter(k => k.status === 'Perlu Revisi').length);
  let ditolakCount     = $derived(karyaList.filter(k => k.status === 'Ditolak').length);

  function isUrgent(tanggal: string): boolean {
    const submitted = new Date(tanggal);
    const now = new Date();
    const diffMs = now.getTime() - submitted.getTime();
    const diffDays = diffMs / (1000 * 60 * 60 * 24);
    return diffDays > 2;
  }

  function getStatusBadgeClass(status: string): string {
    switch (status) {
      case 'Diajukan':     return 'bg-[#0284C7]/10 text-[#0284C7]';
      case 'Dalam Review': return 'bg-[#EAB308]/15 text-[#EAB308]';
      case 'Perlu Revisi': return 'bg-[#F97316]/10 text-[#F97316]';
      case 'Diterbitkan':  return 'bg-[#10B981]/10 text-[#10B981]';
      case 'Ditolak':      return 'bg-[#EF4444]/10 text-[#EF4444]';
      default:             return 'bg-slate-100 text-slate-600';
    }
  }

  function getJenisBadgeClass(jenis: string): string {
    switch (jenis) {
      case 'skripsi': return 'bg-[#dae1ff] text-[#001849]';
      case 'tesis':   return 'bg-[#c2e8ff] text-[#001e2b]';
      case 'jurnal':  return 'bg-[#e3dfff] text-[#100069]';
      case 'kp':      return 'bg-slate-100 text-slate-700';
      default:        return 'bg-slate-100 text-slate-700';
    }
  }

  function handleKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape') onClose();
  }

  function handleExportAkreditasi() {
    showToast('Mengekspor data tabel Kriteria 9 (Publikasi & Sitasi Mahasiswa) format .XLSX...');
  }

  // --- Katalog Internal Kurator Filter State ---
  let katalogSearch = $state('');
  let katalogProdi = $state('all');
  let katalogStatus = $state('all');

  let internalKatalogList = $derived(
    karyaList
      .filter(k => katalogProdi === 'all' || k.prodiKey === katalogProdi)
      .filter(k => katalogStatus === 'all' || k.status === katalogStatus)
      .filter(k =>
        katalogSearch === '' ||
        k.judul.toLowerCase().includes(katalogSearch.toLowerCase()) ||
        k.penulis.toLowerCase().includes(katalogSearch.toLowerCase()) ||
        (k.nim ?? '').toLowerCase().includes(katalogSearch.toLowerCase())
      )
  );
</script>

{#if isOpen}
<!-- Full-screen overlay -->
<div
  class="fixed inset-0 z-50 bg-[#f8f9ff] flex overflow-hidden font-body-md"
  role="dialog"
  aria-modal="true"
  aria-label="Dashboard Kurator"
  onkeydown={handleKeydown}
  tabindex="-1"
>
  <!-- Toast Notification inside Kurator Dashboard -->
  {#if toastMsg}
    <div class="fixed bottom-6 right-6 z-[70] animate-slideUp">
      <div class="flex items-center gap-2.5 px-4 py-3 rounded-xl bg-slate-900 text-white text-xs sm:text-sm font-semibold shadow-xl border border-slate-700">
        <span class="material-symbols-outlined text-primary text-lg">info</span>
        <span>{toastMsg}</span>
      </div>
    </div>
  {/if}

  <!-- ───────────── MOBILE DRAWER BACKDROP ───────────── -->
  {#if mobileSidebarOpen}
    <!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions -->
    <div
      class="fixed inset-0 z-40 bg-slate-900/60 backdrop-blur-sm md:hidden animate-fadeIn"
      role="presentation"
      onclick={() => mobileSidebarOpen = false}
    ></div>

    <aside class="fixed inset-y-0 left-0 z-50 w-72 max-w-[85vw] bg-white shadow-2xl flex flex-col justify-between border-r border-slate-100 md:hidden animate-slideRight">
      <div class="flex flex-col overflow-y-auto">
        <div class="p-4 border-b border-slate-100 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <img
              alt="Immortal Campus Logo"
              class="h-10 w-auto object-contain shrink-0"
              src="/logo.png"
            />
            <div>
              <p class="text-[15px] font-bold text-slate-900 leading-tight tracking-tight font-display-hero">Immortal Campus</p>
              <p class="text-[10px] text-primary leading-tight mt-0.5 font-bold">Portal Kurasi Perpustakaan</p>
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
          <div class="flex items-center gap-3 p-2.5 rounded-xl bg-blue-50/70 border border-blue-100/80">
            <div class="w-8 h-8 rounded-full bg-primary flex-shrink-0 flex items-center justify-center text-white font-bold text-xs shadow-sm">
              {kuratorInitials}
            </div>
            <div class="min-w-0">
              <p class="text-xs font-bold text-slate-900 truncate leading-tight">{kuratorName}</p>
              <span class="inline-flex items-center gap-1 mt-0.5 px-2 py-0.5 rounded-full bg-primary/10 text-primary text-[9px] font-bold">
                <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
                {kuratorUser.nip ? `NIP ${kuratorUser.nip}` : 'Kurator Perpustakaan'}
              </span>
            </div>
          </div>
        </div>

        <nav class="p-3 space-y-1">
          <p class="text-[10px] font-bold tracking-wider uppercase text-slate-400 px-2 py-1">Menu Kurator</p>

          <button
            type="button"
            onclick={() => { activeView = 'beranda'; mobileSidebarOpen = false; }}
            class="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer
              {activeView === 'beranda' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'}"
          >
            <span class="material-symbols-outlined text-lg">dashboard</span>
            <span>Beranda Kurator</span>
          </button>

          <button
            type="button"
            onclick={() => { activeView = 'antrean'; mobileSidebarOpen = false; }}
            class="w-full flex items-center justify-between px-3 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer
              {activeView === 'antrean' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'}"
          >
            <div class="flex items-center gap-2.5">
              <span class="material-symbols-outlined text-lg">rate_review</span>
              <span>Antrean Kurasi</span>
            </div>
            {#if pendingCount > 0}
              <span class="px-2 py-0.5 rounded-full text-[10px] font-bold {activeView === 'antrean' ? 'bg-white/20 text-white' : 'bg-red-500 text-white'}">
                {pendingCount}
              </span>
            {/if}
          </button>

          <button
            type="button"
            onclick={() => { activeView = 'akreditasi'; mobileSidebarOpen = false; }}
            class="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer
              {activeView === 'akreditasi' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'}"
          >
            <span class="material-symbols-outlined text-lg">table_chart</span>
            <span>Borang Akreditasi</span>
          </button>

          <button
            type="button"
            onclick={() => { activeView = 'katalog'; mobileSidebarOpen = false; }}
            class="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer
              {activeView === 'katalog' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'}"
          >
            <span class="material-symbols-outlined text-lg">manage_search</span>
            <span>Katalog &amp; Audit Metadata</span>
          </button>

          <button
            type="button"
            onclick={() => { activeView = 'sop'; mobileSidebarOpen = false; }}
            class="w-full flex items-center gap-2.5 px-3 py-2 rounded-xl text-xs font-semibold transition-all cursor-pointer
              {activeView === 'sop' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'}"
          >
            <span class="material-symbols-outlined text-lg">menu_book</span>
            <span>SOP &amp; Kebijakan Mutu</span>
          </button>
        </nav>
      </div>

      <div class="p-3 border-t border-slate-100 space-y-2">
        <button
          type="button"
          onclick={() => { onClose(); mobileSidebarOpen = false; }}
          class="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-xl bg-slate-100 text-slate-700 text-xs font-semibold hover:bg-slate-200 transition-all"
        >
          <span class="material-symbols-outlined text-base">arrow_back</span>
          <span>Lihat Repositori Publik</span>
        </button>

        {#if onLogout}
          <button
            type="button"
            onclick={() => { if (onLogout) onLogout(); mobileSidebarOpen = false; }}
            class="w-full flex items-center justify-center gap-2 px-3 py-2 rounded-xl text-xs font-bold text-red-600 hover:bg-red-50 border border-red-200 transition-all"
          >
            <span class="material-symbols-outlined text-base">logout</span>
            <span>Keluar dari Akun</span>
          </button>
        {/if}
      </div>
    </aside>
  {/if}

  <!-- ───────────── LEFT SIDEBAR ───────────── -->
  <aside class="hidden md:flex w-64 flex-shrink-0 bg-white shadow-[1px_0_12px_rgba(15,23,42,0.06)] flex-col justify-between z-10 border-r border-slate-100">
    <!-- Top: branding + profile + navigation -->
    <div class="flex flex-col">
      <!-- Brand -->
      <div class="p-5 border-b border-slate-100">
        <div class="flex items-center gap-3 mb-3.5">
          <img
            alt="Immortal Campus Logo"
            class="h-14 w-auto object-contain shrink-0"
            src="/logo.png"
          />
          <div>
            <p class="text-[16px] font-bold text-slate-900 leading-tight tracking-tight font-display-hero">Immortal Campus</p>
            <p class="text-[11px] text-primary leading-tight mt-0.5 font-bold">Portal Kurasi Perpustakaan</p>
          </div>
        </div>

        <!-- Kurator profile card -->
        <div class="flex items-center gap-3 p-3 rounded-xl bg-blue-50/70 border border-blue-100/80">
          <div class="w-9 h-9 rounded-full bg-primary flex-shrink-0 flex items-center justify-center text-white font-bold text-xs shadow-sm">
            {kuratorInitials}
          </div>
          <div class="min-w-0">
            <p class="text-[13px] font-bold text-slate-900 truncate leading-tight">{kuratorName}</p>
            <span class="inline-flex items-center gap-1 mt-0.5 px-2 py-0.5 rounded-full bg-primary/10 text-primary text-[10px] font-bold">
              <span class="w-1.5 h-1.5 rounded-full bg-primary"></span>
              {kuratorUser.nip ? `NIP ${kuratorUser.nip}` : 'Kurator Perpustakaan'}
            </span>
          </div>
        </div>
      </div>

      <!-- Main Navigation Menu (Dedicated Kurator Views) -->
      <nav class="p-3.5 space-y-1 border-b border-slate-100">
        <p class="text-[10px] font-bold tracking-wider uppercase text-slate-400 px-2 py-1">Menu Kurator</p>

        <!-- 1. Beranda Kurator -->
        <button
          type="button"
          onclick={() => activeView = 'beranda'}
          class="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all cursor-pointer
            {activeView === 'beranda' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'}"
        >
          <span class="material-symbols-outlined text-lg">dashboard</span>
          <span>Beranda Kurator</span>
        </button>

        <!-- 2. Antrean Kurasi -->
        <button
          type="button"
          onclick={() => activeView = 'antrean'}
          class="w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all cursor-pointer
            {activeView === 'antrean' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'}"
        >
          <div class="flex items-center gap-2.5">
            <span class="material-symbols-outlined text-lg">rate_review</span>
            <span>Antrean Kurasi</span>
          </div>
          {#if pendingCount > 0}
            <span class="px-2 py-0.5 rounded-full text-[10px] font-bold {activeView === 'antrean' ? 'bg-white/20 text-white' : 'bg-red-500 text-white'}">
              {pendingCount}
            </span>
          {/if}
        </button>

        <!-- 3. Borang Akreditasi -->
        <button
          type="button"
          onclick={() => activeView = 'akreditasi'}
          class="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all cursor-pointer
            {activeView === 'akreditasi' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'}"
        >
          <span class="material-symbols-outlined text-lg">table_chart</span>
          <span>Borang Akreditasi</span>
        </button>

        <!-- 4. Katalog & Audit Metadata Internal -->
        <button
          type="button"
          onclick={() => activeView = 'katalog'}
          class="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all cursor-pointer
            {activeView === 'katalog' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'}"
        >
          <span class="material-symbols-outlined text-lg">manage_search</span>
          <span>Katalog &amp; Audit</span>
        </button>

        <!-- 5. Standar Mutu & SOP Kurasi -->
        <button
          type="button"
          onclick={() => activeView = 'sop'}
          class="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all cursor-pointer
            {activeView === 'sop' ? 'bg-primary text-white shadow-sm' : 'text-slate-600 hover:bg-slate-50 hover:text-slate-900'}"
        >
          <span class="material-symbols-outlined text-lg">policy</span>
          <span>SOP &amp; Standar Mutu</span>
        </button>
      </nav>

      <!-- Stats block -->
      <div class="px-3.5 py-3 space-y-1.5">
        <p class="text-[10px] font-bold tracking-wider uppercase text-slate-400 px-2">Ringkasan Status</p>

        <div class="flex items-center justify-between p-2.5 rounded-xl bg-blue-50/60 text-xs">
          <div class="flex items-center gap-2 text-slate-700">
            <span class="material-symbols-outlined text-primary text-base">hourglass_empty</span>
            <span>Perlu Review</span>
          </div>
          <span class="font-bold text-primary">{pendingCount}</span>
        </div>

        <div class="flex items-center justify-between p-2.5 rounded-xl bg-emerald-50/60 text-xs">
          <div class="flex items-center gap-2 text-slate-700">
            <span class="material-symbols-outlined text-status-published text-base">verified</span>
            <span>Diterbitkan</span>
          </div>
          <span class="font-bold text-status-published">{diterbitkanCount}</span>
        </div>

        <div class="flex items-center justify-between p-2.5 rounded-xl bg-orange-50/60 text-xs">
          <div class="flex items-center gap-2 text-slate-700">
            <span class="material-symbols-outlined text-status-revision text-base">edit_note</span>
            <span>Perlu Revisi</span>
          </div>
          <span class="font-bold text-status-revision">{revisiCount}</span>
        </div>

        <div class="flex items-center justify-between p-2.5 rounded-xl bg-red-50/60 text-xs">
          <div class="flex items-center gap-2 text-slate-700">
            <span class="material-symbols-outlined text-status-rejected text-base">cancel</span>
            <span>Ditolak</span>
          </div>
          <span class="font-bold text-status-rejected">{ditolakCount}</span>
        </div>
      </div>
    </div>

    <!-- Bottom: exit to public button -->
    <div class="p-3.5 border-t border-slate-100 space-y-2">
      <button
        type="button"
        onclick={onClose}
        class="w-full flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl bg-slate-100 text-slate-700 text-xs font-semibold hover:bg-slate-200 transition-all cursor-pointer"
      >
        <span class="material-symbols-outlined text-base">arrow_back</span>
        <span>Lihat Repositori Publik</span>
      </button>

      {#if onLogout}
        <button
          type="button"
          onclick={onLogout}
          class="w-full flex items-center justify-center gap-2 px-4 py-2.5 rounded-xl text-xs font-bold text-red-600 hover:text-red-700 hover:bg-red-50 border border-red-200 transition-all cursor-pointer"
        >
          <span class="material-symbols-outlined text-base">logout</span>
          <span>Keluar dari Akun</span>
        </button>
      {/if}
    </div>
  </aside>

  <!-- ───────────── MAIN CONTENT ───────────── -->
  <div class="flex-1 flex flex-col overflow-hidden min-w-0">
    <!-- Top header bar -->
    <header class="h-16 bg-white/95 backdrop-blur-xl border-b border-slate-100 flex items-center justify-between px-3 sm:px-6 flex-shrink-0 gap-2">
      <div class="flex items-center gap-2 sm:gap-3 min-w-0">
        <!-- Mobile hamburger menu button -->
        <button
          type="button"
          onclick={() => mobileSidebarOpen = true}
          class="md:hidden p-2 rounded-xl text-slate-600 hover:text-slate-900 hover:bg-slate-100 shrink-0"
          aria-label="Buka menu kurator"
        >
          <span class="material-symbols-outlined text-xl">menu</span>
        </button>
        <div class="hidden sm:inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-blue-50 text-primary text-xs font-semibold shrink-0">
          <span class="w-2 h-2 rounded-full bg-status-published animate-pulse"></span>
          <span>Meja Kerja Kurator</span>
        </div>
        <h1 class="text-sm sm:text-base font-bold text-slate-900 tracking-tight font-display-hero truncate">
          {#if activeView === 'beranda'}Beranda &amp; Ikhtisar Kurasi
          {:else if activeView === 'antrean'}Antrean Review &amp; Validasi Naskah
          {:else if activeView === 'akreditasi'}Laporan Borang Akreditasi Kriteria 9
          {:else if activeView === 'katalog'}Katalog Repositori &amp; Audit Metadata
          {:else if activeView === 'sop'}Standar Operasional Prosedur (SOP) Mutu
          {/if}
        </h1>
      </div>

      <div class="flex items-center gap-2 sm:gap-3 shrink-0">
        {#if activeView === 'antrean'}
          <!-- Search bar in Antrean (desktop) -->
          <div class="relative w-40 sm:w-64 hidden sm:block">
            <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-base">search</span>
            <input
              type="text"
              bind:value={searchQuery}
              placeholder="Cari naskah..."
              class="w-full pl-9 pr-4 py-1.5 sm:py-2 rounded-xl bg-slate-50 text-xs text-slate-900 placeholder:text-slate-400 focus:outline-none focus:bg-white focus:ring-2 focus:ring-primary/30 transition-all border border-slate-200"
            />
          </div>
        {:else if activeView === 'akreditasi'}
          <button
            type="button"
            onclick={handleExportAkreditasi}
            class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-primary text-white text-xs font-semibold shadow hover:bg-blue-600 transition-all cursor-pointer"
          >
            <span class="material-symbols-outlined text-base">download</span>
            <span>Ekspor Excel (.xlsx)</span>
          </button>
        {/if}

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

    <!-- Scrollable content area -->
    <main class="flex-1 overflow-y-auto px-6 py-6 bg-slate-50">

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- 1. VIEW: BERANDA KURATOR (EXECUTIVE OVERVIEW)           -->
      <!-- ═══════════════════════════════════════════════════════ -->
      {#if activeView === 'beranda'}
        <div class="max-w-6xl mx-auto space-y-6">
          <!-- Welcome Banner -->
          <div class="relative overflow-hidden rounded-3xl bg-gradient-to-r from-slate-900 via-blue-950 to-slate-900 text-white p-7 md:p-8 shadow-lg">
            <div class="relative z-10 flex flex-col lg:flex-row lg:items-center justify-between gap-6">
              <div class="space-y-2 max-w-2xl">
                <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/10 text-blue-200 text-xs font-semibold backdrop-blur-sm">
                  <span class="material-symbols-outlined text-sm">verified</span>
                  <span>Unit Pengelola Repositori &amp; Terbitan Ilmiah</span>
                </div>
                <h2 class="text-2xl sm:text-3xl font-extrabold tracking-tight font-display-hero">
                  Selamat Bertugas, {kuratorName.split(',')[0].replace('Dr. ', '').trim()}!
                </h2>
                <p class="text-xs sm:text-sm text-slate-300 leading-relaxed">
                  Pantau seluruh aliran pengajuan naskah tugas akhir mahasiswa, kelayakan skor Turnitin, validitas lembar pengesahan, serta kepatuhan metadata OAI-PMH kampus.
                </p>
              </div>

              <div class="flex flex-wrap sm:flex-nowrap items-center gap-3 shrink-0">
                <button
                  type="button"
                  onclick={() => activeView = 'antrean'}
                  class="px-5 py-3 rounded-2xl bg-primary hover:bg-blue-600 text-white font-bold text-xs sm:text-sm shadow-lg shadow-primary/30 transition-all cursor-pointer flex items-center gap-2 active:scale-95"
                >
                  <span class="material-symbols-outlined text-base">rate_review</span>
                  <span>Buka Antrean Review ({pendingCount})</span>
                </button>
              </div>
            </div>
          </div>

          <!-- KPI Executive Metrics Grid -->
          <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
            <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200/80 space-y-2">
              <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Antrean Masuk</span>
                <span class="w-8 h-8 rounded-lg bg-blue-50 text-primary flex items-center justify-center font-bold">
                  <span class="material-symbols-outlined text-base">hourglass_top</span>
                </span>
              </div>
              <div class="text-2xl sm:text-3xl font-extrabold text-slate-900">{pendingCount} <span class="text-xs font-normal text-slate-400">naskah</span></div>
              <p class="text-[11px] text-blue-600 font-semibold">Butuh verifikasi kurator</p>
            </div>

            <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200/80 space-y-2">
              <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Rata-Rata SLA</span>
                <span class="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center font-bold">
                  <span class="material-symbols-outlined text-base">speed</span>
                </span>
              </div>
              <div class="text-2xl sm:text-3xl font-extrabold text-emerald-600">1.4 <span class="text-xs font-normal text-slate-400">hari kerja</span></div>
              <p class="text-[11px] text-emerald-600 font-semibold">Target &le; 3 hari (Tercapai)</p>
            </div>

            <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200/80 space-y-2">
              <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Telah Terbit</span>
                <span class="w-8 h-8 rounded-lg bg-purple-50 text-purple-600 flex items-center justify-center font-bold">
                  <span class="material-symbols-outlined text-base">verified</span>
                </span>
              </div>
              <div class="text-2xl sm:text-3xl font-extrabold text-slate-900">{diterbitkanCount} <span class="text-xs font-normal text-slate-400">karya</span></div>
              <p class="text-[11px] text-purple-600 font-semibold">Tersinkron OAI-PMH &amp; DOI</p>
            </div>

            <div class="bg-white p-5 rounded-2xl shadow-sm border border-slate-200/80 space-y-2">
              <div class="flex items-center justify-between">
                <span class="text-xs font-bold text-slate-500 uppercase tracking-wider">Perlu Revisi</span>
                <span class="w-8 h-8 rounded-lg bg-orange-50 text-orange-600 flex items-center justify-center font-bold">
                  <span class="material-symbols-outlined text-base">error</span>
                </span>
              </div>
              <div class="text-2xl sm:text-3xl font-extrabold text-orange-600">{revisiCount} <span class="text-xs font-normal text-slate-400">naskah</span></div>
              <p class="text-[11px] text-orange-600 font-semibold">Menunggu revisi mahasiswa</p>
            </div>
          </div>

          <!-- Urgent Review Alert Card (if any pending) -->
          {#if antreanReview.length > 0}
            <div class="p-6 rounded-3xl bg-amber-50/80 border border-amber-200 space-y-4">
              <div class="flex items-center justify-between flex-wrap gap-2">
                <div class="flex items-center gap-2 text-amber-900">
                  <span class="material-symbols-outlined text-xl text-amber-600">notification_important</span>
                  <h3 class="font-bold text-sm">Prioritas Telaah Mendesak (Antrean Teratas)</h3>
                </div>
                <span class="text-xs font-bold text-amber-700 bg-amber-100 px-2.5 py-0.5 rounded-full">
                  Status: {antreanReview[0].status}
                </span>
              </div>

              <div class="p-4 rounded-2xl bg-white border border-amber-200 flex flex-col md:flex-row md:items-center justify-between gap-4">
                <div class="space-y-1">
                  <div class="flex items-center gap-2">
                    <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-primary text-white uppercase">{antreanReview[0].jenisLabel}</span>
                    <span class="text-xs text-slate-500">• {antreanReview[0].prodi} • NIM: {antreanReview[0].nim}</span>
                  </div>
                  <h4 class="font-bold text-slate-900 text-sm">{antreanReview[0].judul}</h4>
                  <p class="text-xs text-slate-600">Penulis: <strong>{antreanReview[0].penulis}</strong> | Pembimbing: {antreanReview[0].pembimbing}</p>
                </div>

                <button
                  type="button"
                  onclick={() => onOpenReview(antreanReview[0])}
                  class="px-4 py-2.5 rounded-xl bg-primary hover:bg-blue-600 text-white font-bold text-xs shadow transition-all flex items-center gap-1.5 cursor-pointer shrink-0"
                >
                  <span class="material-symbols-outlined text-base">rate_review</span>
                  <span>Telaah Naskah Ini</span>
                </button>
              </div>
            </div>
          {/if}

          <!-- 3 Quick Access Panels -->
          <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
            <button
              type="button"
              onclick={() => activeView = 'antrean'}
              class="p-5 rounded-2xl bg-white border border-slate-200/80 shadow-sm hover:border-primary/50 hover:shadow-md transition-all text-left cursor-pointer space-y-3 group"
            >
              <div class="w-10 h-10 rounded-xl bg-blue-100 text-primary flex items-center justify-center group-hover:bg-primary group-hover:text-white transition-colors">
                <span class="material-symbols-outlined text-xl">checklist</span>
              </div>
              <div>
                <h4 class="font-bold text-slate-900 text-sm group-hover:text-primary transition-colors">Meja Antrean Kurasi</h4>
                <p class="text-xs text-slate-500 mt-1">Review kesesuaian format, Turnitin similarity score, dan lembar pengesahan naskah.</p>
              </div>
              <span class="text-xs font-bold text-primary flex items-center gap-1">
                Buka Antrean <span class="material-symbols-outlined text-sm">arrow_forward</span>
              </span>
            </button>

            <button
              type="button"
              onclick={() => activeView = 'akreditasi'}
              class="p-5 rounded-2xl bg-white border border-slate-200/80 shadow-sm hover:border-primary/50 hover:shadow-md transition-all text-left cursor-pointer space-y-3 group"
            >
              <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center group-hover:bg-emerald-600 group-hover:text-white transition-colors">
                <span class="material-symbols-outlined text-xl">table_chart</span>
              </div>
              <div>
                <h4 class="font-bold text-slate-900 text-sm group-hover:text-emerald-700 transition-colors">Borang Kriteria 9 BAN-PT</h4>
                <p class="text-xs text-slate-500 mt-1">Rekapitulasi publikasi dan sitasi karya mahasiswa per prodi untuk borang akreditasi.</p>
              </div>
              <span class="text-xs font-bold text-emerald-700 flex items-center gap-1">
                Buka Laporan <span class="material-symbols-outlined text-sm">arrow_forward</span>
              </span>
            </button>

            <button
              type="button"
              onclick={() => activeView = 'sop'}
              class="p-5 rounded-2xl bg-white border border-slate-200/80 shadow-sm hover:border-primary/50 hover:shadow-md transition-all text-left cursor-pointer space-y-3 group"
            >
              <div class="w-10 h-10 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center group-hover:bg-purple-600 group-hover:text-white transition-colors">
                <span class="material-symbols-outlined text-xl">policy</span>
              </div>
              <div>
                <h4 class="font-bold text-slate-900 text-sm group-hover:text-purple-700 transition-colors">SOP &amp; Kebijakan Mutu</h4>
                <p class="text-xs text-slate-500 mt-1">Pedoman resmi standar uji similarity, prefix DOI, dan tata kelola repositori kampus.</p>
              </div>
              <span class="text-xs font-bold text-purple-700 flex items-center gap-1">
                Baca SOP <span class="material-symbols-outlined text-sm">arrow_forward</span>
              </span>
            </button>
          </div>
        </div>

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- 2. VIEW: ANTREAN KURASI (QUEUE & REVIEW TABLE)          -->
      <!-- ═══════════════════════════════════════════════════════ -->
      {:else if activeView === 'antrean'}
        <!-- KPI Cards row -->
        <section class="grid grid-cols-2 xl:grid-cols-4 gap-4 mb-6">
          <div class="bg-white p-4 rounded-xl shadow-sm border border-slate-200 flex flex-col justify-between">
            <div class="flex items-start justify-between">
              <div>
                <p class="text-[11px] font-bold uppercase tracking-wider text-slate-500">Total Antrean</p>
                <div class="flex items-baseline gap-2 mt-1">
                  <span class="text-2xl sm:text-3xl font-extrabold text-slate-900">{antreanReview.length}</span>
                  <span class="text-xs text-slate-500">Naskah</span>
                </div>
              </div>
              <div class="w-10 h-10 rounded-xl bg-blue-50 text-primary flex items-center justify-center">
                <span class="material-symbols-outlined text-xl">hourglass_empty</span>
              </div>
            </div>
            <div class="mt-3 inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-orange-100 text-orange-700 text-[11px] font-bold self-start">
              <span class="material-symbols-outlined text-xs">warning</span>
              {antreanReview.filter(k => isUrgent(k.tanggalTerbit)).length} Perlu Segera Ditinjau
            </div>
          </div>

          <div class="bg-white p-4 rounded-xl shadow-sm border border-slate-200 flex flex-col justify-between">
            <div class="flex items-start justify-between">
              <div>
                <p class="text-[11px] font-bold uppercase tracking-wider text-slate-500">Sedang Ditelaah</p>
                <div class="flex items-baseline gap-2 mt-1">
                  <span class="text-2xl sm:text-3xl font-extrabold text-primary">{karyaList.filter(k => k.status === 'Dalam Review').length}</span>
                  <span class="text-xs text-slate-500">Naskah</span>
                </div>
              </div>
              <div class="w-10 h-10 rounded-xl bg-blue-100/60 text-primary flex items-center justify-center">
                <span class="material-symbols-outlined text-xl">rate_review</span>
              </div>
            </div>
            <p class="mt-3 text-[11px] text-slate-400">Verifikasi lembar sah &amp; Turnitin</p>
          </div>

          <div class="bg-white p-4 rounded-xl shadow-sm border border-slate-200 flex flex-col justify-between">
            <div class="flex items-start justify-between">
              <div>
                <p class="text-[11px] font-bold uppercase tracking-wider text-slate-500">Rata-Rata SLA</p>
                <div class="flex items-baseline gap-2 mt-1">
                  <span class="text-2xl sm:text-3xl font-extrabold text-[#10B981]">1.4</span>
                  <span class="text-xs text-slate-500">Hari Kerja</span>
                </div>
              </div>
              <div class="w-10 h-10 rounded-xl bg-emerald-50 text-[#10B981] flex items-center justify-center">
                <span class="material-symbols-outlined text-xl">speed</span>
              </div>
            </div>
            <p class="mt-3 text-[11px] text-[#10B981] font-semibold flex items-center gap-1">
              <span class="material-symbols-outlined text-xs">check_circle</span>
              Di Bawah Target SLA (3 Hari)
            </p>
          </div>

          <div class="bg-white p-4 rounded-xl shadow-sm border border-slate-200 flex flex-col justify-between">
            <div class="flex items-start justify-between">
              <div>
                <p class="text-[11px] font-bold uppercase tracking-wider text-slate-500">Sudah Diproses</p>
                <div class="flex items-baseline gap-2 mt-1">
                  <span class="text-2xl sm:text-3xl font-extrabold text-slate-900">{sudahDiproses.length}</span>
                  <span class="text-xs text-slate-500">Naskah</span>
                </div>
              </div>
              <div class="w-10 h-10 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center">
                <span class="material-symbols-outlined text-xl">task_alt</span>
              </div>
            </div>
            <p class="mt-3 text-[11px] text-slate-400">{diterbitkanCount} Terbit • {revisiCount} Revisi • {ditolakCount} Tolak</p>
          </div>
        </section>

        <!-- Main Queue Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
          <!-- Filter and tab toolbar -->
          <div class="p-4 border-b border-slate-100 flex flex-col lg:flex-row lg:items-center justify-between gap-4">
            <div class="flex items-center p-1 bg-slate-100 rounded-xl self-start">
              <button
                type="button"
                onclick={() => { activeTab = 'antrean'; filterSubStatus = 'all'; }}
                class="flex items-center gap-2 px-4 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer {activeTab === 'antrean' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-900'}"
              >
                <span>Perlu Ditelaah</span>
                <span class="px-1.5 py-0.2 rounded-full text-[10px] font-extrabold {activeTab === 'antrean' ? 'bg-primary text-white' : 'bg-slate-200 text-slate-600'}">
                  {antreanReview.length}
                </span>
              </button>

              <button
                type="button"
                onclick={() => activeTab = 'diproses'}
                class="flex items-center gap-2 px-4 py-1.5 rounded-lg text-xs font-bold transition-all cursor-pointer {activeTab === 'diproses' ? 'bg-white text-slate-900 shadow-sm' : 'text-slate-500 hover:text-slate-900'}"
              >
                <span>Sudah Diproses</span>
                <span class="px-1.5 py-0.2 rounded-full text-[10px] font-extrabold {activeTab === 'diproses' ? 'bg-primary text-white' : 'bg-slate-200 text-slate-600'}">
                  {sudahDiproses.length}
                </span>
              </button>
            </div>

            <!-- Filter dropdowns -->
            <div class="flex items-center gap-2 flex-wrap text-xs">
              {#if activeTab === 'diproses'}
                <select
                  bind:value={filterSubStatus}
                  class="px-3 py-1.5 rounded-xl border border-slate-200 bg-white text-slate-700 font-semibold focus:outline-none focus:ring-2 focus:ring-primary/20"
                >
                  <option value="all">Semua Status Hasil</option>
                  <option value="Diterbitkan">Diterbitkan ({diterbitkanCount})</option>
                  <option value="Perlu Revisi">Perlu Revisi ({revisiCount})</option>
                  <option value="Ditolak">Ditolak ({ditolakCount})</option>
                </select>
              {/if}

              <select
                bind:value={filterJenis}
                class="px-3 py-1.5 rounded-xl border border-slate-200 bg-white text-slate-700 font-semibold focus:outline-none focus:ring-2 focus:ring-primary/20"
              >
                <option value="all">Semua Jenis Karya</option>
                <option value="skripsi">Skripsi S-1</option>
                <option value="tesis">Tesis S-2</option>
                <option value="jurnal">Artikel Jurnal</option>
                <option value="kp">Laporan KP</option>
              </select>

              <select
                bind:value={filterProdi}
                class="px-3 py-1.5 rounded-xl border border-slate-200 bg-white text-slate-700 font-semibold focus:outline-none focus:ring-2 focus:ring-primary/20"
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

          <!-- Mobile search input for antrean -->
          <div class="p-3 border-b border-slate-100 sm:hidden">
            <div class="relative w-full">
              <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-slate-400 text-base">search</span>
              <input
                type="text"
                bind:value={searchQuery}
                placeholder="Cari judul, penulis, NIM..."
                class="w-full pl-9 pr-4 py-2 rounded-xl bg-slate-50 text-xs text-slate-900 placeholder:text-slate-400 focus:outline-none focus:bg-white focus:ring-2 focus:ring-primary/30 transition-all border border-slate-200"
              />
            </div>
          </div>

          <!-- Table Content -->
          <div class="overflow-x-auto">
            <table class="w-full text-left text-xs min-w-[700px]">
              <thead class="bg-slate-50/80 text-slate-500 font-bold uppercase tracking-wider text-[10px] border-b border-slate-100">
                <tr>
                  <th class="px-5 py-3">Naskah &amp; Penulis</th>
                  <th class="px-4 py-3">Jenis &amp; Prodi</th>
                  <th class="px-4 py-3">Tanggal Unggah</th>
                  <th class="px-4 py-3">Status Kurasi</th>
                  <th class="px-5 py-3 text-right">Aksi Tindakan</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-100">
                {#if displayList.length === 0}
                  <tr>
                    <td colspan="5" class="px-6 py-12 text-center text-slate-400">
                      <span class="material-symbols-outlined text-4xl block mb-2">inbox</span>
                      Tidak ada naskah yang cocok dengan filter yang dipilih.
                    </td>
                  </tr>
                {:else}
                  {#each displayList as karya (karya.id)}
                    <tr class="hover:bg-slate-50/70 transition-colors">
                      <td class="px-5 py-3.5 max-w-md">
                        <div class="font-bold text-slate-900 hover:text-primary transition-colors">
                          <button
                            type="button"
                            onclick={() => onOpenDetail(karya)}
                            class="text-left font-bold text-slate-900 hover:text-primary transition-colors cursor-pointer"
                          >
                            {karya.judul}
                          </button>
                        </div>
                        <div class="flex items-center gap-2 mt-1 text-slate-500 text-[11px]">
                          <span>{karya.penulis}</span>
                          <span>•</span>
                          <span>NIM: {karya.nim ?? '-'}</span>
                          {#if karya.fileSize}
                            <span>•</span>
                            <button
                              type="button"
                              onclick={() => onDownloadKarya ? onDownloadKarya(karya) : showToast(`Mengunduh ${karya.judul.slice(0, 30)}...`)}
                              class="text-primary hover:underline font-semibold cursor-pointer"
                            >
                              PDF ({karya.fileSize})
                            </button>
                          {/if}
                        </div>
                      </td>

                      <td class="px-4 py-3.5">
                        <span class="inline-block px-2 py-0.5 rounded text-[10px] font-bold uppercase {getJenisBadgeClass(karya.jenis)}">
                          {karya.jenisLabel}
                        </span>
                        <p class="text-[11px] text-slate-500 mt-0.5">{karya.prodi}</p>
                      </td>

                      <td class="px-4 py-3.5">
                        <p class="text-slate-700 font-semibold">{karya.tanggalTerbit}</p>
                        {#if isUrgent(karya.tanggalTerbit) && (karya.status === 'Diajukan' || karya.status === 'Dalam Review')}
                          <span class="inline-block px-1.5 py-0.2 rounded text-[10px] font-bold bg-red-100 text-red-700 mt-0.5">
                            SLA Urgent
                          </span>
                        {/if}
                      </td>

                      <td class="px-4 py-3.5">
                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold {getStatusBadgeClass(karya.status)}">
                          <span class="w-1.5 h-1.5 rounded-full bg-current"></span>
                          <span>{karya.status}</span>
                        </span>
                      </td>

                      <td class="px-5 py-3.5 text-right">
                        {#if activeTab === 'antrean'}
                          <button
                            type="button"
                            onclick={() => onOpenReview(karya)}
                            class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-primary hover:bg-blue-600 text-white font-bold text-xs shadow-sm transition-all cursor-pointer"
                          >
                            <span class="material-symbols-outlined text-sm">rate_review</span>
                            <span>Telaah / Validasi</span>
                          </button>
                        {:else}
                          <button
                            type="button"
                            onclick={() => onOpenDetail(karya)}
                            class="inline-flex items-center gap-1 px-3 py-1.5 rounded-xl border border-slate-200 hover:bg-slate-100 text-slate-700 font-semibold text-xs transition-colors cursor-pointer"
                          >
                            <span class="material-symbols-outlined text-sm">visibility</span>
                            <span>Detail</span>
                          </button>
                        {/if}
                      </td>
                    </tr>
                  {/each}
                {/if}
              </tbody>
            </table>
          </div>
        </div>

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- 3. VIEW: BORANG AKREDITASI KRITERIA 9 BAN-PT             -->
      <!-- ═══════════════════════════════════════════════════════ -->
      {:else if activeView === 'akreditasi'}
        <div class="max-w-5xl mx-auto space-y-6">
          <div class="bg-white p-6 rounded-2xl shadow-sm border border-slate-200">
            <h3 class="text-base font-bold text-slate-900 mb-2">Ikhtisar Kriteria 9 (Penelitian &amp; Publikasi Ilmiah Mahasiswa)</h3>
            <p class="text-xs text-slate-500 mb-6">
              Data terintegrasi otomatis dari repositori digital Immortal Campus untuk pengisian instrumen akreditasi program studi dan institusi (BAN-PT / LAM-INFOKOM).
            </p>

            <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
              <div class="p-4 rounded-xl bg-blue-50/60 border border-blue-100">
                <p class="text-xs text-slate-500 font-bold uppercase">Total Naskah Terbit</p>
                <p class="text-2xl font-extrabold text-primary mt-1">{diterbitkanCount}</p>
                <p class="text-[11px] text-slate-400 mt-0.5">Memiliki DOI &amp; OAI-PMH</p>
              </div>

              <div class="p-4 rounded-xl bg-emerald-50/60 border border-emerald-100">
                <p class="text-xs text-slate-500 font-bold uppercase">Total Sitasi Sivitas</p>
                <p class="text-2xl font-extrabold text-status-published mt-1">2.418</p>
                <p class="text-[11px] text-slate-400 mt-0.5">Terindeks Google Scholar</p>
              </div>

              <div class="p-4 rounded-xl bg-purple-50/60 border border-purple-100">
                <p class="text-xs text-slate-500 font-bold uppercase">Skor Borang Kriteria 9</p>
                <p class="text-2xl font-extrabold text-purple-700 mt-1">3.88 / 4.00</p>
                <p class="text-[11px] text-purple-600 font-bold mt-0.5">Predikat Unggul (A)</p>
              </div>
            </div>

            <div class="overflow-x-auto">
              <table class="w-full text-left text-xs border border-slate-200 rounded-xl overflow-hidden">
                <thead class="bg-slate-50 text-slate-600 font-bold text-[11px]">
                  <tr>
                    <th class="p-3 border-b border-slate-200">Program Studi</th>
                    <th class="p-3 border-b border-slate-200 text-center">Skripsi (S-1)</th>
                    <th class="p-3 border-b border-slate-200 text-center">Tesis (S-2)</th>
                    <th class="p-3 border-b border-slate-200 text-center">Jurnal</th>
                    <th class="p-3 border-b border-slate-200 text-center">Total Terbit</th>
                    <th class="p-3 border-b border-slate-200 text-center">Status Borang</th>
                  </tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                  <tr>
                    <td class="p-3 font-bold text-slate-800">Teknik Informatika</td>
                    <td class="p-3 text-center">142</td>
                    <td class="p-3 text-center">28</td>
                    <td class="p-3 text-center">54</td>
                    <td class="p-3 text-center font-bold text-primary">224</td>
                    <td class="p-3 text-center"><span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]">Lengkap 100%</span></td>
                  </tr>
                  <tr>
                    <td class="p-3 font-bold text-slate-800">Sistem Informasi</td>
                    <td class="p-3 text-center">98</td>
                    <td class="p-3 text-center">15</td>
                    <td class="p-3 text-center">36</td>
                    <td class="p-3 text-center font-bold text-primary">149</td>
                    <td class="p-3 text-center"><span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]">Lengkap 100%</span></td>
                  </tr>
                  <tr>
                    <td class="p-3 font-bold text-slate-800">Desain Komunikasi Visual</td>
                    <td class="p-3 text-center">76</td>
                    <td class="p-3 text-center">0</td>
                    <td class="p-3 text-center">21</td>
                    <td class="p-3 text-center font-bold text-primary">97</td>
                    <td class="p-3 text-center"><span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]">Lengkap 100%</span></td>
                  </tr>
                  <tr>
                    <td class="p-3 font-bold text-slate-800">Manajemen</td>
                    <td class="p-3 text-center">112</td>
                    <td class="p-3 text-center">34</td>
                    <td class="p-3 text-center">48</td>
                    <td class="p-3 text-center font-bold text-primary">194</td>
                    <td class="p-3 text-center"><span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]">Lengkap 100%</span></td>
                  </tr>
                  <tr>
                    <td class="p-3 font-bold text-slate-800">Ilmu Komunikasi</td>
                    <td class="p-3 text-center">88</td>
                    <td class="p-3 text-center">0</td>
                    <td class="p-3 text-center">29</td>
                    <td class="p-3 text-center font-bold text-primary">117</td>
                    <td class="p-3 text-center"><span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-800 font-bold text-[10px]">Lengkap 100%</span></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- 4. VIEW: KATALOG & AUDIT METADATA INTERNAL KURATOR     -->
      <!-- ═══════════════════════════════════════════════════════ -->
      {:else if activeView === 'katalog'}
        <div class="max-w-6xl mx-auto space-y-5">
          <div class="p-6 bg-white rounded-3xl border border-slate-200 shadow-sm space-y-4">
            <div>
              <h3 class="text-base font-bold text-slate-900">Direktori Repositori Internal &amp; Audit Metadata</h3>
              <p class="text-xs text-slate-500">Periksa kepatuhan skema Dublin Core, integrasi DOI Crossref, skor Turnitin, dan metrik akses tiap naskah.</p>
            </div>

            <div class="flex flex-col sm:flex-row items-center gap-3">
              <div class="relative flex-1 w-full">
                <span class="material-symbols-outlined absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400 text-base">search</span>
                <input
                  type="text"
                  bind:value={katalogSearch}
                  placeholder="Cari naskah untuk audit metadata..."
                  class="w-full pl-9 pr-4 py-2.5 rounded-xl bg-slate-50 text-xs sm:text-sm border border-slate-200 focus:outline-none focus:ring-2 focus:ring-primary/20"
                />
              </div>

              <select
                bind:value={katalogProdi}
                class="w-full sm:w-auto px-3.5 py-2.5 rounded-xl border border-slate-200 bg-white text-xs sm:text-sm text-slate-700"
              >
                <option value="all">Semua Program Studi</option>
                <option value="ti">Teknik Informatika</option>
                <option value="si">Sistem Informasi</option>
                <option value="dkv">Desain Komunikasi Visual</option>
                <option value="mnj">Manajemen</option>
                <option value="ilkom">Ilmu Komunikasi</option>
              </select>

              <select
                bind:value={katalogStatus}
                class="w-full sm:w-auto px-3.5 py-2.5 rounded-xl border border-slate-200 bg-white text-xs sm:text-sm text-slate-700"
              >
                <option value="all">Semua Status</option>
                <option value="Diterbitkan">Diterbitkan</option>
                <option value="Diajukan">Diajukan</option>
                <option value="Dalam Review">Dalam Review</option>
                <option value="Perlu Revisi">Perlu Revisi</option>
                <option value="Draft">Draft</option>
              </select>
            </div>
          </div>

          <!-- Cards Audit List -->
          <div class="space-y-4">
            {#each internalKatalogList as karya (karya.id)}
              <div class="p-5 bg-white rounded-2xl border border-slate-200 shadow-sm space-y-3">
                <div class="flex items-start justify-between gap-4 flex-wrap">
                  <div class="space-y-1 max-w-3xl">
                    <div class="flex items-center gap-2 flex-wrap">
                      <span class="px-2 py-0.5 rounded text-[10px] font-bold uppercase {getJenisBadgeClass(karya.jenis)}">{karya.jenisLabel}</span>
                      <span class="text-xs text-slate-500">• {karya.prodi} • {karya.tahun}</span>
                      <span class="text-xs text-slate-400">• Penulis: <strong>{karya.penulis}</strong> ({karya.nim})</span>
                    </div>
                    <h4 class="font-bold text-slate-900 text-sm hover:text-primary transition-colors">
                      <button type="button" onclick={() => onOpenDetail(karya)} class="text-left cursor-pointer">
                        {karya.judul}
                      </button>
                    </h4>
                  </div>

                  <!-- Metadata badges -->
                  <div class="flex items-center gap-2 shrink-0">
                    <span class="px-2.5 py-1 rounded-full text-[11px] font-bold {getStatusBadgeClass(karya.status)}">
                      {karya.status}
                    </span>
                    <span class="px-2.5 py-1 rounded-full text-[11px] font-bold bg-purple-50 text-purple-700">
                      DOI: {karya.doi || 'Belum Terbit'}
                    </span>
                  </div>
                </div>

                <!-- Audit info pills -->
                <div class="flex items-center gap-4 text-xs text-slate-500 pt-2 border-t border-slate-100 flex-wrap">
                  <span class="flex items-center gap-1">
                    <span class="material-symbols-outlined text-sm text-emerald-600">verified</span>
                    OAI-PMH: Valid (Dublin Core 1.1)
                  </span>
                  <span class="flex items-center gap-1">
                    <span class="material-symbols-outlined text-sm text-blue-600">download</span>
                    {karya.unduhan} Unduhan Tercatat
                  </span>
                  <span class="flex items-center gap-1">
                    <span class="material-symbols-outlined text-sm text-amber-600">policy</span>
                    Turnitin Similarity: &lt; 15% (Lolos)
                  </span>

                  <div class="ml-auto flex items-center gap-2">
                    <button
                      type="button"
                      onclick={() => onOpenDetail(karya)}
                      class="px-3 py-1 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 font-semibold cursor-pointer"
                    >
                      Audit Detail
                    </button>
                    {#if karya.status === 'Diajukan' || karya.status === 'Dalam Review'}
                      <button
                        type="button"
                        onclick={() => onOpenReview(karya)}
                        class="px-3 py-1 rounded-lg bg-primary hover:bg-blue-600 text-white font-bold cursor-pointer"
                      >
                        Telaah
                      </button>
                    {/if}
                  </div>
                </div>
              </div>
            {/each}
          </div>
        </div>

      <!-- ═══════════════════════════════════════════════════════ -->
      <!-- 5. VIEW: STANDAR MUTU & SOP KURASI PERPUSTAKAAN         -->
      <!-- ═══════════════════════════════════════════════════════ -->
      {:else if activeView === 'sop'}
        <div class="max-w-5xl mx-auto space-y-6">
          <div class="p-6 bg-white rounded-3xl border border-slate-200 shadow-sm space-y-2">
            <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-primary/10 text-primary text-xs font-bold">
              <span class="material-symbols-outlined text-sm">policy</span>
              <span>Dokumen Standar Penjaminan Mutu Perpustakaan (SPMI)</span>
            </div>
            <h3 class="text-xl font-bold text-slate-900">Pedoman Operasional Penelaahan &amp; Kurasi Karya Ilmiah</h3>
            <p class="text-xs sm:text-sm text-slate-600 leading-relaxed">
              Panduan acuan resmi bagi tim pustakawan kurator dalam memvalidasi integritas akademik, orisinalitas naskah, dan kelengkapan repositori digital.
            </p>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div class="p-6 bg-white rounded-2xl border border-slate-200 shadow-sm space-y-3">
              <div class="w-10 h-10 rounded-xl bg-blue-100 text-primary flex items-center justify-center font-bold">
                1
              </div>
              <h4 class="font-bold text-slate-900 text-sm">Validasi Administratif &amp; Pengesahan</h4>
              <p class="text-xs text-slate-600 leading-relaxed">
                Memeriksa keaslian halaman persetujuan pembimbing dan dewan penguji. Naskah harus memiliki lembar pengesahan sah serta surat pernyataan bebas plagiarisme bermaterai.
              </p>
            </div>

            <div class="p-6 bg-white rounded-2xl border border-slate-200 shadow-sm space-y-3">
              <div class="w-10 h-10 rounded-xl bg-emerald-100 text-emerald-700 flex items-center justify-center font-bold">
                2
              </div>
              <h4 class="font-bold text-slate-900 text-sm">Pengecekan Ambang Batas Turnitin (&le; 20%)</h4>
              <p class="text-xs text-slate-600 leading-relaxed">
                Kurator memverifikasi laporan hasil uji kemiripan yang diunggah mahasiswa. Jika indeks kesamaan $\gt 20\%$, kurator wajib menolak dan menginstruksikan parafrase ulang.
              </p>
            </div>

            <div class="p-6 bg-white rounded-2xl border border-slate-200 shadow-sm space-y-3">
              <div class="w-10 h-10 rounded-xl bg-purple-100 text-purple-700 flex items-center justify-center font-bold">
                3
              </div>
              <h4 class="font-bold text-slate-900 text-sm">Pemberian Watermark &amp; Registrasi DOI</h4>
              <p class="text-xs text-slate-600 leading-relaxed">
                Saat naskah disetujui terbit, sistem secara otomatis membubuhkan watermark hak cipta institusi pada berkas PDF dan mendaftarkan prefix DOI resmi kampus.
              </p>
            </div>

            <div class="p-6 bg-white rounded-2xl border border-slate-200 shadow-sm space-y-3">
              <div class="w-10 h-10 rounded-xl bg-amber-100 text-amber-700 flex items-center justify-center font-bold">
                4
              </div>
              <h4 class="font-bold text-slate-900 text-sm">Penerbitan Surat Bebas Pustaka Digital</h4>
              <p class="text-xs text-slate-600 leading-relaxed">
                Persetujuan kurator secara otomatis mengaktifkan status bebas pustaka mahasiswa, menghasilkan nomor surat resmi dan QR Code autentikasi verifikasi ijazah.
              </p>
            </div>
          </div>
        </div>
      {/if}

    </main>
  </div>
</div>
{/if}
