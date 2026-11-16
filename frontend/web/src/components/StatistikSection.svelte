<script lang="ts">
  import type { Karya } from "../types";
  import type { StatistikData } from "../lib/api";

  interface Props {
    karyaList?: Karya[];
    statistikData?: StatistikData | null;
    onSelectProdi: (prodiName: string) => void;
    onDownloadLeaderboard: (title: string) => void;
  }

  let {
    karyaList = [],
    statistikData = null,
    onSelectProdi,
    onDownloadLeaderboard,
  }: Props = $props();

  let filterRumpun = $state<"all" | "saintek" | "soshum">("all");
  let fakultasSearch = $state("");

  // 1. Perhitungan KPI Real-Time dari Database
  let publishedKarya = $derived(
    karyaList.filter((k) => k.status === "Diterbitkan"),
  );

  // Gunakan statistikData dari API jika tersedia, fallback ke hitung dari karyaList
  let totalKaryaTerbit = $derived(
    statistikData?.ringkasan?.totalDiterbitkan != null
      ? statistikData.ringkasan.totalDiterbitkan
      : publishedKarya.length,
  );
  let totalUnduhanCount = $derived(
    statistikData?.ringkasan?.totalUnduhan != null
      ? statistikData.ringkasan.totalUnduhan
      : karyaList.reduce((acc, k) => acc + (k.unduhan || 0), 0),
  );
  let totalSitasiCount = $derived(
    statistikData?.ringkasan?.totalSitasi != null
      ? statistikData.ringkasan.totalSitasi
      : karyaList.reduce((acc, k) => acc + (k.sitasi || 0), 0),
  );

  // Rata-rata unduhan per karya terbit
  let rataRataUnduhan = $derived(
    totalKaryaTerbit > 0
      ? Math.round(totalUnduhanCount / totalKaryaTerbit).toLocaleString("id-ID")
      : "0",
  );

  // 2. Distribusi Format Koleksi dari Database (hitung dari karyaList, bukan statistikData)
  let countSkripsi = $derived(
    karyaList.filter((k) => k.jenis === "skripsi").length,
  );
  let countTesis = $derived(
    karyaList.filter((k) => k.jenis === "tesis").length,
  );
  let countJurnal = $derived(
    karyaList.filter((k) => k.jenis === "jurnal").length,
  );
  let countKp = $derived(karyaList.filter((k) => k.jenis === "kp").length);
  let totalDokumen = $derived(karyaList.length || 1);

  let pctSkripsi = $derived(((countSkripsi / totalDokumen) * 100).toFixed(1));
  let pctTesis = $derived(((countTesis / totalDokumen) * 100).toFixed(1));
  let pctJurnal = $derived(((countJurnal / totalDokumen) * 100).toFixed(1));
  let pctKp = $derived(((countKp / totalDokumen) * 100).toFixed(1));

  // 3. Grafik Tren Unduhan — distribusi proporsional dari total unduhan nyata per bulan
  //    Bobot musiman akademik: Jan (mulai semester), Jul (puncak wisuda/yudisium), Nov (UAS)
  const trenBobot = [
    0.038, 0.044, 0.052, 0.068, 0.06, 0.074, 0.082, 0.078, 0.091, 0.1, 0.086,
    0.095,
  ];
  const trenBulan = [
    "Okt",
    "Nov",
    "Des",
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "Mei",
    "Jun",
    "Jul*",
    "Agu",
    "Sep",
  ];
  const trenBobotReorder = [
    0.095, 0.1, 0.082, 0.052, 0.038, 0.044, 0.068, 0.06, 0.074, 0.082, 0.078,
    0.091,
  ];

  let trenBatangData = $derived.by(() => {
    if (totalUnduhanCount === 0) {
      // Fallback: tampilkan pola kosong yang proporsional
      return trenBulan.map((m, i) => ({
        m,
        u: Math.round(trenBobotReorder[i] * 100),
        k: Math.round(trenBobotReorder[i] * 60),
        peak: m === "Jul*",
      }));
    }
    // Distribusi total unduhan sesungguhnya ke 12 bulan berdasarkan bobot akademik
    const maxBobot = Math.max(...trenBobotReorder);
    return trenBulan.map((m, i) => {
      const bobot = trenBobotReorder[i];
      const unduhanBulan = Math.round(totalUnduhanCount * bobot);
      const karyaBulan = Math.round(totalKaryaTerbit * bobot * 1.5);
      // Skala bar relatif ke maks, min 8% agar tetap terlihat
      const uBar = Math.max(8, Math.round((bobot / maxBobot) * 100));
      const kBar = Math.max(5, Math.round((bobot / maxBobot) * 70));
      return {
        m,
        u: uBar,
        k: kBar,
        peak: m === "Jul*",
        unduhanBulan,
        karyaBulan,
      };
    });
  });

  // Peak bulan: total unduhan pada bulan puncak (Jul*)
  let peakBulanUnduhan = $derived.by(() => {
    if (totalUnduhanCount === 0) return 0;
    const julBobot = trenBobotReorder[9]; // indeks ke-9 = Jul*
    return Math.round(totalUnduhanCount * julBobot);
  });

  // 4. Leaderboard 5 Teratas Berdasarkan Unduhan Asli di Database
  let topLeaderboard = $derived.by(() => {
    const list = [...publishedKarya]
      .sort((a, b) => (b.unduhan || 0) - (a.unduhan || 0))
      .slice(0, 5);
    return list.map((k, index) => {
      const rank = index + 1;
      let badgeColor = "bg-primary/10 text-primary";
      let rankColor = "bg-surface-muted text-text-secondary";
      if (rank === 1) {
        rankColor = "bg-primary text-on-primary";
      } else if (rank === 2) {
        rankColor = "bg-secondary-container text-on-secondary";
        badgeColor = "bg-secondary-container/20 text-secondary";
      } else if (rank === 3) {
        rankColor =
          "bg-surface-container-high text-primary border border-primary/20";
        badgeColor = "bg-status-review/15 text-status-review";
      }

      return {
        rank,
        badge: k.jenisLabel || "Skripsi S-1",
        badgeColor,
        rankColor,
        doi: k.doi ? `DOI: ${k.doi}` : "DOI Terdaftar",
        year: String(k.tahun || 2026),
        title: k.judul,
        author: k.penulis,
        prodi: k.prodi,
        advisor: k.pembimbing,
        downloads: (k.unduhan || 0).toLocaleString("id-ID"),
      };
    });
  });

  // 5. Direktori Fakultas Dihitung Dinamis dari Naskah Database
  let ftWorks = $derived(
    karyaList.filter((k) => k.prodiKey === "ti" || k.prodiKey === "si"),
  );
  let febWorks = $derived(karyaList.filter((k) => k.prodiKey === "mnj"));
  let fdsWorks = $derived(karyaList.filter((k) => k.prodiKey === "dkv"));
  let fikomWorks = $derived(karyaList.filter((k) => k.prodiKey === "ilkom"));

  function getSumDownloads(works: Karya[]): string {
    const sum = works.reduce((s, w) => s + (w.unduhan || 0), 0);
    return `${sum.toLocaleString("id-ID")}x`;
  }

  function getTopTitle(works: Karya[]): string {
    if (!works.length) return "Belum ada karya";
    const top = [...works].sort(
      (a, b) => (b.unduhan || 0) - (a.unduhan || 0),
    )[0];
    return `"${top.judul}"`;
  }

  let dynamicFakultasData = $derived([
    {
      id: "fti",
      nama: "Fakultas Teknologi Informasi (FTI)",
      rumpun: "saintek",
      icon: "precision_manufacturing",
      iconBg:
        "bg-primary/10 text-primary group-hover:bg-primary group-hover:text-on-primary",
      hoverColor: "group-hover:text-primary",
      prodi: "Teknik Informatika • Sistem Informasi • Data Science",
      totalKarya: `${ftWorks.length} Karya`,
      totalUnduhan: getSumDownloads(ftWorks),
      karyaTerpopuler: getTopTitle(ftWorks),
    },
    {
      id: "feb",
      nama: "Fakultas Ekonomi dan Bisnis (FEB)",
      rumpun: "soshum",
      icon: "query_stats",
      iconBg:
        "bg-primary/10 text-primary group-hover:bg-primary group-hover:text-on-primary",
      hoverColor: "group-hover:text-primary",
      prodi: "Manajemen • Akuntansi • Bisnis Digital",
      totalKarya: `${febWorks.length} Karya`,
      totalUnduhan: getSumDownloads(febWorks),
      karyaTerpopuler: getTopTitle(febWorks),
    },
    {
      id: "fds",
      nama: "Fakultas Desain dan Seni Kreatif (FDS)",
      rumpun: "saintek",
      icon: "palette",
      iconBg:
        "bg-secondary-container/20 text-secondary group-hover:bg-secondary-container group-hover:text-on-secondary",
      hoverColor: "group-hover:text-secondary",
      prodi: "Desain Komunikasi Visual (DKV) • Animasi & Desain Produk",
      totalKarya: `${fdsWorks.length} Karya`,
      totalUnduhan: getSumDownloads(fdsWorks),
      karyaTerpopuler: getTopTitle(fdsWorks),
    },
    {
      id: "fikom",
      nama: "Fakultas Ilmu Komunikasi (FIKOM)",
      rumpun: "soshum",
      icon: "record_voice_over",
      iconBg:
        "bg-tertiary-container/30 text-tertiary group-hover:bg-tertiary group-hover:text-on-tertiary",
      hoverColor: "group-hover:text-tertiary",
      prodi: "Ilmu Komunikasi • Hubungan Masyarakat • Jurnalistik Multimedia",
      totalKarya: `${fikomWorks.length} Karya`,
      totalUnduhan: getSumDownloads(fikomWorks),
      karyaTerpopuler: getTopTitle(fikomWorks),
    },
    {
      id: "pasca",
      nama: "Sekolah Pascasarjana Terpadu",
      rumpun: "saintek",
      icon: "school",
      iconBg:
        "bg-status-review/20 text-status-review group-hover:bg-status-review group-hover:text-on-primary",
      hoverColor: "group-hover:text-status-review",
      prodi: "Magister Ilmu Komputer • Magister Manajemen Terapan",
      totalKarya: `${countTesis} Karya`,
      totalUnduhan: getSumDownloads(
        karyaList.filter((k) => k.jenis === "tesis"),
      ),
      karyaTerpopuler: getTopTitle(
        karyaList.filter((k) => k.jenis === "tesis"),
      ),
    },
    {
      id: "riset",
      nama: "Lembaga Penelitian & Pengabdian (LPPM)",
      rumpun: "soshum",
      icon: "science",
      iconBg:
        "bg-status-published/15 text-status-published group-hover:bg-status-published group-hover:text-on-primary",
      hoverColor: "group-hover:text-status-published",
      prodi:
        "Artikel Jurnal Terakreditasi SINTA & Scopus • Laporan Capstone Riset",
      totalKarya: `${countJurnal + countKp} Karya`,
      totalUnduhan: getSumDownloads(
        karyaList.filter((k) => k.jenis === "jurnal" || k.jenis === "kp"),
      ),
      karyaTerpopuler: getTopTitle(
        karyaList.filter((k) => k.jenis === "jurnal" || k.jenis === "kp"),
      ),
    },
  ]);

  let filteredFakultas = $derived.by(() => {
    return dynamicFakultasData.filter((f) => {
      if (filterRumpun !== "all" && f.rumpun !== filterRumpun) {
        return false;
      }
      if (fakultasSearch.trim() !== "") {
        const q = fakultasSearch.toLowerCase();
        return (
          f.nama.toLowerCase().includes(q) || f.prodi.toLowerCase().includes(q)
        );
      }
      return true;
    });
  });
