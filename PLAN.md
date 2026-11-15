# Rencana landing page nusapeta.web.id

Status: **rencana dieksekusi** 2026-11-15. Repo: `nusapeta/landing`.
Kontainer: `nusapeta-lp` (port 8080) di homelab `192.168.1.219`, jaringan
`1panel-network`, diteruskan Cloudflare Tunnel `focused_margulis` ke
`https://nusapeta.web.id`.

---

## 1. Konteks dan masalah

`situs demo <https://demo.nusapeta.web.id>` sudah hidup dan menjawab rute serta
pencarian, tetapi tidak ada satu halaman yang menjelaskan apa itu Nusapeta,
apa yang bisa dicoba tanpa akun, dan apa yang **tidak** diklaim. Akibatnya calon
pengguna mendarat di antarmuka peta tanpa konteks, dan repo terbaca sebagai tiga
proyek terpisah.

Landing page ini menutup celah itu: satu halaman publik di `nusapeta.web.id`
yang menerangkan dua mesin (Route dan Place), memberi jalan ke demo, dan
menyebut batasannya dengan angka yang terukur.

## 2. Tujuan

1. Pengunjung paham dalam 10 detik: Nusapeta = router dan geocoder OSM untuk
   Indonesia yang dijalankan sendiri, satu binary dan satu file index.
2. Pengunjung bisa mencoba tanpa akun dalam satu klik ke
   `https://demo.nusapeta.web.id`.
3. Pengunjung bisa menyalin perintah `docker compose` yang benar-benar dipakai
   repo `nusapeta/stack`.
4. Batasan disebut terbuka: gate akurasi belum lulus, `place_id` bukan Google
   Place ID, cakupan hanya Indonesia.

**Non-tujuan:** tidak ada pendaftaran, tidak ada pricing, tidak ada blog, tidak
ada dashboard, tidak ada pelacakan pihak ketiga, tidak ada font atau skrip dari
CDN.

## 3. Audiens

Pengembang dan operator yang menilai apakah perangkat lunak ini layak
dipasang sendiri. Mereka membaca angka, membuka demo, lalu membuka repo. Mereka
tidak butuh cerita merek.

## 4. Design Read dan dial

> Reading this as: project landing page for developers evaluating a self-hosted
> OSM stack, in a cartographic brand language taken from the supplied logo
> (teal, orange, navy on white), dial ENERGY 2 / RHYTHM 2 / MOTION 1.

- **ENERGY 2**: tegas lewat ukuran huruf dan angka, bukan lewat warna ramai.
- **RHYTHM 2**: tiap bagian punya komposisi berbeda (teks lebar, dua kolom
  asimetris, tabel, daftar bernomor), tetapi tetap satu sistem.
- **MOTION 1**: hanya `:hover`, `:focus-visible`, dan transisi 120 ms. Tidak ada
  animasi masuk, tidak ada parallax, tidak ada loop.

## 5. Identitas visual

Logo disediakan pemilik merek
(`Gemini_Generated_Image_25zsi625zsi625zs.jpeg`, 1376x768): pin lokasi dalam
cincin teal, kepulauan bergaya faset, busur sinyal oranye, wordmark NUSAPETA
navy. Situs memakai aset turunan yang dipangkas dari file itu, bukan lambang
karangan baru.

Palet diambil dari logo, jadi bukan palet default:

| Token | Nilai | Dipakai untuk | Rasio kontras |
|---|---|---|---|
| `--navy` | `#1B3A5C` | teks utama, latar tombol sekunder | 11,63:1 di atas putih |
| `--teal` | `#1B7FA8` | tautan, garis aksen, label kecil | 4,52:1 di atas putih |
| `--teal-deep` | `#0F5B7A` | tautan saat hover | 7,51:1 di atas putih |
| `--orange` | `#F5A623` | satu aksen: tombol demo dan penanda angka | navy di atasnya 5,74:1 |
| `--muted` | `#5A6B7B` | teks sekunder | 5,49:1 di atas putih |
| `--surface` | `#F2F6F9` | latar bagian yang perlu dipisah | navy di atasnya 10,7:1 |

