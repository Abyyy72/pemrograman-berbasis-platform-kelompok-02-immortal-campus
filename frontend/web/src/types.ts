export type JenisKarya = 'skripsi' | 'tesis' | 'jurnal' | 'kp';

export type StatusKarya = 'Draft' | 'Diajukan' | 'Dalam Review' | 'Perlu Revisi' | 'Diterbitkan' | 'Ditolak';

export type RolePengguna = 'publik' | 'penulis' | 'kurator' | 'admin';

export interface Karya {
  id: string;
  judul: string;
  penulis: string;
  nim?: string;
  pembimbing: string;
  jenis: JenisKarya;
  jenisLabel: string;
  prodi: string;
  prodiKey: 'all' | 'ti' | 'si' | 'dkv' | 'mnj' | 'ilkom';
  tahun: number;
  abstrak: string;
  kataKunci: string[];
  unduhan: number;
  sitasi?: number;
  status: StatusKarya;
  tanggalTerbit: string;
  doi?: string;
  fileSize?: string;
  catatanKurator?: string;
  penulisId?: string;
  fileUrl?: string;
  filePath?: string;
}

export interface ReviewAction {
  karyaId: string;
  tindakan: 'terbitkan' | 'revisi' | 'tolak';
  catatan: string;
}