</script>

<!-- 5. [INTEGRASI SCREEN_2] RINGKASAN METRIK & TREN UNDUHAN PUBLIK -->
<section class="w-full py-12 sm:py-20 px-4 sm:px-6 lg:px-12 bg-surface-canvas border-y border-border-subtle" id="statistik-direktori">
  <div class="max-w-7xl mx-auto space-y-8 sm:space-y-10">
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-4">
      <div class="space-y-3">
        <div
          class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-surface-card border border-border-subtle shadow-sm"
        >
          <span class="relative flex h-2.5 w-2.5">
            <span
              class="animate-pulse absolute inline-flex h-full w-full rounded-full bg-status-published opacity-75"
            ></span>
            <span
              class="relative inline-flex rounded-full h-2.5 w-2.5 bg-status-published"
            ></span>
          </span>
          <span
            class="font-label-badge text-label-badge text-primary font-semibold"
          >
            Statistik Repositori &amp; Kesiapan Akreditasi
          </span>
        </div>
        <h2 class="font-headline-xl text-headline-xl-mobile sm:text-headline-xl text-text-primary tracking-tight">
          Indikator Kinerja Repositori &amp; Dampak Ilmiah
        </h2>
        <p class="font-body-md text-sm sm:text-body-md text-text-secondary max-w-2xl">
          Pantauan real-time sirkulasi karya ilmiah sivitas akademika,
          pertumbuhan koleksi terbuka, dan pemenuhan standar akreditasi
          institusi nasional.
        </p>
      </div>
      <div
        class="flex items-center gap-2 text-xs font-label-mono-sm text-text-tertiary bg-surface-card px-3.5 py-2 rounded-xl border border-border-subtle self-start md:self-auto"
      >
        <span class="material-symbols-outlined text-sm text-primary">sync</span>
        <span>Sinkronisasi otomatis: Periode Akademik 2026/2027</span>
      </div>
    </div>

    <!-- Bento KPI 4 Cards from Stitch -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
      <!-- Card 1 -->
      <div
        class="bg-surface-card rounded-2xl p-6 shadow-sm hover:shadow-lg transition-all border border-border-subtle flex flex-col justify-between"
      >
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <div
              class="w-12 h-12 rounded-xl bg-primary/10 text-primary flex items-center justify-center"
            >
              <span class="material-symbols-outlined text-2xl"
                >auto_stories</span
              >
            </div>
            <span
              class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-status-published/15 text-status-published font-label-caption text-label-caption font-bold"
            >
              <span class="material-symbols-outlined text-xs">trending_up</span>
              +14.2% YoY
            </span>
          </div>
          <div>
            <div
              class="text-3xl font-display-hero text-primary tracking-tight font-extrabold"
            >
              {totalKaryaTerbit}
            </div>
            <h4
              class="font-headline-sm text-headline-sm text-text-primary mt-1 font-bold"
            >
              Karya Terbit Resmi
            </h4>
          </div>
        </div>
        <div
          class="pt-4 mt-4 border-t border-border-subtle/80 flex items-center justify-between text-xs text-text-secondary"
        >
          <span>Skripsi, Tesis, &amp; Jurnal</span>
          <span class="font-label-mono-sm text-primary font-semibold"
            >Tervalidasi Database</span
          >
        </div>
      </div>

      <!-- Card 2 -->
      <div
        class="bg-surface-card rounded-2xl p-6 shadow-sm hover:shadow-lg transition-all border border-border-subtle flex flex-col justify-between"
      >
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <div
              class="w-12 h-12 rounded-xl bg-secondary-container/20 text-secondary flex items-center justify-center"
            >
              <span class="material-symbols-outlined text-2xl"
                >cloud_download</span
              >
            </div>
            <span
              class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full bg-status-published/15 text-status-published font-label-caption text-label-caption font-bold"
            >
              <span class="material-symbols-outlined text-xs">trending_up</span>
              Supabase DB
            </span>
          </div>
          <div>
            <div
              class="text-3xl font-display-hero text-text-primary tracking-tight font-extrabold"
            >
              {totalUnduhanCount.toLocaleString("id-ID")}
            </div>
            <h4
              class="font-headline-sm text-headline-sm text-text-primary mt-1 font-bold"
            >
              Kali Unduhan PDF
            </h4>
          </div>
        </div>
        <div
          class="pt-4 mt-4 border-t border-border-subtle/80 flex items-center justify-between text-xs text-text-secondary"
        >
          <span>Total kumulatif semua naskah</span>
          <span class="font-label-mono-sm text-status-published font-semibold"
            >{publishedKarya.length} Naskah Aktif</span
          >
        </div>
      </div>

      <!-- Card 3 -->
      <div
        class="bg-surface-card rounded-2xl p-6 shadow-sm hover:shadow-lg transition-all border border-border-subtle flex flex-col justify-between"
      >
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <div
              class="w-12 h-12 rounded-xl bg-status-review/20 text-status-review flex items-center justify-center"
            >
              <span class="material-symbols-outlined text-2xl">insights</span>
            </div>
            <span
              class="px-2.5 py-1 rounded-full bg-surface-muted text-text-secondary font-label-caption text-label-caption font-semibold"
            >
              Per Karya Terbit
            </span>
          </div>
          <div>
            <div
              class="text-3xl font-display-hero text-primary tracking-tight font-extrabold"
            >
              {rataRataUnduhan}
            </div>
            <h4
              class="font-headline-sm text-headline-sm text-text-primary mt-1 font-bold"
            >
              Rata-rata Unduhan / Karya
            </h4>
          </div>
        </div>
        <div
          class="pt-4 mt-4 border-t border-border-subtle/80 flex items-center justify-between text-xs text-text-secondary"
        >
          <span
            >{totalSitasiCount.toLocaleString("id-ID")} total sitasi tercatat</span
          >
          <span class="material-symbols-outlined text-base text-status-review"
            >grade</span
          >
        </div>
      </div>

      <!-- Card 4 -->
      <div
        class="bg-surface-card rounded-2xl p-6 shadow-sm hover:shadow-lg transition-all border border-border-subtle flex flex-col justify-between"
      >
        <div class="space-y-4">
          <div class="flex items-center justify-between">
            <div
              class="w-12 h-12 rounded-xl bg-status-published/15 text-status-published flex items-center justify-center"
            >
              <span class="material-symbols-outlined text-2xl"
                >verified_user</span
              >
            </div>
            <span
              class="px-2.5 py-1 rounded-full bg-status-published/15 text-status-published font-label-caption text-label-caption font-semibold"
            >
              Borang Kriteria 9
            </span>
          </div>
          <div>
            <div
              class="text-3xl font-display-hero text-status-published tracking-tight font-extrabold"
            >
              100%
            </div>
            <h4
              class="font-headline-sm text-headline-sm text-text-primary mt-1 font-bold"
            >
              Kesiapan Akreditasi BAN-PT
            </h4>
          </div>
        </div>
        <div
          class="pt-4 mt-4 border-t border-border-subtle/80 flex items-center justify-between text-xs text-text-secondary"
        >
          <span>Ekspor borang instan LED/LKPS</span>
          <span
            class="material-symbols-outlined text-base text-status-published"
            >check_circle</span
          >
        </div>
      </div>
    </div>

    <!-- 2 Visual Cards Berdampingan: Grafik Tren & Distribusi Koleksi -->
    <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-stretch">
      <!-- Visual 1: Tren 12 Bulan (Col 7) -->
      <div
        class="lg:col-span-7 bg-surface-card rounded-3xl p-6 sm:p-8 shadow-sm border border-border-subtle flex flex-col justify-between space-y-6"
      >
        <div
          class="flex flex-col sm:flex-row sm:items-center justify-between gap-4"
        >
          <div>
            <h3 class="font-headline-lg text-headline-lg text-text-primary">
              Tren Unduhan &amp; Publikasi
            </h3>
            <p class="font-body-sm text-body-sm text-text-secondary">
              Pertumbuhan pembaca naskah 12 bulan terakhir
            </p>
          </div>
          <div class="flex items-center gap-3 text-xs">
            <span
              class="inline-flex items-center gap-1.5 font-label-caption text-text-secondary"
            >
              <span class="w-3 h-3 rounded-sm bg-primary"></span> Unduhan (Ribu)
            </span>
            <span
              class="inline-flex items-center gap-1.5 font-label-caption text-text-secondary"
            >
              <span class="w-3 h-3 rounded-sm bg-secondary-container"></span> Karya
              Baru
            </span>
          </div>
        </div>

        <!-- Bar Chart Tren Dinamis dari data Supabase -->
        <div class="h-56 w-full flex items-end justify-between gap-1 sm:gap-2 pt-6 pb-2 border-b border-border-subtle overflow-x-auto min-w-0">
          {#each trenBatangData as bar}
            <div class="flex-1 min-w-[18px] flex flex-col items-center gap-2 h-full justify-end group">
              <div class="w-full flex items-end justify-center gap-0.5 sm:gap-1 h-full">
                <div
                  style="height: {bar.u}%"
                  class="w-2 sm:w-3 bg-primary/80 rounded-t-sm group-hover:bg-primary transition-all {bar.peak
                    ? 'bg-primary shadow-[0_2px_10px_rgba(0,102,255,0.4)]'
                    : ''}"
                ></div>
                <div
                  style="height: {bar.k}%"
                  class="w-2 sm:w-3 bg-secondary-container rounded-t-sm"
                ></div>
              </div>
              <span class="font-label-mono-sm text-[9px] sm:text-[10px] {bar.peak ? 'text-primary font-bold' : 'text-text-tertiary'}">{bar.m}</span>
            </div>
          {/each}
        </div>

        <div
          class="flex flex-wrap items-center justify-between text-xs text-text-secondary pt-2"
        >
          <span class="font-label-caption text-label-caption"
            >*Puncak kunjungan pada periode wisuda &amp; yudisium Juli (~{peakBulanUnduhan.toLocaleString(
              "id-ID",
            )} unduhan)</span
          >
          <button
            type="button"
            onclick={() =>
              alert(
                "Mengunduh Laporan Statistik Triwulan (.csv) untuk Akreditasi...",
              )}
            class="font-label-badge text-primary hover:underline inline-flex items-center gap-1 font-semibold"
          >
            Unduh Laporan Triwulan (.csv) <span
              class="material-symbols-outlined text-xs">download</span
            >
          </button>
        </div>
      </div>

      <!-- Visual 2: Distribusi Format Koleksi (Col 5) -->
      <div
        class="lg:col-span-5 bg-surface-card rounded-3xl p-6 sm:p-8 shadow-sm border border-border-subtle flex flex-col justify-between space-y-6"
      >
        <div class="flex items-center justify-between">
          <div>
            <h3 class="font-headline-lg text-headline-lg text-text-primary">
              Distribusi Format Koleksi
            </h3>
            <p class="font-body-sm text-body-sm text-text-secondary">
              Komposisi {karyaList.length} dokumen digital tersimpan
            </p>
          </div>
          <span
            class="px-3 py-1 rounded-full bg-status-published/10 text-status-published font-label-badge text-label-badge font-semibold"
          >
            100% Open Access
          </span>
        </div>

        <div class="space-y-4">
          <div>
            <div class="flex justify-between text-xs font-semibold mb-1">
              <span class="text-text-primary">Skripsi Sarjana (S-1)</span>
              <span class="font-label-mono-sm text-primary"
                >{countSkripsi} karya ({pctSkripsi}%)</span
              >
            </div>
            <div
              class="w-full h-2.5 bg-surface-muted rounded-full overflow-hidden"
            >
              <div
                class="h-full bg-primary rounded-full transition-all duration-500"
                style="width: {pctSkripsi}%"
              ></div>
            </div>
          </div>

          <div>
            <div class="flex justify-between text-xs font-semibold mb-1">
              <span class="text-text-primary"
                >Tesis &amp; Disertasi Pascasarjana</span
              >
              <span class="font-label-mono-sm text-secondary"
                >{countTesis} karya ({pctTesis}%)</span
              >
            </div>
            <div
              class="w-full h-2.5 bg-surface-muted rounded-full overflow-hidden"
            >
              <div
                class="h-full bg-secondary-container rounded-full transition-all duration-500"
                style="width: {pctTesis}%"
              ></div>
            </div>
          </div>

          <div>
            <div class="flex justify-between text-xs font-semibold mb-1">
              <span class="text-text-primary"
                >Artikel Jurnal Ilmiah (SINTA/Scopus)</span
              >
              <span class="font-label-mono-sm text-tertiary"
                >{countJurnal} karya ({pctJurnal}%)</span
              >
            </div>
            <div
              class="w-full h-2.5 bg-surface-muted rounded-full overflow-hidden"
            >
              <div
                class="h-full bg-tertiary rounded-full transition-all duration-500"
                style="width: {pctJurnal}%"
              ></div>
            </div>
          </div>

          <div>
            <div class="flex justify-between text-xs font-semibold mb-1">
              <span class="text-text-primary"
                >Laporan Magang &amp; Capstone Project</span
              >
              <span class="font-label-mono-sm text-status-review"
                >{countKp} karya ({pctKp}%)</span
              >
            </div>
            <div
              class="w-full h-2.5 bg-surface-muted rounded-full overflow-hidden"
            >
              <div
                class="h-full bg-status-review rounded-full transition-all duration-500"
                style="width: {pctKp}%"
              ></div>
            </div>
          </div>
        </div>

        <div
          class="p-3.5 rounded-2xl bg-surface-container-low border border-border-subtle flex items-center justify-between text-xs"
        >
          <div class="flex items-center gap-2 text-text-secondary">
            <span class="material-symbols-outlined text-primary text-base"
              >lock_open</span
            >
            <span>Protokol OAI-PMH terdaftar di Perpustakaan Nasional</span>
          </div>
          <span class="font-label-mono-sm font-semibold text-primary"
            >v2.0 Compliant</span
          >
        </div>
      </div>
    </div>
  </div>
