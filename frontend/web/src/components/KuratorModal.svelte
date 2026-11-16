<script lang="ts">
  import type { Karya, StatusKarya } from '../types';

  interface Props {
    karya: Karya | null;
    onClose: () => void;
    onUpdateStatus: (karyaId: string, newStatus: StatusKarya, catatan?: string) => void;
  }

  let { karya, onClose, onUpdateStatus }: Props = $props();

  type DecisionType = 'terbitkan' | 'revisi' | 'tolak';

  let actionType = $state<DecisionType>('terbitkan');
  let catatan = $state('');

  // Derived: is catatan required and valid?
  let catatanRequired = $derived(actionType === 'revisi' || actionType === 'tolak');
  let catatanValid = $derived(!catatanRequired || catatan.trim().length >= 20);

  // Turnitin score color logic
  function turnitinColor(score: number): string {
    if (score > 25) return '#EF4444';
    if (score >= 15) return '#EAB308';
    return '#10B981';
  }

  function turnitinLabel(score: number): string {
    if (score > 25) return 'Tinggi';
    if (score >= 15) return 'Sedang';
    return 'Rendah';
  }

  // Circular progress SVG parameters
  const radius = 42;
  const circ = 2 * Math.PI * radius;

  function strokeDash(score: number): number {
    const pct = Math.min(score / 100, 1);
    return circ * pct;
  }

  // Turnitin score from karya (if not present, default to 0)
  let turnitinScore = $derived((karya as any)?.turnitinScore ?? 0);

  // Status bar color
  let statusBarColor = $derived(
    actionType === 'terbitkan'
      ? '#10B981'
      : actionType === 'revisi'
      ? '#F97316'
      : '#EF4444'
  );

  // Status badge color/label for current karya status
  function statusBadgeClass(status: string): string {
    const map: Record<string, string> = {
      'Diterbitkan': 'bg-status-published/10 text-status-published',
      'Perlu Revisi': 'bg-status-revision/10 text-status-revision',
      'Ditolak': 'bg-error/10 text-error',
      'Dalam Review': 'bg-status-review/10 text-status-review',
      'Diajukan': 'bg-status-submitted/10 text-status-submitted',
      'Draft': 'bg-status-draft/10 text-status-draft',
    };
    return map[status] ?? 'bg-surface-container text-text-secondary';
  }

  function handleAction() {
    if (!karya) return;
    if (catatanRequired && catatan.trim().length < 20) {
      alert('Catatan kurator wajib minimal 20 karakter untuk tindakan Minta Revisi atau Tolak!');
      return;
    }
    let nextStatus: StatusKarya = 'Diterbitkan';
    if (actionType === 'revisi') nextStatus = 'Perlu Revisi';
    if (actionType === 'tolak') nextStatus = 'Ditolak';
    onUpdateStatus(karya.id, nextStatus, catatan.trim() || undefined);
    onClose();
  }

  function handleBackdropClick(e: MouseEvent) {
    if (e.target === e.currentTarget) onClose();
  }
</script>

