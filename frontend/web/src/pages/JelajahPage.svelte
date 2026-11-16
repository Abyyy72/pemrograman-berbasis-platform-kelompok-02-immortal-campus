<script lang="ts">
  import type { Karya, RolePengguna } from '../types';

  interface Props {
    karyaList: Karya[];
    activeRole: RolePengguna;
    onOpenDetail: (karya: Karya) => void;
    onDownloadKarya: (karya: Karya) => void;
    onOpenReview: (karya: Karya) => void;
    onOpenEdit: (karya: Karya) => void;
    onOpenUpload: () => void;
  }

  let {
    karyaList,
    activeRole,
    onOpenDetail,
    onDownloadKarya,
    onOpenReview,
    onOpenEdit,
    onOpenUpload
  }: Props = $props();

  let searchQuery = $state('');
  let selectedCategory = $state<'all' | 'skripsi' | 'tesis' | 'jurnal' | 'kp'>('all');
  let selectedProdi = $state('all');
  let selectedSort = $state<'populer' | 'terbaru' | 'sitasi'>('populer');
  let selectedRumpun = $state<'all' | 'saintek' | 'soshum'>('all');

  const prodiOptions = [
    { key: 'all', label: 'Semua Program Studi' },
    { key: 'ti', label: 'Teknik Informatika (FTI)' },
    { key: 'si', label: 'Sistem Informasi (FTI)' },
    { key: 'dkv', label: 'Desain Komunikasi Visual (FDS)' },
    { key: 'mnj', label: 'Manajemen & Akuntansi (FEB)' },
    { key: 'ilkom', label: 'Ilmu Komunikasi (FIKOM)' }
  ];

  let filteredKarya = $derived.by(() => {
    return karyaList
      .filter((k) => {
        if (activeRole === 'publik' && k.status !== 'Diterbitkan') {
          return false;
        }
        if (selectedCategory !== 'all') {
          if (selectedCategory === 'skripsi' && k.jenis !== 'skripsi') return false;
          if (selectedCategory === 'tesis' && k.jenis !== 'tesis') return false;
          if (selectedCategory === 'jurnal' && k.jenis !== 'jurnal') return false;
          if (selectedCategory === 'kp' && k.jenis !== 'kp') return false;
        }
        if (selectedProdi !== 'all' && k.prodiKey !== selectedProdi) {
          return false;
        }
        if (selectedRumpun !== 'all') {
          const isSaintek = k.prodiKey === 'ti' || k.prodiKey === 'si' || k.prodiKey === 'dkv';
          if (selectedRumpun === 'saintek' && !isSaintek) return false;
          if (selectedRumpun === 'soshum' && isSaintek) return false;
        }
        if (searchQuery.trim() !== '') {
          const q = searchQuery.toLowerCase();
          const matchTitle = k.judul.toLowerCase().includes(q);
          const matchAuthor = k.penulis.toLowerCase().includes(q);
          const matchAbstract = k.abstrak.toLowerCase().includes(q);
          const matchKeywords = k.kataKunci.some((tag) => tag.toLowerCase().includes(q));
          const matchAdvisor = k.pembimbing.toLowerCase().includes(q);
          if (!matchTitle && !matchAuthor && !matchAbstract && !matchKeywords && !matchAdvisor) {
            return false;
          }
        }
        return true;
      })
      .sort((a, b) => {
        if (selectedSort === 'populer') return (b.unduhan || 0) - (a.unduhan || 0);
        if (selectedSort === 'sitasi') return (b.sitasi || 0) - (a.sitasi || 0);
        return b.tahun - a.tahun;
      });
  });

  const totalDiterbitkan = $derived(karyaList.filter(k => k.status === 'Diterbitkan').length);
  const totalUnduhan = $derived(karyaList.reduce((acc, k) => acc + (k.unduhan || 0), 0));
</script>

