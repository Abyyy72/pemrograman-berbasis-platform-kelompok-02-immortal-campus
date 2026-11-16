<script lang="ts">
  import { onMount, tick } from "svelte";
  import type { RolePengguna } from "../types";
  import { navigate } from "../router";

  interface Props {
    activeRole: RolePengguna;
    currentPath?: string;
    userName?: string;
    currentUser?: any;
    onOpenUpload: () => void;
    onOpenLogin: () => void;
    onLogout?: () => void;
    pendingReviewCount?: number;
  }

  let {
    activeRole,
    currentPath = "beranda",
    userName = "",
    currentUser = null,
    onOpenUpload,
    onOpenLogin,
    onLogout,
    pendingReviewCount = 3,
  }: Props = $props();

  function getInitials(name?: string): string {
    if (!name) return "U";
    const parts = name.trim().split(/\s+/);
    if (parts.length === 1) return parts[0].slice(0, 2).toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  let displayName = $derived(
    currentUser?.nama ||
      (userName && !userName.includes("@") ? userName : "") ||
      (activeRole !== "publik" ? "Pengguna" : ""),
  );

  let displayInitials = $derived(getInitials(displayName));

  let mobileMenuOpen = $state(false);

  // 5 Public landing page anchors
  const publicNavItems = [
    { id: "beranda", label: "Beranda", href: "#beranda" },
    { id: "jelajah-karya", label: "Jelajah Karya", href: "#jelajah-karya" },
    {
      id: "statistik-direktori",
      label: "Statistik & Direktori",
      href: "#statistik-direktori",
    },
    { id: "alur-kurasi", label: "Alur Kurasi", href: "#alur-kurasi" },
    { id: "panduan", label: "Panduan", href: "#panduan" },
  ];

  // Penulis nav items
  const penulisNavItems = [
    {
      id: "dashboard-penulis",
      label: "Dashboard Penulis",
      href: "#/dashboard-penulis",
    },
    { id: "jelajah", label: "Katalog Karya", href: "#/jelajah" },
    { id: "panduan", label: "Panduan Unggah", href: "#panduan" },
  ];

  // Kurator nav items
  const kuratorNavItems = [
    {
      id: "dashboard-kurator",
      label: "Antrean Kurasi",
      href: "#/dashboard-kurator",
    },
    { id: "jelajah", label: "Katalog Publik", href: "#/jelajah" },
  ];

  // Admin nav items
  const adminNavItems = [
    {
      id: "dashboard-admin",
      label: "Panel Kontrol Admin",
      href: "#/dashboard-admin",
    },
    { id: "jelajah", label: "Katalog Publik", href: "#/jelajah" },
  ];

  // Dynamic nav items based on role
  let currentNavItems = $derived.by(() => {
    if (activeRole === "admin") return adminNavItems;
    if (activeRole === "penulis") return penulisNavItems;
    if (activeRole === "kurator") return kuratorNavItems;
    return publicNavItems;
  });

  // Active pill state & sliding animation
  let activeTabId = $state<string>("beranda");
  let itemRefs = $state<Record<string, HTMLElement | null>>({});

  let pillLeft = $state(0);
  let pillTop = $state(0);
  let pillWidth = $state(0);
  let pillHeight = $state(0);
  let pillOpacity = $state(0);

  let isProgrammaticScrolling = false;
  let scrollTimeout: any = null;

  function updatePillPosition() {
    const el = itemRefs[activeTabId];
    if (el) {
      pillLeft = el.offsetLeft;
      pillTop = el.offsetTop;
      pillWidth = el.offsetWidth;
      pillHeight = el.offsetHeight;
      pillOpacity = 1;
    } else {
      pillOpacity = 0;
    }
  }

  function scrollToSection(id: string) {
    if (id === "beranda") {
      window.scrollTo({ top: 0, behavior: "smooth" });
      return;
    }
    const el = document.getElementById(id);
    if (el) {
      const yOffset = -72;
      const y = el.getBoundingClientRect().top + window.pageYOffset + yOffset;
      window.scrollTo({ top: y, behavior: "smooth" });
    }
  }

  function handleNavClick(
    item: { id: string; label: string; href: string },
    e: MouseEvent,
  ) {
    e.preventDefault();
    activeTabId = item.id;
    updatePillPosition();

    // Admin navigation
    if (activeRole === "admin") {
      if (item.id === "dashboard-admin") {
        navigate("/dashboard-admin");
        return;
      } else if (item.id === "jelajah") {
        navigate("/jelajah");
        return;
      }
    }

    // Penulis navigation
    if (activeRole === "penulis") {
      if (item.id === "dashboard-penulis") {
        navigate("/dashboard-penulis");
        return;
      } else if (item.id === "jelajah") {
        navigate("/jelajah");
        return;
      } else if (item.id === "panduan") {
        if (currentPath !== "beranda") {
          navigate("/");
          setTimeout(() => scrollToSection("panduan"), 150);
        } else {
          scrollToSection("panduan");
        }
        return;
      }
    }

    // Kurator navigation
    if (activeRole === "kurator") {
      if (item.id === "dashboard-kurator") {
        navigate("/dashboard-kurator");
        return;
      } else if (item.id === "jelajah") {
        navigate("/jelajah");
        return;
      }
    }

    // Public navigation (5 landing page sections)
    isProgrammaticScrolling = true;
    clearTimeout(scrollTimeout);
    scrollTimeout = setTimeout(() => {
      isProgrammaticScrolling = false;
    }, 1000);

    if (currentPath !== "beranda") {
      navigate("/");
      setTimeout(() => {
        scrollToSection(item.id);
      }, 120);
    } else {
      scrollToSection(item.id);
    }
  }

  function handleBrandClick(e: MouseEvent) {
    e.preventDefault();
    if (activeRole === "admin") {
      activeTabId = "dashboard-admin";
      navigate("/dashboard-admin");
    } else if (activeRole === "penulis") {
      activeTabId = "dashboard-penulis";
      navigate("/dashboard-penulis");
    } else if (activeRole === "kurator") {
      activeTabId = "dashboard-kurator";
      navigate("/dashboard-kurator");
    } else {
      activeTabId = "beranda";
      updatePillPosition();
      if (currentPath !== "beranda") {
        navigate("/");
        setTimeout(() => {
          window.scrollTo({ top: 0, behavior: "smooth" });
        }, 100);
      } else {
        window.scrollTo({ top: 0, behavior: "smooth" });
      }
    }
  }

  function handleCariClick(e: MouseEvent) {
    e.preventDefault();
    navigate("/jelajah");
  }

  function handleLoginClick() {
    navigate("/login");
  }

  $effect(() => {
    // Keep activeTabId in sync with currentPath and role
    if (activeRole === "admin") {
      if (currentPath === "dashboard-admin") activeTabId = "dashboard-admin";
      else if (currentPath === "jelajah") activeTabId = "jelajah";
    } else if (activeRole === "penulis") {
      if (currentPath === "dashboard-penulis")
        activeTabId = "dashboard-penulis";
      else if (currentPath === "jelajah") activeTabId = "jelajah";
      else if (currentPath === "panduan") activeTabId = "panduan";
    } else if (activeRole === "kurator") {
      if (currentPath === "dashboard-kurator")
        activeTabId = "dashboard-kurator";
      else if (currentPath === "jelajah") activeTabId = "jelajah";
    } else {
      if (currentPath === "jelajah") activeTabId = "jelajah-karya";
    }
    tick().then(updatePillPosition);
  });

  onMount(() => {
    tick().then(updatePillPosition);
    window.addEventListener("resize", updatePillPosition);

    function handleWindowScroll() {
      if (
        isProgrammaticScrolling ||
        currentPath !== "beranda" ||
        activeRole !== "publik"
      )
        return;

      // Scrolled near top -> Beranda
      if (window.scrollY < 200) {
        if (activeTabId !== "beranda") {
          activeTabId = "beranda";
          updatePillPosition();
        }
        return;
      }

      // Scrolled to bottom -> Panduan
      const isBottom =
        window.innerHeight + window.scrollY >=
        document.documentElement.scrollHeight - 100;
      if (isBottom) {
        if (activeTabId !== "panduan") {
          activeTabId = "panduan";
          updatePillPosition();
        }
        return;
      }

      // Check all 5 sections from bottom to top
      const sectionIds = [
        "panduan",
        "alur-kurasi",
        "statistik-direktori",
        "jelajah-karya",
        "beranda",
      ];
      const scrollPos = window.scrollY + 220;

      for (const id of sectionIds) {
        const el = document.getElementById(id);
        if (el) {
          const top = el.getBoundingClientRect().top + window.pageYOffset;
          if (scrollPos >= top) {
            if (activeTabId !== id) {
              activeTabId = id;
              updatePillPosition();
            }
            return;
          }
        }
      }
    }

    window.addEventListener("scroll", handleWindowScroll, { passive: true });
    return () => {
      window.removeEventListener("resize", updatePillPosition);
      window.removeEventListener("scroll", handleWindowScroll);
      clearTimeout(scrollTimeout);
    };
  });
</script>

<header
  class="fixed top-0 inset-x-0 z-50 bg-white/95 backdrop-blur-xl border-b border-slate-100 shadow-sm"
>
  <div
    class="h-16 max-w-screen-xl mx-auto px-3 sm:px-5 lg:px-10 flex items-center justify-between gap-2 sm:gap-6"
  >
    <!-- Brand Logo -->
    <a
      href="#/"
      onclick={handleBrandClick}
      class="flex items-center gap-2 sm:gap-3 shrink-0 group cursor-pointer py-1"
    >
      <img
        alt="Immortal Campus Logo"
        class="h-10 sm:h-12 w-auto object-contain shrink-0 group-hover:scale-105 transition-transform duration-200"
        src="/logo.png"
      />
      <div class="flex flex-col leading-none">
        <span
          class="text-[14px] sm:text-[15px] font-extrabold text-primary tracking-tight font-display-hero"
        >
          Immortal Campus
        </span>
        <span
          class="text-[9px] sm:text-[10px] text-slate-400 tracking-wide font-medium mt-0.5"
        >
          Etalase Digital Ilmiah
        </span>
      </div>
    </a>

    <!-- Center Navigation with Gliding Capsule -->
    <nav
      class="hidden md:flex items-center gap-0.5 bg-slate-50 border border-slate-200 px-1.5 py-1.5 rounded-2xl relative"
    >
      <!-- Animated Gliding Capsule Indicator -->
      <span
        class="absolute bg-primary rounded-xl shadow-[0_2px_12px_rgba(0,102,255,0.30)] transition-all duration-300 ease-out pointer-events-none z-0"
        style="left: {pillLeft}px; top: {pillTop}px; width: {pillWidth}px; height: {pillHeight}px; opacity: {pillOpacity};"
      ></span>

      {#each currentNavItems as item (item.id)}
        <a
          bind:this={itemRefs[item.id]}
          href={item.href}
          onclick={(e) => handleNavClick(item, e)}
          class="relative z-10 px-4 py-1.5 rounded-xl text-xs sm:text-sm font-semibold cursor-pointer select-none transition-colors duration-200 flex items-center gap-1.5
            {activeTabId === item.id
            ? 'text-white'
            : 'text-slate-600 hover:text-slate-900'}"
        >
          <span>{item.label}</span>
          {#if item.id === "dashboard-kurator" && pendingReviewCount > 0}
            <span
              class="px-1.5 py-0.2 rounded-full bg-red-500 text-white text-[10px] font-bold"
            >
              {pendingReviewCount}
            </span>
          {/if}
        </a>
      {/each}
    </nav>

    <!-- Right Side Actions (Differentiated by Role) -->
    <div class="flex items-center gap-2 shrink-0">
      <!-- ── 1. MODE PUBLIK (BELUM LOGIN) ── -->
      {#if activeRole === "publik"}
        <!-- Search Button -->
        <button
          onclick={handleCariClick}
          class="hidden sm:inline-flex items-center gap-1.5 text-xs sm:text-sm text-slate-600 hover:text-primary border border-slate-200 hover:border-primary/40 hover:bg-primary/5 px-3.5 py-1.5 rounded-xl transition-all duration-200 font-semibold cursor-pointer"
        >
          <span class="material-symbols-outlined text-base">search</span>
          <span>Cari Karya</span>
        </button>

        <!-- Direct Login Button (NO SWITCHER BAR!) -->
        <button
          onclick={handleLoginClick}
          class="inline-flex items-center gap-1.5 text-xs sm:text-sm bg-primary hover:bg-blue-600 text-white px-4 py-2 rounded-xl shadow-md shadow-primary/20 transition-all duration-200 active:scale-95 font-bold cursor-pointer"
        >
          <span class="material-symbols-outlined text-base">login</span>
          <span>Masuk / Login</span>
        </button>

        <!-- ── 2. MODE PENULIS (SETELAH LOGIN MAHASISWA/PENULIS) ── -->
      {:else if activeRole === "penulis"}
        <!-- + Unggah Karya Button -->
        <button
          type="button"
          onclick={onOpenUpload}
          class="inline-flex items-center gap-1.5 text-xs sm:text-sm bg-primary hover:bg-blue-600 text-white px-3.5 py-2 rounded-xl shadow-md shadow-primary/20 transition-all duration-200 active:scale-95 font-bold cursor-pointer"
        >
          <span class="material-symbols-outlined text-base">upload_file</span>
          <span class="hidden sm:inline">+ Unggah Karya</span>
        </button>

        <!-- Student Profile Pill -->
        <div
          class="flex items-center gap-2 p-1 pl-2 pr-3 rounded-xl bg-slate-50 border border-slate-200 text-xs"
        >
          <div
            class="w-7 h-7 rounded-full bg-primary text-white flex items-center justify-center font-bold text-[10px]"
          >
            {displayInitials}
          </div>
          <div class="hidden sm:flex flex-col leading-none">
            <span class="font-bold text-slate-900 truncate max-w-[130px]"
              >{displayName}</span
            >
            <span class="text-[10px] text-primary font-semibold"
              >Penulis (Mahasiswa)</span
            >
          </div>
        </div>

        <!-- Logout Button -->
        {#if onLogout}
          <button
            type="button"
            onclick={onLogout}
            title="Keluar dari akun Penulis dan kembali ke Repositori Publik"
            class="p-2 text-slate-400 hover:text-red-600 rounded-xl hover:bg-red-50 transition-colors cursor-pointer"
            aria-label="Keluar"
          >
            <span class="material-symbols-outlined text-xl">logout</span>
          </button>
        {/if}

        <!-- ── 3. MODE KURATOR (SETELAH LOGIN STAF PERPUSTAKAAN) ── -->
      {:else if activeRole === "kurator"}
        <!-- Curator Profile Pill -->
        <div
          class="flex items-center gap-2 p-1 pl-2 pr-3 rounded-xl bg-blue-50/70 border border-blue-200/80 text-xs"
        >
          <div
            class="w-7 h-7 rounded-full bg-primary text-white flex items-center justify-center font-bold text-[10px]"
          >
            {displayInitials}
          </div>
          <div class="hidden sm:flex flex-col leading-none">
            <span class="font-bold text-slate-900 truncate max-w-[130px]"
              >{displayName}</span
            >
            <span class="text-[10px] text-primary font-bold"
              >Kurator Perpustakaan</span
            >
          </div>
        </div>

        <!-- Logout Button -->
        {#if onLogout}
          <button
            type="button"
            onclick={onLogout}
            title="Keluar dari akun Kurator dan kembali ke Repositori Publik"
            class="p-2 text-slate-400 hover:text-red-600 rounded-xl hover:bg-red-50 transition-colors cursor-pointer"
            aria-label="Keluar"
          >
            <span class="material-symbols-outlined text-xl">logout</span>
          </button>
        {/if}

        <!-- ── 4. MODE ADMIN (SUPER ADMIN SISTEM) ── -->
      {:else if activeRole === "admin"}
        <div
          class="flex items-center gap-2 p-1 pl-2 pr-3 rounded-xl bg-amber-50 border border-amber-200 text-xs"
        >
          <div
            class="w-7 h-7 rounded-full bg-amber-600 text-white flex items-center justify-center font-bold text-[10px]"
          >
            {displayInitials}
          </div>
          <div class="hidden sm:flex flex-col leading-none">
            <span class="font-bold text-slate-900 truncate max-w-[130px]"
              >{displayName}</span
            >
            <span class="text-[10px] text-amber-600 font-bold"
              >Administrator Sistem</span
            >
          </div>
        </div>

        {#if onLogout}
          <button
            type="button"
            onclick={onLogout}
            title="Keluar dari akun Admin"
            class="p-2 text-slate-400 hover:text-red-600 rounded-xl hover:bg-red-50 transition-colors cursor-pointer"
            aria-label="Keluar"
          >
            <span class="material-symbols-outlined text-xl">logout</span>
          </button>
        {/if}
      {/if}

      <!-- Mobile Hamburger Button -->
      <button
        onclick={() => (mobileMenuOpen = !mobileMenuOpen)}
        class="md:hidden p-2 rounded-xl text-slate-500 hover:text-slate-800 hover:bg-slate-100 transition-colors cursor-pointer"
        aria-label="Menu navigasi mobile"
      >
        <span class="material-symbols-outlined text-xl"
          >{mobileMenuOpen ? "close" : "menu"}</span
        >
      </button>
    </div>
  </div>

  <!-- Mobile Dropdown Menu -->
  {#if mobileMenuOpen}
    <div
      class="md:hidden px-4 pt-2 pb-5 bg-white border-t border-slate-100 shadow-xl space-y-3 max-h-[calc(100vh-4rem)] overflow-y-auto"
    >
      <!-- Status Badge on Mobile if Logged In -->
      {#if activeRole !== "publik"}
        <div
          class="p-3 rounded-xl bg-slate-50 border border-slate-200 flex items-center justify-between gap-2"
        >
          <div class="flex items-center gap-2.5 min-w-0">
            <div
              class="w-8 h-8 rounded-full {activeRole === 'admin'
                ? 'bg-amber-600'
                : 'bg-primary'} text-white flex items-center justify-center font-bold text-xs shrink-0"
            >
              {displayInitials}
            </div>
            <div class="min-w-0">
              <p class="text-xs font-bold text-slate-900 truncate">
                {displayName}
              </p>
              <p
                class="text-[10px] {activeRole === 'admin'
                  ? 'text-amber-600'
                  : 'text-primary'} font-semibold truncate"
              >
                {activeRole === "admin"
                  ? "Mode Administrator Sistem"
                  : activeRole === "penulis"
                    ? "Mode Penulis (Mahasiswa)"
                    : "Mode Kurator Perpustakaan"}
              </p>
            </div>
          </div>
          {#if onLogout}
            <button
              onclick={() => {
                if (onLogout) onLogout();
                mobileMenuOpen = false;
              }}
              class="px-2.5 py-1 rounded-lg bg-red-50 text-red-600 text-xs font-bold hover:bg-red-100 shrink-0"
            >
              Keluar
            </button>
          {/if}
        </div>
      {/if}

      <!-- Nav Links Mobile -->
      <nav class="flex flex-col gap-1">
        {#each currentNavItems as item (item.id)}
          <a
            href={item.href}
            onclick={(e) => {
              handleNavClick(item, e);
              mobileMenuOpen = false;
            }}
            class="flex items-center justify-between px-3.5 py-2.5 rounded-xl text-sm font-semibold transition-all
              {activeTabId === item.id
              ? 'bg-primary text-white shadow-sm'
              : 'text-slate-700 hover:bg-slate-50 hover:text-slate-900'}"
          >
            <span>{item.label}</span>
            {#if item.id === "dashboard-kurator" && pendingReviewCount > 0}
              <span
                class="px-2 py-0.5 rounded-full bg-red-500 text-white text-[10px] font-bold"
              >
                {pendingReviewCount}
              </span>
            {/if}
          </a>
        {/each}
      </nav>

      <!-- If Public: Direct Login button on mobile -->
      {#if activeRole === "publik"}
        <div class="pt-2 border-t border-slate-100 space-y-2">
          <button
            onclick={() => {
              handleCariClick({ preventDefault: () => {} } as MouseEvent);
              mobileMenuOpen = false;
            }}
            class="w-full py-2.5 rounded-xl border border-slate-200 text-slate-700 font-bold text-sm hover:bg-slate-50 transition-all flex items-center justify-center gap-2"
          >
            <span class="material-symbols-outlined text-base">search</span>
            <span>Cari Karya Ilmiah</span>
          </button>
          <button
            onclick={() => {
              handleLoginClick();
              mobileMenuOpen = false;
            }}
            class="w-full py-2.5 rounded-xl bg-primary text-white font-bold text-sm shadow hover:bg-blue-600 transition-all flex items-center justify-center gap-2"
          >
            <span class="material-symbols-outlined text-base">login</span>
            <span>Masuk ke Akun Kampus</span>
          </button>
        </div>
      {/if}
    </div>
  {/if}
</header>
