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
> (pin, ring, signal arc), dial ENERGY 2 / RHYTHM 3 / MOTION 2.

- **ENERGY 2**: tegas lewat ukuran huruf dan angka, bukan lewat warna ramai.
- **RHYTHM 3**: komposisi antar-bagian wajib terlihat beda: hero dua kolom
  dengan kartu peta, ukur dua kolom 0,75/1,7, mesin 1,6/1, batas pita penuh,
  quickstart bertumpuk selebar 68ch, batas satu kolom 64ch.
- **MOTION 2**: satu animasi masuk yang punya alasan, yaitu garis rute digambar
  sekali (900 ms, `both`, bertahap 80/200/320/440 ms), dimatikan total oleh
  `prefers-reduced-motion`. Tidak ada loop, parallax, atau animasi hover. Alasan:
  rute adalah subjek produk, jadi gerak pertama menjelaskan bentuk datanya.

## 5. Identitas visual

Logo disediakan pemilik merek
(`Gemini_Generated_Image_25zsi625zsi625zs.jpeg`, 1376x768): pin lokasi dalam
cincin teal, kepulauan bergaya faset, busur sinyal oranye, wordmark NUSAPETA
navy. Situs memakai aset turunan yang dipangkas dari file itu, bukan lambang
karangan baru.

Palet tidak diambil dari logo. Gaya **C. 8-bit cartography** dipilih pemilik
merek pada 16 November 2026 dari tiga arah yang dipratinjau; logo tetap dipakai
apa adanya sebagai aset wordmark, tetapi situs berjalan di atas palet pixel
sendiri:

| Token | Nilai | Dipakai untuk | Rasio kontras |
|---|---|---|---|
| `--ink` | `#14120E` | teks utama, garis, latar bagian gelap | 16,98:1 di atas cream |
| `--cream` | `#F9F4E2` | latar halaman, teks di atas tinta | 16,98:1 dengan ink |
| `--paper` | `#FFFDF3` | latar kartu, tabel, bidang terang | ink di atasnya 17,5:1 |
| `--red` | `#C9331D` | satu aksen: tombol utama, penanda angka, garis rute | putih di atasnya 5,28:1 |
| `--blue` | `#2450C8` | semua tautan teks, cincin fokus | 6,24:1 di atas cream |
| `--sun` | `#FFCC33` | sorotan hover, seleksi, latar tombol sekunder | ink di atasnya 12,41:1 |

Aturan pemakaian: merah hanya untuk isian dan garis; teks di atasnya selalu
putih (5,28:1). Hover merah memakai `#B02E19` (6,46:1) dan `:active`
`#9C2815` (7,7:1). Teks sekunder memakai `#33302A` (11,94:1 di atas cream) dan
`#D9D2BD` di atas tinta (12,39:1). Tidak ada gradien, blur, atau bayangan
lembut: semua bayangan adalah blok offset tanpa blur.

Tipografi tanpa unduhan jaringan: seluruh halaman memakai satu tumpukan
monospace sistem, yaitu `ui-monospace, SFMono-Regular, Menlo, Consolas,
"Liberation Mono", monospace`. Alasan: grid huruf monospace membuat angka tabel
rata sendiri dan menahan nada 8-bit tanpa memuat font apa pun.

Skala huruf memakai `clamp()`, satu skala jarak 4/8/12/16/24/32/48/64/96 px.

Keputusan modernisasi 16 November 2026 (satu alasan per keputusan):

- `text-wrap: balance` pada `h1`/`h2`/`h3`: tidak ada kata yatim di baris
  terakhir judul.
- `h2::before { content: "> " }` berwarna merah: penanda bagian terbaca
  sebagai prompt terminal, bukan nomor dekoratif.
- `scroll-margin-top: 80px` pada bagian ber-id: header sticky setinggi 68 px
  tidak lagi menutupi target `#quickstart` dan `#repos`.
- `::selection` kuning di atas tinta: sorotan teks ikut palet dan tetap lolos
  12,41:1.
- Semua radius nol dan semua bayangan blok offset: satu sistem bentuk, tidak
  ada token `--radius` yang perlu dirawat.
- Garis tabel 2 px dan garis bagian 4 px: kedalaman dibaca dari ketebalan garis,
  bukan dari bayangan lembut.
- Transisi 80 ms `steps(2)` hanya pada tombol, 120 ms pada warna tautan dan
  baris tabel: gerak diskret, cocok dengan dial MOTION 2 dan tidak ada animasi
  hover pada elemen lain.
- Latar baris tabel saat hover memakai `--sun`: mata melacak kolom pada tabel
  tiga kolom yang lebar.
- `code` inline diberi isian cream dan garis tinta 2 px: token kode terbaca
  sebagai objek terpisah tanpa ikon atau lencana.
- `min-width: 44px` pada `.brand`: saat wordmark disembunyikan di layar kecil,
  logo tetap punya area tap 44 px.


Revamp peta-sebagai-produk, 16 November 2026 (satu alasan per keputusan):

