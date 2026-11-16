<script lang="ts">
  interface Props {
    onOpenUpload: () => void;
    onOpenPanduanModal?: () => void;
  }

  let { onOpenUpload }: Props = $props();

  let activeTab = $state<'persyaratan' | 'langkah' | 'format' | 'alur' | 'faq'>('persyaratan');
  let openFaq = $state<number | null>(0);

  const guideTabs = [
    { id: 'persyaratan', label: 'Persyaratan Dokumen', icon: 'checklist' },
    { id: 'langkah',     label: '5 Langkah Unggah',    icon: 'stairs' },
    { id: 'format',      label: 'Format & Metadata',   icon: 'description' },
    { id: 'alur',        label: 'Alur Cek Kurator',    icon: 'rate_review' },
    { id: 'faq',         label: 'Tanya Jawab (FAQ)',   icon: 'help' }
  ] as const;

  const faqList = [
    {
      q: 'Berapa lama proses verifikasi naskah oleh kurator perpustakaan?',
      a: 'Pemeriksaan naskah oleh tim kurator perpustakaan kampus dilakukan maksimal 3 × 24 jam kerja. Rata-rata waktu verifikasi saat ini adalah 18 jam kerja sejak berkas diajukan.'
    },
    {
      q: 'Bagaimana jika skor similarity Turnitin saya di atas 20%?',
      a: 'Naskah akan dikembalikan dengan status "Perlu Revisi" disertai catatan khusus pada bagian paragraf yang perlu diparafrase. Mahasiswa dapat mengunggah perbaikan naskah di menu Revisi tanpa biaya tambahan.'
    },
    {
      q: 'Format file apa saja yang diterima oleh repositori?',
      a: 'Hanya berkas berformat PDF tunggal (standar PDF/A) dengan ukuran maksimal 20 MB. Lembar pengesahan dewan penguji yang telah bertanda tangan/TTE wajib digabungkan menjadi satu file PDF utuh.'
    },
    {
      q: 'Bagaimana cara memperoleh Surat Keterangan Bebas Pustaka?',
      a: 'Setelah status naskah dinyatakan "Diterbitkan", tombol "Unduh Surat Bebas Pustaka" otomatis aktif di dashboard penulis Anda untuk keperluan yudisium dan kelulusan.'
    },
    {
      q: 'Apakah naskah saya langsung dapat diakses publik setelah disetujui?',
      a: 'Ya, karya ilmiah Anda langsung tampil di etalase direktori publik dan terindeks melalui protokol OAI-PMH untuk Google Scholar, Garuda Dikti, dan sistem akreditasi nasional.'
    }
  ];

  function handleExportBorang() {
    alert('Mengekspor tabel data borang akreditasi Kriteria 9 (Publikasi Mahasiswa & Sitasi Ilmiah) dalam format Excel (.xlsx)...');
  }

  function handleDownloadTemplate() {
    alert('Mengunduh paket template naskah skripsi resmi (Word .docx & LaTeX .tex)...');
  }
</script>

