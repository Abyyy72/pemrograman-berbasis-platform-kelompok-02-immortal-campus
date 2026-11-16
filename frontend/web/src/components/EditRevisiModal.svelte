<script lang="ts">
  import type { Karya } from '../types';

  interface Props {
    karya: Karya | null;
    onClose: () => void;
    onSubmitRevisi: (karyaId: string, data: Partial<Karya>, submitForReview: boolean) => void;
  }

  let { karya, onClose, onSubmitRevisi }: Props = $props();

  let editJudul      = $state('');
  let editAbstrak    = $state('');
  let editKataKunci  = $state('');
  let editPembimbing = $state('');
  let fileSelected   = $state(false);
  let fileName       = $state('');
  let agreed         = $state(false);
  let isDragOver     = $state(false);

  $effect(() => {
    if (karya) {
      editJudul      = karya.judul;
      editAbstrak    = karya.abstrak;
      editKataKunci  = karya.kataKunci.join(', ');
      editPembimbing = karya.pembimbing;
      fileSelected   = false;
      fileName       = '';
      agreed         = false;
    }
  });

  function handleFileChange(e: Event) {
    const input = e.target as HTMLInputElement;
    if (input.files && input.files[0]) {
      const file = input.files[0];
      if (file.size > 20 * 1024 * 1024) {
        alert('File melebihi batas 20MB!');
        return;
      }
      fileSelected = true;
      fileName = file.name;
    }
  }

  function handleDrop(e: DragEvent) {
    e.preventDefault();
    isDragOver = false;
    const file = e.dataTransfer?.files?.[0];
    if (!file) return;
    if (!file.name.toLowerCase().endsWith('.pdf')) { alert('Hanya file PDF yang diterima.'); return; }
    if (file.size > 20 * 1024 * 1024) { alert('File melebihi batas 20MB!'); return; }
    fileSelected = true;
    fileName = file.name;
  }

  function buildData(): Partial<Karya> {
    return {
      judul:      editJudul,
      abstrak:    editAbstrak,
      kataKunci:  editKataKunci.split(',').map(k => k.trim()).filter(Boolean),
      pembimbing: editPembimbing,
    };
  }

  function handleSaveDraft() {
    if (!karya) return;
    onSubmitRevisi(karya.id, buildData(), false);
  }

  function handleSubmitReview() {
    if (!karya) return;
    onSubmitRevisi(karya.id, buildData(), true);
  }

  let isRevisi = $derived(karya?.status === 'Perlu Revisi');
  let modalTitle = $derived(isRevisi ? 'Revisi & Penyerahan Ulang Karya' : 'Edit Karya Ilmiah');
</script>

