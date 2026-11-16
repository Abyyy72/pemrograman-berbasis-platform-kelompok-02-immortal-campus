<script lang="ts">
  import type { RolePengguna } from '../types';
  import { apiLogin, apiRegister } from '../lib/api';

  interface Props {
    isOpen: boolean;
    onClose: () => void;
    onLoginSuccess: (role: RolePengguna, userEmail: string, token?: string, userData?: any) => void;
  }

  let { isOpen, onClose, onLoginSuccess }: Props = $props();

  // Tab state
  let activeTab = $state<'login' | 'register'>('login');

  // Login form state
  let loginEmail = $state('');
  let loginPassword = $state('');
  let rememberMe = $state(false);
  let showPassword = $state(false);
  let loginError = $state<string | null>(null);

  // Register form state
  let regNama = $state('');
  let regNim = $state('');
  let regEmail = $state('');
  let regProdi = $state('Teknik Informatika');
  let regPassword = $state('');
  let regConfirmPassword = $state('');
  let registerError = $state<string | null>(null);

  // Forgot password overlay
  let showForgot = $state(false);
  let forgotInput = $state('');

  // Loading state
  let isLoading = $state(false);

  async function handleLogin(e: Event) {
    e.preventDefault();
    loginError = null;

    const identifier = loginEmail.trim();
    if (!identifier || !loginPassword) {
      loginError = 'Harap isi email/NIM/NIP dan kata sandi Anda.';
      return;
    }

    isLoading = true;

    try {
      const data = await apiLogin(identifier, loginPassword);
      onLoginSuccess(data.user.role, data.user.email, data.token, data.user);
      onClose();
    } catch (err: any) {
      loginError = err.message || 'Login gagal. Periksa kembali kredensial Anda.';
    } finally {
      isLoading = false;
    }
  }

  async function handleRegister(e: Event) {
    e.preventDefault();
    registerError = null;

    if (!regNama.trim()) {
      registerError = 'Nama lengkap wajib diisi.';
      return;
    }
    if (!regEmail.trim()) {
      registerError = 'Email resmi kampus wajib diisi.';
      return;
    }
    if (!regPassword || regPassword.length < 6) {
      registerError = 'Kata sandi minimal 6 karakter.';
      return;
    }
    if (regPassword !== regConfirmPassword) {
      registerError = 'Kata sandi dan konfirmasi sandi tidak cocok!';
      return;
    }

    isLoading = true;
    const role: 'penulis' | 'kurator' = regProdi === 'UPT Perpustakaan' ? 'kurator' : 'penulis';

    try {
      const payload: any = {
        nama: regNama.trim(),
        email: regEmail.trim(),
        password: regPassword,
        prodi: regProdi || 'Teknik Informatika',
        role,
      };

      if (role === 'penulis') {
        payload.nim = regNim.trim() || undefined;
      } else {
        payload.nip = regNim.trim() || undefined;
      }

      const data = await apiRegister(payload);
      onLoginSuccess(data.user.role, data.user.email, data.token, data.user);
      onClose();
    } catch (err: any) {
      registerError = err.message || 'Registrasi gagal. Silakan coba kembali.';
    } finally {
      isLoading = false;
    }
  }

  function sendForgot() {
    alert('Instruksi pemulihan telah dikirimkan ke email kampus Anda.');
    showForgot = false;
    forgotInput = '';
  }

  function handleBackdropClick(e: MouseEvent) {
    if (e.target === e.currentTarget) onClose();
  }
</script>