<!-- 9. PANDUAN LENGKAP UNGGAH & SOLUSI BORANG AKREDITASI KRITERIA 9 (MERGED SECTION) -->
<section class="w-full py-20 px-6 lg:px-12 max-w-7xl mx-auto space-y-12" id="panduan">

  <!-- Header Judul Section -->
  <div class="text-center max-w-3xl mx-auto space-y-4">
    <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-primary/10 text-primary border border-primary/20 shadow-sm">
      <span class="material-symbols-outlined text-sm">menu_book</span>
      <span class="font-label-badge text-label-badge font-semibold">
        Panduan Resmi Repositori Institusi Periode 2026/2027
      </span>
    </div>

    <h2 class="font-headline-xl text-3xl sm:text-4xl text-text-primary tracking-tight font-extrabold font-display-hero">
      Panduan Lengkap Unggah Karya &amp; Bebas Pustaka
    </h2>

    <p class="font-body-md text-base text-text-secondary leading-relaxed">
      Petunjuk komprehensif bagi mahasiswa untuk pemenuhan syarat kelulusan yudisium, format naskah standar, serta kesiapan data borang akreditasi Kriteria 9 bagi pimpinan fakultas.
    </p>
  </div>

  <!-- Interactive Tabs Navigation for Guide -->
  <div class="bg-surface-card rounded-3xl p-6 sm:p-8 shadow-sm border border-border-subtle space-y-8">
    <!-- Tab Pill Buttons -->
    <div class="flex items-center gap-2 overflow-x-auto pb-2 border-b border-border-subtle scrollbar-none">
      {#each guideTabs as tab}
        <button
          type="button"
          onclick={() => activeTab = tab.id}
          class="shrink-0 flex items-center gap-2 px-4 py-2.5 rounded-xl font-semibold text-xs sm:text-sm transition-all cursor-pointer {activeTab === tab.id ? 'bg-primary text-white shadow-sm font-bold' : 'text-text-secondary hover:text-text-primary hover:bg-surface-muted'}"
        >
          <span class="material-symbols-outlined text-lg">{tab.icon}</span>
          <span>{tab.label}</span>
        </button>
      {/each}
    </div>

    <!-- Tab 1: Persyaratan Dokumen -->
    {#if activeTab === 'persyaratan'}
      <div class="space-y-6 animate-fadeIn">
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-border-subtle pb-4">
          <div>
            <h3 class="font-headline-lg text-lg font-bold text-text-primary">Persyaratan Berkas Dokumen</h3>
            <p class="text-xs sm:text-sm text-text-secondary mt-0.5">Pastikan 4 syarat berkas berikut terpenuhi sebelum mengajukan ke antrean kurator.</p>
          </div>
          <span class="inline-flex items-center gap-1.5 text-xs text-status-published font-semibold bg-status-published/10 px-3 py-1.5 rounded-xl self-start sm:self-auto">
            <span class="material-symbols-outlined text-sm">verified_user</span> Wajib Lengkap
          </span>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div class="p-5 rounded-2xl bg-surface-muted/60 border border-border-subtle space-y-2.5 hover:border-primary/40 transition-colors">
            <div class="w-10 h-10 rounded-xl bg-primary/10 text-primary flex items-center justify-center">
              <span class="material-symbols-outlined text-xl">picture_as_pdf</span>
            </div>
            <h4 class="font-bold text-sm sm:text-base text-text-primary">Format Dokumen PDF/A Standar</h4>
            <p class="text-xs text-text-secondary leading-relaxed">
              Naskah wajib berformat PDF tunggal standar PDF/A untuk pengarsipan digital jangka panjang dengan ukuran berkas maksimal 20 MB.
            </p>
          </div>

          <div class="p-5 rounded-2xl bg-surface-muted/60 border border-border-subtle space-y-2.5 hover:border-status-published/40 transition-colors">
            <div class="w-10 h-10 rounded-xl bg-status-published/15 text-status-published flex items-center justify-center">
              <span class="material-symbols-outlined text-xl">verified</span>
            </div>
            <h4 class="font-bold text-sm sm:text-base text-text-primary">Lembar Pengesahan Sah &amp; Bertandatangan</h4>
            <p class="text-xs text-text-secondary leading-relaxed">
              Telah ditandatangani dewan penguji dan ketua program studi, lengkap dengan stempel fakultas atau TTE (Tanda Tangan Elektronik) terverifikasi.
            </p>
          </div>

          <div class="p-5 rounded-2xl bg-surface-muted/60 border border-border-subtle space-y-2.5 hover:border-status-review/40 transition-colors">
            <div class="w-10 h-10 rounded-xl bg-status-review/15 text-status-review flex items-center justify-center">
              <span class="material-symbols-outlined text-xl">fact_check</span>
            </div>
            <h4 class="font-bold text-sm sm:text-base text-text-primary">Bebas Plagiarisme Turnitin (&le; 20%)</h4>
            <p class="text-xs text-text-secondary leading-relaxed">
              Hasil uji Turnitin tidak boleh melebihi batas 20% similarity score (pengecualian: daftar pustaka dan lampiran kuesioner mentah).
            </p>
          </div>

          <div class="p-5 rounded-2xl bg-surface-muted/60 border border-border-subtle space-y-2.5 hover:border-secondary/40 transition-colors">
            <div class="w-10 h-10 rounded-xl bg-secondary-container/20 text-secondary flex items-center justify-center">
              <span class="material-symbols-outlined text-xl">translate</span>
            </div>
            <h4 class="font-bold text-sm sm:text-base text-text-primary">Abstrak Dwibahasa &amp; Kata Kunci</h4>
            <p class="text-xs text-text-secondary leading-relaxed">
              Menyertakan abstrak Bahasa Indonesia (200-250 kata) dan Bahasa Inggris (Abstract), lengkap dengan 3-5 kata kunci relevan.
            </p>
          </div>
        </div>
      </div>

    <!-- Tab 2: 5 Langkah Unggah -->
    {:else if activeTab === 'langkah'}
      <div class="space-y-6 animate-fadeIn">
        <div class="border-b border-border-subtle pb-4">
          <h3 class="font-headline-lg text-lg font-bold text-text-primary">5 Langkah Pengunggahan Karya Ilmiah</h3>
          <p class="text-xs sm:text-sm text-text-secondary mt-0.5">Ikuti panduan langkah demi langkah untuk proses verifikasi yang cepat dan bebas revisi.</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-5 gap-4">
          {#each [
            { no: '1', title: 'Login Akun Kampus', desc: 'Masuk dengan email resmi @campus.ac.id atau NIM mahasiswa aktif.', icon: 'login' },
            { no: '2', title: 'Isi Metadata', desc: 'Lengkapi judul skripsi, pembimbing, prodi, tahun, dan abstrak dwibahasa.', icon: 'edit_note' },
            { no: '3', title: 'Unggah File PDF', desc: 'Pilih file PDF skripsi tunggal yang telah digabung dari cover hingga lampiran (maks 20 MB).', icon: 'upload_file' },
            { no: '4', title: 'Verifikasi Kurator', desc: 'Tim kurator perpustakaan memeriksa lembar sah & Turnitin dalam 18 jam kerja.', icon: 'schedule' },
            { no: '5', title: 'Terbit & Bebas Pustaka', desc: 'Karya terbit di repositori publik dan surat bebas pustaka langsung aktif.', icon: 'workspace_premium' }
          ] as step}
            <div class="p-4 rounded-2xl bg-surface-muted/50 border border-border-subtle flex flex-col justify-between space-y-3">
              <div class="space-y-2">
                <div class="flex items-center justify-between">
                  <span class="w-8 h-8 rounded-xl bg-primary text-white font-bold flex items-center justify-center text-sm shadow-sm">
                    {step.no}
                  </span>
                  <span class="material-symbols-outlined text-text-tertiary text-xl">{step.icon}</span>
                </div>
                <h4 class="font-bold text-sm text-text-primary">{step.title}</h4>
                <p class="text-xs text-text-secondary leading-relaxed">{step.desc}</p>
              </div>
            </div>
          {/each}
        </div>
      </div>

    <!-- Tab 3: Format & Metadata -->
    {:else if activeTab === 'format'}
      <div class="space-y-6 animate-fadeIn">
        <div class="border-b border-border-subtle pb-4">
          <h3 class="font-headline-lg text-lg font-bold text-text-primary">Standar Penamaan Berkas &amp; Format Sitasi</h3>
          <p class="text-xs sm:text-sm text-text-secondary mt-0.5">Struktur berkas dan gaya sitasi wajib mengikuti ketentuan repositori institusi.</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div class="p-5 rounded-2xl bg-slate-50 border border-border-subtle space-y-3">
            <span class="text-xs font-bold text-text-tertiary uppercase tracking-wider block">Standar Penamaan File PDF:</span>
            <code class="px-3.5 py-2.5 rounded-xl bg-white border border-border-subtle font-mono text-primary font-bold block text-xs sm:text-sm shadow-sm">
              [TAHUN]_[JENIS]_[NIM]_[NAMA_LENGKAP].pdf
            </code>
            <p class="text-xs text-text-secondary">
              <strong>Contoh:</strong> <span class="font-mono text-slate-700">2026_SKRIPSI_2110512034_Amanda_Putri_Wibowo.pdf</span>
            </p>
            <p class="text-[11px] text-text-tertiary">
              Gunakan huruf kapital untuk jenis naskah dan garis bawah (_) sebagai pemisah antar elemen.
            </p>
          </div>

          <div class="p-5 rounded-2xl bg-slate-50 border border-border-subtle space-y-3">
            <span class="text-xs font-bold text-text-tertiary uppercase tracking-wider block">Format Sitasi yang Digunakan:</span>
            <div class="space-y-2 text-xs">
              <div class="p-3 bg-white rounded-xl border border-border-subtle">
                <strong class="text-primary font-bold">IEEE Style (Numerik)</strong>
                <p class="text-text-secondary text-[11px] mt-0.5">Standar wajib rumpun Fakultas Teknik dan Fakultas Ilmu Komputer.</p>
              </div>
              <div class="p-3 bg-white rounded-xl border border-border-subtle">
                <strong class="text-primary font-bold">APA 7th Edition (Author-Date)</strong>
                <p class="text-text-secondary text-[11px] mt-0.5">Standar wajib rumpun Ekonomi Bisnis, FKIP, FISIP, dan Hukum.</p>
              </div>
            </div>
          </div>
        </div>
      </div>

    <!-- Tab 4: Alur Cek Kurator -->
    {:else if activeTab === 'alur'}
      <div class="space-y-6 animate-fadeIn">
        <div class="border-b border-border-subtle pb-4">
          <h3 class="font-headline-lg text-lg font-bold text-text-primary">Status Penilaian Kurator &amp; Tindak Lanjut</h3>
          <p class="text-xs sm:text-sm text-text-secondary mt-0.5">Transparansi setiap status yang akan Anda terima di dashboard secara real-time.</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div class="p-5 rounded-2xl border border-status-published/30 bg-status-published/5 space-y-2.5">
            <div class="flex items-center gap-2 text-status-published font-bold text-sm">
              <span class="material-symbols-outlined">verified</span>
              <span>Diterbitkan</span>
            </div>
            <p class="text-xs text-text-secondary leading-relaxed">
              Berkas memenuhi semua kriteria akademik dan format. Surat bebas pustaka langsung terbit dan berkas terindeks publik secara otomatis.
            </p>
          </div>

          <div class="p-5 rounded-2xl border border-status-revision/30 bg-status-revision/5 space-y-2.5">
            <div class="flex items-center gap-2 text-status-revision font-bold text-sm">
              <span class="material-symbols-outlined">edit_note</span>
              <span>Perlu Revisi</span>
            </div>
            <p class="text-xs text-text-secondary leading-relaxed">
              Terdapat kekurangan minor (misal stempel kurang jelas atau abstrak kurang kata kunci). Buka tombol Revisi untuk mengunggah naskah perbaikan.
            </p>
          </div>

          <div class="p-5 rounded-2xl border border-status-rejected/30 bg-status-rejected/5 space-y-2.5">
            <div class="flex items-center gap-2 text-status-rejected font-bold text-sm">
              <span class="material-symbols-outlined">cancel</span>
              <span>Ditolak</span>
            </div>
            <p class="text-xs text-text-secondary leading-relaxed">
              Similarity Turnitin melebihi ambang 20% atau berkas terindikasi manipulasi. Mahasiswa wajib mengulang pengajuan baru setelah bimbingan ulang.
            </p>
          </div>
        </div>
      </div>

    <!-- Tab 5: Tanya Jawab (FAQ) -->
    {:else if activeTab === 'faq'}
      <div class="space-y-6 animate-fadeIn">
        <div class="border-b border-border-subtle pb-4">
          <h3 class="font-headline-lg text-lg font-bold text-text-primary">Pertanyaan yang Sering Diajukan (FAQ)</h3>
          <p class="text-xs sm:text-sm text-text-secondary mt-0.5">Jawaban cepat seputar kendala pengunggahan naskah dan bebas pustaka.</p>
        </div>

        <div class="space-y-3">
          {#each faqList as item, idx}
            <div class="rounded-2xl border border-border-subtle overflow-hidden">
              <button
                type="button"
                onclick={() => openFaq = openFaq === idx ? null : idx}
                class="w-full p-4 text-left font-semibold text-xs sm:text-sm text-text-primary bg-slate-50 hover:bg-slate-100 flex items-center justify-between gap-3 transition-colors cursor-pointer"
              >
                <span>{item.q}</span>
                <span class="material-symbols-outlined text-lg text-text-tertiary transition-transform {openFaq === idx ? 'rotate-180' : ''}">expand_more</span>
              </button>
              {#if openFaq === idx}
                <div class="p-4 bg-white text-xs sm:text-sm text-text-secondary leading-relaxed border-t border-border-subtle">
                  {item.a}
                </div>
              {/if}
            </div>
          {/each}
        </div>
      </div>
    {/if}
  </div>

  <!-- BANNER SOLUSI BORANG AKREDITASI KRITERIA 9 & CTA ACTION CARD -->
  <div class="bg-primary text-on-primary rounded-3xl p-8 sm:p-14 shadow-2xl relative overflow-hidden">
    <div class="absolute -right-20 -bottom-20 w-80 h-80 rounded-full bg-white/10 blur-2xl pointer-events-none"></div>
    <div class="absolute left-10 -top-20 w-64 h-64 rounded-full bg-secondary-container/20 blur-2xl pointer-events-none"></div>

    <div class="relative z-10 max-w-4xl space-y-6">
      <div class="flex flex-wrap items-center gap-3">
        <span class="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/15 text-on-primary font-label-badge text-label-badge backdrop-blur-sm">
          <span class="material-symbols-outlined text-sm">school</span>
          Bebas Pustaka &amp; Yudisium Periode Genap 2026/2027
        </span>
        <span class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/20 text-on-primary font-label-badge text-label-badge backdrop-blur-sm">
          <span class="material-symbols-outlined text-sm">verified</span>
          Solusi Kriteria 9 LAM &amp; BAN-PT
        </span>
      </div>

      <h3 class="font-headline-xl text-display-hero-mobile sm:text-headline-xl text-on-primary tracking-tight font-extrabold">
        Siap Mempublikasikan Karya Ilmiah Anda ke Dunia?
      </h3>

      <p class="font-body-lg text-body-lg text-on-primary/90 leading-relaxed max-w-3xl">
        Bagi mahasiswa: Unggah naskah sekarang untuk verifikasi kurator resmi, sertifikat penyerahan karya, dan syarat bebas pustaka. Bagi ketua program studi &amp; pimpinan fakultas: ekspor otomatis seluruh tabel data borang akreditasi Kriteria 9 (Publikasi Mahasiswa &amp; Sitasi Ilmiah) hanya dalam 1-klik.
      </p>

      <div class="flex flex-col sm:flex-row items-center gap-4 pt-4 flex-wrap">
        <button
          type="button"
          onclick={onOpenUpload}
          class="w-full sm:w-auto inline-flex items-center justify-center gap-2 bg-surface-card text-primary hover:bg-surface-bright font-headline-sm text-headline-sm px-8 py-4 rounded-xl shadow-lg transition-all active:scale-95 font-bold cursor-pointer"
        >
          <span class="material-symbols-outlined text-xl">cloud_upload</span>
          <span>Mulai Unggah Karya</span>
        </button>

        <button
          type="button"
          onclick={handleExportBorang}
          class="w-full sm:w-auto inline-flex items-center justify-center gap-2 bg-white/10 hover:bg-white/20 text-on-primary font-headline-sm text-headline-sm px-6 py-4 rounded-xl transition-all border border-white/25 cursor-pointer font-bold"
        >
          <span class="material-symbols-outlined text-xl">table_chart</span>
          <span>Ekspor Borang Akreditasi (XLS)</span>
        </button>

        <button
          type="button"
          onclick={handleDownloadTemplate}
          class="w-full sm:w-auto inline-flex items-center justify-center gap-1.5 text-on-primary/90 hover:text-white bg-white/10 hover:bg-white/20 font-body-sm text-body-sm px-4 py-3.5 rounded-xl border border-white/25 transition-all cursor-pointer font-semibold"
        >
          <span class="material-symbols-outlined text-base">download</span>
          <span>Unduh Template Naskah</span>
        </button>
      </div>
    </div>
  </div>
</section>