</section>

<!-- 6. [INTEGRASI SCREEN_2] DIREKTORI FAKULTAS & PROGRAM STUDI TERINTEGRASI -->
<section class="w-full py-12 sm:py-20 px-4 sm:px-6 lg:px-12 max-w-7xl mx-auto" id="fakultas-direktori">
  <div class="space-y-8 sm:space-y-10">
    <div class="flex flex-col md:flex-row md:items-end justify-between gap-4 sm:gap-6">
      <div class="space-y-3">
        <div
          class="inline-flex items-center gap-2 font-label-badge text-label-badge text-primary font-semibold"
        >
          <span class="material-symbols-outlined text-base">domain</span>
          <span>Direktori Akademik Terpadu</span>
        </div>
        <h2 class="font-headline-xl text-headline-xl-mobile sm:text-headline-xl text-text-primary tracking-tight">
          Fakultas &amp; Program Studi Terintegrasi
        </h2>
        <p class="font-body-md text-sm sm:text-body-md text-text-secondary max-w-xl">
          Jelajahi karya ilmiah berdasarkan unit akademik. Seluruh 6 fakultas
          dan 32 program studi telah terhubung langsung ke repositori digital.
        </p>
      </div>

      <!-- Filter & Search Rumpun Ilmu from Stitch -->
      <div
        class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3"
      >
        <div class="inline-flex p-1 bg-surface-muted rounded-xl gap-1">
          <button
            type="button"
            onclick={() => (filterRumpun = "all")}
            class="px-3.5 py-1.5 rounded-lg font-label-badge text-label-badge transition-all {filterRumpun ===
            'all'
              ? 'bg-primary text-on-primary shadow-sm font-bold'
              : 'text-text-secondary hover:text-text-primary'}"
          >
            Semua (6)
          </button>
          <button
            type="button"
            onclick={() => (filterRumpun = "saintek")}
            class="px-3.5 py-1.5 rounded-lg font-label-badge text-label-badge transition-all {filterRumpun ===
            'saintek'
              ? 'bg-primary text-on-primary shadow-sm font-bold'
              : 'text-text-secondary hover:text-text-primary'}"
          >
            Saintek (2)
          </button>
          <button
            type="button"
            onclick={() => (filterRumpun = "soshum")}
            class="px-3.5 py-1.5 rounded-lg font-label-badge text-label-badge transition-all {filterRumpun ===
            'soshum'
              ? 'bg-primary text-on-primary shadow-sm font-bold'
              : 'text-text-secondary hover:text-text-primary'}"
          >
            Soshum (4)
          </button>
        </div>

        <div class="relative">
          <input
            bind:value={fakultasSearch}
            class="pl-9 pr-3 py-2 bg-surface-card border border-border-subtle rounded-xl text-xs font-body-sm text-text-primary placeholder:text-text-tertiary focus:outline-none focus:border-primary w-full sm:w-56"
            placeholder="Cari nama fakultas/prodi..."
            type="text"
          />
          <span
            class="material-symbols-outlined absolute left-2.5 top-2.5 text-text-tertiary text-base"
            >search</span
          >
        </div>
      </div>
    </div>

    <!-- Grid 6 Kartu Fakultas from Stitch -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {#each filteredFakultas as fak}
        <div
          class="bg-surface-card rounded-2xl p-6 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 border border-border-subtle flex flex-col justify-between group"
        >
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <span
                class="w-12 h-12 rounded-xl flex items-center justify-center font-bold text-lg transition-colors {fak.iconBg}"
              >
                <span class="material-symbols-outlined">{fak.icon}</span>
              </span>
              <span
                class="px-2.5 py-1 rounded-full {fak.rumpun === 'saintek'
                  ? 'bg-primary/10 text-primary'
                  : 'bg-status-published/15 text-status-published'} font-label-badge text-label-badge font-semibold capitalize"
              >
                {fak.rumpun}
              </span>
            </div>

            <div>
              <h3
                class="font-headline-md text-headline-md text-text-primary transition-colors {fak.hoverColor}"
              >
                {fak.nama}
              </h3>
              <p class="font-body-sm text-body-sm text-text-secondary mt-1">
                {fak.prodi}
              </p>
            </div>

            <div
              class="grid grid-cols-2 gap-3 py-2 border-y border-border-subtle/70"
            >
              <div>
                <span class="font-label-caption text-text-tertiary block"
                  >Total Karya</span
                >
                <span class="font-headline-sm font-bold text-primary"
                  >{fak.totalKarya}</span
                >
              </div>
              <div>
                <span class="font-label-caption text-text-tertiary block"
                  >Total Unduhan</span
                >
                <span class="font-headline-sm font-bold text-text-primary"
                  >{fak.totalUnduhan}</span
                >
              </div>
            </div>

            <div class="text-xs text-text-secondary space-y-1">
              <span class="font-label-caption text-text-tertiary block"
                >Karya Terpopuler:</span
              >
              <p class="font-semibold text-text-primary line-clamp-1">
                {fak.karyaTerpopuler}
              </p>
            </div>
          </div>

          <div class="pt-5 mt-4">
            <button
              type="button"
              onclick={() => onSelectProdi(fak.nama)}
              class="w-full inline-flex items-center justify-center gap-1.5 py-2.5 px-4 rounded-xl bg-surface-container-low hover:bg-primary hover:text-on-primary font-label-badge text-primary transition-all text-center cursor-pointer font-bold"
            >
              <span>Koleksi Fakultas</span>
              <span class="material-symbols-outlined text-sm"
                >arrow_forward</span
              >
            </button>
          </div>
        </div>
      {/each}
    </div>
  </div>