{#if karya}
  <!-- Overlay backdrop -->
  <div class="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-on-surface/40 backdrop-blur-sm">
    <!-- Backdrop close -->
    <button type="button" aria-label="Tutup modal" class="fixed inset-0 bg-transparent cursor-default border-none w-full h-full" onclick={onClose}></button>

    <!-- Modal Box -->
    <div class="relative w-full max-w-2xl bg-surface-card rounded-2xl shadow-2xl border border-border-subtle max-h-[92vh] flex flex-col overflow-hidden z-10">

      <!-- Header -->
      <div class="p-6 border-b border-border-subtle flex items-start justify-between gap-4 bg-surface-canvas shrink-0">
        <div class="flex flex-col gap-1">
          <div class="flex items-center gap-space-sm flex-wrap">
            <div class="w-9 h-9 rounded-xl bg-primary/10 text-primary flex items-center justify-center shrink-0">
              <span class="material-symbols-outlined text-[20px]">{isRevisi ? 'edit_document' : 'edit_square'}</span>
            </div>
            <h2 class="font-headline-md text-headline-md text-text-primary">{modalTitle}</h2>
            {#if isRevisi}
              <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-status-revision/10 text-status-revision font-label-badge text-label-badge">
                <span class="w-1.5 h-1.5 rounded-full bg-status-revision animate-ping"></span>
                Perlu Revisi
              </span>
            {:else}
              <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full bg-status-draft/10 text-status-draft font-label-badge text-label-badge">
                <span class="material-symbols-outlined text-[13px]">edit_document</span>
                Draft
              </span>
            {/if}
          </div>
          <p class="font-body-sm text-body-sm text-text-secondary pl-11 line-clamp-1">{karya.judul}</p>
        </div>
        <button type="button" onclick={onClose} aria-label="Tutup" class="w-8 h-8 rounded-lg bg-surface-muted hover:bg-surface-container flex items-center justify-center text-text-secondary hover:text-on-surface transition-colors shrink-0">
          <span class="material-symbols-outlined text-[20px]">close</span>
        </button>
      </div>

      <!-- Scrollable Body -->
      <div class="flex-1 overflow-y-auto p-6 flex flex-col gap-space-lg">

        <!-- Curator Notes Alert (if revision) -->
        {#if isRevisi && karya.catatanKurator}
          <section class="w-full bg-gradient-to-r from-amber-500/10 via-amber-500/5 to-surface-card rounded-xl p-space-md shadow-sm relative overflow-hidden">
            <div class="absolute -right-8 -top-8 w-32 h-32 bg-amber-400/10 rounded-full blur-2xl pointer-events-none"></div>
            <div class="relative z-10 flex flex-col gap-space-sm">
              <div class="flex items-center gap-space-sm">
                <div class="w-9 h-9 rounded-xl bg-amber-500/20 text-amber-800 flex items-center justify-center font-bold text-sm shrink-0">RZ</div>
                <div class="flex flex-col">
                  <span class="font-headline-sm text-headline-sm text-text-primary">Catatan Kurator Perpustakaan</span>
                  <span class="font-label-caption text-label-caption text-text-secondary">Dr. M. Rizal — Kurator Utama Repositori</span>
                </div>
                <span class="ml-auto px-2 py-0.5 rounded-md bg-amber-500 text-white font-label-badge text-label-badge font-semibold shrink-0">MANDATORI</span>
              </div>
              <div class="flex items-start gap-space-xs pl-11">
                <span class="material-symbols-outlined text-amber-500 text-[20px] shrink-0 mt-0.5">format_quote</span>
                <p class="font-body-sm text-body-sm text-text-secondary italic">{karya.catatanKurator}</p>
              </div>
            </div>
          </section>
        {/if}

        <!-- Section 1: Metadata -->
        <section class="flex flex-col gap-space-md">
          <div class="flex items-center gap-space-sm pb-space-xs border-b border-border-subtle">
            <div class="w-8 h-8 rounded-lg bg-primary/10 text-primary flex items-center justify-center">
              <span class="material-symbols-outlined text-[18px]">subject</span>
            </div>
            <div>
              <h3 class="font-headline-sm text-headline-sm text-text-primary">1. Metadata Naskah</h3>
              <p class="font-label-caption text-label-caption text-text-tertiary">Perbarui informasi karya ilmiah Anda</p>
            </div>
          </div>

          <!-- Judul -->
          <div class="flex flex-col gap-1.5">
            <label for="editJudulInput" class="font-body-sm text-body-sm text-text-primary font-semibold flex items-center justify-between">
              <span>Judul Naskah Ilmiah <span class="text-error">*</span></span>
              <span class="font-label-caption text-label-caption text-text-tertiary font-normal">{editJudul.length} karakter</span>
            </label>
            <textarea
              id="editJudulInput"
              rows="2"
              bind:value={editJudul}
              placeholder="Judul karya ilmiah..."
              class="w-full px-4 py-3 rounded-xl bg-surface-canvas text-text-primary font-body-md text-body-md focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-primary/30 shadow-inner resize-none transition-all"
            ></textarea>
          </div>

          <!-- Context fields (read-only) -->
          <div class="grid grid-cols-2 gap-space-sm">
            <div class="flex flex-col gap-1">
              <span class="font-label-caption text-label-caption text-text-tertiary uppercase tracking-wider">Jenis Naskah</span>
              <div class="px-3 py-2.5 rounded-xl bg-surface-muted text-text-secondary font-body-sm text-body-sm flex items-center justify-between">
                <span>{karya.jenisLabel}</span>
                <span class="material-symbols-outlined text-[16px] text-text-tertiary">lock</span>
              </div>
            </div>
            <div class="flex flex-col gap-1">
              <span class="font-label-caption text-label-caption text-text-tertiary uppercase tracking-wider">Program Studi</span>
              <div class="px-3 py-2.5 rounded-xl bg-surface-muted text-text-secondary font-body-sm text-body-sm flex items-center justify-between truncate">
                <span class="truncate">{karya.prodi}</span>
                <span class="material-symbols-outlined text-[16px] text-text-tertiary shrink-0">school</span>
              </div>
            </div>
          </div>

          <!-- Pembimbing -->
          <div class="flex flex-col gap-1.5">
            <label for="editPembimbingInput" class="font-body-sm text-body-sm text-text-primary font-semibold">Pembimbing Utama</label>
            <input
              id="editPembimbingInput"
              type="text"
              bind:value={editPembimbing}
              placeholder="Nama Pembimbing..."
              class="w-full px-4 py-3 rounded-xl bg-surface-canvas text-text-primary font-body-md text-body-md focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-primary/30 shadow-inner transition-all"
            />
          </div>

          <!-- Kata Kunci -->
          <div class="flex flex-col gap-1.5">
            <label for="editKataKunciInput" class="font-body-sm text-body-sm text-text-primary font-semibold flex items-center justify-between">
              <span>Kata Kunci <span class="text-text-tertiary font-normal">(pisahkan dengan koma)</span></span>
              <span class="font-label-badge text-label-badge px-2 py-0.5 bg-status-published/10 text-status-published rounded-md">
                {editKataKunci.split(',').filter(k => k.trim()).length} kata
              </span>
            </label>
            <input
              id="editKataKunciInput"
              type="text"
              bind:value={editKataKunci}
              placeholder="Contoh: machine learning, IoT, deep learning"
              class="w-full px-4 py-3 rounded-xl bg-surface-canvas text-text-primary font-body-md text-body-md focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-primary/30 shadow-inner transition-all"
            />
            <div class="flex items-center gap-1 font-label-caption text-label-caption text-text-tertiary">
              <span class="material-symbols-outlined text-[13px] text-primary">lightbulb</span>
              Gunakan kata baku dan terminologi standar IEEE/ACM.
            </div>
          </div>

          <!-- Abstrak -->
          <div class="flex flex-col gap-1.5">
            <label for="editAbstrakInput" class="font-body-sm text-body-sm text-text-primary font-semibold flex items-center justify-between">
              <span>Abstrak <span class="text-error">*</span></span>
              <span class="font-label-mono-sm text-label-mono-sm text-text-tertiary">{editAbstrak.split(/\s+/).filter(Boolean).length} kata</span>
            </label>
            <textarea
              id="editAbstrakInput"
              rows="6"
              bind:value={editAbstrak}
              placeholder="Abstrak karya ilmiah (150–250 kata)..."
              class="w-full px-4 py-3 rounded-xl bg-surface-canvas text-text-secondary font-body-sm text-body-sm focus:bg-surface-card focus:outline-none focus:ring-2 focus:ring-primary/30 shadow-inner resize-y leading-relaxed transition-all"
            ></textarea>
          </div>
        </section>

        <!-- Section 2: File Upload -->
        <section class="flex flex-col gap-space-md">
          <div class="flex items-center gap-space-sm pb-space-xs border-b border-border-subtle">
            <div class="w-8 h-8 rounded-lg bg-primary/10 text-primary flex items-center justify-center">
              <span class="material-symbols-outlined text-[18px]">upload_file</span>
            </div>
            <div>
              <h3 class="font-headline-sm text-headline-sm text-text-primary">2. {isRevisi ? 'Penggantian Berkas Revisi (PDF/A)' : 'Unggah File Naskah (PDF)'}</h3>
              <p class="font-label-caption text-label-caption text-text-tertiary">Maksimal 20 MB • Format PDF</p>
            </div>
          </div>

          {#if fileSelected}
            <!-- File Selected State -->
            <div class="flex items-center gap-space-md p-space-md rounded-xl bg-status-published/5 ring-1 ring-status-published/30 shadow-sm">
              <div class="w-12 h-12 rounded-xl bg-status-published/10 text-status-published flex items-center justify-center shrink-0">
                <span class="material-symbols-outlined text-[28px]">picture_as_pdf</span>
              </div>
              <div class="flex flex-col flex-1 overflow-hidden">
                <span class="font-headline-sm text-body-sm font-semibold text-text-primary truncate">{fileName}</span>
                <span class="font-label-caption text-label-caption text-status-published flex items-center gap-1 mt-0.5">
                  <span class="material-symbols-outlined text-[13px]">task_alt</span>
                  File siap diunggah
                </span>
              </div>
              <button
                type="button"
                onclick={() => { fileSelected = false; fileName = ''; }}
                class="p-1.5 rounded-lg text-text-tertiary hover:text-error hover:bg-error-container/30 transition-colors"
                title="Hapus file"
              >
                <span class="material-symbols-outlined text-[18px]">delete</span>
              </button>
            </div>
          {:else}
            <!-- Drop Zone -->
            <label
              for="file-upload-input"
              class={[
                'flex flex-col items-center justify-center p-space-lg rounded-2xl cursor-pointer text-center transition-all group',
                isDragOver
                  ? 'bg-primary/5 ring-2 ring-primary shadow-inner'
                  : 'bg-surface-canvas shadow-inner hover:bg-surface-card'
              ].join(' ')}
              ondragover={(e) => { e.preventDefault(); isDragOver = true; }}
              ondragleave={() => isDragOver = false}
              ondrop={handleDrop}
            >
              <div class="w-14 h-14 rounded-2xl bg-primary/10 text-primary flex items-center justify-center mb-space-sm group-hover:scale-110 transition-transform">
                <span class="material-symbols-outlined text-[32px]">cloud_sync</span>
              </div>
              <p class="font-headline-sm text-headline-sm text-text-primary mb-1">
                Klik atau Seret File PDF ke Sini
              </p>
              <p class="font-body-sm text-body-sm text-text-tertiary max-w-xs">
                Format <strong>PDF/A</strong> • Maksimal <strong>20 MB</strong>
              </p>
              <div class="mt-space-sm flex items-center gap-4 text-text-tertiary font-label-mono-sm text-label-mono-sm">
                <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[13px] text-status-published">check</span>Auto PDF Validation</span>
                <span class="flex items-center gap-1"><span class="material-symbols-outlined text-[13px] text-status-published">check</span>Antivirus Scanned</span>
              </div>
            </label>
            <input
              id="file-upload-input"
              type="file"
              accept=".pdf"
              class="hidden"
              onchange={handleFileChange}
            />
          {/if}
        </section>

        <!-- Integrity pledge -->
        <div class="p-space-md rounded-xl bg-primary/5 flex items-start gap-3 shadow-inner">
          <input
            type="checkbox"
            id="integrity-agreement"
            bind:checked={agreed}
            class="mt-1 w-4 h-4 rounded text-primary focus:ring-primary cursor-pointer"
          />
          <label for="integrity-agreement" class="font-body-sm text-body-sm text-text-secondary cursor-pointer select-none leading-relaxed">
            Saya menyatakan bahwa naskah ini telah dikonsultasikan dengan dosen pembimbing, bebas plagiarisme, dan mematuhi Kode Etik Publikasi Ilmiah <strong>Immortal Campus</strong>.
          </label>
        </div>

      </div>

      <!-- Footer Actions -->
      <div class="p-4 border-t border-border-subtle bg-surface-canvas flex flex-col-reverse sm:flex-row items-stretch sm:items-center justify-between gap-3 shrink-0">
        <div class="flex items-center gap-space-xs text-text-tertiary font-label-caption text-label-caption justify-center sm:justify-start">
          <span class="material-symbols-outlined text-[14px] text-status-published">security</span>
          Data tersimpan otomatis
        </div>
        <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2">
          <button
            type="button"
            onclick={handleSaveDraft}
            class="inline-flex items-center justify-center gap-1.5 px-space-md py-2.5 rounded-xl bg-surface-muted hover:bg-surface-container text-on-surface font-headline-sm text-headline-sm transition-all"
          >
            <span class="material-symbols-outlined text-[18px]">save</span>
            Simpan Draft
          </button>
          <button
            type="button"
            onclick={handleSubmitReview}
            disabled={!agreed}
            class="inline-flex items-center justify-center gap-1.5 px-space-lg py-2.5 rounded-xl bg-primary-container text-on-primary font-headline-sm text-headline-sm shadow-[0_4px_14px_rgba(0,102,255,0.25)] hover:opacity-90 active:scale-95 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span class="material-symbols-outlined text-[18px]">send</span>
            {isRevisi ? 'Ajukan Revisi ke Kurator' : 'Ajukan ke Kurator'}
          </button>
        </div>
      </div>

    </div>
  </div>
{/if}