<div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-12 py-6 sm:py-10 space-y-6 sm:space-y-10">
  <!-- HERO BANNER DEDIKASI JELAJAH KARYA FROM STITCH SCREEN 8 -->
  <div class="relative overflow-hidden rounded-3xl bg-gradient-to-r from-primary/10 via-primary/5 to-secondary-container/10 p-5 sm:p-8 lg:p-12 border border-primary/20 shadow-sm">
    <div class="absolute -right-16 -top-16 w-80 h-80 rounded-full bg-primary/10 blur-3xl pointer-events-none"></div>
    <div class="relative z-10 flex flex-col lg:flex-row lg:items-center justify-between gap-6">
      <div class="max-w-2xl space-y-3">
        <div class="inline-flex items-center gap-2 px-3.5 py-1 rounded-full bg-white shadow-sm text-primary font-label-badge text-label-badge font-semibold">
          <span class="material-symbols-outlined text-base">auto_stories</span>
          <span>Repositori Akademik Terbuka &amp; Terakreditasi</span>
        </div>
        <h1 class="font-display-hero text-2xl sm:text-display-hero-mobile text-text-primary tracking-tight font-extrabold">
          Katalog Jelajah Karya Ilmiah
        </h1>
        <p class="font-body-md text-sm sm:text-base text-text-secondary leading-relaxed">
          Temukan skripsi, tesis, artikel jurnal terindeks, dan laporan riset sivitas akademika yang telah melewati sidang yudisium dan verifikasi kurator.
        </p>
      </div>

      <!-- Quick Metrics Bento -->
      <div class="flex flex-wrap sm:flex-nowrap items-center gap-3 shrink-0">
        <div class="bg-white px-5 py-3.5 rounded-2xl shadow-sm border border-border-subtle flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-primary/10 text-primary flex items-center justify-center">
            <span class="material-symbols-outlined text-xl">description</span>
          </div>
          <div>
            <span class="text-xs text-text-tertiary block font-medium">Koleksi Terbuka</span>
            <strong class="text-base text-text-primary font-bold">{totalDiterbitkan} Naskah</strong>
          </div>
        </div>

        <div class="bg-white px-5 py-3.5 rounded-2xl shadow-sm border border-border-subtle flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-status-published/15 text-status-published flex items-center justify-center">
            <span class="material-symbols-outlined text-xl">cloud_download</span>
          </div>
          <div>
            <span class="text-xs text-text-tertiary block font-medium">Total Diunduh</span>
            <strong class="text-base text-text-primary font-bold">{totalUnduhan.toLocaleString('id-ID')}x</strong>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- SEARCH & FILTER CONTROLS BAR -->
  <div class="bg-white rounded-2xl p-5 shadow-sm border border-border-subtle space-y-4">
    <!-- Row 1: Search input + Buttons -->
    <div class="flex flex-col md:flex-row items-stretch gap-3">
      <div class="relative flex-1">
        <span class="absolute left-4 top-1/2 -translate-y-1/2 material-symbols-outlined text-text-tertiary">search</span>
        <input
          type="text"
          bind:value={searchQuery}
          placeholder="Cari judul penelitian, nama mahasiswa/dosen, abstrak, atau topik..."
          class="w-full pl-11 pr-4 py-3 bg-surface-muted rounded-xl text-sm text-text-primary placeholder:text-text-tertiary focus:outline-none focus:ring-2 focus:ring-primary/40 transition-all border border-transparent focus:bg-white"
        />
        {#if searchQuery}
          <button
            onclick={() => searchQuery = ''}
            class="absolute right-3 top-1/2 -translate-y-1/2 text-text-tertiary hover:text-text-primary p-1"
          >
            <span class="material-symbols-outlined text-sm">close</span>
          </button>
        {/if}
      </div>

      <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2">
        <!-- Prodi Selector -->
        <select
          bind:value={selectedProdi}
          class="flex-1 sm:flex-none px-3.5 py-2.5 sm:py-3 bg-surface-muted rounded-xl text-xs sm:text-sm text-text-primary border border-border-subtle/80 focus:outline-none focus:ring-2 focus:ring-primary/40 font-medium cursor-pointer"
        >
          {#each prodiOptions as p}
            <option value={p.key}>{p.label}</option>
          {/each}
        </select>

        <!-- Sorting -->
        <select
          bind:value={selectedSort}
          class="flex-1 sm:flex-none px-3.5 py-2.5 sm:py-3 bg-surface-muted rounded-xl text-xs sm:text-sm text-text-primary border border-border-subtle/80 focus:outline-none focus:ring-2 focus:ring-primary/40 font-medium cursor-pointer"
        >
          <option value="populer">Paling Banyak Diunduh</option>
          <option value="terbaru">Tahun Terbaru</option>
          <option value="sitasi">Sitasi Tertinggi</option>
        </select>

        {#if activeRole === 'penulis'}
          <button
            onclick={onOpenUpload}
            class="px-4 py-2.5 sm:py-3 bg-primary text-white rounded-xl text-xs sm:text-sm font-semibold hover:bg-primary-container shadow-sm flex items-center justify-center gap-1.5 shrink-0 transition-all active:scale-95"
          >
            <span class="material-symbols-outlined text-base">upload_file</span>
            <span>Unggah Karya</span>
          </button>
        {/if}
      </div>
    </div>

    <!-- Row 2: Category Filter Tabs -->
    <div class="flex flex-wrap items-center justify-between gap-3 pt-3 border-t border-border-subtle/60 text-xs">
      <div class="flex items-center gap-1.5 flex-wrap">
        <span class="text-text-tertiary font-semibold mr-1">Jenis:</span>
        {#each ([
          ['all', 'Semua'],
          ['skripsi', 'Skripsi S-1'],
          ['tesis', 'Tesis S-2'],
          ['jurnal', 'Jurnal Ilmiah'],
          ['kp', 'Kerja Praktik']
        ] as const) as [key, label]}
          <button
            onclick={() => selectedCategory = key}
            class="px-3 py-1.5 rounded-xl transition-all font-semibold {selectedCategory === key ? 'bg-primary text-white shadow-sm' : 'bg-surface-muted text-text-secondary hover:text-text-primary hover:bg-slate-200'}"
          >
            {label}
          </button>
        {/each}
      </div>

      <div class="flex items-center gap-1.5">
        <span class="text-text-tertiary font-semibold mr-1">Rumpun:</span>
        <button
          onclick={() => selectedRumpun = 'all'}
          class="px-2.5 py-1 rounded-lg font-medium {selectedRumpun === 'all' ? 'bg-slate-800 text-white font-bold' : 'text-text-secondary hover:bg-surface-muted'}"
        >Semua</button>
        <button
          onclick={() => selectedRumpun = 'saintek'}
          class="px-2.5 py-1 rounded-lg font-medium {selectedRumpun === 'saintek' ? 'bg-secondary text-white font-bold' : 'text-text-secondary hover:bg-surface-muted'}"
        >Saintek</button>
        <button
          onclick={() => selectedRumpun = 'soshum'}
          class="px-2.5 py-1 rounded-lg font-medium {selectedRumpun === 'soshum' ? 'bg-status-review text-white font-bold' : 'text-text-secondary hover:bg-surface-muted'}"
        >Soshum</button>
      </div>
    </div>
  </div>

  <!-- RESULTS COUNT & STATUS -->
  <div class="flex items-center justify-between text-xs text-text-secondary px-1">
    <span>Menampilkan <strong>{filteredKarya.length}</strong> karya ilmiah</span>
    {#if searchQuery || selectedCategory !== 'all' || selectedProdi !== 'all'}
      <button
        onclick={() => { searchQuery = ''; selectedCategory = 'all'; selectedProdi = 'all'; selectedRumpun = 'all'; }}
        class="text-primary hover:underline font-semibold flex items-center gap-1"
      >
        <span class="material-symbols-outlined text-sm">refresh</span>
        <span>Reset Filter</span>
      </button>
    {/if}
  </div>

  <!-- CATALOG CARDS GRID -->
  {#if filteredKarya.length === 0}
    <div class="py-16 text-center space-y-4 bg-white rounded-3xl border border-border-subtle p-8">
      <div class="w-16 h-16 rounded-2xl bg-surface-muted flex items-center justify-center mx-auto text-text-tertiary">
        <span class="material-symbols-outlined text-3xl">search_off</span>
      </div>
      <h3 class="font-headline-md text-text-primary font-bold">Karya Tidak Ditemukan</h3>
      <p class="font-body-sm text-text-secondary max-w-md mx-auto">
        Tidak ada naskah yang cocok dengan kata kunci atau filter saat ini. Silakan coba kata kunci lain atau reset filter pencarian.
      </p>
    </div>
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {#each filteredKarya as karya (karya.id)}
        <div class="bg-white rounded-2xl p-6 shadow-sm hover:shadow-xl transition-all duration-300 border border-border-subtle flex flex-col justify-between group">
          <div class="space-y-4">
            <!-- Header Badges -->
            <div class="flex items-center justify-between gap-2 flex-wrap">
              <span class="px-2.5 py-0.5 rounded-full bg-primary/10 text-primary font-label-badge text-label-badge font-semibold">
                {karya.jenisLabel}
              </span>
              <span class="font-label-mono-sm text-label-mono-sm text-text-tertiary">
                {karya.tahun}
              </span>
            </div>

            <!-- Title -->
            <button
              type="button"
              onclick={() => onOpenDetail(karya)}
              class="text-left font-headline-md text-base font-bold text-text-primary group-hover:text-primary transition-colors cursor-pointer line-clamp-2 leading-snug w-full"
            >
              {karya.judul}
            </button>

            <!-- Author & Advisor -->
            <div class="space-y-1 text-xs">
              <div class="flex items-center gap-1.5 text-text-primary font-semibold">
                <span class="material-symbols-outlined text-sm text-primary">person</span>
                <span>{karya.penulis}</span>
                {#if karya.nim}
                  <span class="text-text-tertiary font-normal">({karya.nim})</span>
                {/if}
              </div>
              <div class="text-text-tertiary pl-5">
                <span>{karya.prodi}</span>
              </div>
            </div>

            <!-- Abstract Snippet -->
            <p class="font-body-sm text-xs text-text-secondary line-clamp-3 leading-relaxed">
              {karya.abstrak}
            </p>

            <!-- Tags -->
            <div class="flex flex-wrap gap-1 pt-1">
              {#each karya.kataKunci.slice(0, 3) as tag}
                <span class="px-2 py-0.5 rounded-md bg-surface-muted text-[10px] text-text-secondary font-medium">
                  #{tag}
                </span>
              {/each}
            </div>
          </div>

          <!-- Card Footer -->
          <div class="pt-5 mt-5 border-t border-border-subtle space-y-3">
            <div class="flex items-center justify-between text-xs text-text-secondary">
              <div class="flex items-center gap-1 font-semibold text-text-primary">
                <span class="material-symbols-outlined text-sm text-primary">download</span>
                <span>{karya.unduhan}x diunduh</span>
              </div>
              <div class="flex items-center gap-1 text-text-tertiary">
                <span class="material-symbols-outlined text-sm text-status-review">star</span>
                <span>{karya.sitasi || 0} sitasi</span>
              </div>
            </div>

            <div class="flex items-center gap-2">
              <button
                type="button"
                onclick={() => onOpenDetail(karya)}
                class="flex-1 py-2 px-3 rounded-xl bg-surface-muted hover:bg-slate-200 text-text-primary text-xs font-semibold transition-all text-center"
              >
                Detail &amp; Sitasi
              </button>
              <button
                type="button"
                onclick={() => onDownloadKarya(karya)}
                class="inline-flex items-center justify-center gap-1.5 py-2 px-4 rounded-xl bg-primary text-white hover:bg-primary-container text-xs font-semibold shadow-sm transition-all active:scale-95"
              >
                <span class="material-symbols-outlined text-sm">download</span>
                <span>Unduh PDF</span>
              </button>
            </div>

            <!-- Role Action Buttons -->
            {#if activeRole === 'kurator'}
              <button
                type="button"
                onclick={() => onOpenReview(karya)}
                class="w-full py-1.5 px-3 rounded-xl bg-status-review/10 text-status-review hover:bg-status-review/20 text-xs font-bold flex items-center justify-center gap-1 transition-colors"
              >
                <span class="material-symbols-outlined text-sm">fact_check</span>
                <span>Review Kurator</span>
              </button>
            {:else if activeRole === 'penulis' && (karya.status === 'Draft' || karya.status === 'Perlu Revisi')}
              <button
                type="button"
                onclick={() => onOpenEdit(karya)}
                class="w-full py-1.5 px-3 rounded-xl bg-status-revision/10 text-status-revision hover:bg-status-revision/20 text-xs font-bold flex items-center justify-center gap-1 transition-colors"
              >
                <span class="material-symbols-outlined text-sm">edit_note</span>
                <span>Revisi &amp; Kirim Ulang</span>
              </button>
            {/if}
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>
