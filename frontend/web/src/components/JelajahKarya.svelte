<script lang="ts">
  import type { Karya, RolePengguna } from '../types';

  interface Props {
    karyaList: Karya[];
    activeRole: RolePengguna;
    selectedCategory: string;
    searchQuery: string;
    selectedProdiKey: string;
    onCategoryChange: (cat: string) => void;
    onOpenDetail: (karya: Karya) => void;
    onDownloadKarya: (karya: Karya) => void;
    onOpenReviewModal?: (karya: Karya) => void;
    onOpenEdit?: (karya: Karya) => void;
  }

  let {
    karyaList,
    activeRole,
    selectedCategory,
    searchQuery,
    selectedProdiKey,
    onCategoryChange,
    onOpenDetail,
    onDownloadKarya,
    onOpenReviewModal,
    onOpenEdit
  }: Props = $props();

  let filteredKarya = $derived.by(() => {
    return karyaList.filter((k) => {
      if (activeRole === 'publik' && k.status !== 'Diterbitkan') {
        return false;
      }
      if (selectedCategory === 'skripsi' && k.jenis !== 'skripsi' && k.jenis !== 'tesis') {
        return false;
      }
      if (selectedCategory === 'jurnal' && k.jenis !== 'jurnal') {
        return false;
      }
      if (selectedCategory === 'kp' && k.jenis !== 'kp') {
        return false;
      }
      if (selectedProdiKey !== 'all' && k.prodiKey !== selectedProdiKey) {
        return false;
      }
      if (searchQuery.trim() !== '') {
        const q = searchQuery.toLowerCase();
        const matchTitle = k.judul.toLowerCase().includes(q);
        const matchAuthor = k.penulis.toLowerCase().includes(q);
        const matchAbstract = k.abstrak.toLowerCase().includes(q);
        const matchKeywords = k.kataKunci.some((tag) => tag.toLowerCase().includes(q));
        const matchAdvisor = k.pembimbing.toLowerCase().includes(q);
        const matchProdi = k.prodi.toLowerCase().includes(q);
        if (!matchTitle && !matchAuthor && !matchAbstract && !matchKeywords && !matchAdvisor && !matchProdi) {
          return false;
        }
      }
      return true;
    });
  });
</script>

