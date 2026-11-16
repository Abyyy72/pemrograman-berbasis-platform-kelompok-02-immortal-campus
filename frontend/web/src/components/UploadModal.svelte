<script lang="ts">
  import type { Karya, JenisKarya } from '../types';

  interface Props {
    isOpen: boolean;
    onClose: () => void;
    onSubmitKarya: (karya: Karya) => void;
    currentUser?: { nama?: string; nim?: string; prodi?: string } | null;
  }

  let { isOpen, onClose, onSubmitKarya, currentUser }: Props = $props();

  let judul = $state('');
  let penulis = $state('');
  let nim = $state('');
  let pembimbing = $state('');
  let jenis = $state<JenisKarya>('skripsi');
  let prodi = $state('Teknik Informatika');
  let tahun = $state(2026);
  let abstrak = $state('');
  let kataKunciStr = $state('');
  let fileName = $state('');
  let fileSize = $state('');
  let fileError = $state('');

  $effect(() => {
    if (isOpen && currentUser) {
      if (!penulis && currentUser.nama) penulis = currentUser.nama;
      if (!nim && currentUser.nim) nim = currentUser.nim;
      if (currentUser.prodi) prodi = currentUser.prodi;
    }
  });

  function handleFileChange(e: Event) {
    const input = e.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      const file = input.files[0];
      // Validation: PDF and max 20 MB
      if (file.type !== 'application/pdf' && !file.name.toLowerCase().endsWith('.pdf')) {
        fileError = 'Hanya file format PDF yang diperbolehkan!';
        fileName = '';
        fileSize = '';
        return;
      }
      const sizeMB = file.size / (1024 * 1024);
      if (sizeMB > 20) {
        fileError = `Ukuran file melebihi batas maksimal 20 MB (${sizeMB.toFixed(1)} MB)!`;
        fileName = '';
        fileSize = '';
        return;
      }
      fileError = '';
      fileName = file.name;
      fileSize = `${sizeMB.toFixed(1)} MB`;
    }
  }

  function submit(isDraft: boolean) {
    if (!judul.trim() || !penulis.trim() || !pembimbing.trim() || !abstrak.trim()) {
      alert('Mohon lengkapi judul, penulis, pembimbing, dan abstrak!');
      return;
    }

    const prodiKeyMap: Record<string, 'ti' | 'si' | 'dkv' | 'mnj' | 'ilkom'> = {
      'Teknik Informatika': 'ti',
      'Sistem Informasi': 'si',
      'Desain Komunikasi Visual': 'dkv',
      'Manajemen': 'mnj',
      'Manajemen Bisnis': 'mnj',
      'Akuntansi': 'mnj',
      'Ilmu Komunikasi': 'ilkom'
    };

    const jenisLabelMap: Record<JenisKarya, string> = {
      skripsi: 'Skripsi S-1',
      tesis: 'Tesis Magister S-2',
      jurnal: 'Jurnal Ilmiah',
      kp: 'Laporan Kerja Praktik'
    };

    const tags = kataKunciStr
      ? kataKunciStr.split(',').map((s) => s.trim()).filter((s) => s.length > 0)
      : ['Karya Ilmiah', prodi];

    const newKarya: Karya = {
      id: `karya-${Date.now().toString().slice(-4)}`,
      judul: judul.trim(),
      penulis: penulis.trim(),
      nim: nim.trim() || '2108561000',
      pembimbing: pembimbing.trim(),
      jenis,
      jenisLabel: jenisLabelMap[jenis],
      prodi,
      prodiKey: prodiKeyMap[prodi] || 'ti',
      tahun: Number(tahun) || 2026,
      abstrak: abstrak.trim(),
      kataKunci: tags,
      unduhan: 0,
      status: isDraft ? 'Draft' : 'Diajukan',
      tanggalTerbit: 'Menunggu Kurasi',
      doi: `10.2412/imc.${tahun}.${Math.floor(100 + Math.random() * 900)}`,
      fileSize: fileSize || '3.5 MB'
    };

    onSubmitKarya(newKarya);
    onClose();
    resetForm();
  }

  function resetForm() {
    judul = '';
    penulis = '';
    nim = '';
    pembimbing = '';
    abstrak = '';
    kataKunciStr = '';
    fileName = '';
    fileSize = '';
    fileError = '';
  }
