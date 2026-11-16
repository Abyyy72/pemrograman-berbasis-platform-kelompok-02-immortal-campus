<script lang="ts">
  import type { Karya, RolePengguna } from '../types';

  interface Props {
    karya: Karya | null;
    activeRole: RolePengguna;
    onClose: () => void;
    onDownload: (k: Karya) => void;
    onOpenReview?: (k: Karya) => void;
  }

  let { karya, activeRole, onClose, onDownload, onOpenReview }: Props = $props();

  let citationStyle = $state<'apa' | 'ieee' | 'harvard'>('apa');
  let copiedCitation = $state(false);
  let activeTab = $state<'abstrak' | 'sitasi' | 'pratinjau'>('abstrak');

  let citationText = $derived.by(() => {
    if (!karya) return '';
    const lastWord = karya.penulis.split(' ').pop() || karya.penulis;
    const initial = karya.penulis.charAt(0);

    if (citationStyle === 'apa') {
      return `${lastWord}, ${initial}. (${karya.tahun}). ${karya.judul}. Repositori Institusi Immortal Campus. ${karya.doi ? `https://doi.org/${karya.doi}` : ''}`;
    } else if (citationStyle === 'ieee') {
      return `[1] ${initial}. ${lastWord}, "${karya.judul}," ${karya.jenisLabel}, ${karya.prodi}, Immortal Campus, ${karya.tahun}.`;
    } else {
      // Harvard
      const todayStr = new Date().toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' });
      return `${lastWord}, ${initial}., ${karya.tahun}. ${karya.judul}. [Online] Tersedia di: <portal.immortal-campus.ac.id/karya/${karya.id}> [Diakses ${todayStr}].`;
    }
  });

  function copyCitation() {
    navigator.clipboard.writeText(citationText);
    copiedCitation = true;
    setTimeout(() => copiedCitation = false, 2000);
  }
</script>

