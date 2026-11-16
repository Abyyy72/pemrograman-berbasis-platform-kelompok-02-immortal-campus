<script lang="ts">
  import { onMount } from 'svelte';
  import type { Karya, StatusKarya } from '../types';
  import {
    apiAdminGetUsers,
    apiAdminCreateUser,
    apiAdminDeleteUser,
    apiAdminResetPassword,
    apiAdminGetStatistik,
    apiAdminDeleteKarya,
    apiAdminOverrideKaryaStatus,
  } from '../lib/api';

  interface Props {
    karyaList: Karya[];
    currentUser?: any;
    onClose: () => void;
    onLogout?: () => void;
    onOpenDetail?: (karya: Karya) => void;
    onNavigateHome?: () => void;
    onNavigateJelajah?: () => void;
  }

  let {
    karyaList,
    currentUser = null,
    onClose,
    onLogout,
    onOpenDetail,
    onNavigateHome,
    onNavigateJelajah
  }: Props = $props();

  let adminName = $derived(currentUser?.nama || 'Administrator Utama');

  // Active tab: 'users' | 'karya' | 'system'
  let activeTab = $state<'users' | 'karya' | 'system'>('users');

  // User management state
  let usersList = $state<any[]>([]);
  let roleFilter = $state<string>('all');
  let userSearch = $state('');
  let isLoadingUsers = $state(false);

  // New curator / user modal state
  let isAddUserOpen = $state(false);
  let newNama = $state('');
  let newEmail = $state('');
  let newNip = $state('');
  let newProdi = $state('UPT Perpustakaan');
  let newRole = $state<'kurator' | 'admin' | 'penulis'>('kurator');
  let newPassword = $state('password123');
  let addUserError = $state<string | null>(null);
  let isSavingUser = $state(false);

  // Reset password modal state
  let resetUserId = $state<string | null>(null);
  let resetUserName = $state('');
  let resetNewPassword = $state('password123');
  let isResettingPassword = $state(false);

  // Karya moderation state
  let karyaSearch = $state('');
  let karyaStatusFilter = $state('all');

  // Stats state
  let adminStats = $state<any>(null);

  // Feedback toast
  let toastMsg = $state<string | null>(null);
  let toastType = $state<'success' | 'error'>('success');
  function showToast(msg: string, type: 'success' | 'error' = 'success') {
    toastMsg = msg;
    toastType = type;
    setTimeout(() => { toastMsg = null; }, 3500);
  }

  async function loadUsers() {
    isLoadingUsers = true;
    try {
      usersList = await apiAdminGetUsers();
    } catch (e: any) {
      showToast(e.message || 'Gagal memuat daftar pengguna', 'error');
    } finally {
      isLoadingUsers = false;
    }
  }

  async function loadStats() {
    try {
      adminStats = await apiAdminGetStatistik();
    } catch (e) {
      // Non-blocking
    }
  }

  onMount(() => {
    loadUsers();
    loadStats();
  });

  // Filtered users
  let filteredUsers = $derived.by(() => {
    return usersList.filter((u) => {
      const matchRole = roleFilter === 'all' || u.role === roleFilter;
      const q = userSearch.toLowerCase().trim();
      const matchSearch =
        !q ||
        u.nama?.toLowerCase().includes(q) ||
        u.email?.toLowerCase().includes(q) ||
        u.nip?.toLowerCase().includes(q) ||
        u.nim?.toLowerCase().includes(q);
      return matchRole && matchSearch;
    });
  });

  // Filtered karya
  let filteredKarya = $derived.by(() => {
    return karyaList.filter((k) => {
      const matchStatus = karyaStatusFilter === 'all' || k.status === karyaStatusFilter;
      const q = karyaSearch.toLowerCase().trim();
      const matchSearch =
        !q ||
        k.judul?.toLowerCase().includes(q) ||
        k.penulis?.toLowerCase().includes(q) ||
        k.prodi?.toLowerCase().includes(q);
      return matchStatus && matchSearch;
    });
  });

  async function handleCreateUser(e: Event) {
    e.preventDefault();
    addUserError = null;

    if (!newNama.trim() || !newEmail.trim() || !newPassword) {
      addUserError = 'Nama, email, dan kata sandi wajib diisi.';
      return;
    }

    isSavingUser = true;
    try {
      await apiAdminCreateUser({
        nama: newNama.trim(),
        email: newEmail.trim(),
        nip: newNip.trim() || undefined,
        prodi: newProdi,
        role: newRole,
        password: newPassword,
      });

      showToast(`Berhasil menambahkan ${newRole.toUpperCase()} baru: ${newNama}`, 'success');
      isAddUserOpen = false;
      // Reset form
      newNama = '';
      newEmail = '';
      newNip = '';
      newPassword = 'password123';
      newRole = 'kurator';
      await loadUsers();
      await loadStats();
    } catch (err: any) {
      addUserError = err.message || 'Gagal menambahkan pengguna.';
    } finally {
      isSavingUser = false;
    }
  }

  async function handleDeleteUser(user: any) {
    if (!confirm(`Yakin ingin menghapus akun ${user.nama} (${user.email})? Tindakan ini tidak dapat dibatalkan.`)) {
      return;
    }

    try {
      await apiAdminDeleteUser(user.id);
      showToast(`Pengguna ${user.nama} berhasil dihapus.`, 'success');
      await loadUsers();
      await loadStats();
    } catch (err: any) {
      showToast(err.message || 'Gagal menghapus pengguna.', 'error');
    }
  }

  async function handleResetPasswordSubmit(e: Event) {
    e.preventDefault();
    if (!resetUserId || !resetNewPassword) return;

    isResettingPassword = true;
    try {
      await apiAdminResetPassword(resetUserId, resetNewPassword);
      showToast(`Kata sandi akun ${resetUserName} berhasil direset!`, 'success');
      resetUserId = null;
    } catch (err: any) {
      showToast(err.message || 'Gagal mereset kata sandi.', 'error');
    } finally {
      isResettingPassword = false;
    }
  }

  async function handleForceStatus(karyaId: string, status: StatusKarya) {
    try {
      await apiAdminOverrideKaryaStatus(karyaId, status, `Ditetapkan langsung oleh Administrator Sistem`);
      showToast(`Status karya berhasil diubah menjadi ${status}.`, 'success');
      const target = karyaList.find(k => k.id === karyaId);
      if (target) target.status = status;
    } catch (err: any) {
      showToast(err.message || 'Gagal memperbarui status karya.', 'error');
    }
  }

  async function handleDeleteKarya(karyaId: string, title: string) {
    if (!confirm(`Hapus permanen karya "${title}" dari repositori? Tindakan ini tidak dapat dibatalkan.`)) {
      return;
    }
    try {
      await apiAdminDeleteKarya(karyaId);
      showToast(`Karya berhasil dihapus dari database.`, 'success');
      const idx = karyaList.findIndex(k => k.id === karyaId);
      if (idx !== -1) karyaList.splice(idx, 1);
    } catch (err: any) {
      showToast(err.message || 'Gagal menghapus karya.', 'error');
    }
  }
