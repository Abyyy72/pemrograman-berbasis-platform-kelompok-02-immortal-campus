import type { Karya, RolePengguna, StatusKarya } from '../types';
import { initialKaryaList } from '../data/karyaData';

const BASE_URL = import.meta.env.VITE_API_URL || '/api/v1';

export function getAuthToken(): string | null {
  if (typeof localStorage === 'undefined') return null;
  return localStorage.getItem('immortal_token');
}

export function setAuthSession(token: string, role: RolePengguna, email: string, user?: any) {
  if (typeof localStorage === 'undefined') return;
  localStorage.setItem('immortal_token', token);
  localStorage.setItem('immortal_role', role);
  localStorage.setItem('immortal_email', email);
  if (user) {
    localStorage.setItem('immortal_user', JSON.stringify(user));
  }
}

export function getAuthUser(): any | null {
  if (typeof localStorage === 'undefined') return null;
  const raw = localStorage.getItem('immortal_user');
  try {
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

export function clearAuthSession() {
  if (typeof localStorage === 'undefined') return;
  localStorage.removeItem('immortal_token');
  localStorage.removeItem('immortal_role');
  localStorage.removeItem('immortal_email');
  localStorage.removeItem('immortal_user');
}

/**
 * Fetch all manuscripts from backend (fallback to initialKaryaList if offline)
 */
export async function apiFetchAllKarya(): Promise<Karya[]> {
  try {
    const res = await fetch(`${BASE_URL}/karya/semua`, {
      headers: { 'Content-Type': 'application/json' },
    });
    if (!res.ok) throw new Error('Backend responded with error');
    const json = await res.json();
    if (json.status && Array.isArray(json.data) && json.data.length > 0) {
      return json.data;
    }
    return initialKaryaList;
  } catch (err) {
    // Graceful offline fallback
    console.warn('Backend API offline or unreachable, using local dataset fallback.', err);
    return initialKaryaList;
  }
}

export interface StatistikData {
  ringkasan: {
    totalKarya: number;
    totalDiterbitkan: number;
    totalUnduhan: number;
    totalSitasi: number;
    antreanReview: number;
    diajukan: number;
    dalamReview: number;
    perluRevisi: number;
    ditolak: number;
    draft: number;
  };
  distribusiProdi: Record<string, number>;
  distribusiJenis: Record<string, number>;
  topUnduhan: {
    id: string;
    judul: string;
    penulis: string;
    unduhan: number;
    prodi: string;
  }[];
}

/**
 * Fetch statistik real-time dari Supabase database
 */
export async function apiFetchStatistik(): Promise<StatistikData | null> {
  try {
    const res = await fetch(`${BASE_URL}/statistik`);
    if (!res.ok) throw new Error('Failed to fetch statistik');
    const json = await res.json();
    return json.status ? json.data : null;
  } catch (err) {
    console.warn('Gagal mengambil statistik dari backend:', err);
    return null;
  }
}

/**
 * Login user via backend (FR-01, FR-02)
 */
export async function apiLogin(identifier: string, password: string, role?: 'penulis' | 'kurator') {
  try {
    const res = await fetch(`${BASE_URL}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ identifier, password, role }),
    });
    
    // Periksa jika respons bukan JSON (misal error proxy Vite berupa plain text / HTML)
    const contentType = res.headers.get('content-type') || '';
    if (!contentType.includes('application/json')) {
      throw new Error('Gagal menghubungi server backend (port 3000). Pastikan server backend sedang aktif.');
    }

    const json = await res.json();
    if (!res.ok || !json.status) {
      throw new Error(json.message || 'Login gagal.');
    }
    return json.data; // { token, user: { id, nama, email, nim, nip, prodi, role } }
  } catch (err: any) {
    if (err.message && err.message.includes('Failed to fetch')) {
      throw new Error('Tidak dapat terhubung ke server backend. Pastikan server backend sedang aktif di port 3000.');
    }
    throw err;
  }
}

/**
 * Register author / curator via backend (FR-01, FR-02)
 */
export async function apiRegister(userData: {
  nama: string;
  email: string;
  password: string;
  nim?: string;
  nip?: string;
  prodi?: string;
  role?: 'penulis' | 'kurator';
}) {
  try {
    const res = await fetch(`${BASE_URL}/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ...userData,
        role: userData.role || 'penulis',
      }),
    });

    const contentType = res.headers.get('content-type') || '';
    if (!contentType.includes('application/json')) {
      throw new Error('Gagal menghubungi server backend (port 3000). Pastikan server backend sedang aktif.');
    }

    const json = await res.json();
    if (!res.ok || !json.status) {
      throw new Error(json.message || 'Registrasi gagal.');
    }
    return json.data; // { token, user: { id, nama, email, nim, nip, prodi, role } }
  } catch (err: any) {
    if (err.message && err.message.includes('Failed to fetch')) {
      throw new Error('Tidak dapat terhubung ke server backend. Pastikan server backend sedang aktif di port 3000.');
    }
    throw err;
  }
}