</script>

{#if isOpen}
  <div class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-on-surface/40 backdrop-blur-sm animate-fadeIn">
    <button type="button" aria-label="Tutup modal" class="fixed inset-0 bg-transparent cursor-default border-none w-full h-full" onclick={onClose}></button>

    <div class="relative w-full max-w-2xl bg-surface-card rounded-3xl shadow-2xl border border-border-subtle max-h-[92vh] flex flex-col overflow-hidden z-10">
      <!-- Header -->
      <div class="p-4 sm:p-6 border-b border-border-subtle flex items-center justify-between bg-surface-canvas">
        <div class="flex items-center gap-3 min-w-0">
          <div class="w-10 h-10 rounded-xl bg-primary/10 text-primary flex items-center justify-center shrink-0">
            <span class="material-symbols-outlined text-2xl">cloud_upload</span>
          </div>
          <div class="min-w-0">
            <h2 class="font-headline-md text-base sm:text-lg font-bold text-text-primary truncate">Unggah Karya Ilmiah Baru</h2>
            <p class="text-xs text-text-secondary truncate">Isi metadata karya dan lampirkan naskah lengkap (PDF)</p>
          </div>
        </div>
        <button onclick={onClose} class="p-1.5 sm:p-2 rounded-xl text-text-tertiary hover:text-text-primary hover:bg-surface-muted transition-colors shrink-0">
          <span class="material-symbols-outlined text-2xl">close</span>
        </button>
      </div>

      <!-- Form Body -->
      <div class="p-6 overflow-y-auto space-y-4 text-xs sm:text-sm">
        <!-- Judul -->
        <div class="space-y-1">
          <label for="upload-judul" class="font-semibold text-text-primary block">Judul Lengkap Karya <span class="text-error">*</span></label>
          <input
            id="upload-judul"
            bind:value={judul}
            type="text"
            placeholder="Contoh: Analisis Penerapan Machine Learning untuk..."
            class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle bg-surface-muted/50 focus:outline-none focus:border-primary text-text-primary"
          />
        </div>

        <!-- 2 cols: Jenis & Prodi -->
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <div class="space-y-1">
            <label for="upload-jenis" class="font-semibold text-text-primary block">Jenis Karya <span class="text-error">*</span></label>
            <select
              id="upload-jenis"
              bind:value={jenis}
              class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle bg-surface-muted/50 focus:outline-none focus:border-primary text-text-primary"
            >
              <option value="skripsi">Skripsi S-1</option>
              <option value="tesis">Tesis Magister S-2</option>
              <option value="jurnal">Jurnal Ilmiah</option>
              <option value="kp">Laporan Kerja Praktik</option>
            </select>
          </div>

          <div class="space-y-1">
            <label for="upload-prodi" class="font-semibold text-text-primary block">Program Studi <span class="text-error">*</span></label>
            <select
              id="upload-prodi"
              bind:value={prodi}
              class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle bg-surface-muted/50 focus:outline-none focus:border-primary text-text-primary"
            >
              <option value="Teknik Informatika">Teknik Informatika</option>
              <option value="Sistem Informasi">Sistem Informasi</option>
              <option value="Desain Komunikasi Visual">Desain Komunikasi Visual</option>
              <option value="Manajemen Bisnis">Manajemen Bisnis</option>
              <option value="Ilmu Komunikasi">Ilmu Komunikasi</option>
            </select>
          </div>
        </div>

        <!-- 3 cols: Penulis, NIM, Tahun -->
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div class="space-y-1 sm:col-span-1">
            <label for="upload-penulis" class="font-semibold text-text-primary block">Nama Penulis <span class="text-error">*</span></label>
            <input
              id="upload-penulis"
              bind:value={penulis}
              type="text"
              placeholder="Nama lengkap"
              class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle bg-surface-muted/50 focus:outline-none focus:border-primary text-text-primary"
            />
          </div>
          <div class="space-y-1 sm:col-span-1">
            <label for="upload-nim" class="font-semibold text-text-primary block">NIM / NIDN</label>
            <input
              id="upload-nim"
              bind:value={nim}
              type="text"
              placeholder="2108561000"
              class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle bg-surface-muted/50 focus:outline-none focus:border-primary text-text-primary"
            />
          </div>
          <div class="space-y-1 sm:col-span-1">
            <label for="upload-tahun" class="font-semibold text-text-primary block">Tahun Sidang</label>
            <input
              id="upload-tahun"
              bind:value={tahun}
              type="number"
              class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle bg-surface-muted/50 focus:outline-none focus:border-primary text-text-primary"
            />
          </div>
        </div>

        <!-- Pembimbing -->
        <div class="space-y-1">
          <label for="upload-pembimbing" class="font-semibold text-text-primary block">Dosen Pembimbing <span class="text-error">*</span></label>
          <input
            id="upload-pembimbing"
            bind:value={pembimbing}
            type="text"
            placeholder="Lengkap dengan gelar akademik"
            class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle bg-surface-muted/50 focus:outline-none focus:border-primary text-text-primary"
          />
        </div>

        <!-- Abstrak -->
        <div class="space-y-1">
          <label for="upload-abstrak" class="font-semibold text-text-primary block">Abstrak (Bahasa Indonesia) <span class="text-error">*</span></label>
          <textarea
            id="upload-abstrak"
            bind:value={abstrak}
            rows="4"
            placeholder="Tuliskan latar belakang, metode penelitian, serta temuan utama..."
            class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle bg-surface-muted/50 focus:outline-none focus:border-primary text-text-primary leading-relaxed"
          ></textarea>
        </div>

        <!-- Kata Kunci -->
        <div class="space-y-1">
          <label for="upload-keywords" class="font-semibold text-text-primary block">Kata Kunci (Pisahkan dengan koma)</label>
          <input
            id="upload-keywords"
            bind:value={kataKunciStr}
            type="text"
            placeholder="Contoh: Deep Learning, Retinopati Diabetik, ViT"
            class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle bg-surface-muted/50 focus:outline-none focus:border-primary text-text-primary"
          />
        </div>

        <!-- File Upload (PDF, max 20 MB) -->
        <div class="space-y-2 pt-2">
          <label for="upload-file" class="font-semibold text-text-primary block">Upload Dokumen Full-Text (PDF, Maks. 20 MB) <span class="text-error">*</span></label>
          <div class="border-2 border-dashed border-border-subtle rounded-2xl p-5 text-center bg-surface-muted/30 hover:border-primary transition-colors cursor-pointer relative">
            <input
              id="upload-file"
              type="file"
              accept=".pdf"
              onchange={handleFileChange}
              class="absolute inset-0 opacity-0 cursor-pointer w-full h-full"
            />
            <span class="material-symbols-outlined text-3xl text-primary mb-1">upload_file</span>
            <p class="text-xs font-semibold text-text-primary">
              {#if fileName}
                <span class="text-status-published font-bold">Terpilih: {fileName} ({fileSize})</span>
              {:else}
                Klik atau seret file PDF naskah ke sini
              {/if}
            </p>
            <p class="text-[11px] text-text-tertiary mt-0.5">Format PDF sesuai standar repositori kampus</p>
          </div>
          {#if fileError}
            <p class="text-xs text-error font-semibold">{fileError}</p>
          {/if}
        </div>
      </div>

      <!-- Footer Buttons -->
      <div class="p-4 sm:p-6 border-t border-border-subtle bg-surface-canvas flex flex-col-reverse sm:flex-row items-stretch sm:items-center justify-between gap-3">
        <button
          onclick={() => submit(true)}
          class="w-full sm:w-auto px-4 py-2.5 rounded-xl border border-border-subtle bg-surface-card hover:bg-surface-muted text-text-secondary hover:text-text-primary font-semibold text-xs transition-colors text-center"
        >
          Simpan Draft
        </button>

        <div class="flex items-center gap-2 w-full sm:w-auto justify-end">
          <button
            onclick={onClose}
            class="px-4 py-2.5 rounded-xl text-text-tertiary hover:text-text-primary text-xs font-medium"
          >
            Batal
          </button>
          <button
            onclick={() => submit(false)}
            class="flex-1 sm:flex-none justify-center px-6 py-2.5 rounded-xl bg-primary hover:bg-primary-container text-on-primary font-bold text-xs shadow-md transition-all active:scale-95 flex items-center gap-1.5"
          >
            <span class="material-symbols-outlined text-base">send</span>
            <span>Ajukan ke Kurator</span>
          </button>
        </div>
      </div>
    </div>
  </div>
{/if}
