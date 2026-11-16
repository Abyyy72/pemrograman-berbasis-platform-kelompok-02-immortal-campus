# Panduan Kontribusi - Immortal Campus

## Format Pesan Commit
Mengikuti standar PRD bagian 15.4:

```
<tipe>(<bagian>): <ringkasan perubahan>
```

| Tipe | Dipakai untuk | Contoh |
|---|---|---|
| `feat` | Fitur atau tugas baru | `feat(backend): tambah endpoint upload karya` |
| `fix` | Perbaikan | `fix(backend): perbaiki validasi login` |
| `docs` | Dokumentasi | `docs(kelompok-02): perbarui laporan proyek` |
| `test` | Pengujian | `test(frontend-web): tambah bukti pengujian` |

## Alur Kerja Git & Pull Request
1. Branch utama: `main`.
2. Buat branch tugas dari `main` terbaru: `kelompok-02-fitur-nama`.
3. Satu commit untuk satu perubahan terfokus.
4. Buka Pull Request ke `main` dan minta review minimal 1 anggota kelompok.
5. Catat setiap kendala sebagai GitHub Issue.