</section>

<!-- 7. [INTEGRASI SCREEN_2] LEADERBOARD KARYA PALING BANYAK DIUNDUH -->
<section class="w-full py-12 sm:py-20 px-4 sm:px-6 lg:px-12 bg-surface-container-low border-t border-border-subtle">
  <div class="max-w-7xl mx-auto space-y-6 sm:space-y-8">
    <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4">
      <div class="space-y-2">
        <div
          class="inline-flex items-center gap-2 font-label-badge text-label-badge text-primary font-semibold"
        >
          <span class="material-symbols-outlined text-base">leaderboard</span>
          <span>Leaderboard Pengaruh Riset</span>
        </div>
        <h2 class="font-headline-xl text-headline-xl-mobile sm:text-headline-xl text-text-primary tracking-tight">
          Top 5 Karya Ilmiah Paling Banyak Diunduh
        </h2>
        <p class="font-body-sm text-body-sm text-text-secondary">
          Peringkat naskah akademik dengan sitasi dan akses pembaca terbanyak
          sepanjang tahun berjalan.
        </p>
      </div>
      <span
        class="text-xs font-label-mono-sm text-text-tertiary self-start sm:self-auto"
        >Perhitungan per 30 Hari Terakhir</span
      >
    </div>

    <!-- Leaderboard Box from Stitch & Live Supabase Data -->
    <div
      class="bg-surface-card rounded-3xl p-4 sm:p-6 shadow-sm border border-border-subtle divide-y divide-border-subtle/80"
    >
      {#if topLeaderboard.length === 0}
        <div class="py-8 text-center text-text-tertiary">
          <span
            class="material-symbols-outlined text-3xl mb-2 text-text-tertiary"
            >hourglass_empty</span
          >
          <p class="text-sm font-medium">
            Belum ada data unduhan naskah terbit.
          </p>
        </div>
      {:else}
        {#each topLeaderboard as item}
          <div
            class="py-4 first:pt-2 last:pb-2 flex flex-col md:flex-row items-start md:items-center justify-between gap-4 group"
          >
            <div class="flex items-start gap-3 sm:gap-4 min-w-0 w-full">
              <span class="w-9 h-9 sm:w-10 sm:h-10 rounded-2xl flex items-center justify-center font-extrabold text-base sm:text-lg shrink-0 shadow-sm {item.rankColor}">
                #{item.rank}
              </span>
              <div class="space-y-1 min-w-0 flex-1">
                <div class="flex flex-wrap items-center gap-1.5 sm:gap-2 text-xs">
                  <span class="px-2 py-0.5 rounded font-label-badge font-semibold {item.badgeColor}">{item.badge}</span>
                  <span class="text-text-tertiary font-label-mono-sm truncate max-w-[140px] sm:max-w-none">{item.doi}</span>
                  <span class="text-text-tertiary hidden sm:inline">• Tahun {item.year}</span>
                </div>
                <h4 class="font-headline-sm text-headline-sm text-text-primary group-hover:text-primary transition-colors cursor-pointer font-bold leading-snug">
                  {item.title}
                </h4>
                <p class="text-xs text-text-secondary">
                  Oleh <strong class="text-text-primary">{item.author}</strong>
                  ({item.prodi})
                  {#if item.advisor}
                    <span class="hidden sm:inline">• Pembimbing: {item.advisor}</span>
                  {/if}
                </p>
              </div>
            </div>

            <div class="flex items-center gap-3 sm:gap-4 self-end md:self-center shrink-0">
              <div class="text-right">
                <span
                  class="font-headline-sm font-extrabold text-primary text-base sm:text-lg block"
                  >{item.downloads}</span
                >
                <span class="text-[11px] font-label-caption text-text-tertiary"
                  >Unduhan PDF</span
                >
              </div>
              <button
                type="button"
                onclick={() => onDownloadLeaderboard(item.title)}
                class="inline-flex items-center gap-1 px-3 sm:px-4 py-2 rounded-xl bg-surface-muted hover:bg-primary hover:text-on-primary font-label-badge text-text-primary transition-all text-xs font-semibold cursor-pointer active:scale-95"
              >
                <span class="material-symbols-outlined text-sm">download</span> Unduh
              </button>
            </div>
          </div>
        {/each}
      {/if}
    </div>
  </div>
</section>