- Hero memuat kartu peta, bukan lambang kedua: empat rute mobil nyata dari Monas
  (6,1 sampai 14,0 km, diambil dari demo pada 16 November 2026 dan disederhanakan
  Douglas-Peucker ke toleransi 0,00045 derajat) karena geometri rute adalah satu-
  satunya bukti visual yang dimiliki proyek ini.
- SVG rute ditulis inline, bukan `img`: hanya elemen inline yang bisa dianimasikan
  `stroke-dashoffset` oleh stylesheet, dan hasilnya nol request tambahan.
- Panel peta berlatar `--paper` dengan bingkai tinta 4 px dan rute `--red`
  (5,18:1 di atas paper, lolos 3:1 untuk grafik) supaya kartu terbaca sebagai
  permukaan produk, bukan ilustrasi.
- Rute terpanjang memakai opasitas 1 dan tebal 4 px tanpa garis putus, tiga
  lainnya garis putus 5-4 pada opasitas 0,45: mata punya satu jalur utama tanpa
  legenda tambahan.
- `<svg aria-hidden="true">` plus `figcaption` berisi angka: pembaca layar tidak
  perlu mendengar daftar koordinat, tetapi tetap mendapat fakta.
- Logo hanya dimuat sekali, di header, tanpa `fetchpriority`: gambar hero yang
  lama memakai prioritas tinggi untuk aset dekoratif.
- Bagian "ukur" dipecah 0,75/1,7 dengan judul sempit 16ch: tabel mendapat lebar
  yang dibutuhkannya, judul tidak lagi mengambang sendirian (RHYTHM 3).
- Blok Route mendapat `dl` angka sampel (10.724 m, 680,9 s, car) sementara Place
  tetap prosa: Route adalah unggulan, jadi ia mendapat angka, Place mendapat
  penjelasan format (R-14).
- Batas pita penuh dan sempit 64ch: bagian kejujuran dibaca sebagai catatan,
  bukan sebagai kartu pemasaran; butir gate yang masih gagal ditandai lencana
  merah "Open gate" karena itulah satu-satunya status yang belum lulus.
- Nav "Repositories" menuju GitHub org, bukan jangkar footer: jangkar memaksa
  footer memakai dua `h2` yang bersaing dengan judul bagian.
- Tema tetap terang, tanpa toggle: tile OSM yang disediakan hanya terang, jadi
  mode gelap akan menuntut tile kedua atau filter invers yang merusak label peta.
  Alasan ini dicatat di sini dan di README demo; ditinjau ulang bila ada sumber
  tile gelap.
- Bahasa dipisah dengan sengaja: Inggris untuk halaman ini (audiens open source),
  Indonesia untuk demo (audiens pengguna peta lokal). Istilah API tetap sama di
  keduanya.

## 6. Struktur halaman dan naskah

Naskah ditulis bahasa Inggris karena semua dokumen publik berbahasa Inggris.

1. **Header** (sticky tipis, tinggi 68 px): mark logo, `Nusapeta`, tautan
   `Demo`, `Quickstart`, `Repositories`. Semua tautan punya tujuan nyata.
2. **Hero**: H1 "Routing and geocoding for Indonesia, on your own machine."
   Subjudul menyebut dua artefak konkret (binary router, satu file index) dan
   angka terukur. Dua aksi: `Open the live demo` (ke demo) dan
   `See what it takes to run` (ke bagian quickstart).
3. **Tabel bukti** (`Measured on this stack`, 2026-11-15): simpul graph
   54.891.393, sisi 112.340.071, RAM diam router sekitar 17 MB, RAM diam
   geocoder sekitar 6 MB, image 36,8 MB dan 147,5 MB, e2e 9/9. Setiap angka
   menyebut asalnya (`/healthz`, `docker images`, `scripts/e2e.sh`).
4. **Dua mesin, satu compose**: komposisi asimetris. Route memakai kolom lebar
   (router mmap, format `.graph` v5, `nusa-serve`), Place memakai kolom sempit
   (satu `.idx`, format v1, `nusa-place`). Masing-masing menaut ke repo.
5. **Coba tanpa akun**: tiga contoh permintaan nyata yang bisa diklik:
   pencarian `monumen nasional`, reverse geocode Monas, dan rute Monas ke Blok M
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
  `Permissions-Policy`), cache satu tahun untuk aset gambar, cache 300 s untuk
  HTML, CSS, dan JS (tautan CSS/JS memakai query versi agar perubahan tidak
  tertahan cache lama), dan 404 kustom.
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
- Fokus terlihat (`:focus-visible`, outline 3 px biru + offset 3 px), tidak ada
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
| Hero peta | `document.querySelectorAll(".hero-route").length` dan `getComputedStyle(path).animationName` | 4 path, `hero-route-draw` aktif, `stroke-dashoffset` 0 setelah 1,4 s |
| Geometri hero | angka di `figcaption` dibandingkan dengan `/route` demo | jarak 6,1 sampai 14,0 km cocok dengan respons API 16 November 2026 |
| Gerak dihormati | blok `@media (prefers-reduced-motion: no-preference)` di `styles.css` | animasi hanya ada di dalam blok itu; rute terlihat penuh tanpa animasi |
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