<!-- 4. BAGIAN EKSPLORASI KARYA POPULER & TERBARU FROM STITCH -->
<section class="w-full py-12 sm:py-20 px-4 sm:px-6 lg:px-12 bg-surface-container-low" id="jelajah-karya">
  <div class="max-w-7xl mx-auto">
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-6 mb-8 sm:mb-12">
      <div class="space-y-3">
        <div class="inline-flex items-center gap-2 font-label-badge text-label-badge text-primary font-semibold">
          <span class="material-symbols-outlined text-base">auto_stories</span>
          <span>Koleksi Terverifikasi</span>
        </div>
        <h2 class="font-headline-xl text-headline-xl-mobile sm:text-headline-xl text-text-primary tracking-tight">
          Jelajahi Karya Ilmiah Terbaru &amp; Terpopuler
        </h2>
        <p class="font-body-md text-sm sm:text-body-md text-text-secondary max-w-xl">
          Akses ratusan hasil riset akademik terkini yang telah melalui pengujian sidang yudisium dan verifikasi kurator.
        </p>
      </div>

      <!-- Stitch Tabs with horizontal scroll on mobile -->
      <div class="w-full md:w-auto overflow-x-auto flex flex-nowrap sm:flex-wrap p-1.5 bg-surface-card rounded-2xl shadow-sm gap-1 self-start md:self-auto border border-border-subtle/50 scrollbar-none" id="galleryTabs">
        <button
          type="button"
          onclick={() => onCategoryChange('all')}
          class="shrink-0 whitespace-nowrap gallery-tab px-3.5 sm:px-4 py-2 rounded-xl font-headline-sm text-xs sm:text-headline-sm transition-all {selectedCategory === 'all' ? 'bg-primary text-on-primary shadow-sm font-bold' : 'text-text-secondary hover:text-text-primary hover:bg-surface-muted'}"
        >
          Semua Karya
        </button>
        <button
          type="button"
          onclick={() => onCategoryChange('skripsi')}
          class="shrink-0 whitespace-nowrap gallery-tab px-3.5 sm:px-4 py-2 rounded-xl font-headline-sm text-xs sm:text-headline-sm transition-all {selectedCategory === 'skripsi' ? 'bg-primary text-on-primary shadow-sm font-bold' : 'text-text-secondary hover:text-text-primary hover:bg-surface-muted'}"
        >
          Skripsi &amp; Tesis
        </button>
        <button
          type="button"
          onclick={() => onCategoryChange('jurnal')}
          class="shrink-0 whitespace-nowrap gallery-tab px-3.5 sm:px-4 py-2 rounded-xl font-headline-sm text-xs sm:text-headline-sm transition-all {selectedCategory === 'jurnal' ? 'bg-primary text-on-primary shadow-sm font-bold' : 'text-text-secondary hover:text-text-primary hover:bg-surface-muted'}"
        >
          Jurnal Ilmiah
        </button>
        <button
          type="button"
          onclick={() => onCategoryChange('kp')}
          class="shrink-0 whitespace-nowrap gallery-tab px-3.5 sm:px-4 py-2 rounded-xl font-headline-sm text-xs sm:text-headline-sm transition-all {selectedCategory === 'kp' ? 'bg-primary text-on-primary shadow-sm font-bold' : 'text-text-secondary hover:text-text-primary hover:bg-surface-muted'}"
        >
          Kerja Praktik
        </button>
      </div>
    </div>

    <!-- Active filter alert if filtering -->
    {#if searchQuery || selectedProdiKey !== 'all'}
      <div class="mb-6 flex items-center justify-between p-3 rounded-xl bg-surface-card border border-border-subtle text-xs">
        <span class="text-text-secondary">
          Menampilkan hasil untuk:
          {#if searchQuery}
            <strong>"{searchQuery}"</strong>
          {/if}
          {#if selectedProdiKey !== 'all'}
            <span class="ml-1 text-primary">Prodi: {selectedProdiKey.toUpperCase()}</span>
          {/if}
          ({filteredKarya.length} karya ditemukan)
        </span>
        <button
          type="button"
          onclick={() => { onCategoryChange('all'); }}
          class="text-primary font-bold hover:underline"
        >
          Tampilkan Semua
        </button>
      </div>
    {/if}

    <!-- Grid of Karya Cards from Stitch -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6" id="karyaCardGrid">
      {#each filteredKarya as karya (karya.id)}
        <div class="karya-item bg-surface-card rounded-2xl p-6 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 flex flex-col justify-between border border-border-subtle group">
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <span class="px-2.5 py-1 rounded-full {karya.jenis === 'jurnal' ? 'bg-status-published/15 text-status-published' : karya.jenis === 'tesis' ? 'bg-secondary-container/20 text-secondary' : karya.jenis === 'kp' ? 'bg-status-review/20 text-status-review' : 'bg-primary/10 text-primary'} font-label-badge text-label-badge font-semibold">
                {karya.jenisLabel}
              </span>
              <span class="font-label-mono-sm text-label-mono-sm text-text-tertiary">{karya.tahun}</span>
            </div>

            <button
              type="button"
              onclick={() => onOpenDetail(karya)}
              class="text-left font-headline-md text-headline-md text-text-primary line-clamp-2 hover:text-primary transition-colors cursor-pointer w-full leading-snug"
            >
              {karya.judul}
            </button>

            <div class="text-xs text-text-secondary space-y-1">
              <p class="font-semibold text-text-primary">{karya.penulis}</p>
              <p class="truncate text-text-tertiary">Pembimbing: {karya.pembimbing}</p>
              <span class="inline-block px-2 py-0.5 rounded bg-surface-muted text-text-secondary font-label-caption text-label-caption font-semibold">
                {karya.prodi}
              </span>
            </div>

            <p class="font-body-sm text-body-sm text-text-secondary line-clamp-3 leading-relaxed">
              {karya.abstrak}
            </p>
          </div>

          <div class="pt-6 mt-4 flex items-center justify-between text-xs border-t border-border-subtle/70">
            <div class="flex items-center gap-1 text-text-secondary">
              <span class="material-symbols-outlined text-sm text-primary">download</span>
              <span class="font-label-mono-sm font-semibold">{karya.unduhan}x</span>
            </div>
            <div class="flex items-center gap-2">
              <button
                type="button"
                onclick={() => onOpenDetail(karya)}
                class="px-2.5 py-1.5 rounded-lg bg-surface-muted hover:bg-surface-container-high text-text-primary font-label-badge transition-colors font-semibold"
              >
                Abstrak
              </button>
              <button
                type="button"
                onclick={() => onDownloadKarya(karya)}
                class="px-3 py-1.5 rounded-lg bg-primary text-on-primary font-label-badge hover:bg-primary-container transition-colors shadow-sm flex items-center gap-1 font-semibold active:scale-95"
              >
                <span class="material-symbols-outlined text-xs">picture_as_pdf</span>
                <span>PDF</span>
              </button>
            </div>
          </div>

          {#if activeRole === 'kurator' && onOpenReviewModal}
            <div class="pt-3 border-t border-dashed border-status-review/30 mt-3">
              <button
                type="button"
                onclick={() => onOpenReviewModal(karya)}
                class="w-full py-1.5 px-3 rounded-lg bg-status-review/10 text-status-review hover:bg-status-review/20 text-xs font-semibold flex items-center justify-center gap-1 transition-colors"
              >
                <span class="material-symbols-outlined text-sm">fact_check</span>
                <span>Review Kurator</span>
              </button>
            </div>
          {:else if activeRole === 'penulis' && onOpenEdit && (karya.status === 'Draft' || karya.status === 'Perlu Revisi')}
            <div class="pt-3 border-t border-dashed border-status-revision/30 mt-3">
              <button
                type="button"
                onclick={() => onOpenEdit(karya)}
                class="w-full py-1.5 px-3 rounded-lg bg-status-revision/10 text-status-revision hover:bg-status-revision/20 text-xs font-semibold flex items-center justify-center gap-1 transition-colors"
              >
                <span class="material-symbols-outlined text-sm">edit_note</span>
                <span>Revisi &amp; Kirim Ulang Naskah</span>
              </button>
            </div>
          {/if}
        </div>
      {/each}
    </div>

    <!-- Bottom link from Stitch -->
    <div class="mt-12 text-center">
      <button
        type="button"
        onclick={() => { onCategoryChange('all'); }}
        class="inline-flex items-center gap-2 font-headline-sm text-headline-sm text-primary hover:text-primary-container px-6 py-3 rounded-full bg-surface-card shadow-sm hover:shadow-md transition-all border border-border-subtle cursor-pointer"
      >
        <span>Telusuri Seluruh {karyaList.length > 0 ? `${karyaList.length} Koleksi` : 'Koleksi'} Karya Ilmiah Kampus</span>
        <span class="material-symbols-outlined text-base">expand_more</span>
      </button>
    </div>
  </div>
</section>
