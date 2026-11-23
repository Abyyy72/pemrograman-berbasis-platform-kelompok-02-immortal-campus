# Immortal Campus - Etalase Digital Karya Ilmiah Kampus

> Repositori digital institusional kampus untuk menyimpan, mengkurasi, dan mempublikasikan karya ilmiah (skripsi, tesis, jurnal, laporan penelitian, laporan kerja praktik) sivitas akademika.

## Identitas Proyek
- **Mata Kuliah:** Pemrograman Berbasis Platform
- **Kelompok:** 02
- **Nama Tim:** Immortal Campus Team
- **Platform:** Web (Svelte 5 + Tailwind CSS) + Mobile (Flutter) + Backend (Node.js Express + Supabase PostgreSQL)

## Arsitektur Sistem
```
Frontend Web (Svelte 5 + Vite + TS + Tailwind) ──┐
                                                 ├──> REST API (Express 4.21 + JWT) ──> Supabase (PostgreSQL & Storage)
Frontend Mobile (Flutter + Provider) ────────────┘
```

## Struktur Repository
Mengikuti standar PRD bagian 15.2:
```
├── README.md
├── CONTRIBUTING.md
├── .gitignore
├── docs/
│   ├── PRD.md
│   ├── tugas-kelompok-1-kelompok.md
│   ├── proposal.md
│   └── backlog.md
├── backend/
│   └── README.md
├── frontend/
│   ├── web/        # Aplikasi Svelte 5 + TypeScript + Vite + Tailwind CSS
│   │   ├── README.md
│   │   ├── src/
│   │   │   ├── components/
│   │   │   ├── data/
│   │   │   ├── types.ts
│   │   │   ├── App.svelte
│   │   │   └── main.ts
│   └── mobile/     # Aplikasi Flutter
│       └── README.md
└── stitch_assets/  # Berkas rancangan antarmuka & screenshot Stitch
```


