<script lang="ts">
  import type { Karya } from "../types";

  interface Props {
    karyaList?: Karya[];
    searchQuery: string;
    selectedProdiKey: string;
    onSearchChange: (q: string) => void;
    onProdiSelect: (key: "all" | "ti" | "si" | "dkv" | "mnj" | "ilkom") => void;
    onOpenUpload: () => void;
    onOpenDetail: (karya: Karya) => void;
    onDownloadKarya: (karya: Karya) => void;
  }

  let {
    karyaList = [],
    searchQuery,
    selectedProdiKey,
    onSearchChange,
    onProdiSelect,
    onOpenUpload,
    onOpenDetail,
    onDownloadKarya,
  }: Props = $props();

  let localInput = $state("");

  $effect(() => {
    localInput = searchQuery;
  });

  // Featured paper otomatis memilih naskah terbit dengan unduhan tertinggi dari database
  const fallbackKarya: Karya = {
    id: "karya-001",
    judul:
      "Penerapan Deep Learning CNN untuk Deteksi Dini Penyakit Padi Berbasis Mobile",
    penulis: "Amanda Putri Wibowo",
    nim: "2110512034",
    pembimbing: "Dr. Eng. Hendra Sucipto, S.Kom., M.T.",
    jenis: "skripsi",
    jenisLabel: "Skripsi S-1",
    prodi: "Teknik Informatika",
    prodiKey: "ti",
    tahun: 2024,
    abstrak:
      "Rancang bangun MobileNetV3 terkompresi INT8 quantization untuk deteksi penyakit daun padi tropis dengan akurasi 96,8%.",
    kataKunci: ["Teknik Informatika", "Computer Vision", "Deep Learning"],
    unduhan: 1420,
    sitasi: 18,
    status: "Diterbitkan",
    tanggalTerbit: "14 Juli 2024",
    doi: "10.2412/imc.2024.089",
    fileSize: "6.4 MB",
  };

  let totalUnduhanHero = $derived(
    karyaList.reduce((acc, k) => acc + (k.unduhan || 0), 0),
  );

  let featuredKaryaObj = $derived.by(() => {
    if (karyaList && karyaList.length > 0) {
      const published = karyaList.filter((k) => k.status === "Diterbitkan");
      if (published.length > 0) {
        return [...published].sort(
          (a, b) => (b.unduhan || 0) - (a.unduhan || 0),
        )[0];
      }
    }
    return fallbackKarya;
  });

  function handleSubmit(e: Event) {
    e.preventDefault();
    onSearchChange(localInput);
    const el = document.getElementById("jelajah-karya");
    if (el) el.scrollIntoView({ behavior: "smooth" });
  }

  function handleFilterClick(
    key: "all" | "ti" | "si" | "dkv" | "mnj" | "ilkom",
    label: string,
  ) {
    onProdiSelect(key);
    localInput = key === "all" ? "" : label;
    onSearchChange(localInput);
    const el = document.getElementById("jelajah-karya");
    if (el) el.scrollIntoView({ behavior: "smooth" });
  }
</script>