{#if isOpen}
  <!-- Backdrop -->
  <!-- svelte-ignore a11y_click_events_have_key_events a11y_no_static_element_interactions a11y-click-events-have-key-events a11y-no-static-element-interactions -->
  <div
    class="fixed inset-0 z-50 flex items-start justify-center p-3 sm:p-4 pt-6 sm:pt-16 bg-slate-950/60 backdrop-blur-md overflow-y-auto"
    onclick={handleBackdropClick}
    role="presentation"
  >
    <!-- Card -->
    <div class="relative w-full max-w-xl bg-surface-card rounded-2xl shadow-[0_24px_50px_rgba(15,23,42,0.28)] overflow-hidden z-10 my-auto">

      <!-- Decorative glow blobs -->
      <div class="absolute -top-20 -left-20 w-64 h-64 bg-primary-container/10 rounded-full blur-3xl pointer-events-none"></div>
      <div class="absolute -bottom-20 -right-20 w-64 h-64 bg-secondary-container/10 rounded-full blur-3xl pointer-events-none"></div>

      <!-- Header branding -->
      <div class="relative z-10 pt-6 sm:pt-8 pb-4 sm:pb-5 px-4 sm:px-8 text-center space-y-2 sm:space-y-3">
        <img
          alt="Immortal Campus Logo"
          class="h-24 sm:h-32 w-auto object-contain mx-auto"
          src="/logo.png"
        />
        <p class="font-body-sm text-xs sm:text-body-sm text-text-secondary">Portal Repositori &amp; Etalase Digital Karya Ilmiah</p>
      </div>

      <!-- Close button -->
      <button
        onclick={onClose}
        class="absolute top-3 right-3 sm:top-4 sm:right-4 w-8 h-8 sm:w-9 sm:h-9 rounded-xl bg-surface-canvas hover:bg-surface-container-high text-text-secondary hover:text-on-surface flex items-center justify-center transition-colors z-20 cursor-pointer"
        aria-label="Tutup modal"
      >
        <span class="material-symbols-outlined text-[18px] sm:text-[20px]">close</span>
      </button>

      <!-- Card inner -->
      <div class="relative z-10 px-4 sm:px-8 pb-6 sm:pb-8 space-y-4 sm:space-y-5">
        <!-- Tabs selector -->
        <div class="flex p-1 bg-surface-canvas rounded-xl border border-border-subtle">
          <button
            type="button"
            onclick={() => { activeTab = 'login'; loginError = null; registerError = null; }}
            class="flex-1 py-2 px-3 rounded-lg font-headline-sm text-headline-sm transition-all text-center flex items-center justify-center gap-2 cursor-pointer
              {activeTab === 'login'
                ? 'bg-primary-container text-on-primary-container shadow-sm'
                : 'text-text-secondary hover:text-on-surface'}"
          >
            <span class="material-symbols-outlined text-[18px]">login</span>
            <span>Masuk Akun</span>
          </button>
          <button
            type="button"
            onclick={() => { activeTab = 'register'; loginError = null; registerError = null; }}
            class="flex-1 py-2 px-3 rounded-lg font-headline-sm text-headline-sm transition-all text-center flex items-center justify-center gap-2 cursor-pointer
              {activeTab === 'register'
                ? 'bg-primary-container text-on-primary-container shadow-sm'
                : 'text-text-secondary hover:text-on-surface'}"
          >
            <span class="material-symbols-outlined text-[18px]">person_add</span>
            <span>Aktivasi / Daftar</span>
          </button>
        </div>

        <!-- ── LOGIN PANEL ── -->
        {#if activeTab === 'login'}
          <div class="space-y-4">
            {#if loginError}
              <div class="p-3 rounded-xl bg-error/10 border border-error/20 text-error text-xs flex items-center gap-2 animate-fadeIn">
                <span class="material-symbols-outlined text-base">error</span>
                <span>{loginError}</span>
              </div>
            {/if}

            <form onsubmit={handleLogin} class="space-y-4">
              <!-- Email / NIM field -->
              <div class="space-y-1.5">
                <label for="loginEmailInput" class="font-label-badge text-label-badge text-on-surface font-semibold flex items-center justify-between">
                  <span>Email Kampus / NIM / NIP</span>
                </label>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-text-tertiary">
                    <span class="material-symbols-outlined text-[20px]">badge</span>
                  </div>
                  <input
                    id="loginEmailInput"
                    bind:value={loginEmail}
                    type="text"
                    required
                    placeholder="Masukkan Email, NIM, atau NIP Anda"
                    class="w-full pl-11 pr-4 py-2.5 rounded-xl bg-surface-canvas text-on-surface font-body-md text-body-md placeholder:text-text-tertiary focus:outline-none focus:bg-surface-card focus:shadow-[0_0_0_3px_rgba(0,102,255,0.2)] transition-all"
                  />
                </div>
              </div>

              <!-- Password field -->
              <div class="space-y-1.5">
                <div class="flex items-center justify-between">
                  <label for="loginPasswordInput" class="font-label-badge text-label-badge text-on-surface font-semibold">Kata Sandi</label>
                  <button
                    type="button"
                    onclick={() => { showForgot = true; }}
                    class="font-label-badge text-label-badge text-primary hover:underline font-medium cursor-pointer"
                  >Lupa Sandi?</button>
                </div>
                <div class="relative">
                  <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-text-tertiary">
                    <span class="material-symbols-outlined text-[20px]">key</span>
                  </div>
                  <input
                    id="loginPasswordInput"
                    bind:value={loginPassword}
                    type={showPassword ? 'text' : 'password'}
                    required
                    placeholder="Masukkan kata sandi Anda"
                    class="w-full pl-11 pr-11 py-2.5 rounded-xl bg-surface-canvas text-on-surface font-body-md text-body-md placeholder:text-text-tertiary focus:outline-none focus:bg-surface-card focus:shadow-[0_0_0_3px_rgba(0,102,255,0.2)] transition-all"
                  />
                  <button
                    type="button"
                    onclick={() => { showPassword = !showPassword; }}
                    class="absolute inset-y-0 right-0 pr-3.5 flex items-center text-text-tertiary hover:text-on-surface cursor-pointer"
                  >
                    <span class="material-symbols-outlined text-[20px]">{showPassword ? 'visibility_off' : 'visibility'}</span>
                  </button>
                </div>
              </div>

              <!-- Remember me -->
              <div class="flex items-center justify-between pt-1">
                <label class="flex items-center gap-2 cursor-pointer select-none">
                  <input bind:checked={rememberMe} type="checkbox" class="w-4 h-4 rounded text-primary focus:ring-primary-container bg-surface-canvas cursor-pointer" />
                  <span class="font-body-sm text-body-sm text-text-secondary">Ingat saya di perangkat ini</span>
                </label>
              </div>

              <!-- Submit button -->
              <button
                type="submit"
                disabled={isLoading}
                class="w-full py-3 px-4 rounded-xl bg-primary text-white font-headline-sm text-headline-sm font-semibold shadow-md hover:bg-primary-container transition-all flex items-center justify-center gap-2 active:scale-[0.99] disabled:opacity-70 cursor-pointer"
              >
                {#if isLoading}
                  <span class="material-symbols-outlined text-[20px] animate-spin">progress_activity</span>
                  <span>Memverifikasi Akun...</span>
                {:else}
                  <span>Masuk ke Repositori</span>
                  <span class="material-symbols-outlined text-[20px]">arrow_forward</span>
                {/if}
              </button>
            </form>
          </div>

        <!-- ── REGISTER PANEL ── -->
        {:else}
          <div class="space-y-4">
            {#if registerError}
              <div class="p-3 rounded-xl bg-error/10 border border-error/20 text-error text-xs flex items-center gap-2 animate-fadeIn">
                <span class="material-symbols-outlined text-base">error</span>
                <span>{registerError}</span>
              </div>
            {/if}

            <form onsubmit={handleRegister} class="space-y-3.5">
              <!-- Nama Lengkap -->
              <div class="space-y-1">
                <label for="regNamaInput" class="font-label-badge text-label-badge text-on-surface font-semibold">
                  Nama Lengkap <span class="text-error">*</span>
                </label>
                <input
                  id="regNamaInput"
                  bind:value={regNama}
                  type="text"
                  placeholder="Masukkan nama lengkap Anda"
                  required
                  class="w-full px-4 py-2.5 rounded-xl bg-surface-canvas text-on-surface font-body-md text-body-md placeholder:text-text-tertiary focus:outline-none focus:bg-surface-card focus:shadow-[0_0_0_3px_rgba(0,102,255,0.2)] transition-all"
                />
              </div>

              <!-- NIM/NIP + Email kampus -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div class="space-y-1">
                  <label for="regNimInput" class="font-label-badge text-label-badge text-on-surface font-semibold">
                    NIM Mahasiswa / NIP Staf
                  </label>
                  <input
                    id="regNimInput"
                    bind:value={regNim}
                    type="text"
                    placeholder="Contoh: 21051204088 atau NIP"
                    class="w-full px-4 py-2.5 rounded-xl bg-surface-canvas text-on-surface font-body-md text-body-md placeholder:text-text-tertiary focus:outline-none focus:bg-surface-card focus:shadow-[0_0_0_3px_rgba(0,102,255,0.2)] transition-all"
                  />
                </div>
                <div class="space-y-1">
                  <label for="regEmailInput" class="font-label-badge text-label-badge text-on-surface font-semibold">
                    Email Kampus <span class="text-error">*</span>
                  </label>
                  <input
                    id="regEmailInput"
                    bind:value={regEmail}
                    type="email"
                    placeholder="nama@campus.ac.id"
                    required
                    class="w-full px-4 py-2.5 rounded-xl bg-surface-canvas text-on-surface font-body-md text-body-md placeholder:text-text-tertiary focus:outline-none focus:bg-surface-card focus:shadow-[0_0_0_3px_rgba(0,102,255,0.2)] transition-all"
                  />
                </div>
              </div>

              <!-- Program Studi -->
              <div class="space-y-1">
                <label for="regProdiSelect" class="font-label-badge text-label-badge text-on-surface font-semibold">
                  Program Studi / Unit <span class="text-error">*</span>
                </label>
                <select
                  id="regProdiSelect"
                  bind:value={regProdi}
                  required
                  class="w-full px-3.5 py-2.5 rounded-xl bg-surface-canvas text-on-surface font-body-md text-body-md focus:outline-none focus:bg-surface-card focus:shadow-[0_0_0_3px_rgba(0,102,255,0.2)] transition-all cursor-pointer"
                >
                  <option value="Teknik Informatika">Teknik Informatika</option>
                  <option value="Sistem Informasi">Sistem Informasi</option>
                  <option value="Desain Komunikasi Visual">Desain Komunikasi Visual</option>
                  <option value="Manajemen">Manajemen</option>
                  <option value="Ilmu Komunikasi">Ilmu Komunikasi</option>
                  <option value="UPT Perpustakaan">UPT Perpustakaan</option>
                </select>
              </div>

              <!-- Password + Confirm -->
              <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div class="space-y-1">
                  <label for="regPasswordInput" class="font-label-badge text-label-badge text-on-surface font-semibold">
                    Kata Sandi <span class="text-error">*</span>
                  </label>
                  <input
                    id="regPasswordInput"
                    bind:value={regPassword}
                    type="password"
                    placeholder="Minimal 6 karakter"
                    required
                    minlength="6"
                    class="w-full px-4 py-2.5 rounded-xl bg-surface-canvas text-on-surface font-body-md text-body-md placeholder:text-text-tertiary focus:outline-none focus:bg-surface-card focus:shadow-[0_0_0_3px_rgba(0,102,255,0.2)] transition-all"
                  />
                </div>
                <div class="space-y-1">
                  <label for="regConfirmPasswordInput" class="font-label-badge text-label-badge text-on-surface font-semibold">
                    Konfirmasi <span class="text-error">*</span>
                  </label>
                  <input
                    id="regConfirmPasswordInput"
                    bind:value={regConfirmPassword}
                    type="password"
                    placeholder="Ulangi kata sandi"
                    required
                    class="w-full px-4 py-2.5 rounded-xl bg-surface-canvas text-on-surface font-body-md text-body-md placeholder:text-text-tertiary focus:outline-none focus:bg-surface-card focus:shadow-[0_0_0_3px_rgba(0,102,255,0.2)] transition-all"
                  />
                </div>
              </div>

              <div class="pt-1">
                <button
                  type="submit"
                  disabled={isLoading}
                  class="w-full py-3 px-4 rounded-xl bg-primary text-white font-headline-sm text-headline-sm font-semibold shadow-md hover:bg-primary-container transition-all flex items-center justify-center gap-2 active:scale-[0.99] disabled:opacity-70 cursor-pointer"
                >
                  {#if isLoading}
                    <span class="material-symbols-outlined text-[20px] animate-spin">progress_activity</span>
                    <span>Mendaftarkan Akun...</span>
                  {:else}
                    <span class="material-symbols-outlined text-[20px]">how_to_reg</span>
                    <span>Daftar Akun Baru</span>
                  {/if}
                </button>
              </div>
            </form>
          </div>
        {/if}

        <!-- Footer note -->
        <p class="text-center font-label-caption text-label-caption text-text-tertiary leading-relaxed">
          Dengan mengakses repositori, data Anda terotentikasi aman via JWT &amp; bcryptjs sesuai standar PRD.
        </p>
      </div>

      <!-- Forgot password overlay -->
      {#if showForgot}
        <div class="absolute inset-0 bg-surface-card/95 backdrop-blur-md rounded-2xl p-6 sm:p-8 flex flex-col justify-between z-30">
          <div class="space-y-4">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-2 text-primary font-headline-sm text-headline-sm font-bold">
                <span class="material-symbols-outlined text-[22px]">lock_reset</span>
                <span>Pemulihan Kata Sandi</span>
              </div>
              <button
                type="button"
                onclick={() => { showForgot = false; forgotInput = ''; }}
                class="p-1 rounded-lg hover:bg-surface-container-high text-text-secondary cursor-pointer"
              >
                <span class="material-symbols-outlined text-[20px]">close</span>
              </button>
            </div>
            <p class="font-body-sm text-body-sm text-text-secondary">Tautan reset kredensial akan dikirimkan ke email resmi kampus Anda.</p>
            <div class="space-y-1.5">
              <label for="forgotEmailInput" class="font-label-badge text-label-badge text-on-surface font-semibold">Email Kampus / NIM</label>
              <input
                id="forgotEmailInput"
                bind:value={forgotInput}
                type="text"
                placeholder="Masukkan NIM atau email@campus.ac.id"
                class="w-full px-4 py-2.5 rounded-xl bg-surface-canvas text-on-surface font-body-md text-body-md focus:outline-none focus:bg-surface-card focus:shadow-[0_0_0_3px_rgba(0,102,255,0.2)]"
              />
            </div>
          </div>
          <div class="flex items-center gap-3 pt-4">
            <button
              type="button"
              onclick={() => { showForgot = false; forgotInput = ''; }}
              class="flex-1 py-2.5 px-4 rounded-xl bg-surface-container-low text-text-secondary font-headline-sm text-headline-sm hover:bg-surface-container-high transition-all cursor-pointer"
            >Batal</button>
            <button
              type="button"
              onclick={sendForgot}
              class="flex-1 py-2.5 px-4 rounded-xl bg-primary text-white font-headline-sm text-headline-sm font-semibold shadow-md hover:bg-primary-container transition-all cursor-pointer"
            >Kirim Tautan</button>
          </div>
        </div>
      {/if}
    </div>
  </div>
{/if}
