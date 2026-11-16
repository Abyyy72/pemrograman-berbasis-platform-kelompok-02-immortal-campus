<script lang="ts">
  import type { RolePengguna } from '../types';
  import { apiLogin, apiRegister } from '../lib/api';

  interface Props {
    onLoginSuccess: (role: RolePengguna, email: string, token?: string, userData?: any) => void;
  }

  let { onLoginSuccess }: Props = $props();

  let activeTab = $state<'login' | 'register'>('login');

  // Form states - Login
  let identifier = $state('');
  let password = $state('');
  let showPassword = $state(false);
  let rememberMe = $state(true);
  let isSubmitting = $state(false);
  let loginError = $state<string | null>(null);

  // Form states - Register
  let regNama = $state('');
  let regIdentifier = $state(''); // NIM atau NIP
  let regEmail = $state('');
  let regProdi = $state('Teknik Informatika');
  let regPassword = $state('');
  let regConfirm = $state('');
  let isRegistering = $state(false);
  let registerError = $state<string | null>(null);

  let showForgot = $state(false);
  let forgotEmail = $state('');

  async function handleSubmitLogin(e: Event) {
    e.preventDefault();
    loginError = null;

    const cleanIdentifier = identifier.trim();
    if (!cleanIdentifier || !password) {
      loginError = 'Harap masukkan Email / NIM / NIP dan kata sandi Anda.';
      return;
    }

    isSubmitting = true;
    try {
      const data = await apiLogin(cleanIdentifier, password);
      onLoginSuccess(data.user.role, data.user.email, data.token, data.user);
    } catch (err: any) {
      loginError = err.message || 'Gagal masuk. Periksa kembali kredensial Anda.';
    } finally {
      isSubmitting = false;
    }
  }

  async function handleSubmitRegister(e: Event) {
    e.preventDefault();
    registerError = null;

    if (!regNama.trim()) {
      registerError = 'Nama lengkap wajib diisi.';
      return;
    }
    if (!regEmail.trim()) {
      registerError = 'Email institusi / kampus wajib diisi.';
      return;
    }
    if (!regPassword) {
      registerError = 'Kata sandi minimal 6 karakter.';
      return;
    }
    if (regPassword.length < 6) {
      registerError = 'Kata sandi minimal harus terdiri dari 6 karakter.';
      return;
    }
    if (regPassword !== regConfirm) {
      registerError = 'Kata sandi dan konfirmasi sandi tidak sesuai!';
      return;
    }

    isRegistering = true;
    try {
      const role = regProdi === 'UPT Perpustakaan' ? 'kurator' : 'penulis';
      const payload: any = {
        nama: regNama.trim(),
        email: regEmail.trim(),
        password: regPassword,
        prodi: regProdi,
        role,
      };

      if (role === 'penulis') {
        payload.nim = regIdentifier.trim() || undefined;
      } else {
        payload.nip = regIdentifier.trim() || undefined;
      }

      const data = await apiRegister(payload);
      onLoginSuccess(data.user.role, data.user.email, data.token, data.user);
    } catch (err: any) {
      registerError = err.message || 'Gagal mendaftar. Silakan coba kembali.';
    } finally {
      isRegistering = false;
    }
  }
</script>