</script>

<div class="min-h-screen bg-slate-50 text-slate-800 pb-20">
  <!-- Toast Notification -->
  {#if toastMsg}
    <div class="fixed bottom-6 right-6 z-50 animate-slideUp">
      <div
        class="flex items-center gap-3 px-5 py-3.5 rounded-2xl shadow-2xl text-xs sm:text-sm font-semibold {toastType === 'success' ? 'bg-emerald-600 text-white' : 'bg-rose-600 text-white'}"
      >
        <span class="material-symbols-outlined text-lg">{toastType === 'success' ? 'check_circle' : 'error'}</span>
        <span>{toastMsg}</span>
        <button onclick={() => toastMsg = null} class="ml-2 hover:opacity-80">
          <span class="material-symbols-outlined text-sm">close</span>
        </button>
      </div>
    </div>
  {/if}

  <!-- Header Banner -->
  <header class="bg-gradient-to-r from-slate-900 via-indigo-950 to-slate-900 text-white border-b border-slate-800 sticky top-16 z-30 shadow-md">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
      <div class="flex items-center gap-3 sm:gap-4 min-w-0">
        <div class="w-10 h-10 sm:w-12 sm:h-12 rounded-2xl bg-indigo-600/30 border border-indigo-400/30 flex items-center justify-center text-indigo-300 shrink-0">
          <span class="material-symbols-outlined text-xl sm:text-2xl">admin_panel_settings</span>
        </div>
        <div class="min-w-0">
          <div class="flex items-center gap-2 flex-wrap">
            <h1 class="text-lg sm:text-2xl font-black font-display-hero tracking-tight text-white truncate">
              Panel Administrator Sistem
            </h1>
            <span class="px-2 py-0.5 rounded-full text-[9px] sm:text-[10px] font-bold bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 shrink-0">
              SUPER ADMIN
            </span>
          </div>
          <p class="text-[11px] sm:text-xs text-slate-400 mt-0.5 line-clamp-1 sm:line-clamp-none">
            Manajemen akun kurator, otorisasi pengguna, dan pengawasan repositori ilmiah terpadu.
          </p>
        </div>
      </div>

      <div class="flex items-center gap-2 w-full sm:w-auto justify-end shrink-0">
        <button
          onclick={() => isAddUserOpen = true}
          class="flex items-center gap-2 px-3.5 sm:px-4 py-2 rounded-xl text-xs sm:text-sm font-bold bg-indigo-600 hover:bg-indigo-500 text-white shadow-lg shadow-indigo-600/20 transition-all hover:scale-[1.02]"
        >
          <span class="material-symbols-outlined text-base">person_add</span>
          <span>Tambah Akun Kurator</span>
        </button>

        {#if onLogout}
          <button
            onclick={onLogout}
            title="Keluar Sesi"
            class="flex items-center gap-1.5 px-3 py-2 rounded-xl text-xs font-semibold bg-white/10 hover:bg-white/20 text-slate-300 transition-colors"
          >
            <span class="material-symbols-outlined text-base">logout</span>
            <span class="hidden sm:inline">Keluar</span>
          </button>
        {/if}
      </div>
    </div>

    <!-- Navigation Tabs -->
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex gap-1 border-t border-white/5 pt-2 overflow-x-auto flex-nowrap scrollbar-none">
      <button
        onclick={() => activeTab = 'users'}
        class="shrink-0 whitespace-nowrap px-3.5 sm:px-4 py-2.5 text-xs sm:text-sm font-bold rounded-t-xl transition-all border-b-2 flex items-center gap-2 {activeTab === 'users' ? 'border-indigo-400 text-indigo-300 bg-white/5' : 'border-transparent text-slate-400 hover:text-white'}"
      >
        <span class="material-symbols-outlined text-base">group</span>
        <span>Kelola Pengguna ({usersList.length})</span>
      </button>

      <button
        onclick={() => activeTab = 'karya'}
        class="shrink-0 whitespace-nowrap px-3.5 sm:px-4 py-2.5 text-xs sm:text-sm font-bold rounded-t-xl transition-all border-b-2 flex items-center gap-2 {activeTab === 'karya' ? 'border-indigo-400 text-indigo-300 bg-white/5' : 'border-transparent text-slate-400 hover:text-white'}"
      >
        <span class="material-symbols-outlined text-base">library_books</span>
        <span>Pengawasan Naskah ({karyaList.length})</span>
      </button>

      <button
        onclick={() => activeTab = 'system'}
        class="shrink-0 whitespace-nowrap px-3.5 sm:px-4 py-2.5 text-xs sm:text-sm font-bold rounded-t-xl transition-all border-b-2 flex items-center gap-2 {activeTab === 'system' ? 'border-indigo-400 text-indigo-300 bg-white/5' : 'border-transparent text-slate-400 hover:text-white'}"
      >
        <span class="material-symbols-outlined text-base">monitoring</span>
        <span>Statistik &amp; Audit</span>
      </button>
    </div>
  </header>

  <!-- Main Content Area -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-8">
    <!-- TAB 1: KELOLA PENGGUNA -->
    {#if activeTab === 'users'}
      <div class="space-y-6">
        <!-- Overview summary cards -->
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 sm:gap-4">
          <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center font-bold">
              <span class="material-symbols-outlined text-2xl">group</span>
            </div>
            <div>
              <p class="text-xs font-semibold text-slate-500 uppercase tracking-wider">Total Pengguna</p>
              <h3 class="text-2xl font-black text-slate-900">{usersList.length}</h3>
            </div>
          </div>

          <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-purple-50 text-purple-600 flex items-center justify-center font-bold">
              <span class="material-symbols-outlined text-2xl">verified_user</span>
            </div>
            <div>
              <p class="text-xs font-semibold text-slate-500 uppercase tracking-wider">Tim Kurator</p>
              <h3 class="text-2xl font-black text-slate-900">{usersList.filter(u => u.role === 'kurator').length}</h3>
            </div>
          </div>

          <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center font-bold">
              <span class="material-symbols-outlined text-2xl">school</span>
            </div>
            <div>
              <p class="text-xs font-semibold text-slate-500 uppercase tracking-wider">Penulis / Mhs</p>
              <h3 class="text-2xl font-black text-slate-900">{usersList.filter(u => u.role === 'penulis').length}</h3>
            </div>
          </div>

          <div class="bg-white p-5 rounded-2xl border border-slate-200/80 shadow-sm flex items-center gap-4">
            <div class="w-12 h-12 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center font-bold">
              <span class="material-symbols-outlined text-2xl">shield_person</span>
            </div>
            <div>
              <p class="text-xs font-semibold text-slate-500 uppercase tracking-wider">Administrator</p>
              <h3 class="text-2xl font-black text-slate-900">{usersList.filter(u => u.role === 'admin').length}</h3>
            </div>
          </div>
        </div>

        <!-- Filter bar & action -->
        <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-sm flex flex-wrap items-center justify-between gap-4">
          <div class="flex flex-wrap items-center gap-3 flex-1 min-w-[280px]">
            <div class="relative flex-1 max-w-md">
              <span class="material-symbols-outlined absolute left-3 top-2.5 text-slate-400 text-lg">search</span>
              <input
                type="text"
                bind:value={userSearch}
                placeholder="Cari berdasarkan nama, email, NIP, atau NIM..."
                class="w-full pl-9 pr-4 py-2 rounded-xl text-xs sm:text-sm border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
              />
            </div>

            <div class="flex items-center gap-1.5">
              <button
                onclick={() => roleFilter = 'all'}
                class="px-3 py-1.5 rounded-lg text-xs font-bold transition-colors {roleFilter === 'all' ? 'bg-slate-900 text-white' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'}"
              >
                Semua
              </button>
              <button
                onclick={() => roleFilter = 'kurator'}
                class="px-3 py-1.5 rounded-lg text-xs font-bold transition-colors {roleFilter === 'kurator' ? 'bg-purple-600 text-white' : 'bg-purple-50 text-purple-700 hover:bg-purple-100'}"
              >
                Kurator ({usersList.filter(u => u.role === 'kurator').length})
              </button>
              <button
                onclick={() => roleFilter = 'penulis'}
                class="px-3 py-1.5 rounded-lg text-xs font-bold transition-colors {roleFilter === 'penulis' ? 'bg-blue-600 text-white' : 'bg-blue-50 text-blue-700 hover:bg-blue-100'}"
              >
                Penulis ({usersList.filter(u => u.role === 'penulis').length})
              </button>
              <button
                onclick={() => roleFilter = 'admin'}
                class="px-3 py-1.5 rounded-lg text-xs font-bold transition-colors {roleFilter === 'admin' ? 'bg-amber-600 text-white' : 'bg-amber-50 text-amber-700 hover:bg-amber-100'}"
              >
                Admin ({usersList.filter(u => u.role === 'admin').length})
              </button>
            </div>
          </div>

          <button
            onclick={() => isAddUserOpen = true}
            class="flex items-center gap-2 px-4 py-2 rounded-xl text-xs font-bold bg-indigo-600 hover:bg-indigo-700 text-white transition-colors shrink-0"
          >
            <span class="material-symbols-outlined text-base">add</span>
            <span>Tambah Pengguna / Kurator</span>
          </button>
        </div>

        <!-- Users Table -->
        <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
          <div class="overflow-x-auto">
            <table class="w-full text-left text-xs sm:text-sm min-w-[680px]">
              <thead class="bg-slate-50 border-b border-slate-200 text-slate-500 uppercase text-[11px] font-bold tracking-wider">
                <tr>
                  <th class="px-6 py-4">Nama Lengkap &amp; Identitas</th>
                  <th class="px-6 py-4">Peran</th>
                  <th class="px-6 py-4">Prodi / Unit</th>
                  <th class="px-6 py-4">NIP / NIM</th>
                  <th class="px-6 py-4 text-right">Aksi</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-100">
                {#if isLoadingUsers}
                  <tr>
                    <td colspan="5" class="text-center py-12 text-slate-400">
                      <div class="inline-flex items-center gap-2">
                        <span class="animate-spin material-symbols-outlined text-indigo-600">progress_activity</span>
                        <span>Memuat data pengguna...</span>
                      </div>
                    </td>
                  </tr>
                {:else if filteredUsers.length === 0}
                  <tr>
                    <td colspan="5" class="text-center py-12 text-slate-400">
                      Tidak ada pengguna yang cocok dengan kriteria pencarian.
                    </td>
                  </tr>
                {:else}
                  {#each filteredUsers as user}
                    <tr class="hover:bg-slate-50/80 transition-colors">
                      <td class="px-6 py-4">
                        <div class="flex items-center gap-3">
                          <div class="w-9 h-9 rounded-full font-bold flex items-center justify-center text-xs shrink-0 {user.role === 'admin' ? 'bg-amber-100 text-amber-700' : user.role === 'kurator' ? 'bg-purple-100 text-purple-700' : 'bg-blue-100 text-blue-700'}">
                            {(user.nama || 'U').slice(0, 2).toUpperCase()}
                          </div>
                          <div>
                            <p class="font-bold text-slate-900">{user.nama}</p>
                            <p class="text-xs text-slate-500 font-mono">{user.email}</p>
                          </div>
                        </div>
                      </td>

                      <td class="px-6 py-4">
                        <span class="inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-[11px] font-bold {user.role === 'admin' ? 'bg-amber-50 text-amber-700 border border-amber-200' : user.role === 'kurator' ? 'bg-purple-50 text-purple-700 border border-purple-200' : 'bg-blue-50 text-blue-700 border border-blue-200'}">
                          <span class="material-symbols-outlined text-xs">
                            {user.role === 'admin' ? 'shield_person' : user.role === 'kurator' ? 'verified_user' : 'school'}
                          </span>
                          {user.role.toUpperCase()}
                        </span>
                      </td>

                      <td class="px-6 py-4 text-slate-600 font-medium">
                        {user.prodi || 'UPT Perpustakaan'}
                      </td>

                      <td class="px-6 py-4 font-mono text-slate-600">
                        {user.nip || user.nim || '-'}
                      </td>

                      <td class="px-6 py-4 text-right">
                        <div class="inline-flex items-center gap-1.5">
                          <button
                            onclick={() => {
                              resetUserId = user.id;
                              resetUserName = user.nama;
                              resetNewPassword = 'password123';
                            }}
                            title="Reset Kata Sandi"
                            class="p-1.5 rounded-lg hover:bg-slate-100 text-slate-500 hover:text-amber-600 transition-colors"
                          >
                            <span class="material-symbols-outlined text-base">lock_reset</span>
                          </button>

                          {#if user.email !== 'admin@campus.ac.id' && user.id !== currentUser?.id}
                            <button
                              onclick={() => handleDeleteUser(user)}
                              title="Hapus Pengguna"
                              class="p-1.5 rounded-lg hover:bg-rose-50 text-slate-400 hover:text-rose-600 transition-colors"
                            >
                              <span class="material-symbols-outlined text-base">delete</span>
                            </button>
                          {/if}
                        </div>
                      </td>
                    </tr>
                  {/each}
                {/if}
              </tbody>
            </table>
          </div>
        </div>
      </div>

    <!-- TAB 2: PENGAWASAN NASKAH & OVERRIDE -->
    {:else if activeTab === 'karya'}
      <div class="space-y-6">
        <!-- Filter bar -->
        <div class="bg-white p-4 rounded-2xl border border-slate-200/80 shadow-sm flex flex-wrap items-center justify-between gap-4">
          <div class="relative flex-1 max-w-md">
            <span class="material-symbols-outlined absolute left-3 top-2.5 text-slate-400 text-lg">search</span>
            <input
              type="text"
              bind:value={karyaSearch}
              placeholder="Cari naskah berdasarkan judul, penulis, prodi..."
              class="w-full pl-9 pr-4 py-2 rounded-xl text-xs sm:text-sm border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
            />
          </div>

          <div class="flex items-center gap-2">
            <select
              bind:value={karyaStatusFilter}
              class="px-3 py-2 rounded-xl text-xs font-semibold border border-slate-200 bg-white focus:outline-none"
            >
              <option value="all">Semua Status</option>
              <option value="Diajukan">Diajukan</option>
              <option value="Dalam Review">Dalam Review</option>
              <option value="Diterbitkan">Diterbitkan</option>
              <option value="Perlu Revisi">Perlu Revisi</option>
              <option value="Ditolak">Ditolak</option>
            </select>
          </div>
        </div>

        <!-- Karya Table -->
        <div class="bg-white rounded-2xl border border-slate-200/80 shadow-sm overflow-hidden">
          <div class="overflow-x-auto">
            <table class="w-full text-left text-xs sm:text-sm min-w-[700px]">
              <thead class="bg-slate-50 border-b border-slate-200 text-slate-500 uppercase text-[11px] font-bold tracking-wider">
                <tr>
                  <th class="px-6 py-4">Judul Karya &amp; Penulis</th>
                  <th class="px-6 py-4">Status Kurasi</th>
                  <th class="px-6 py-4">Prodi &amp; Tahun</th>
                  <th class="px-6 py-4">Metrik</th>
                  <th class="px-6 py-4 text-right">Otorisasi Admin</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-slate-100">
                {#if filteredKarya.length === 0}
                  <tr>
                    <td colspan="5" class="text-center py-12 text-slate-400">
                      Tidak ada karya yang sesuai dengan filter.
                    </td>
                  </tr>
                {:else}
                  {#each filteredKarya as k}
                    <tr class="hover:bg-slate-50/80 transition-colors">
                      <td class="px-6 py-4 max-w-md">
                        <p class="font-bold text-slate-900 line-clamp-2 leading-snug">{k.judul}</p>
                        <p class="text-xs text-slate-500 mt-1">
                          Penulis: <span class="font-semibold text-slate-700">{k.penulis}</span> ({k.nim || 'NIM -'})
                        </p>
                      </td>

                      <td class="px-6 py-4">
                        <span class="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-bold {k.status === 'Diterbitkan' ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' : k.status === 'Dalam Review' ? 'bg-blue-50 text-blue-700 border border-blue-200' : k.status === 'Diajukan' ? 'bg-amber-50 text-amber-700 border border-amber-200' : k.status === 'Perlu Revisi' ? 'bg-orange-50 text-orange-700 border border-orange-200' : 'bg-rose-50 text-rose-700 border border-rose-200'}">
                          <span class="w-1.5 h-1.5 rounded-full {k.status === 'Diterbitkan' ? 'bg-emerald-500' : k.status === 'Dalam Review' ? 'bg-blue-500' : k.status === 'Diajukan' ? 'bg-amber-500' : 'bg-rose-500'}"></span>
                          {k.status}
                        </span>
                      </td>

                      <td class="px-6 py-4">
                        <p class="font-medium text-slate-700">{k.prodi}</p>
                        <p class="text-xs text-slate-400">Tahun {k.tahun}</p>
                      </td>

                      <td class="px-6 py-4">
                        <div class="flex items-center gap-3 text-xs text-slate-600">
                          <span class="flex items-center gap-1">
                            <span class="material-symbols-outlined text-sm text-slate-400">download</span>
                            {k.unduhan}
                          </span>
                          <span class="flex items-center gap-1">
                            <span class="material-symbols-outlined text-sm text-slate-400">format_quote</span>
                            {k.sitasi || 0}
                          </span>
                        </div>
                      </td>

                      <td class="px-6 py-4 text-right">
                        <div class="inline-flex items-center gap-1">
                          {#if k.status !== 'Diterbitkan'}
                            <button
                              onclick={() => handleForceStatus(k.id, 'Diterbitkan')}
                              title="Force Publish (Terbitkan Langsung)"
                              class="px-2.5 py-1 rounded-lg text-xs font-bold bg-emerald-50 hover:bg-emerald-100 text-emerald-700 transition-colors"
                            >
                              Terbitkan
                            </button>
                          {/if}

                          {#if k.status !== 'Ditolak'}
                            <button
                              onclick={() => handleForceStatus(k.id, 'Ditolak')}
                              title="Tolak Karya"
                              class="px-2.5 py-1 rounded-lg text-xs font-bold bg-rose-50 hover:bg-rose-100 text-rose-700 transition-colors"
                            >
                              Tolak
                            </button>
                          {/if}

                          <button
                            onclick={() => handleDeleteKarya(k.id, k.judul)}
                            title="Hapus Permanen"
                            class="p-1 rounded-lg hover:bg-rose-50 text-slate-400 hover:text-rose-600 transition-colors ml-1"
                          >
                            <span class="material-symbols-outlined text-base">delete</span>
                          </button>
                        </div>
                      </td>
                    </tr>
                  {/each}
                {/if}
              </tbody>
            </table>
          </div>
        </div>
      </div>

    <!-- TAB 3: STATISTIK & AUDIT -->
    {:else if activeTab === 'system'}
      <div class="space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- Ringkasan Repositori -->
          <div class="bg-white p-6 rounded-2xl border border-slate-200/80 shadow-sm space-y-4">
            <h3 class="text-base font-bold text-slate-900 flex items-center gap-2">
              <span class="material-symbols-outlined text-indigo-600">database</span>
              <span>Integritas Basis Data &amp; Penyimpanan</span>
            </h3>

            <div class="space-y-3">
              <div class="flex items-center justify-between p-3 rounded-xl bg-slate-50">
                <span class="text-xs font-semibold text-slate-600">Database Engine</span>
                <span class="text-xs font-mono font-bold text-slate-900">PostgreSQL (Supabase Cloud)</span>
              </div>
              <div class="flex items-center justify-between p-3 rounded-xl bg-slate-50">
                <span class="text-xs font-semibold text-slate-600">File Storage Bucket</span>
                <span class="text-xs font-mono font-bold text-slate-900">immortal-karya (Private)</span>
              </div>
              <div class="flex items-center justify-between p-3 rounded-xl bg-slate-50">
                <span class="text-xs font-semibold text-slate-600">Status OAI-PMH Protocol</span>
                <span class="text-xs font-bold text-emerald-600 flex items-center gap-1">
                  <span class="w-2 h-2 rounded-full bg-emerald-500"></span>
                  Aktif (v2.0 Compliant)
                </span>
              </div>
              <div class="flex items-center justify-between p-3 rounded-xl bg-slate-50">
                <span class="text-xs font-semibold text-slate-600">Standar Akreditasi</span>
                <span class="text-xs font-bold text-indigo-600">Kriteria 9 BAN-PT Terintegrasi</span>
              </div>
            </div>
          </div>

          <!-- Distribusi Tugas Kurasi -->
          <div class="bg-white p-6 rounded-2xl border border-slate-200/80 shadow-sm space-y-4">
            <h3 class="text-base font-bold text-slate-900 flex items-center gap-2">
              <span class="material-symbols-outlined text-purple-600">assignment_turned_in</span>
              <span>Beban Kurasi &amp; Pustakawan Aktif</span>
            </h3>

            <div class="space-y-3">
              {#each usersList.filter(u => u.role === 'kurator') as kurator}
                <div class="flex items-center justify-between p-3 rounded-xl bg-slate-50 hover:bg-slate-100/80 transition-colors">
                  <div class="flex items-center gap-3">
                    <div class="w-8 h-8 rounded-full bg-purple-100 text-purple-700 font-bold flex items-center justify-center text-xs">
                      {kurator.nama.slice(0, 2).toUpperCase()}
                    </div>
                    <div>
                      <p class="text-xs font-bold text-slate-900">{kurator.nama}</p>
                      <p class="text-[11px] font-mono text-slate-500">{kurator.nip || 'NIP Belum disetel'}</p>
                    </div>
                  </div>
                  <span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-purple-100 text-purple-700">
                    Kurator Aktif
                  </span>
                </div>
              {/each}
            </div>
          </div>
        </div>
      </div>
    {/if}
  </main>

  <!-- MODAL: TAMBAH KURATOR / PENGGUNA BARU -->
  {#if isAddUserOpen}
    <div class="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
      <div class="bg-white rounded-3xl shadow-2xl border border-slate-200 max-w-md w-full p-6 sm:p-8 space-y-6 animate-scaleUp">
        <div class="flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-indigo-50 text-indigo-600 flex items-center justify-center">
              <span class="material-symbols-outlined text-xl">person_add</span>
            </div>
            <div>
              <h2 class="text-lg font-bold text-slate-900">Tambah Akun Baru</h2>
              <p class="text-xs text-slate-500">Buat akun Kurator Perpustakaan atau staf resmi</p>
            </div>
          </div>
          <button
            onclick={() => isAddUserOpen = false}
            class="p-1 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100"
          >
            <span class="material-symbols-outlined text-lg">close</span>
          </button>
        </div>

        {#if addUserError}
          <div class="p-3.5 rounded-xl bg-rose-50 text-rose-700 text-xs font-semibold flex items-center gap-2">
            <span class="material-symbols-outlined text-base">error</span>
            <span>{addUserError}</span>
          </div>
        {/if}

        <form onsubmit={handleCreateUser} class="space-y-4 text-xs sm:text-sm">
          <div>
            <label class="block font-semibold text-slate-700 mb-1" for="user-role">
              Peran Akun <span class="text-rose-500">*</span>
            </label>
            <select
              id="user-role"
              bind:value={newRole}
              class="w-full px-3 py-2.5 rounded-xl border border-slate-200 bg-white font-semibold focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
            >
              <option value="kurator">Kurator Perpustakaan (Reviewer Naskah)</option>
              <option value="penulis">Penulis (Mahasiswa / Dosen Peneliti)</option>
              <option value="admin">Administrator Sistem (Full Control)</option>
            </select>
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1" for="user-nama">
              Nama Lengkap &amp; Gelar <span class="text-rose-500">*</span>
            </label>
            <input
              id="user-nama"
              type="text"
              bind:value={newNama}
              placeholder="mis. Hendra Wijaya, M.Hum."
              required
              class="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
            />
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1" for="user-email">
              Email Resmi Kampus <span class="text-rose-500">*</span>
            </label>
            <input
              id="user-email"
              type="email"
              bind:value={newEmail}
              placeholder="hendra.wijaya@campus.ac.id"
              required
              class="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
            />
          </div>

          <div class="grid grid-cols-2 gap-3">
            <div>
              <label class="block font-semibold text-slate-700 mb-1" for="user-nip">
                NIP / Identitas Pegawai
              </label>
              <input
                id="user-nip"
                type="text"
                bind:value={newNip}
                placeholder="19850711..."
                class="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
              />
            </div>

            <div>
              <label class="block font-semibold text-slate-700 mb-1" for="user-prodi">
                Unit / Prodi
              </label>
              <input
                id="user-prodi"
                type="text"
                bind:value={newProdi}
                placeholder="UPT Perpustakaan"
                class="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
              />
            </div>
          </div>

          <div>
            <label class="block font-semibold text-slate-700 mb-1" for="user-pw">
              Kata Sandi Awal <span class="text-rose-500">*</span>
            </label>
            <input
              id="user-pw"
              type="text"
              bind:value={newPassword}
              required
              class="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 font-mono focus:outline-none focus:ring-2 focus:ring-indigo-500/20 focus:border-indigo-500"
            />
            <p class="text-[11px] text-slate-400 mt-1">Default sistem: password123</p>
          </div>

          <div class="flex items-center justify-end gap-3 pt-3 border-t border-slate-100">
            <button
              type="button"
              onclick={() => isAddUserOpen = false}
              class="px-4 py-2.5 rounded-xl font-bold text-slate-600 hover:bg-slate-100 transition-colors"
            >
              Batal
            </button>

            <button
              type="submit"
              disabled={isSavingUser}
              class="flex items-center gap-2 px-5 py-2.5 rounded-xl font-bold bg-indigo-600 hover:bg-indigo-700 text-white shadow-lg shadow-indigo-600/20 transition-all disabled:opacity-50"
            >
              {#if isSavingUser}
                <span class="animate-spin material-symbols-outlined text-base">progress_activity</span>
                <span>Menyimpan...</span>
              {:else}
                <span class="material-symbols-outlined text-base">save</span>
                <span>Buat Akun</span>
              {/if}
            </button>
          </div>
        </form>
      </div>
    </div>
  {/if}

  <!-- MODAL: RESET PASSWORD -->
  {#if resetUserId}
    <div class="fixed inset-0 z-50 bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4">
      <div class="bg-white rounded-3xl shadow-2xl border border-slate-200 max-w-sm w-full p-6 space-y-5 animate-scaleUp">
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center">
            <span class="material-symbols-outlined text-xl">lock_reset</span>
          </div>
          <div>
            <h3 class="text-base font-bold text-slate-900">Reset Kata Sandi</h3>
            <p class="text-xs text-slate-500">{resetUserName}</p>
          </div>
        </div>

        <form onsubmit={handleResetPasswordSubmit} class="space-y-4 text-xs sm:text-sm">
          <div>
            <label class="block font-semibold text-slate-700 mb-1" for="reset-pw-input">
              Kata Sandi Baru
            </label>
            <input
              id="reset-pw-input"
              type="text"
              bind:value={resetNewPassword}
              required
              class="w-full px-3.5 py-2.5 rounded-xl border border-slate-200 font-mono focus:outline-none focus:ring-2 focus:ring-amber-500/20 focus:border-amber-500"
            />
          </div>

          <div class="flex items-center justify-end gap-2 pt-2 border-t border-slate-100">
            <button
              type="button"
              onclick={() => resetUserId = null}
              class="px-4 py-2 rounded-xl font-bold text-slate-600 hover:bg-slate-100"
            >
              Batal
            </button>
            <button
              type="submit"
              disabled={isResettingPassword}
              class="px-4 py-2 rounded-xl font-bold bg-amber-600 hover:bg-amber-700 text-white transition-colors"
            >
              {isResettingPassword ? 'Menyimpan...' : 'Simpan Sandi Baru'}
            </button>
          </div>
        </form>
      </div>
    </div>
  {/if}
</div>