<!-- 2. HERO SECTION FROM STITCH -->
<section id="beranda" class="relative overflow-hidden px-4 sm:px-6 lg:px-12 pt-8 sm:pt-12 pb-16 sm:pb-24 max-w-7xl mx-auto w-full">
  <div class="absolute top-10 left-1/2 -translate-x-1/2 w-[720px] max-w-full h-[340px] bg-primary/5 rounded-full blur-3xl pointer-events-none -z-10"></div>
  <div class="absolute top-48 right-10 w-96 max-w-full h-96 bg-secondary-container/10 rounded-full blur-3xl pointer-events-none -z-10"></div>

  <div class="flex flex-col items-center text-center max-w-4xl mx-auto space-y-4 sm:space-y-6">
    <div class="inline-flex items-center gap-2 px-3 sm:px-4 py-1.5 rounded-full bg-surface-card shadow-sm hover:shadow transition-shadow max-w-full">
      <span class="flex h-2 w-2 rounded-full bg-status-published animate-pulse shrink-0"></span>
      <span class="font-label-badge text-xs sm:text-label-badge text-primary tracking-wide text-center leading-tight">
        Repositori Resmi Karya Ilmiah Kampus • Terkurasi &amp; Terbuka
      </span>
    </div>

    <h1 class="font-display-hero text-display-hero-mobile sm:text-display-hero text-text-primary tracking-tight max-w-3xl">
      Abadikan Karya Ilmiah, <span class="text-primary underline decoration-primary/20 decoration-wavy decoration-2">Buka Gerbang</span> Pengetahuan Kampus.
    </h1>

    <p class="font-body-md sm:font-body-lg text-sm sm:text-body-lg text-text-secondary max-w-2xl leading-relaxed">
      Satu wadah resmi untuk menyimpan, mengkurasi, dan mempublikasikan skripsi, tesis, jurnal, serta laporan riset sivitas akademika. Akses ribuan referensi tervalidasi bebas hambatan.
    </p>

    <!-- Search Box Card -->
    <div
      class="w-full max-w-3xl bg-surface-card rounded-2xl shadow-xl p-3 sm:p-4 space-y-3 mt-4 border border-border-subtle/50"
    >
      <form
        onsubmit={handleSubmit}
        class="flex flex-col sm:flex-row items-center gap-2 bg-surface-canvas rounded-xl p-2"
      >
        <div
          class="flex items-center gap-3 w-full px-3 py-1 text-text-secondary"
        >
          <span class="material-symbols-outlined text-primary text-xl"
            >search</span
          >
          <input
            bind:value={localInput}
            class="w-full bg-transparent font-body-md text-body-md text-text-primary placeholder:text-text-tertiary focus:outline-none"
            id="heroSearchInput"
            placeholder="Cari judul skripsi, penulis, abstrak, atau kata kunci..."
            type="text"
          />
        </div>
        <div
          class="flex items-center gap-2 w-full sm:w-auto shrink-0 justify-end"
        >
          <button
            type="submit"
            class="w-full sm:w-auto inline-flex items-center justify-center gap-2 bg-primary hover:bg-primary-container text-on-primary font-headline-sm text-headline-sm px-6 py-3 rounded-xl shadow-md transition-all active:scale-95"
          >
            <span>Cari Karya</span>
            <span class="material-symbols-outlined text-sm">arrow_forward</span>
          </button>
        </div>
      </form>

      <div
        class="flex flex-wrap items-center justify-between gap-3 pt-1 text-xs"
      >
        <div class="flex flex-wrap items-center gap-1.5" id="heroFilterGroup">
          <span
            class="font-label-badge text-label-badge text-text-tertiary mr-1"
            >Filter Cepat:</span
          >
          <button
            type="button"
            onclick={() => handleFilterClick("all", "")}
            class="filter-pill px-3 py-1 rounded-full font-label-badge text-label-badge transition-all {selectedProdiKey ===
              'all' && !searchQuery
              ? 'bg-primary text-on-primary'
              : 'bg-surface-muted text-text-secondary hover:text-text-primary'}"
          >
            Semua Kategori
          </button>
          <button
            type="button"
            onclick={() => handleFilterClick("ti", "Informatika")}
            class="filter-pill px-3 py-1 rounded-full font-label-badge text-label-badge transition-all {selectedProdiKey ===
              'ti' || searchQuery.includes('Informatika')
              ? 'bg-primary text-on-primary'
              : 'bg-surface-muted text-text-secondary hover:text-text-primary'}"
          >
            Informatika
          </button>
          <button
            type="button"
            onclick={() => handleFilterClick("si", "Sistem Informasi")}
            class="filter-pill px-3 py-1 rounded-full font-label-badge text-label-badge transition-all {selectedProdiKey ===
              'si' || searchQuery.includes('Sistem Informasi')
              ? 'bg-primary text-on-primary'
              : 'bg-surface-muted text-text-secondary hover:text-text-primary'}"
          >
            Sistem Informasi
          </button>
          <button
            type="button"
            onclick={() => handleFilterClick("dkv", "DKV")}
            class="filter-pill px-3 py-1 rounded-full font-label-badge text-label-badge transition-all {selectedProdiKey ===
              'dkv' || searchQuery.includes('DKV')
              ? 'bg-primary text-on-primary'
              : 'bg-surface-muted text-text-secondary hover:text-text-primary'}"
          >
            DKV
          </button>
          <button
            type="button"
            onclick={() => handleFilterClick("mnj", "Manajemen")}
            class="filter-pill px-3 py-1 rounded-full font-label-badge text-label-badge transition-all {selectedProdiKey ===
              'mnj' || searchQuery.includes('Manajemen')
              ? 'bg-primary text-on-primary'
              : 'bg-surface-muted text-text-secondary hover:text-text-primary'}"
          >
            Manajemen
          </button>
        </div>

        <button
          type="button"
          onclick={onOpenUpload}
          class="inline-flex items-center gap-1.5 font-label-badge text-label-badge text-primary hover:text-primary-container px-3 py-1 rounded-lg hover:bg-surface-muted transition-all font-semibold"
        >
          <span class="material-symbols-outlined text-base">cloud_upload</span>
          <span>Ajukan Karya Baru</span>
        </button>
      </div>
    </div>
  </div>

  <!-- Featured Mockup Box from Stitch -->
  <div class="mt-12 sm:mt-16 max-w-5xl mx-auto relative">
    <div class="bg-surface-card rounded-3xl p-5 sm:p-8 shadow-xl relative z-10 border border-border-subtle/70 overflow-hidden">
      <div class="flex items-center justify-between pb-4 sm:pb-6 mb-6 border-b border-border-subtle/80 flex-wrap gap-2">
        <div class="flex items-center gap-2 min-w-0">
          <div class="w-3 h-3 rounded-full bg-error/70 shrink-0"></div>
          <div class="w-3 h-3 rounded-full bg-status-review/80 shrink-0"></div>
          <div class="w-3 h-3 rounded-full bg-status-published/80 shrink-0"></div>
          <span class="ml-2 sm:ml-4 font-label-mono-sm text-label-mono-sm text-text-tertiary truncate max-w-[170px] sm:max-w-none">portal.immortal-campus.ac.id/etalase/karya/{featuredKaryaObj.id}</span>
        </div>
        <div class="flex items-center gap-2 sm:gap-3 shrink-0">
          <span
            class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-status-published/10 text-status-published font-label-badge text-label-badge font-semibold"
          >
            <span class="material-symbols-outlined text-xs">verified</span> Terverifikasi
            Kurator
          </span>
          <span class="font-label-mono-sm text-label-mono-sm text-text-tertiary hidden sm:inline">DOI: {featuredKaryaObj.doi || '10.2412/imc.2026.001'}</span>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-start">
        <!-- Left Thumbnail Column -->
        <div
          class="lg:col-span-4 bg-surface-muted rounded-2xl p-5 flex flex-col justify-between h-full relative overflow-hidden group"
        >
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <span
                class="px-2.5 py-1 rounded-md bg-primary text-on-primary font-label-badge text-label-badge font-bold uppercase"
                >{featuredKaryaObj.jenisLabel || featuredKaryaObj.jenis}</span
              >
              <span
                class="font-label-mono-sm text-label-mono-sm text-text-secondary"
                >Tahun {featuredKaryaObj.tahun}</span
              >
            </div>
            <div class="h-44 rounded-xl overflow-hidden shadow-sm relative">
              <img
                alt="Laboratory research"
                class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                src="https://lh3.googleusercontent.com/aida-public/AB6AXuA0ljUqcgCcbdF1EUiH9WLJNo_Sqy5wpTmKXLak61a-RbdUpU9MxP2R20dOtGRR8M74KB-TeSSRy7otuRi9qg0upsUifelM9R5-IbPK48FYsAhrY3B8CKO-WwYmkfZqRQU31dEDbd_m06toyqZVKsSeXTyINp_dFUqcvlBqDDfpr_wbXrJjN4XAFz96mH4jQVD0bn_UWLMExEH7EixodjArdPTG7GQWQNR4SGruhuM"
              />
              <div
                class="absolute inset-0 bg-gradient-to-t from-inverse-surface/80 via-transparent to-transparent flex items-end p-3"
              >
                <span
                  class="text-on-primary font-headline-sm text-xs font-semibold"
                  >{featuredKaryaObj.prodi}</span
                >
              </div>
            </div>
          </div>

          <div class="pt-4 space-y-2">
            <div
              class="flex items-center justify-between text-xs text-text-secondary"
            >
              <span>Ukuran Berkas:</span>
              <span class="font-label-mono-sm font-semibold text-text-primary"
                >PDF • {featuredKaryaObj.fileSize || "4.5 MB"}</span
              >
            </div>
            <div
              class="flex items-center justify-between text-xs text-text-secondary"
            >
              <span>Status Kurasi:</span>
              <span
                class="inline-flex items-center font-label-mono-sm font-semibold text-status-published"
                >100% Lolos Uji</span
              >
            </div>
          </div>
        </div>

        <!-- Right Description Column -->
        <div
          class="lg:col-span-8 flex flex-col justify-between h-full space-y-6"
        >
          <div class="space-y-3">
            <div class="flex flex-wrap items-center gap-2">
              <span
                class="px-3 py-0.5 rounded-full bg-primary/10 text-primary font-label-badge text-label-badge font-semibold"
                >{featuredKaryaObj.prodi}</span
              >
              {#each (featuredKaryaObj.kataKunci || []).slice(0, 3) as kw}
                <span
                  class="px-3 py-0.5 rounded-full bg-surface-muted text-text-secondary font-label-badge text-label-badge"
                  >{kw}</span
                >
              {/each}
            </div>

            <button
              type="button"
              onclick={() => onOpenDetail(featuredKaryaObj)}
              class="text-left font-headline-xl text-headline-xl-mobile sm:text-headline-xl text-text-primary tracking-tight leading-tight hover:text-primary transition-colors cursor-pointer w-full"
            >
              {featuredKaryaObj.judul}
            </button>

            <div class="flex items-center gap-3 pt-1">
              <div
                class="w-10 h-10 rounded-full bg-primary text-white flex items-center justify-center font-bold text-sm shadow-sm shrink-0"
              >
                {(featuredKaryaObj.penulis || "U")
                  .split(/\s+/)
                  .map((w) => w[0])
                  .slice(0, 2)
                  .join("")
                  .toUpperCase()}
              </div>
              <div class="min-w-0">
                <h4 class="font-headline-sm text-headline-sm text-text-primary font-bold truncate">{featuredKaryaObj.penulis}</h4>
                <p class="font-body-sm text-body-sm text-text-secondary truncate">
                  {#if featuredKaryaObj.nim}NIM: {featuredKaryaObj.nim} •
                  {/if}
                  Pembimbing: {featuredKaryaObj.pembimbing}
                </p>
              </div>
            </div>

            <p
              class="font-body-md text-body-md text-text-secondary leading-relaxed line-clamp-3"
            >
              {featuredKaryaObj.abstrak}
            </p>
          </div>

          <div
            class="pt-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4"
          >
            <div
              class="flex flex-wrap items-center gap-x-6 gap-y-2 text-sm text-text-secondary"
            >
              <div class="flex items-center gap-1.5">
                <span class="material-symbols-outlined text-primary text-lg"
                  >download</span
                >
                <span class="font-semibold text-text-primary"
                  >{(featuredKaryaObj.unduhan || 0).toLocaleString(
                    "id-ID",
                  )}</span
                > unduhan
              </div>
              <div class="flex items-center gap-1.5">
                <span
                  class="material-symbols-outlined text-status-review text-lg"
                  style="font-variation-settings: 'FILL' 1;">star</span
                >
                <span class="font-semibold text-text-primary"
                  >{featuredKaryaObj.sitasi || 0}</span
                > sitasi ilmiah
              </div>
              <div class="flex items-center gap-1.5">
                <span class="material-symbols-outlined text-secondary text-lg"
                  >verified</span
                >
                <span>Tervalidasi Resmi</span>
              </div>
            </div>

            <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 w-full sm:w-auto shrink-0">
              <button
                type="button"
                onclick={() => onOpenDetail(featuredKaryaObj)}
                class="inline-flex items-center justify-center px-4 py-2.5 rounded-xl bg-surface-muted hover:bg-surface-container-high text-text-primary font-headline-sm text-headline-sm transition-all font-semibold whitespace-nowrap"
              >
                Baca Abstrak
              </button>
              <button
                type="button"
                onclick={() => onDownloadKarya(featuredKaryaObj)}
                class="inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl bg-primary text-on-primary hover:bg-primary-container font-headline-sm text-headline-sm shadow-md transition-all active:scale-95 font-semibold whitespace-nowrap"
              >
                <span class="material-symbols-outlined text-base"
                  >download_for_offline</span
                >
                <span>Unduh PDF Lengkap</span>
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Floating badges from Stitch -->
    <div
      class="hidden md:flex absolute -left-8 -bottom-8 bg-surface-card p-4 rounded-2xl shadow-xl items-center gap-3.5 z-20 max-w-xs animate-bounce border border-border-subtle"
      style="animation-duration: 4s;"
    >
      <div
        class="w-10 h-10 rounded-full bg-status-published/15 text-status-published flex items-center justify-center shrink-0"
      >
        <span class="material-symbols-outlined text-2xl font-bold"
          >check_circle</span
        >
      </div>
      <div>
        <span
          class="font-label-badge text-label-badge text-status-published block leading-tight font-bold"
          >Kurasi Selesai &amp; Disetujui</span
        >
        <p class="font-body-sm text-body-sm text-text-primary font-semibold">
          Tesis • Terbit ke SINTA 2
        </p>
        <span class="font-label-caption text-label-caption text-text-tertiary"
          >Oleh Dr. Rina S. (Tim Reviewer)</span
        >
      </div>
    </div>

    <div
      class="hidden lg:flex flex-col absolute -right-6 -top-8 bg-surface-card p-4 rounded-2xl shadow-xl z-20 w-64 space-y-3 border border-border-subtle"
    >
      <div class="flex items-center justify-between">
        <span
          class="font-label-badge text-label-badge text-text-secondary font-semibold"
          >Statistik Triwulan</span
        >
        <span
          class="px-2 py-0.5 rounded-full bg-primary/10 text-primary font-label-caption text-label-caption font-semibold"
          >Akreditasi Unggul</span
        >
      </div>
      <div>
        <span
          class="font-label-mono-sm text-xs text-text-tertiary uppercase tracking-wider block"
          >Total Unduhan Resmi</span
        >
        <div class="flex items-baseline gap-2">
          <span
            class="font-headline-xl text-headline-xl text-primary font-extrabold tracking-tight"
            >{(totalUnduhanHero || 7200).toLocaleString("id-ID")}+</span
          >
          <span
            class="text-xs text-status-published font-semibold flex items-center"
            >↑ 34%</span
          >
        </div>
      </div>
      <div class="h-10 w-full flex items-end gap-1.5 pt-2">
        <div class="h-4 w-1/6 bg-primary/20 rounded-t-sm"></div>
        <div class="h-6 w-1/6 bg-primary/30 rounded-t-sm"></div>
        <div class="h-5 w-1/6 bg-primary/40 rounded-t-sm"></div>
        <div class="h-8 w-1/6 bg-primary/60 rounded-t-sm"></div>
        <div class="h-7 w-1/6 bg-primary/80 rounded-t-sm"></div>
        <div class="h-10 w-1/6 bg-primary rounded-t-sm"></div>
      </div>
      <p class="font-label-caption text-label-caption text-text-tertiary">
        Terintegrasi otomatis ke feeder PDDIKTI &amp; BAN-PT
      </p>
    </div>
  </div>
</section>
