<script lang="ts">
  import type { Karya } from '../types';

  interface Props {
    isOpen: boolean;
    karya: Karya | null;
    authorName?: string;
    authorNim?: string;
    onClose: () => void;
  }

  let {
    isOpen,
    karya,
    authorName = 'Amanda Putri Wibowo',
    authorNim = '2110512034',
    onClose
  }: Props = $props();

  let copied = $state(false);

  // Generate unique certificate verification number
  let nomorSurat = $derived.by(() => {
    if (!karya) return '412/SK-BP/PERPUS-IMC/2026';
    const year = karya.tahun || 2026;
    const cleanId = karya.id.replace(/\D/g, '').slice(-4) || '1088';
    return `${cleanId}/SK-BP/PERPUS-IMC/X/${year}`;
  });

  function handlePrint() {
    window.print();
  }

  function copyNomorSurat() {
    navigator.clipboard.writeText(nomorSurat);
    copied = true;
    setTimeout(() => { copied = false; }, 2000);
  }

  function handleBackdropClick(e: MouseEvent) {
    if (e.target === e.currentTarget) onClose();
  }
</script>

{#if isOpen}
  <!-- Backdrop -->
  <!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions a11y-click-events-have-key-events a11y-no-static-element-interactions -->
  <div
    class="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-6 bg-slate-950/70 backdrop-blur-md overflow-y-auto animate-fadeIn"
    onclick={handleBackdropClick}
    role="presentation"
  >
    <!-- Certificate Modal Window -->
    <div class="relative w-full max-w-3xl bg-white rounded-2xl shadow-2xl overflow-hidden my-auto border border-slate-200 print:m-0 print:border-none print:shadow-none print:w-full">

      <!-- Action Top Bar (Hidden during print) -->
      <div class="bg-slate-900 text-white px-4 sm:px-6 py-3 flex items-center justify-between gap-2 print:hidden">
        <div class="flex items-center gap-2 min-w-0">
          <span class="material-symbols-outlined text-primary text-xl shrink-0">workspace_premium</span>
          <span class="text-xs sm:text-sm font-semibold tracking-wide truncate">Bukti Bebas Pustaka</span>
        </div>
        <div class="flex items-center gap-2 shrink-0">
          <button
            type="button"
            onclick={handlePrint}
            class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-primary hover:bg-blue-600 text-white text-xs font-semibold shadow transition-all cursor-pointer"
          >
            <span class="material-symbols-outlined text-sm">print</span>
            <span class="hidden sm:inline">Cetak / Simpan PDF</span>
            <span class="sm:hidden">Cetak</span>
          </button>
          <button
            type="button"
            onclick={onClose}
            class="p-1 rounded-lg text-slate-400 hover:text-white hover:bg-slate-800 transition-colors cursor-pointer"
            aria-label="Tutup sertifikat"
          >
            <span class="material-symbols-outlined text-xl">close</span>
          </button>
        </div>
      </div>

      <!-- Printable Certificate Canvas -->
      <div class="p-4 sm:p-8 md:p-12 text-slate-800 space-y-6 relative overflow-hidden bg-[radial-gradient(#f1f5f9_1px,transparent_1px)] [background-size:16px_16px]">

        <!-- Decorative Watermark in Background -->
        <div class="absolute inset-0 flex items-center justify-center opacity-[0.03] pointer-events-none select-none">
          <span class="material-symbols-outlined text-[360px]">school</span>
        </div>

        <!-- Institutional Letterhead (KOP SURAT) -->
        <div class="flex items-center justify-between pb-6 border-b-2 border-slate-800 gap-4">
          <div class="flex items-center gap-4">
            <img
              alt="Logo Kampus"
              class="h-20 w-auto object-contain"
              src="/logo.png"
            />
            <div>
              <h3 class="font-extrabold text-base sm:text-lg tracking-tight uppercase text-slate-900 font-display-hero">
                IMMORTAL CAMPUS INDONESIA
              </h3>
              <p class="text-xs text-slate-600 font-medium">UNIT PELAKSANA TEKNIS (UPT) PERPUSTAKAAN &amp; REPOSITORI DIGITAL</p>
              <p class="text-[11px] text-slate-500">Gedung Graha Pustaka Utama Lt. 2 • Surel: library@immortalcampus.ac.id • Laman: repositori.immortalcampus.ac.id</p>
            </div>
          </div>
          <div class="hidden sm:flex flex-col items-end text-right shrink-0">
            <span class="inline-flex items-center gap-1 text-[11px] font-bold text-status-published bg-status-published/10 px-2.5 py-1 rounded-full border border-status-published/20">
              <span class="material-symbols-outlined text-xs">verified</span> TERVALIDASI
            </span>
            <span class="text-[10px] text-slate-400 font-mono mt-1">ISO 27001 Certified</span>
          </div>
        </div>

        <!-- Title of Certificate -->
        <div class="text-center space-y-1 pt-2">
          <h2 class="text-lg sm:text-xl font-bold tracking-tight uppercase text-slate-900 underline underline-offset-4 decoration-slate-400">
            SURAT KETERANGAN PENYERAHAN KARYA ILMIAH &amp; BEBAS PUSTAKA
          </h2>
          <div class="flex items-center justify-center gap-2 text-xs text-slate-500 font-mono">
            <span>Nomor: <strong>{nomorSurat}</strong></span>
            <button
              type="button"
              onclick={copyNomorSurat}
              title="Salin nomor surat"
              class="hover:text-primary print:hidden cursor-pointer"
            >
              <span class="material-symbols-outlined text-xs">{copied ? 'done' : 'content_copy'}</span>
            </button>
          </div>
        </div>

        <!-- Body Statement -->
        <div class="space-y-4 text-xs sm:text-sm text-slate-700 leading-relaxed pt-2">
          <p>
            Kepala Unit Pelaksana Teknis Perpustakaan dan Kurator Repositori Digital Institusi Immortal Campus menerangkan dengan sebenarnya bahwa mahasiswa di bawah ini:
          </p>

          <!-- Table of Student Metadata -->
          <div class="bg-slate-50 rounded-xl p-4 border border-slate-200 space-y-2">
            <div class="grid grid-cols-3 sm:grid-cols-4 gap-2">
              <span class="text-slate-500">Nama Lengkap</span>
              <span class="col-span-2 sm:col-span-3 font-bold text-slate-900">: {karya?.penulis || authorName}</span>
            </div>
            <div class="grid grid-cols-3 sm:grid-cols-4 gap-2">
              <span class="text-slate-500">NIM / Identitas</span>
              <span class="col-span-2 sm:col-span-3 font-semibold text-slate-900 font-mono">: {karya?.nim || authorNim}</span>
            </div>
            <div class="grid grid-cols-3 sm:grid-cols-4 gap-2">
              <span class="text-slate-500">Program Studi / Fak.</span>
              <span class="col-span-2 sm:col-span-3 text-slate-900">: {karya?.prodi || 'Teknik Informatika (Fakultas Teknik & Ilmu Komputer)'}</span>
            </div>
            <div class="grid grid-cols-3 sm:grid-cols-4 gap-2">
              <span class="text-slate-500">Jenis Naskah</span>
              <span class="col-span-2 sm:col-span-3 text-slate-900">: {karya?.jenisLabel || 'Skripsi S-1'}</span>
            </div>
            <div class="grid grid-cols-3 sm:grid-cols-4 gap-2">
              <span class="text-slate-500">Judul Karya Ilmiah</span>
              <span class="col-span-2 sm:col-span-3 font-semibold text-slate-900 italic">: &ldquo;{karya?.judul || 'Penerapan Deep Learning Convolutional Neural Network untuk Deteksi Dini Hama Padi'}&rdquo;</span>
            </div>
            <div class="grid grid-cols-3 sm:grid-cols-4 gap-2">
              <span class="text-slate-500">Dosen Pembimbing</span>
              <span class="col-span-2 sm:col-span-3 text-slate-900">: {karya?.pembimbing || 'Dr. Eng. Hendra Sucipto, S.Kom., M.T.'}</span>
            </div>
            <div class="grid grid-cols-3 sm:grid-cols-4 gap-2">
              <span class="text-slate-500">Status Kurasi</span>
              <span class="col-span-2 sm:col-span-3 text-status-published font-bold flex items-center gap-1">
                <span class="material-symbols-outlined text-sm">check_circle</span>
                DITERBITKAN (Lolos Turnitin Similarity &le; 20% &amp; Pengesahan Sah)
              </span>
            </div>
          </div>

          <p class="pt-2">
            Telah menyerahkan naskah akhir karya ilmiah dalam format dokumen digital standar <strong>PDF/A</strong> serta dinyatakan <strong>BEBAS TANGGUNGAN PUSTAKA</strong> (tidak memiliki tunggakan peminjaman buku maupun denda administrasi). Surat keterangan ini diterbitkan sebagai salah satu syarat kelengkapan administrasi <strong>Yudisium &amp; Wisuda</strong> periode Tahun Akademik 2026/2027.
          </p>
        </div>

        <!-- Signature & Verification QR Section -->
        <div class="pt-8 grid grid-cols-2 items-end justify-between border-t border-slate-200 text-xs">
          <!-- QR Code Authenticator -->
          <div class="flex items-center gap-3">
            <div class="w-20 h-20 bg-slate-100 border border-slate-300 rounded-xl p-1.5 flex flex-col items-center justify-center shrink-0">
              <img
                src="https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=https://portal.immortal-campus.ac.id/verify/{nomorSurat}"
                alt="QR Verifikasi"
                class="w-full h-full object-contain"
              />
            </div>
            <div class="space-y-0.5 text-[11px] text-slate-500">
              <span class="font-bold text-slate-800 block">Pindai untuk Verifikasi</span>
              <span>Dokumen sah terenkripsi secara digital via sistem Immortal Campus.</span>
            </div>
          </div>

          <!-- Official Signature Box -->
          <div class="text-right space-y-1">
            <p class="text-slate-500">Diterbitkan di: Kampus Terpadu</p>
            <p class="text-slate-500">Tanggal: 31 Oktober 2026</p>
            <div class="h-14 flex items-center justify-end">
              <!-- Digital signature stamp -->
              <span class="px-3 py-1 rounded border-2 border-primary/40 text-primary font-bold text-[10px] uppercase rotate-[-3deg] tracking-wider bg-primary/5">
                TERVERIFIKASI TTE ELEKTRONIK
              </span>
            </div>
            <p class="font-bold text-slate-900">Dr. Rina Suryani, M.Kom.</p>
            <p class="text-[11px] text-slate-500">Kepala UPT Perpustakaan &amp; Kurasi</p>
          </div>
        </div>

      </div>

      <!-- Footer Action in Modal (Hidden during print) -->
      <div class="bg-slate-50 p-4 border-t border-slate-200 flex items-center justify-between text-xs text-slate-500 print:hidden">
        <span>Gunakan tombol cetak untuk menyimpan sebagai PDF dokumen resmi yudisium.</span>
        <button
          type="button"
          onclick={onClose}
          class="px-4 py-2 rounded-xl bg-slate-200 hover:bg-slate-300 text-slate-700 font-semibold transition-colors cursor-pointer"
        >
          Tutup
        </button>
      </div>

    </div>
  </div>
{/if}