{#if karya}
  <!-- Backdrop -->
  <!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions a11y-click-events-have-key-events a11y-no-static-element-interactions -->
  <div
    class="fixed inset-0 z-50 flex items-center justify-center p-3 sm:p-6 bg-slate-950/70 backdrop-blur-md overflow-y-auto"
    onclick={handleBackdropClick}
    role="presentation"
  >
    <!-- Modal dialog -->
    <div class="relative w-full max-w-4xl bg-surface-card rounded-2xl shadow-[0_24px_50px_rgba(15,23,42,0.32)] my-auto flex flex-col overflow-hidden max-h-[92vh]">

      <!-- Top status bar (color changes with decision) -->
      <div class="h-1.5 w-full transition-colors duration-300 shrink-0" style="background:{statusBarColor}"></div>

      <!-- ── HEADER ── -->
      <div class="p-4 sm:p-7 bg-surface-card shrink-0">
        <div class="flex items-start justify-between gap-3 sm:gap-4">
          <div class="flex items-start gap-3 sm:gap-3.5 min-w-0">
            <!-- Icon badge -->
            <div
              class="w-10 h-10 sm:w-12 sm:h-12 rounded-xl flex items-center justify-center flex-shrink-0 shadow-sm transition-colors duration-300"
              style="background:{statusBarColor}22; color:{statusBarColor}"
            >
              <span class="material-symbols-outlined text-[24px] sm:text-[28px]">
                {actionType === 'terbitkan' ? 'verified' : actionType === 'revisi' ? 'rule_settings' : 'cancel'}
              </span>
            </div>
            <div class="flex flex-col min-w-0">
              <!-- Meta badges row -->
              <div class="flex flex-wrap items-center gap-1.5 sm:gap-2 mb-1">
                <span class="px-2.5 py-0.5 rounded-full bg-surface-container-low text-primary font-label-mono-sm text-label-mono-sm font-semibold tracking-wide">
                  {karya.jenis.toUpperCase()}-{karya.tahun}
                </span>
                <span class="px-2.5 py-0.5 rounded-full bg-surface-container-high text-secondary font-label-badge text-label-badge font-medium">
                  {karya.jenisLabel}
                </span>
                <span class="px-2.5 py-0.5 rounded-full font-label-badge text-label-badge font-semibold {statusBadgeClass(karya.status)}">
                  {karya.status}
                </span>
              </div>
              <h2 class="font-headline-lg text-base sm:text-headline-lg text-on-surface font-bold tracking-tight">
                Keputusan Kurasi &amp; Validasi Naskah
              </h2>
              <p class="font-body-sm text-xs sm:text-body-sm text-text-secondary mt-0.5 truncate">
                Penulis: <span class="font-semibold text-on-surface">{karya.penulis}</span>
                {#if karya.nim} <span class="text-text-tertiary">(NIM {karya.nim})</span>{/if}
                &nbsp;• {karya.prodi}
              </p>
            </div>
          </div>

          <!-- Close button -->
          <button
            onclick={onClose}
            class="w-9 h-9 rounded-xl bg-surface-canvas hover:bg-surface-container-high text-text-secondary hover:text-on-surface flex items-center justify-center transition-colors flex-shrink-0"
            aria-label="Tutup dialog"
          >
            <span class="material-symbols-outlined text-[20px]">close</span>
          </button>
        </div>

        <!-- Judul naskah banner -->
        <div class="mt-3 sm:mt-4 p-3 sm:p-3.5 rounded-xl bg-surface-container-low flex items-start gap-2.5 sm:gap-3">
          <span class="material-symbols-outlined text-primary text-[20px] mt-0.5 flex-shrink-0">article</span>
          <div class="flex flex-col min-w-0">
            <span class="font-label-caption text-label-caption text-text-secondary uppercase tracking-wider font-semibold">Judul Naskah</span>
            <p class="font-headline-sm text-xs sm:text-headline-sm text-on-surface font-semibold mt-0.5 leading-snug line-clamp-2 sm:line-clamp-none">
              {karya.judul}
            </p>
          </div>
        </div>
      </div>

      <!-- ── BODY ── -->
      <div class="px-4 sm:px-7 pb-6 space-y-5 sm:space-y-6 flex-1 overflow-y-auto">

        <!-- Row: Turnitin Score + Abstrak -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">

          <!-- Turnitin circular indicator -->
          <div class="md:col-span-1 bg-surface-canvas rounded-xl p-5 flex flex-col items-center justify-center gap-3">
            <span class="font-label-caption text-label-caption text-text-secondary uppercase tracking-wider font-semibold">Turnitin Score</span>
            <div class="relative w-28 h-28">
              <svg class="w-full h-full -rotate-90" viewBox="0 0 100 100">
                <!-- Track -->
                <circle
                  cx="50" cy="50"
                  r={radius}
                  fill="none"
                  stroke="#E2E8F0"
                  stroke-width="10"
                />
                <!-- Progress arc -->
                <circle
                  cx="50" cy="50"
                  r={radius}
                  fill="none"
                  stroke={turnitinColor(turnitinScore)}
                  stroke-width="10"
                  stroke-linecap="round"
                  stroke-dasharray="{strokeDash(turnitinScore)} {circ}"
                  class="transition-all duration-700"
                />
              </svg>
              <div class="absolute inset-0 flex flex-col items-center justify-center">
                <span class="font-headline-lg text-headline-lg font-bold" style="color:{turnitinColor(turnitinScore)}">{turnitinScore}%</span>
              </div>
            </div>
            <span
              class="px-3 py-1 rounded-full font-label-badge text-label-badge font-semibold"
              style="background:{turnitinColor(turnitinScore)}22; color:{turnitinColor(turnitinScore)}"
            >
              {turnitinLabel(turnitinScore)} — {turnitinScore > 25 ? 'Di atas batas' : turnitinScore >= 15 ? 'Perlu perhatian' : 'Aman'}
            </span>
          </div>

          <!-- Abstrak preview -->
          <div class="md:col-span-2 bg-surface-canvas rounded-xl p-4 flex flex-col gap-2">
            <span class="font-label-caption text-label-caption text-text-secondary uppercase tracking-wider font-semibold flex items-center gap-1.5">
              <span class="material-symbols-outlined text-[14px]">description</span>
              Abstrak
            </span>
            <div class="overflow-y-auto max-h-36 pr-1">
              <p class="font-body-sm text-body-sm text-on-surface leading-relaxed">{karya.abstrak}</p>
            </div>
            {#if karya.kataKunci?.length}
              <div class="flex flex-wrap gap-1.5 pt-1 border-t border-border-subtle">
                {#each karya.kataKunci as kk}
                  <span class="px-2 py-0.5 rounded-full bg-surface-container-high text-text-secondary font-label-caption text-label-caption">{kk}</span>
                {/each}
              </div>
            {/if}
          </div>
        </div>

        <!-- ── DECISION CARDS ── -->
        <div class="space-y-2.5">
          <div class="flex items-center justify-between">
            <span class="font-headline-sm text-headline-sm text-on-surface font-semibold flex items-center gap-2">
              <span class="flex items-center justify-center w-5 h-5 rounded-full bg-primary text-on-primary font-label-mono-sm text-[11px] font-bold">1</span>
              <span>Tentukan Hasil Kurasi</span>
            </span>
            <span class="font-label-caption text-label-caption text-text-tertiary">Pilih salah satu status legal</span>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-3">

            <!-- ✅ Terbitkan -->
            <button
              type="button"
              onclick={() => { actionType = 'terbitkan'; }}
              class="relative flex flex-col p-4 rounded-xl cursor-pointer text-left transition-all duration-200 border-2
                {actionType === 'terbitkan'
                  ? 'bg-status-published/5 border-status-published shadow-sm'
                  : 'bg-surface-canvas border-transparent hover:bg-surface-container-low hover:border-border-subtle'}"
            >
              <div class="flex items-center justify-between mb-2">
                <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full font-label-badge text-label-badge font-bold
                  {actionType === 'terbitkan' ? 'bg-status-published/15 text-status-published' : 'bg-surface-container-high text-text-secondary'}">
                  <span class="w-1.5 h-1.5 rounded-full {actionType === 'terbitkan' ? 'bg-status-published' : 'bg-text-tertiary'}"></span>
                  Terima &amp; Terbitkan
                </span>
                <span class="material-symbols-outlined text-[20px] {actionType === 'terbitkan' ? 'text-status-published' : 'text-text-tertiary'}">
                  {actionType === 'terbitkan' ? 'radio_button_checked' : 'radio_button_unchecked'}
                </span>
              </div>
              <span class="font-headline-sm text-headline-sm text-on-surface font-semibold">Terbitkan Karya</span>
              <p class="font-body-sm text-body-sm text-text-secondary mt-1 leading-snug">
                Naskah memenuhi standar lengkap. Siap tayang di etalase publik dan diindeks OAI-PMH.
              </p>
            </button>

            <!-- 📝 Minta Revisi -->
            <button
              type="button"
              onclick={() => { actionType = 'revisi'; }}
              class="relative flex flex-col p-4 rounded-xl cursor-pointer text-left transition-all duration-200 border-2
                {actionType === 'revisi'
                  ? 'bg-status-revision/5 border-status-revision shadow-sm'
                  : 'bg-surface-canvas border-transparent hover:bg-surface-container-low hover:border-border-subtle'}"
            >
              <div class="flex items-center justify-between mb-2">
                <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full font-label-badge text-label-badge font-bold
                  {actionType === 'revisi' ? 'bg-status-revision/15 text-status-revision' : 'bg-surface-container-high text-text-secondary'}">
                  <span class="w-1.5 h-1.5 rounded-full {actionType === 'revisi' ? 'bg-status-revision animate-pulse' : 'bg-text-tertiary'}"></span>
                  Kembalikan Revisi
                </span>
                <span class="material-symbols-outlined text-[20px] {actionType === 'revisi' ? 'text-status-revision' : 'text-text-tertiary'}">
                  {actionType === 'revisi' ? 'radio_button_checked' : 'radio_button_unchecked'}
                </span>
              </div>
              <span class="font-headline-sm text-headline-sm text-on-surface font-semibold">Minta Revisi</span>
              <p class="font-body-sm text-body-sm text-text-secondary mt-1 leading-snug">
                Terdapat catatan format atau metadata yang wajib diperbaiki sebelum persetujuan publik.
              </p>
            </button>

            <!-- ❌ Tolak Permanen -->
            <button
              type="button"
              onclick={() => { actionType = 'tolak'; }}
              class="relative flex flex-col p-4 rounded-xl cursor-pointer text-left transition-all duration-200 border-2
                {actionType === 'tolak'
                  ? 'bg-error/5 border-error shadow-sm'
                  : 'bg-surface-canvas border-transparent hover:bg-surface-container-low hover:border-border-subtle'}"
            >
              <div class="flex items-center justify-between mb-2">
                <span class="inline-flex items-center gap-1.5 px-2.5 py-0.5 rounded-full font-label-badge text-label-badge font-bold
                  {actionType === 'tolak' ? 'bg-error/15 text-error' : 'bg-surface-container-high text-text-secondary'}">
                  <span class="w-1.5 h-1.5 rounded-full {actionType === 'tolak' ? 'bg-error' : 'bg-text-tertiary'}"></span>
                  Tolak Permanen
                </span>
                <span class="material-symbols-outlined text-[20px] {actionType === 'tolak' ? 'text-error' : 'text-text-tertiary'}">
                  {actionType === 'tolak' ? 'radio_button_checked' : 'radio_button_unchecked'}
                </span>
              </div>
              <span class="font-headline-sm text-headline-sm text-on-surface font-semibold">Tolak Karya</span>
              <p class="font-body-sm text-body-sm text-text-secondary mt-1 leading-snug">
                Karya tidak memenuhi kualifikasi (duplikasi terbukti, plagiasi mayor, atau naskah tidak relevan).
              </p>
            </button>
          </div>
        </div>

        <!-- ── CATATAN / ALASAN ── -->
        <div class="flex flex-col space-y-2">
          <div class="flex items-center justify-between">
            <label class="font-headline-sm text-headline-sm text-on-surface font-semibold flex items-center gap-2" for="kurator-catatan">
              <span class="flex items-center justify-center w-5 h-5 rounded-full bg-primary text-on-primary font-label-mono-sm text-[11px] font-bold">2</span>
              <span>
                {#if actionType === 'terbitkan'}
                  Catatan Apresiasi (Opsional)
                {:else if actionType === 'revisi'}
                  Arahan Revisi <span class="text-error font-normal text-body-sm">*Wajib, min. 20 karakter</span>
                {:else}
                  Alasan Penolakan <span class="text-error font-normal text-body-sm">*Wajib, min. 20 karakter</span>
                {/if}
              </span>
            </label>
            <span class="font-label-mono-sm text-label-mono-sm text-text-secondary">{catatan.length} karakter</span>
          </div>

          <div class="relative rounded-xl bg-surface-canvas focus-within:bg-surface-card transition-all">
            <textarea
              id="kurator-catatan"
              bind:value={catatan}
              rows="4"
              placeholder={
                actionType === 'revisi'
                  ? 'Sebutkan bagian yang perlu diperbaiki, misal: format TTE BSrE, kata kunci IEEE, dll...'
                  : actionType === 'tolak'
                  ? 'Jelaskan alasan penolakan secara jelas dan spesifik...'
                  : 'Catatan apresiasi atau pengantar indeksasi (opsional)'
              }
              class="w-full p-4 rounded-xl bg-transparent font-body-md text-body-md text-on-surface placeholder:text-text-tertiary focus:outline-none resize-none leading-relaxed"
            ></textarea>
          </div>

          {#if catatanRequired && catatan.trim().length > 0 && catatan.trim().length < 20}
            <p class="font-label-caption text-label-caption text-error flex items-center gap-1">
              <span class="material-symbols-outlined text-[14px]">warning</span>
              Catatan minimal 20 karakter ({20 - catatan.trim().length} karakter lagi)
            </p>
          {:else}
            <p class="font-label-caption text-label-caption text-text-secondary flex items-center gap-1.5">
              <span class="material-symbols-outlined text-[16px] text-primary">info</span>
              <span>Instruksi ini diteruskan langsung ke notifikasi mahasiswa dan rekam jejak repositori.</span>
            </p>
          {/if}
        </div>
      </div>

      <!-- ── FOOTER ── -->
      <div class="p-4 sm:p-6 bg-surface-canvas flex flex-col-reverse sm:flex-row items-center justify-between gap-3 shadow-[0_-1px_0_rgba(0,0,0,0.06)] shrink-0">
        <button
          type="button"
          onclick={onClose}
          class="w-full sm:w-auto px-4 py-2.5 rounded-xl bg-surface-card hover:bg-surface-container-high text-on-surface font-body-sm text-body-sm font-semibold transition-all shadow-sm"
        >
          Batalkan
        </button>

        <button
          type="button"
          onclick={handleAction}
          disabled={!catatanValid}
          class="w-full sm:w-auto flex items-center justify-center gap-2 px-6 py-2.5 rounded-xl text-white font-body-sm text-body-sm font-bold shadow-md hover:opacity-95 transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          style="background:{statusBarColor}"
        >
          <span class="material-symbols-outlined text-[18px]">
            {actionType === 'terbitkan' ? 'verified' : actionType === 'revisi' ? 'outgoing_mail' : 'block'}
          </span>
          <span>
            {actionType === 'terbitkan'
              ? 'Konfirmasi: Terbitkan Karya'
              : actionType === 'revisi'
              ? 'Konfirmasi: Minta Revisi'
              : 'Konfirmasi: Tolak Karya'}
          </span>
        </button>
      </div>
    </div>
  </div>
{/if}