<div class="min-h-[calc(100vh-4rem)] flex items-center justify-center p-3 sm:p-6 bg-surface-canvas py-6 sm:py-12">
  <div class="w-full max-w-xl bg-white rounded-2xl sm:rounded-3xl shadow-xl border border-border-subtle p-5 sm:p-8 md:p-10 relative overflow-hidden space-y-6">
    <!-- Top Branding Header -->
    <div class="text-center space-y-4">
      <img
        alt="Immortal Campus Logo"
        class="h-32 sm:h-36 w-auto object-contain mx-auto"
        src="/logo.png"
      />
      <h1 class="font-display-hero text-2xl font-bold text-text-primary tracking-tight">
        Portal Masuk Immortal Campus
      </h1>
      <p class="font-body-sm text-xs sm:text-sm text-text-secondary">
        Akses repositori terpadu untuk pengunggahan naskah, validasi kurator, dan pengarsipan ilmiah kampus sesuai PRD.
      </p>
    </div>

    <!-- Tab Selector -->
    <div class="flex p-1.5 rounded-2xl bg-slate-100 border border-slate-200">
      <button
        type="button"
        onclick={() => { activeTab = 'login'; loginError = null; registerError = null; }}
        class="flex-1 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all {activeTab === 'login' ? 'bg-white text-primary shadow-sm' : 'text-text-secondary hover:text-text-primary'}"
      >
        Masuk Akun
      </button>
      <button
        type="button"
        onclick={() => { activeTab = 'register'; loginError = null; registerError = null; }}
        class="flex-1 py-2.5 rounded-xl text-xs sm:text-sm font-semibold transition-all {activeTab === 'register' ? 'bg-white text-primary shadow-sm' : 'text-text-secondary hover:text-text-primary'}"
      >
        Aktivasi / Registrasi
      </button>
    </div>

    {#if activeTab === 'login'}
      <!-- LOGIN FORM (INPUT SENDIRI) -->
      <form onsubmit={handleSubmitLogin} class="space-y-4 pt-1">
        {#if loginError}
          <div class="p-3.5 rounded-xl bg-error/10 border border-error/20 text-error text-xs flex items-center gap-2 animate-fadeIn">
            <span class="material-symbols-outlined text-base">error</span>
            <span>{loginError}</span>
          </div>
        {/if}

        <div class="space-y-1.5">
          <label for="loginIdentifier" class="text-xs font-semibold text-text-primary flex items-center justify-between">
            <span>Email Kampus / NIM Mahasiswa / NIP Staf</span>
          </label>
          <div class="relative">
            <span class="absolute left-3.5 top-1/2 -translate-y-1/2 material-symbols-outlined text-text-tertiary text-lg">mail</span>
            <input
              id="loginIdentifier"
              type="text"
              bind:value={identifier}
              required
              placeholder="Masukkan Email, NIM, atau NIP Anda"
              class="w-full pl-10 pr-4 py-2.5 rounded-xl border border-border-subtle text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
            />
          </div>
        </div>

        <div class="space-y-1.5">
          <div class="flex items-center justify-between">
            <label for="loginPassword" class="text-xs font-semibold text-text-primary">Kata Sandi</label>
            <button
              type="button"
              onclick={() => showForgot = !showForgot}
              class="text-[11px] text-primary hover:underline font-semibold"
            >
              Lupa Sandi?
            </button>
          </div>
          <div class="relative">
            <span class="absolute left-3.5 top-1/2 -translate-y-1/2 material-symbols-outlined text-text-tertiary text-lg">lock</span>
            <input
              id="loginPassword"
              type={showPassword ? 'text' : 'password'}
              bind:value={password}
              required
              placeholder="Masukkan kata sandi akun Anda"
              class="w-full pl-10 pr-10 py-2.5 rounded-xl border border-border-subtle text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
            />
            <button
              type="button"
              onclick={() => showPassword = !showPassword}
              class="absolute right-3 top-1/2 -translate-y-1/2 text-text-tertiary hover:text-text-primary"
              aria-label="Tampilkan sandi"
            >
              <span class="material-symbols-outlined text-lg">{showPassword ? 'visibility_off' : 'visibility'}</span>
            </button>
          </div>
        </div>

        <div class="flex items-center justify-between text-xs pt-1">
          <label class="flex items-center gap-2 cursor-pointer">
            <input type="checkbox" bind:checked={rememberMe} class="rounded text-primary focus:ring-primary" />
            <span class="text-text-secondary">Ingat saya di perangkat ini</span>
          </label>
        </div>

        <button
          type="submit"
          disabled={isSubmitting}
          class="w-full py-3 rounded-xl bg-primary text-white font-bold text-sm shadow-md hover:bg-primary-container transition-all flex items-center justify-center gap-2 active:scale-95 disabled:opacity-50"
        >
          {#if isSubmitting}
            <span class="material-symbols-outlined text-base animate-spin">progress_activity</span>
            <span>Memverifikasi Kredensial...</span>
          {:else}
            <span class="material-symbols-outlined text-base">login</span>
            <span>Masuk ke Repositori</span>
          {/if}
        </button>
      </form>

    {:else}
      <!-- REGISTER FORM (INPUT SENDIRI) -->
      <form onsubmit={handleSubmitRegister} class="space-y-3.5 pt-1">
        {#if registerError}
          <div class="p-3.5 rounded-xl bg-error/10 border border-error/20 text-error text-xs flex items-center gap-2 animate-fadeIn">
            <span class="material-symbols-outlined text-base">error</span>
            <span>{registerError}</span>
          </div>
        {/if}

        <div class="space-y-1">
          <label for="regNama" class="text-xs font-semibold text-text-primary">
            Nama Lengkap <span class="text-error">*</span>
          </label>
          <input
            id="regNama"
            type="text"
            bind:value={regNama}
            required
            placeholder="Masukkan nama lengkap beserta gelar jika ada"
            class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
          />
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div class="space-y-1">
            <label for="regIdentifier" class="text-xs font-semibold text-text-primary">
              NIM Mahasiswa / NIP Staf
            </label>
            <input
              id="regIdentifier"
              type="text"
              bind:value={regIdentifier}
              placeholder="Contoh: 2110512034 atau NIP"
              class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
            />
          </div>
          <div class="space-y-1">
            <label for="regEmail" class="text-xs font-semibold text-text-primary">
              Email Kampus / Institusi <span class="text-error">*</span>
            </label>
            <input
              id="regEmail"
              type="email"
              bind:value={regEmail}
              required
              placeholder="nama@campus.ac.id"
              class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
            />
          </div>
        </div>

        <div class="space-y-1">
          <label for="regProdi" class="text-xs font-semibold text-text-primary">
            Program Studi / Unit <span class="text-error">*</span>
          </label>
          <select
            id="regProdi"
            bind:value={regProdi}
            class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
          >
            <option value="Teknik Informatika">Teknik Informatika</option>
            <option value="Sistem Informasi">Sistem Informasi</option>
            <option value="Desain Komunikasi Visual">Desain Komunikasi Visual</option>
            <option value="Manajemen">Manajemen</option>
            <option value="Ilmu Komunikasi">Ilmu Komunikasi</option>
            <option value="UPT Perpustakaan">UPT Perpustakaan</option>
          </select>
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
          <div class="space-y-1">
            <label for="regPass" class="text-xs font-semibold text-text-primary">
              Kata Sandi Baru <span class="text-error">*</span>
            </label>
            <input
              id="regPass"
              type="password"
              bind:value={regPassword}
              required
              minlength="6"
              placeholder="Minimal 6 karakter"
              class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
            />
          </div>
          <div class="space-y-1">
            <label for="regConf" class="text-xs font-semibold text-text-primary">
              Ulangi Sandi <span class="text-error">*</span>
            </label>
            <input
              id="regConf"
              type="password"
              bind:value={regConfirm}
              required
              placeholder="Ketik ulang kata sandi"
              class="w-full px-3.5 py-2.5 rounded-xl border border-border-subtle text-xs sm:text-sm focus:outline-none focus:ring-2 focus:ring-primary/30"
            />
          </div>
        </div>

        <button
          type="submit"
          disabled={isRegistering}
          class="w-full py-3 rounded-xl bg-primary text-white font-bold text-sm shadow-md hover:bg-primary-container transition-all flex items-center justify-center gap-2 active:scale-95 disabled:opacity-50 mt-2"
        >
          {#if isRegistering}
            <span class="material-symbols-outlined text-base animate-spin">progress_activity</span>
            <span>Mendaftarkan Akun ke Database...</span>
          {:else}
            <span class="material-symbols-outlined text-base">how_to_reg</span>
            <span>Daftar &amp; Aktifkan Akun Sendiri</span>
          {/if}
        </button>
      </form>
    {/if}
  </div>
</div>
