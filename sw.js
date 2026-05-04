// GameHub Service Worker
// Cache-first untuk asset statis, network-first untuk HTML
const CACHE_VERSION = 'gamehub-v19-stickman';
const STATIC_CACHE = `${CACHE_VERSION}-static`;
const RUNTIME_CACHE = `${CACHE_VERSION}-runtime`;

// Derive scope base path dari lokasi sw.js sendiri
// Bekerja baik di GitHub Pages /File-GameHub/ maupun root /
const SCOPE = self.location.pathname.replace(/sw\.js$/, '');

const STATIC_ASSETS = [
  SCOPE,
  SCOPE + 'index.html',
  SCOPE + 'manifest.json',
  SCOPE + 'icon.svg',
  SCOPE + 'icons/icon-192.png',
  SCOPE + 'icons/icon-512.png',
];

// Listen untuk skipWaiting message dari client
self.addEventListener('message', event => {
  if (event.data && event.data.action === 'skipWaiting') self.skipWaiting();
});

// INSTALL: pre-cache static assets (per-file, jangan all-or-nothing)
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(STATIC_CACHE).then(cache =>
      // Pakai Promise.allSettled supaya 1 file gagal tidak blokir SW install
      Promise.allSettled(
        STATIC_ASSETS.map(url => cache.add(url).catch(err => console.warn('SW pre-cache miss:', url, err)))
      )
    ).then(() => self.skipWaiting())
  );
});

// ACTIVATE: clean up old caches
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.filter(k => !k.startsWith(CACHE_VERSION)).map(k => caches.delete(k))
      )
    ).then(() => self.clients.claim())
  );
});

// FETCH: serve from cache if available, fallback to network
self.addEventListener('fetch', event => {
  const { request } = event;
  if (request.method !== 'GET') return;
  // Skip cross-origin (CDN, dll - termasuk EmulatorJS CDN)
  const url = new URL(request.url);
  if (url.origin !== location.origin) return;

  // Network-first untuk HTML (selalu coba dapat versi terbaru)
  if (request.mode === 'navigate' || request.headers.get('accept')?.includes('text/html')) {
    event.respondWith(
      fetch(request)
        .then(response => {
          const copy = response.clone();
          caches.open(RUNTIME_CACHE).then(cache => cache.put(request, copy));
          return response;
        })
        .catch(() => caches.match(request).then(r => r || caches.match(SCOPE + 'index.html')))
    );
    return;
  }

  // Cache-first untuk asset (PNG, CSS, JS)
  event.respondWith(
    caches.match(request).then(cached => {
      if (cached) return cached;
      return fetch(request).then(response => {
        const copy = response.clone();
        caches.open(RUNTIME_CACHE).then(cache => cache.put(request, copy));
        return response;
      }).catch(() => cached);
    })
  );
});