Aturan pemakaian: oranye tidak pernah jadi warna teks (tidak lolos 4,5:1 di
atas putih), hanya isian dan garis. Teal dipakai untuk tautan dan label, tidak
untuk blok besar. Tidak ada gradien, tidak ada glow, tidak ada bayangan selain
satu tingkat pada tombol utama.

Tipografi tanpa unduhan jaringan: judul memakai `ui-serif, Georgia, serif`
(alasan: memberi nada atlas dan editorial, cocok dengan subjek peta, dan tidak
menambah request), badan memakai `ui-sans-serif, system-ui, sans-serif` (alasan:
netral, sudah ada di perangkat, angka tabel rata dengan baik).

Skala huruf memakai `clamp()`, satu skala jarak 4/8/12/16/24/32/48/64/96 px.

## 6. Struktur halaman dan naskah

Naskah ditulis bahasa Inggris karena semua dokumen publik berbahasa Inggris.

1. **Header** (sticky tipis, tinggi 64 px): lockup logo, `nusapeta`, tautan
   `Demo`, `Quickstart`, `Repos`. Semua tautan punya tujuan nyata.
2. **Hero**: H1 "Routing and geocoding for Indonesia, on your own machine."
   Subjudul menyebut dua artefak konkret (binary router, satu file index) dan
   angka terukur. Dua aksi: `Open the live demo` (ke demo) dan
   `Read the compose file` (ke repo stack).
3. **Tabel bukti** (`Measured on this stack`, 2026-11-15): simpul graph
   54.891.393, sisi 112.340.071, RAM diam router sekitar 17 MB, RAM diam
   geocoder sekitar 6 MB, image 36,8 MB dan 147,5 MB, e2e 9/9. Setiap angka
   menyebut asalnya (`/healthz`, `docker images`, `scripts/e2e.sh`).
4. **Dua mesin, satu compose**: komposisi asimetris. Route memakai kolom lebar
   (router mmap, format `.graph` v5, `nusa-serve`), Place memakai kolom sempit
   (satu `.idx`, format v1, `nusa-place`). Masing-masing menaut ke repo.
5. **Coba tanpa akun**: tiga contoh permintaan nyata yang bisa diklik:
   pencarian `monas`, reverse geocode Monas, dan rute Monas ke Blok M
   (10.724 m, 680,9 s). URL memakai `demo.nusapeta.web.id`.
6. **Quickstart**: blok kode `docker compose` yang disalin dari
   `nusapeta/stack`, dengan tombol salin. Bukan jendela terminal hiasan.
7. **Yang tidak kami klaim**: daftar bernomor berisi batasan nyata
   (gate akurasi E1 belum lulus: median selisih 0,23 %, p95 14,49 %;
   `place_id` bukan Google Place ID; cakupan Indonesia; format 0.x).
8. **Footer**: tautan ketiga repo, demo, lisensi (MIT untuk kode, ODbL untuk
   data OSM), dan kontak keamanan lewat `SECURITY.md` repo.

Tidak ada bagian testimoni, logo pelanggan, pricing, FAQ template, atau
"how it works" tiga langkah.

## 7. Teknis

- Situs statis tanpa build: `site/index.html`, `site/styles.css`,
  `site/app.js` (satu tombol salin), `site/404.html`, `site/robots.txt`,
  `site/healthz` (teks `ok`).
- Server: `nginxinc/nginx-unprivileged:1.29-alpine`, uid 101, port 8080.
  Konfigurasi `deploy/nginx.conf` menetapkan `server_tokens off`, header
  keamanan (`X-Content-Type-Options`, `Referrer-Policy`, `X-Frame-Options`,
  `Permissions-Policy`), cache panjang untuk aset berversi, cache 300 s untuk
  HTML, dan 404 kustom.
- Image: `ghcr.io/nusapeta/landing:0.1.0` (multi-arch amd64+arm64) dibangun CI
  dari `Dockerfile`; homelab membangun image lokal dari sumber yang sama.