/**
 * Upload / create new karya via backend (FR-10, FR-14)
 */
export async function apiCreateKarya(karya: Partial<Karya>): Promise<Karya | null> {
  const token = getAuthToken();
  try {
    const res = await fetch(`${BASE_URL}/karya`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: JSON.stringify(karya),
    });
    const json = await res.json();
    if (json.status && json.data) {
      return json.data;
    }
  } catch (err) {
    console.warn('Backend submission failed, falling back to client-side state.', err);
  }
  return null;
}

/**
 * Curator review decision via backend (FR-23)
 */
export async function apiReviewKarya(
  karyaId: string,
  tindakan: 'terbitkan' | 'revisi' | 'tolak',
  catatan?: string
): Promise<Karya | null> {
  const token = getAuthToken();
  try {
    const res = await fetch(`${BASE_URL}/karya/${karyaId}/review`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: JSON.stringify({ tindakan, catatan }),
    });
    const json = await res.json();
    if (json.status && json.data) {
      return json.data;
    }
  } catch (err) {
    console.warn('Backend review failed, falling back to client-side state.', err);
  }
  return null;
}

/**
 * Submit revision via backend (FR-10, FR-14)
 */
export async function apiSubmitRevisi(
  karyaId: string,
  fields: Partial<Karya>,
  submitForReview: boolean
): Promise<Karya | null> {
  const token = getAuthToken();
  try {
    const res = await fetch(`${BASE_URL}/karya/${karyaId}`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        ...(token ? { Authorization: `Bearer ${token}` } : {}),
      },
      body: JSON.stringify({ ...fields, submitForReview }),
    });
    const json = await res.json();
    if (json.status && json.data) {
      return json.data;
    }
  } catch (err) {
    console.warn('Backend revision update failed, falling back to client-side state.', err);
  }
  return null;
}

/**
 * Record download in backend (FR-40, FR-41)
 */
export async function apiRecordDownload(karyaId: string): Promise<void> {
  try {
    await fetch(`${BASE_URL}/karya/${karyaId}/unduh`, {
      method: 'POST',
    });
  } catch (err) {
    // Non-blocking
  }
}

// ─── ADMIN API HELPERS ────────────────────────────────────────────────────────

export async function apiAdminGetUsers(role?: string): Promise<any[]> {
  const token = getAuthToken();
  const query = role ? `?role=${role}` : '';
  const res = await fetch(`${BASE_URL}/admin/users${query}`, {
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  if (!res.ok) throw new Error('Gagal mengambil data pengguna');
  const json = await res.json();
  return json.data || [];
}

export async function apiAdminCreateUser(userData: {
  nama: string;
  email: string;
  password: string;
  nip?: string;
  nim?: string;
  prodi?: string;
  role?: 'kurator' | 'penulis' | 'admin';
}): Promise<any> {
  const token = getAuthToken();
  const res = await fetch(`${BASE_URL}/admin/users`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify(userData),
  });
  const json = await res.json();
  if (!res.ok || !json.status) {
    throw new Error(json.message || 'Gagal membuat pengguna');
  }
  return json.data;
}

export async function apiAdminDeleteUser(id: string): Promise<void> {
  const token = getAuthToken();
  const res = await fetch(`${BASE_URL}/admin/users/${id}`, {
    method: 'DELETE',
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  const json = await res.json();
  if (!res.ok || !json.status) {
    throw new Error(json.message || 'Gagal menghapus pengguna');
  }
}

export async function apiAdminResetPassword(id: string, newPassword: string): Promise<void> {
  const token = getAuthToken();
  const res = await fetch(`${BASE_URL}/admin/users/${id}/reset-password`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify({ newPassword }),
  });
  const json = await res.json();
  if (!res.ok || !json.status) {
    throw new Error(json.message || 'Gagal mereset kata sandi');
  }
}

export async function apiAdminGetStatistik(): Promise<any> {
  const token = getAuthToken();
  const res = await fetch(`${BASE_URL}/admin/statistik`, {
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  if (!res.ok) throw new Error('Gagal mengambil statistik admin');
  const json = await res.json();
  return json.data;
}

export async function apiAdminDeleteKarya(id: string): Promise<void> {
  const token = getAuthToken();
  const res = await fetch(`${BASE_URL}/admin/karya/${id}`, {
    method: 'DELETE',
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
  });
  const json = await res.json();
  if (!res.ok || !json.status) {
    throw new Error(json.message || 'Gagal menghapus karya');
  }
}

export async function apiAdminOverrideKaryaStatus(id: string, status: StatusKarya, catatan?: string): Promise<any> {
  const token = getAuthToken();
  const res = await fetch(`${BASE_URL}/admin/karya/${id}/status`, {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify({ status, catatan }),
  });
  const json = await res.json();
  if (!res.ok || !json.status) {
    throw new Error(json.message || 'Gagal mengubah status karya');
  }
  return json.data;
}
