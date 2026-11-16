<script lang="ts">
  interface Props {
    isOpen: boolean;
    onClose: () => void;
    onOpenUpload: () => void;
  }

  let { isOpen, onClose, onOpenUpload }: Props = $props();

  let activeSection = $state('persyaratan');

  const sections = [
    { id: 'persyaratan', label: 'Persyaratan Dokumen', icon: 'checklist' },
    { id: 'langkah',     label: 'Langkah Unggah',      icon: 'stairs' },
    { id: 'format',      label: 'Format & Metadata',    icon: 'description' },
    { id: 'alur-review', label: 'Alur Review Kurator',  icon: 'rate_review' },
    { id: 'faq',         label: 'FAQ',                  icon: 'help' },
  ] as const;

  type SectionId = typeof sections[number]['id'];

  // FAQ accordion state
  let openFaq = $state<number | null>(null);

  const faqItems = [
    {
      q: 'Berapa lama proses verifikasi kurator?',
      a: 'Pemeriksaan dilakukan dalam maksimal 3 × 24 jam kerja (tidak termasuk hari Sabtu, Minggu, dan hari libur nasional). Rata-rata penyelesaian saat ini: 18 jam.',
    },
    {
      q: 'Apa yang terjadi jika skor Turnitin melebihi 20%?',
      a: 'Naskah akan dikembalikan dengan status "Perlu Revisi" beserta catatan bagian yang perlu diperbaiki. Anda dapat mengunggah ulang naskah yang telah direvisi.',
    },
    {
      q: 'Apakah saya bisa mengunggah lebih dari satu file?',
      a: 'Sistem hanya menerima satu berkas tunggal PDF/A (maks 20 MB). Lampirkan lembar pengesahan yang sudah discan atau TTE dalam satu berkas yang sama.',
    },
    {
      q: 'Bagaimana cara mendapatkan sertifikat Bebas Pustaka?',
      a: 'Sertifikat Bebas Pustaka akan tersedia secara otomatis di dashboard Anda segera setelah karya berstatus "Diterbitkan". Anda dapat mengunduhnya kapan saja.',
    },
    {
      q: 'Format sitasi apa yang diterima repositori?',
      a: 'Gunakan standar IEEE untuk bidang Teknik & Informatika, serta APA Style edisi ke-7 untuk rumpun Sosial Humaniora dan Bisnis. Disarankan menggunakan Mendeley atau Zotero.',
    },
    {
      q: 'Apakah naskah saya langsung terlihat publik setelah diterbitkan?',
      a: 'Ya, begitu kurator menerbitkan karya Anda, naskah langsung dapat diakses publik di katalog repositori dan terindeks via protokol OAI-PMH untuk mesin pencari akademik.',
    },
    {
      q: 'Bagaimana jika file saya melebihi 20 MB?',
      a: 'Kompres gambar/grafik dari 300 DPI ke 150 DPI menggunakan Adobe Acrobat atau Ghostscript. Panduan teknis konversi PDF/A tersedia di halaman unduhan template.',
    },
  ];

  function handleKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape') onClose();
  }

  function handleOverlayClick(e: MouseEvent) {
    if (e.target === e.currentTarget) onClose();
  }

  function handleAction() {
    onOpenUpload();
    onClose();
  }
</script>

