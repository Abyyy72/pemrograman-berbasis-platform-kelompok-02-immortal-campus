// Lightweight reactive hash router for Svelte 5
export type RoutePath =
  | 'beranda'
  | 'jelajah'
  | 'panduan'
  | 'login'
  | 'dashboard-penulis'
  | 'dashboard-kurator'
  | 'dashboard-admin'
  | 'detail'
  | 'revisi';

export interface RouteState {
  path: RoutePath;
  params: Record<string, string>;
  hash: string;
}

function parseHash(): RouteState {
  const hash = window.location.hash.replace(/^#\/?/, '');
  const [routePart, queryPart] = hash.split('?');
  const segments = routePart.split('/').filter(Boolean);

  const params: Record<string, string> = {};
  if (queryPart) {
    const searchParams = new URLSearchParams(queryPart);
    searchParams.forEach((val, key) => {
      params[key] = val;
    });
  }

  const firstSeg = segments[0] || 'beranda';

  if (firstSeg === 'karya' && segments[1]) {
    params.id = segments[1];
    return { path: 'detail', params, hash };
  }

  if (firstSeg === 'revisi' && segments[1]) {
    params.id = segments[1];
    return { path: 'revisi', params, hash };
  }

  if (
    firstSeg === 'jelajah' ||
    firstSeg === 'panduan' ||
    firstSeg === 'login' ||
    firstSeg === 'dashboard-penulis' ||
    firstSeg === 'dashboard-kurator' ||
    firstSeg === 'dashboard-admin'
  ) {
    return { path: firstSeg as RoutePath, params, hash };
  }

  return { path: 'beranda', params, hash };
}

// Global active route state
let currentRouteState = parseHash();
const listeners = new Set<(route: RouteState) => void>();

export function getRoute(): RouteState {
  return currentRouteState;
}

export function subscribeRoute(fn: (route: RouteState) => void) {
  listeners.add(fn);
  fn(currentRouteState);
  return () => listeners.delete(fn);
}

export function navigate(newHash: string) {
  if (!newHash.startsWith('#')) {
    newHash = '#' + (newHash.startsWith('/') ? newHash : '/' + newHash);
  }
  window.location.hash = newHash;
}

// Window hashchange listener
if (typeof window !== 'undefined') {
  window.addEventListener('hashchange', () => {
    currentRouteState = parseHash();
    listeners.forEach(fn => fn(currentRouteState));
  });
}

