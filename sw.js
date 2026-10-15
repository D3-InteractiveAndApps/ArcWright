// ArcWright Service Worker
// Bump VERSION on every deploy so installed apps fetch fresh files
const VERSION = 'arcwright-v111-1';

const PRECACHE = [
  './',
  './index.html',
  './config.js',
  './supabase.js',
  './manifest.webmanifest',
  './apple-touch-icon.png',
  './icon-192.png',
  './icon-512.png',
  './icon-maskable-192.png',
  './icon-maskable-512.png',
  './favicon.ico',
  './favicon.svg',
  './favicon-32.png',
  'https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600&display=swap',
  'https://fonts.googleapis.com/css2?family=Crimson+Pro:ital,wght@0,400;0,500;1,400&display=swap',
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(VERSION).then(c => c.addAll(PRECACHE)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(keys.filter(k => k !== VERSION).map(k => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  // Network-first for Supabase API calls
  if (e.request.url.includes('supabase.co')) {
    e.respondWith(fetch(e.request).catch(() => caches.match(e.request)));
    return;
  }
  // Cache-first for everything else
  e.respondWith(
    caches.match(e.request).then(cached => cached || fetch(e.request).then(res => {
      if (res && res.status === 200 && e.request.method === 'GET') {
        const clone = res.clone();
        caches.open(VERSION).then(c => c.put(e.request, clone));
      }
      return res;
    }))
  );
});