- Deploy: `deploy/compose.yml` dengan `container_name: nusapeta-lp`, jaringan
  eksternal `1panel-network`, tanpa port host.
- Tunnel: hostname `nusapeta.web.id` sudah diarahkan ke
  `http://nusapeta-lp:8080`; container cukup berada di jaringan yang sama
  dengan `focused_margulis`.

## 8. Aksesibilitas dan kualitas

- Semua pasangan warna di §5 dihitung dengan pemeriksa kontras, bukan dikira.
- `html lang="en"`, satu `<main>`, hierarki heading tanpa lompatan, `<title>`
  unik, skip link ke konten.
- Fokus terlihat (`:focus-visible`, outline 2 px navy + offset), tidak ada
  `outline: none` tanpa pengganti.
- Target sentuh minimum 44x44 px, jarak antar target minimal 8 px.
- Tab melalui seluruh kontrol: nav, dua CTA, tiga tautan permintaan, tombol
  salin, tautan footer; tombol salin mengumumkan hasil lewat `aria-live`.
- `prefers-reduced-motion: reduce` mematikan transisi.
- Tata letak diuji pada 320, 375, 768, 1024, 1440 px tanpa gulir horizontal.
- Angka tidak pernah dikarang; setiap klaim di halaman punya sumber di repo.

## 9. Verifikasi sebelum rilis

| Pemeriksaan | Cara | Lulus bila |
|---|---|---|
| Halaman hidup | `curl -sI https://nusapeta.web.id/` | `200`, `content-type: text/html` |
| Header keamanan | `curl -sI` | empat header ada |
| 404 kustom | `curl -s -o /dev/null -w '%{http_code}' https://nusapeta.web.id/tidak-ada` | `404` dan memuat `404` body |
| Kesehatan | `curl -s https://nusapeta.web.id/healthz` | `ok` |
| Aset | `curl -sI https://nusapeta.web.id/assets/logo-lockup.png` | `200`, `cache-control: max-age=31536000` |
| Tanpa gulir horizontal | screenshot 375 px + `document.documentElement.scrollWidth <= innerWidth` | benar di semua lebar uji |
| Kontras | pemeriksa kontras untuk setiap pasangan §5 | semua lolos AA |
| Keyboard | Tab berurutan, Enter pada tautan, tombol salin aktif | semua kontrol terjangkau, fokus terlihat |
| Multi-arch | `docker buildx imagetools inspect ghcr.io/nusapeta/landing:0.1.0` | `linux/amd64` dan `linux/arm64` |
| Deploy | `docker ps` di homelab | `nusapeta-lp` sehat, jaringan `1panel-network` |

## 10. Definition of done

- [x] `https://nusapeta.web.id` menjawab 200 dengan halaman final.
- [x] Demo tertaut dan benar-benar menjawab (`/route`, `/place/search`).
- [x] Repo `nusapeta/landing` publik, CI hijau, image GHCR terbit.
- [x] Verifikasi §9 dijalankan dan hasilnya dicatat di README.
- [x] Tidak ada angka, testimoni, atau logo karangan.

## 11. Risiko dan mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Jaringan `1panel-network` berubah nama | tunnel 502 | nama jaringan dieksplisitkan di compose dan diverifikasi sebelum rilis |
| Logo JPEG berlatar putih dipakai di latar gelap | pin putih hilang | situs tetap terang; latar gelap tidak dipakai |
| Angka di halaman basi setelah rilis mesin | klaim salah | angka menyebut tanggal ukur; perbarui bersama rilis mesin |
| Cache HTML agresif di Cloudflare | perubahan tidak terlihat | `max-age=300` dan purge manual saat rilis |

## 12. Rollback

`docker compose -f deploy/compose.yml down` di homelab mengembalikan tunnel ke
502. Image sebelumnya tetap ada dengan tag `0.1.0`; tidak ada data yang
tersentuh karena situs statis.