{#if isOpen}
<!-- Backdrop -->
<div
  class="fixed inset-0 z-50 bg-black/40 backdrop-blur-sm flex items-center justify-center p-4"
  role="dialog"
  aria-modal="true"
  aria-label="Panduan Unggah Karya Ilmiah"
  onkeydown={handleKeydown}
  onclick={handleOverlayClick}
  tabindex="-1"
>
  <!-- Modal panel (max-w-4xl) -->
  <div
    class="relative bg-white rounded-2xl shadow-[0_24px_80px_-12px_rgba(0,0,0,0.25)] w-full max-w-4xl max-h-[90vh] flex flex-col overflow-hidden"
    role="document"
  >
    <!-- ───── Modal Header ───── -->
    <div class="flex items-center justify-between px-6 py-4 border-b border-slate-100 flex-shrink-0">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-[#0050cb] flex items-center justify-center shadow-[0_4px_14px_rgba(0,102,255,0.2)]">
          <span class="material-symbols-outlined text-white text-[20px]">menu_book</span>
        </div>
        <div>
          <h2 class="text-[18px] font-bold text-[#0b1c30] tracking-tight">Panduan Lengkap Unggah Karya Ilmiah</h2>
          <p class="text-[12px] text-[#475569] mt-0.5">Prosedur Akademik & SOP Penyerahan Mandiri</p>
        </div>
      </div>
      <button
        type="button"
        onclick={onClose}
        class="p-2 rounded-xl text-[#475569] hover:bg-[#eff4ff] hover:text-[#0050cb] transition-colors"
        aria-label="Tutup panduan"
      >
        <span class="material-symbols-outlined text-[22px]">close</span>
      </button>
    </div>

    <!-- ───── Modal Body (sidebar + content) ───── -->
    <div class="flex flex-1 min-h-0">
      <!-- Left nav -->
      <nav class="w-52 flex-shrink-0 bg-[#F8FAFC] border-r border-slate-100 flex flex-col py-4 px-3 gap-1 overflow-y-auto">
        {#each sections as sec}
          <button
            type="button"
            onclick={() => { activeSection = sec.id; }}
            class="flex items-center gap-2.5 px-3 py-2.5 rounded-xl text-[13px] text-left transition-all {activeSection === sec.id ? 'bg-[#0050cb] text-white font-semibold shadow-[0_4px_14px_rgba(0,102,255,0.2)]' : 'text-[#424656] hover:bg-[#eff4ff] hover:text-[#0050cb]'}"
          >
            <span class="material-symbols-outlined text-[18px]">{sec.icon}</span>
            <span>{sec.label}</span>
          </button>
        {/each}

        <!-- Info widget in sidebar -->
        <div class="mt-auto pt-4 px-1">
          <div class="p-3 rounded-xl bg-[#eff4ff] text-[11px] text-[#475569]">
            <div class="flex items-center gap-1 text-[#0050cb] font-semibold mb-2">
              <span class="material-symbols-outlined text-[14px]">info</span>
              Info Cepat
            </div>
            <p class="mb-1">⏱ SLA Kurasi: <strong class="text-[#0b1c30]">1×24 Jam</strong></p>
            <p class="mb-1">📄 Max ukuran: <strong class="text-[#0b1c30]">20 MB</strong></p>
            <p>📊 Turnitin: <strong class="text-[#0b1c30]">&lt; 20%</strong></p>
          </div>
        </div>
      </nav>

      <!-- Right content area -->
      <div class="flex-1 overflow-y-auto px-6 py-5">

        <!-- ──── Persyaratan Dokumen ──── -->
        {#if activeSection === 'persyaratan'}
          <div class="space-y-5">
            <div>
              <span class="text-[11px] font-semibold tracking-widest uppercase text-[#0050cb]">Persyaratan Wajib</span>
              <h3 class="text-[20px] font-bold text-[#0b1c30] mt-1 tracking-tight">Persyaratan Dokumen</h3>
              <p class="text-[14px] text-[#475569] mt-1">Pastikan semua persyaratan berikut terpenuhi sebelum mengunggah naskah.</p>
            </div>

            {#each [
              { icon: 'picture_as_pdf', color: 'text-[#0050cb]', bg: 'bg-[#eff4ff]', title: 'File PDF/A Maks. 20 MB', desc: 'Berkas wajib format PDF/A-1b atau PDF/A-2b dengan semua fon tertanam. Ukuran maksimum 20 MB.' },
              { icon: 'text_fields',    color: 'text-[#006688]', bg: 'bg-[#c2e8ff]/30', title: 'Metadata Lengkap',       desc: 'Judul lengkap, abstrak, kata kunci, nama pembimbing, tahun, program studi, dan jenis karya harus diisi lengkap.' },
              { icon: 'translate',      color: 'text-[#4b41d2]', bg: 'bg-[#e3dfff]/40', title: 'Abstrak Dua Bahasa',    desc: 'Abstrak dalam Bahasa Indonesia dan Bahasa Inggris (maks. 250 kata per bahasa), disertai 3–5 kata kunci.' },
              { icon: 'draw',           color: 'text-[#0050cb]', bg: 'bg-[#eff4ff]',    title: 'Persetujuan Pembimbing', desc: 'Lembar pengesahan dengan tanda tangan basah (scan berwarna) atau TTE bersertifikasi BSrE/QR barcode resmi.' },
              { icon: 'policy',         color: 'text-[#10B981]', bg: 'bg-[#10B981]/10', title: 'Bebas Plagiarisme < 20%', desc: 'Skor Turnitin similarity index ≤ 20% (no-quotes filter, tanpa exclude bibliography). Sertakan halaman rekap resmi.' },
            ] as req}
              <div class="flex items-start gap-4 p-4 rounded-xl bg-[#F8FAFC] border border-[#E2E8F0]">
                <div class="w-10 h-10 rounded-xl {req.bg} flex items-center justify-center flex-shrink-0">
                  <span class="material-symbols-outlined {req.color} text-[22px]">{req.icon}</span>
                </div>
                <div>
                  <p class="text-[14px] font-semibold text-[#0b1c30] mb-0.5">{req.title}</p>
                  <p class="text-[13px] text-[#475569] leading-relaxed">{req.desc}</p>
                </div>
                <span class="material-symbols-outlined text-[#10B981] text-[22px] flex-shrink-0 mt-1">check_circle</span>
              </div>
            {/each}
          </div>

        <!-- ──── Langkah Unggah ──── -->
        {:else if activeSection === 'langkah'}
          <div class="space-y-5">
            <div>
              <span class="text-[11px] font-semibold tracking-widest uppercase text-[#0050cb]">Tahapan Pengajuan</span>
              <h3 class="text-[20px] font-bold text-[#0b1c30] mt-1 tracking-tight">Langkah-langkah Unggah</h3>
            </div>

            {#each [
              { num: '01', color: 'bg-[#0050cb]/10 text-[#0050cb]', icon: 'description',   title: 'Siapkan Dokumen',         desc: 'Pastikan naskah telah disetujui pembimbing, termasuk lembar pengesahan yang sah dan telah lulus uji plagiasi Turnitin.' },
              { num: '02', color: 'bg-[#006688]/10 text-[#006688]', icon: 'edit_note',      title: 'Isi Metadata Karya',      desc: 'Lengkapi formulir: judul, abstrak dwibahasa, kata kunci, nama pembimbing, program studi, tahun, dan jenis karya.' },
              { num: '03', color: 'bg-[#EAB308]/15 text-[#EAB308]', icon: 'upload_file',   title: 'Unggah File PDF/A',       desc: 'Unggah satu berkas tunggal PDF/A maks. 20 MB. Pastikan bookmark daftar isi aktif dan fon tertanam.' },
              { num: '04', color: 'bg-[#F97316]/10 text-[#F97316]', icon: 'rate_review',   title: 'Tunggu Verifikasi Kurator', desc: 'Tim kurator akan memeriksa format, keaslian, dan skor plagiasi dalam 1×24 jam kerja. Anda akan dinotifikasi via email.' },
              { num: '05', color: 'bg-[#10B981]/10 text-[#10B981]', icon: 'workspace_premium', title: 'Karya Terbit & DOI Aktif', desc: 'Setelah disetujui, karya terbit di repositori dengan DOI permanen. Sertifikat Bebas Pustaka dapat langsung diunduh.' },
            ] as step, i}
              <div class="flex gap-4">
                <!-- Step indicator + connector line -->
                <div class="flex flex-col items-center">
                  <div class="w-10 h-10 rounded-xl {step.color} flex items-center justify-center font-bold text-[14px] flex-shrink-0">{step.num}</div>
                  {#if i < 4}
                    <div class="w-0.5 flex-1 bg-[#E2E8F0] my-2 min-h-[20px]"></div>
                  {/if}
                </div>
                <div class="pb-5 flex-1">
                  <div class="flex items-center gap-2 mb-1">
                    <span class="material-symbols-outlined text-[18px] text-[#475569]">{step.icon}</span>
                    <p class="text-[15px] font-semibold text-[#0b1c30]">{step.title}</p>
                  </div>
                  <p class="text-[13px] text-[#475569] leading-relaxed">{step.desc}</p>
                </div>
              </div>
            {/each}
          </div>

        <!-- ──── Format & Metadata ──── -->
        {:else if activeSection === 'format'}
          <div class="space-y-5">
            <div>
              <span class="text-[11px] font-semibold tracking-widest uppercase text-[#0050cb]">Ketentuan Standar</span>
              <h3 class="text-[20px] font-bold text-[#0b1c30] mt-1 tracking-tight">Format & Metadata Wajib</h3>
            </div>

            <!-- Metadata table -->
            <div class="bg-[#F8FAFC] rounded-xl border border-[#E2E8F0] overflow-hidden">
              <div class="grid grid-cols-3 bg-[#eff4ff] px-4 py-2.5 text-[11px] font-bold uppercase tracking-wider text-[#0050cb]">
                <span>Field Metadata</span>
                <span>Keterangan</span>
                <span>Wajib?</span>
              </div>
              {#each [
                { field: 'Judul',             desc: 'Judul lengkap, kapitalisasi standar, tidak disingkat',      wajib: true },
                { field: 'Abstrak (ID)',       desc: 'Bahasa Indonesia, maks. 250 kata',                          wajib: true },
                { field: 'Abstrak (EN)',       desc: 'Bahasa Inggris, maks. 250 kata',                            wajib: true },
                { field: 'Kata Kunci',         desc: '3–5 kata kunci spesifik, pisahkan dengan koma',             wajib: true },
                { field: 'Pembimbing',         desc: 'Nama lengkap beserta gelar akademik',                       wajib: true },
                { field: 'Tahun',             desc: 'Tahun akademik penyelesaian karya',                          wajib: true },
                { field: 'Program Studi',     desc: 'Nama resmi program studi sesuai SK',                         wajib: true },
                { field: 'Jenis Karya',       desc: 'Skripsi / Tesis / Disertasi / Artikel Jurnal / KP',          wajib: true },
                { field: 'NIM',              desc: 'Nomor Induk Mahasiswa 8 digit',                               wajib: false },
                { field: 'DOI',              desc: 'Akan digenerate otomatis oleh sistem setelah terbit',          wajib: false },
              ] as row, i}
                <div class="grid grid-cols-3 px-4 py-3 text-[13px] {i % 2 === 0 ? 'bg-white' : 'bg-[#F8FAFC]'} border-t border-[#E2E8F0]">
                  <span class="font-semibold text-[#0b1c30]">{row.field}</span>
                  <span class="text-[#475569]">{row.desc}</span>
                  <span>
                    {#if row.wajib}
                      <span class="inline-flex items-center gap-1 text-[#10B981] font-semibold">
                        <span class="material-symbols-outlined text-[14px]">check_circle</span> Wajib
                      </span>
                    {:else}
                      <span class="text-[#94A3B8]">Opsional</span>
                    {/if}
                  </span>
                </div>
              {/each}
            </div>

            <!-- Sitasi formats -->
            <div class="grid grid-cols-2 gap-4">
              <div class="p-4 rounded-xl bg-[#eff4ff] border border-[#0050cb]/20">
                <p class="text-[13px] font-semibold text-[#0050cb] mb-1">Format Sitasi Teknik & Informatika</p>
                <p class="text-[12px] text-[#475569]">Gunakan standar <strong>IEEE</strong> untuk semua referensi. Tools: Mendeley, Zotero, EndNote.</p>
              </div>
              <div class="p-4 rounded-xl bg-[#e3dfff]/40 border border-[#4b41d2]/20">
                <p class="text-[13px] font-semibold text-[#4b41d2] mb-1">Format Sitasi Sosial Humaniora & Bisnis</p>
                <p class="text-[12px] text-[#475569]">Gunakan <strong>APA Style edisi ke-7</strong>. Tools: Mendeley, Zotero, atau manual.</p>
              </div>
            </div>
          </div>

        <!-- ──── Alur Review Kurator ──── -->
        {:else if activeSection === 'alur-review'}
          <div class="space-y-5">
            <div>
              <span class="text-[11px] font-semibold tracking-widest uppercase text-[#0050cb]">Proses Kurasi</span>
              <h3 class="text-[20px] font-bold text-[#0b1c30] mt-1 tracking-tight">Alur Review Kurator</h3>
              <p class="text-[14px] text-[#475569] mt-1">Berikut alur lengkap proses kurasi dari pengajuan hingga terbit.</p>
            </div>

            <!-- Timeline -->
            <div class="relative">
              <!-- Vertical line -->
              <div class="absolute left-5 top-5 bottom-5 w-0.5 bg-[#E2E8F0]"></div>

              <div class="space-y-6">
                {#each [
                  { icon: 'upload_file',       color: 'bg-[#0050cb] text-white',    label: 'Pengajuan Masuk',          desc: 'Penulis mengunggah naskah melalui portal. Sistem memvalidasi format file dan kelengkapan metadata secara otomatis.', status: 'Diajukan', statusColor: 'bg-[#0284C7]/10 text-[#0284C7]' },
                  { icon: 'hourglass_empty',   color: 'bg-[#EAB308] text-white',    label: 'Antrean Kurasi',           desc: 'Naskah masuk antrean. Kurator perpustakaan menerima notifikasi dan mulai menelaah dalam 1×24 jam kerja.', status: 'Dalam Review', statusColor: 'bg-[#EAB308]/15 text-[#EAB308]' },
                  { icon: 'fact_check',        color: 'bg-[#4b41d2] text-white',    label: 'Verifikasi & Uji Plagiasi', desc: 'Kurator memeriksa: (1) kesesuaian format PDF/A, (2) kelengkapan lembar pengesahan, (3) skor Turnitin ≤ 20%, (4) kelengkapan metadata.', status: null, statusColor: '' },
                  { icon: 'assignment_return', color: 'bg-[#F97316] text-white',    label: 'Revisi (jika diperlukan)', desc: 'Jika ada kekurangan, naskah dikembalikan dengan catatan detail. Penulis memperbaiki dan mengunggah ulang dalam waktu yang ditentukan.', status: 'Perlu Revisi', statusColor: 'bg-[#F97316]/10 text-[#F97316]' },
                  { icon: 'verified',          color: 'bg-[#10B981] text-white',    label: 'Penerbitan & DOI Aktif',   desc: 'Setelah disetujui, karya terbit di repositori dengan DOI permanen. Sertifikat Bebas Pustaka langsung dapat diunduh.', status: 'Diterbitkan', statusColor: 'bg-[#10B981]/10 text-[#10B981]' },
                ] as step}
                  <div class="flex gap-4 relative">
                    <div class="w-10 h-10 rounded-full {step.color} flex items-center justify-center flex-shrink-0 z-10 shadow-sm">
                      <span class="material-symbols-outlined text-[18px]">{step.icon}</span>
                    </div>
                    <div class="flex-1 pt-1 pb-2">
                      <div class="flex items-center gap-2 mb-1">
                        <p class="text-[14px] font-semibold text-[#0b1c30]">{step.label}</p>
                        {#if step.status}
                          <span class="px-2 py-0.5 rounded-full text-[11px] font-semibold {step.statusColor}">{step.status}</span>
                        {/if}
                      </div>
                      <p class="text-[13px] text-[#475569] leading-relaxed">{step.desc}</p>
                    </div>
                  </div>
                {/each}
              </div>
            </div>

            <!-- SLA note -->
            <div class="p-4 rounded-xl bg-[#eff4ff] border border-[#0050cb]/20 flex items-start gap-3">
              <span class="material-symbols-outlined text-[#0050cb] text-[22px] flex-shrink-0">timer</span>
              <div>
                <p class="text-[13px] font-semibold text-[#0050cb] mb-1">SLA Target: 1×24 Jam Kerja</p>
                <p class="text-[12px] text-[#475569]">Tidak termasuk hari Sabtu, Minggu, dan hari libur nasional. Rata-rata aktual penyelesaian: 14.2 jam.</p>
              </div>
            </div>
          </div>

        <!-- ──── FAQ ──── -->
        {:else if activeSection === 'faq'}
          <div class="space-y-5">
            <div>
              <span class="text-[11px] font-semibold tracking-widest uppercase text-[#0050cb]">Bantuan & Solusi</span>
              <h3 class="text-[20px] font-bold text-[#0b1c30] mt-1 tracking-tight">Pertanyaan Umum (FAQ)</h3>
            </div>

            <div class="space-y-2">
              {#each faqItems as item, i}
                <div class="rounded-xl border border-[#E2E8F0] overflow-hidden">
                  <button
                    type="button"
                    onclick={() => { openFaq = openFaq === i ? null : i; }}
                    class="w-full flex items-center justify-between px-4 py-3.5 text-left {openFaq === i ? 'bg-[#eff4ff]' : 'bg-white hover:bg-[#F8FAFC]'} transition-colors"
                  >
                    <div class="flex items-center gap-3">
                      <span class="material-symbols-outlined text-[#0050cb] text-[18px]">help</span>
                      <span class="text-[14px] font-semibold text-[#0b1c30]">{item.q}</span>
                    </div>
                    <span class="material-symbols-outlined text-[#475569] text-[20px] flex-shrink-0 transition-transform {openFaq === i ? 'rotate-180' : ''}">expand_more</span>
                  </button>
                  {#if openFaq === i}
                    <div class="px-4 py-3 bg-white border-t border-[#E2E8F0]">
                      <p class="text-[13px] text-[#475569] leading-relaxed pl-8">{item.a}</p>
                    </div>
                  {/if}
                </div>
              {/each}
            </div>

            <!-- Contact support -->
            <div class="p-4 rounded-xl bg-[#e3dfff]/40 border border-[#4b41d2]/20 flex items-start gap-3">
              <span class="material-symbols-outlined text-[#4b41d2] text-[22px] flex-shrink-0">support_agent</span>
              <div>
                <p class="text-[13px] font-semibold text-[#4b41d2] mb-1">Masih ada pertanyaan?</p>
                <p class="text-[12px] text-[#475569]">Hubungi Tim Perpustakaan melalui email <strong class="text-[#0b1c30]">library@immortalcampus.ac.id</strong> atau datang langsung ke Gedung Perpustakaan Lantai 2, jam 08.00–16.00 WIB.</p>
              </div>
            </div>
          </div>
        {/if}

      </div>
    </div>

    <!-- ───── Modal Footer ───── -->
    <div class="flex items-center justify-between px-6 py-4 border-t border-slate-100 bg-[#F8FAFC] flex-shrink-0">
      <p class="text-[12px] text-[#94A3B8]">Versi Panduan: Tahun Akademik 2024/2025</p>
      <div class="flex items-center gap-3">
        <button
          type="button"
          onclick={onClose}
          class="px-4 py-2.5 rounded-xl bg-white border border-[#E2E8F0] text-[#475569] text-[13px] font-semibold hover:bg-[#F8FAFC] hover:text-[#0050cb] transition-all"
        >
          Tutup
        </button>
        <button
          type="button"
          onclick={handleAction}
          class="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-[#0066ff] text-white text-[13px] font-semibold shadow-[0_4px_14px_rgba(0,102,255,0.25)] hover:bg-[#0050cb] hover:scale-[0.99] active:scale-[0.97] transition-all"
        >
          <span class="material-symbols-outlined text-[18px]">upload_file</span>
          Mulai Unggah Sekarang
        </button>
      </div>
    </div>
  </div>
</div>
{/if}