{#if karya}
  <div class="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-4 bg-on-surface/40 backdrop-blur-sm animate-fadeIn">
    <!-- Backdrop button for accessible close -->
    <button type="button" aria-label="Tutup modal" class="fixed inset-0 bg-transparent cursor-default border-none w-full h-full" onclick={onClose}></button>

    <!-- Modal Box -->
    <div class="relative w-full max-w-3xl bg-surface-card rounded-2xl sm:rounded-3xl shadow-2xl border border-border-subtle max-h-[92vh] flex flex-col overflow-hidden z-10 animate-scaleUp">
      <!-- Modal Header -->
      <div class="p-4 sm:p-6 border-b border-border-subtle flex items-start justify-between gap-3 sm:gap-4 bg-surface-canvas shrink-0">
        <div class="space-y-1 min-w-0">
          <div class="flex items-center gap-1.5 sm:gap-2 flex-wrap">
            <span class="px-2.5 py-0.5 rounded-full bg-primary/10 text-primary font-label-badge text-label-badge font-semibold">
              {karya.jenisLabel}
            </span>
            <span class="px-2.5 py-0.5 rounded-full bg-surface-muted text-text-secondary font-label-badge text-label-badge font-medium">
              {karya.prodi}
            </span>
            {#if karya.status === 'Diterbitkan'}
              <span class="inline-flex items-center gap-1 px-2.5 py-0.5 rounded-full bg-status-published/10 text-status-published font-label-badge text-label-badge font-semibold">
                <span class="material-symbols-outlined text-xs">verified</span> Terverifikasi
              </span>
            {:else}
              <span class="px-2.5 py-0.5 rounded-full bg-status-review/10 text-status-review font-label-badge text-label-badge font-semibold">
                {karya.status}
              </span>
            {/if}
          </div>
          <h2 class="font-headline-lg text-base sm:text-xl font-bold text-text-primary leading-snug mt-1.5">
            {karya.judul}
          </h2>
          {#if karya.doi}
            <p class="font-label-mono-sm text-label-mono-sm text-text-tertiary truncate">DOI: {karya.doi}</p>
          {/if}
        </div>

        <button
          onclick={onClose}
          class="p-1.5 sm:p-2 rounded-xl text-text-tertiary hover:text-text-primary hover:bg-surface-muted transition-colors shrink-0"
        >
          <span class="material-symbols-outlined text-xl sm:text-2xl">close</span>
        </button>
      </div>

      <!-- Tab bar -->
      <div class="flex border-b border-border-subtle px-3 sm:px-6 bg-surface shrink-0 overflow-x-auto scrollbar-none">
        <button
          onclick={() => activeTab = 'abstrak'}
          class="shrink-0 py-2.5 sm:py-3 px-3 sm:px-4 font-semibold text-xs sm:text-sm border-b-2 transition-colors {activeTab === 'abstrak' ? 'border-primary text-primary' : 'border-transparent text-text-secondary hover:text-text-primary'}"
        >
          Informasi &amp; Abstrak
        </button>
        <button
          onclick={() => activeTab = 'sitasi'}
          class="shrink-0 py-2.5 sm:py-3 px-3 sm:px-4 font-semibold text-xs sm:text-sm border-b-2 transition-colors {activeTab === 'sitasi' ? 'border-primary text-primary' : 'border-transparent text-text-secondary hover:text-text-primary'}"
        >
          Sitasi &amp; Referensi
        </button>
        <button
          onclick={() => activeTab = 'pratinjau'}
          class="shrink-0 py-2.5 sm:py-3 px-3 sm:px-4 font-semibold text-xs sm:text-sm border-b-2 transition-colors {activeTab === 'pratinjau' ? 'border-primary text-primary' : 'border-transparent text-text-secondary hover:text-text-primary'}"
        >
          Pratinjau Naskah (PDF)
        </button>
      </div>

      <!-- Modal Body -->
      <div class="p-4 sm:p-6 overflow-y-auto flex-1 space-y-5 sm:space-y-6">
        {#if activeTab === 'abstrak'}
          <!-- Metadata Table Grid -->
          <div class="grid grid-cols-2 sm:grid-cols-3 gap-4 p-4 rounded-2xl bg-surface-muted/50 border border-border-subtle text-xs">
            <div>
              <span class="text-text-tertiary block mb-0.5">Penulis Utama:</span>
              <strong class="text-text-primary">{karya.penulis}</strong>
              {#if karya.nim}
                <span class="text-text-tertiary block mt-0.5">NIM: {karya.nim}</span>
              {/if}
            </div>
            <div>
              <span class="text-text-tertiary block mb-0.5">Dosen Pembimbing:</span>
              <strong class="text-text-primary">{karya.pembimbing}</strong>
            </div>
            <div>
              <span class="text-text-tertiary block mb-0.5">Tahun Sidang / Terbit:</span>
              <strong class="text-text-primary">{karya.tahun}</strong> ({karya.tanggalTerbit})
            </div>
            <div>
              <span class="text-text-tertiary block mb-0.5">Jumlah Unduhan:</span>
              <span class="text-primary font-bold flex items-center gap-1">
                <span class="material-symbols-outlined text-sm">download</span>
                {karya.unduhan} kali
              </span>
            </div>
            <div>
              <span class="text-text-tertiary block mb-0.5">Ukuran File:</span>
              <strong class="text-text-primary">{karya.fileSize || 'PDF Resmi'}</strong>
            </div>
            <div>
              <span class="text-text-tertiary block mb-0.5">Lisensi:</span>
              <span class="text-text-primary font-medium">CC BY-NC 4.0</span>
            </div>
          </div>

          <!-- Abstract -->
          <div class="space-y-2">
            <h4 class="font-headline-sm text-sm font-bold text-text-primary uppercase tracking-wider text-xs">Abstrak Penelitian</h4>
            <p class="font-body-md text-sm text-text-secondary leading-relaxed bg-surface-canvas p-4 rounded-xl border border-border-subtle/50">
              {karya.abstrak}
            </p>
          </div>

          <!-- Keywords -->
          <div class="space-y-2">
            <h4 class="font-headline-sm text-xs font-bold text-text-primary uppercase tracking-wider">Kata Kunci (Keywords)</h4>
            <div class="flex flex-wrap gap-1.5">
              {#each karya.kataKunci as tag}
                <span class="px-3 py-1 rounded-lg bg-surface-muted text-text-secondary text-xs font-medium border border-border-subtle/40">
                  #{tag}
                </span>
              {/each}
            </div>
          </div>
        {:else if activeTab === 'sitasi'}
          <div class="space-y-4">
            <div class="flex items-center gap-2">
              <span class="text-xs font-semibold text-text-secondary">Pilih Format Sitasi:</span>
              <button
                onclick={() => citationStyle = 'apa'}
                class="px-2.5 py-1 rounded-lg text-xs font-semibold {citationStyle === 'apa' ? 'bg-primary text-on-primary' : 'bg-surface-muted text-text-secondary'}"
              >
                APA 7th
              </button>
              <button
                onclick={() => citationStyle = 'ieee'}
                class="px-2.5 py-1 rounded-lg text-xs font-semibold {citationStyle === 'ieee' ? 'bg-primary text-on-primary' : 'bg-surface-muted text-text-secondary'}"
              >
                IEEE
              </button>
              <button
                onclick={() => citationStyle = 'harvard'}
                class="px-2.5 py-1 rounded-lg text-xs font-semibold {citationStyle === 'harvard' ? 'bg-primary text-on-primary' : 'bg-surface-muted text-text-secondary'}"
              >
                Harvard
              </button>
            </div>

            <div class="p-4 rounded-xl bg-surface-muted font-label-mono-sm text-xs text-text-primary leading-relaxed border border-border-subtle">
              {citationText}
            </div>

            <button
              onclick={copyCitation}
              class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-primary text-on-primary font-semibold text-xs shadow-sm hover:bg-primary-container transition-all"
            >
              <span class="material-symbols-outlined text-sm">{copiedCitation ? 'done' : 'content_copy'}</span>
              <span>{copiedCitation ? 'Tersalin ke Clipboard!' : 'Salin Sitasi'}</span>
            </button>
          </div>
        {:else if activeTab === 'pratinjau'}
          <!-- Simulated PDF Previewer -->
          <div class="rounded-2xl border border-border-subtle bg-surface-canvas p-6 flex flex-col items-center justify-center text-center space-y-4 min-h-[260px]">
            <div class="w-16 h-16 rounded-2xl bg-primary/10 text-primary flex items-center justify-center">
              <span class="material-symbols-outlined text-3xl">picture_as_pdf</span>
            </div>
            <div>
              <h4 class="font-bold text-text-primary text-sm">{karya.judul}.pdf</h4>
              <p class="text-xs text-text-secondary mt-1">Dokumen Resmi Repositori Institusi ({karya.fileSize || 'PDF'})</p>
            </div>
            <div class="flex items-center justify-center gap-3 pt-2 w-full">
              <button
                onclick={() => onDownload(karya)}
                class="inline-flex items-center gap-2 px-5 py-2.5 rounded-xl bg-primary text-on-primary font-semibold text-xs shadow-sm hover:bg-primary-container transition-all whitespace-nowrap"
              >
                <span class="material-symbols-outlined text-base">download</span>
                <span>Unduh File Lengkap</span>
              </button>
            </div>
          </div>
        {/if}
      </div>

      <!-- Modal Footer -->
      <div class="p-4 sm:p-6 border-t border-border-subtle bg-surface-canvas flex flex-col sm:flex-row items-stretch sm:items-center justify-between gap-3 shrink-0">
        <div class="text-xs text-text-tertiary flex items-center gap-1.5 min-w-0">
          <span class="material-symbols-outlined text-sm text-status-published shrink-0">security</span>
          <span class="text-[11px] sm:text-xs">Setiap unduhan dicatat secara anonim untuk akreditasi.</span>
        </div>

        <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-2 justify-end shrink-0">
          {#if activeRole === 'kurator' && onOpenReview}
            <button
              onclick={() => { onOpenReview(karya); onClose(); }}
              class="inline-flex items-center justify-center gap-1.5 px-4 py-2.5 rounded-xl border border-status-review bg-status-review/10 text-status-review font-semibold text-xs hover:bg-status-review/20 transition-colors whitespace-nowrap"
            >
              <span class="material-symbols-outlined text-base">fact_check</span>
              <span>Review Kurator</span>
            </button>
          {/if}
          <button
            onclick={() => onDownload(karya)}
            class="inline-flex items-center justify-center gap-2 px-5 py-2.5 rounded-xl bg-primary hover:bg-primary-container text-on-primary font-semibold text-xs shadow-md transition-all whitespace-nowrap"
          >
            <span class="material-symbols-outlined text-base">download</span>
            <span>Unduh Naskah PDF</span>
          </button>
        </div>
      </div>
    </div>
  </div>
{/if}
