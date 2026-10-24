# 92. Referensi Halaman Non-Docs (Landing dan 404)

Status: Riset v1 (2026-10-16)
Owner: Dimas
Terkait: `91-out-of-scope.md` OS-2 (redesign halaman non-docs), `02-design-spec.md`

Dokumen ini adalah bahan riset untuk redesign halaman non-docs. Bukan
keputusan desain. Filter dan cara menyusunnya mengikuti skill Impeccable
(`.agents/skills/impeccable`, v4.5.2): `SKILL.md`, `reference/new-work.md`,
`reference/mode-persuade.md`, dan `reference/craft-floor.md`.

## 0. Scope dan batasan yang dikunci

| Hal                     | Keputusan                                                                                       |
| ----------------------- | ----------------------------------------------------------------------------------------------- |
| Halaman                 | `/[lang]` (landing) dan `not-found` (404)                                                       |
| Dihapus nanti           | `/[lang]/components` dan `/[lang]/studio`. Tidak dicarikan referensi                            |
| Tidak disentuh          | `/install.sh` dan `/install.ps1`                                                                |
| Palette                 | Wajib Ink and Paper (`02-design-spec.md`): monokrom, tanpa aksen, teks AAA 7:1                  |
| Font                    | Plus Jakarta Sans untuk semua teks. IBM Plex Mono hanya untuk teks monospace (DP-6, 2026-10-16) |
| Mode Impeccable landing | Persuade: visitor harus paham offer-nya dan langsung ambil aksi                                 |
| Mode Impeccable 404     | Ikut world landing. Impeccable: surface di dalam world yang sudah ada mewarisi world itu        |

Product truth yang dipakai (dari `apps/docs/src/lib/homepage-translations.ts`
dan PRD):

- Headline sekarang: "One command. One file. Yours."
- Mekanisme: CLI `justui` meng-copy source komponen Flutter ke project user.
  Bukan dependency, tanpa Material, tidak butuh apa pun selain SDK.
- 30 keluarga komponen, 2 preset (default dan neobrutalism), tint netral.
- Aksi utama kategori ini: install CLI lalu `justui init` / `justui add`.
  Install strip sekarang punya tab curl, PowerShell dan cargo.

## 1. Cara riset ini mengikuti Impeccable

1. **Rut dulu, baru referensi.** `new-work.md` 3.1 minta kita menamai halaman
   yang selalu dibuat kategori ini dan kebalikannya yang mudah ditebak.
   Keduanya tidak boleh masuk daftar kandidat.
2. **Tujuh world dari dunia audiens, bukan dari kategori.** Audiens: developer
   Flutter. World diambil dari benda, cetakan, ritual dan tradisi grafis yang
   mereka kenal, minimal tiga keluarga material. Di surface Persuade, alat yang
   mereka pakai sehari-hari (terminal, editor) dihitung sebagai rut dan hanya
   boleh dipakai sebagai satu kandidat.
3. **Yang diambil adalah disiplin, bukan baju.** Dari tiap referensi kita
   ambil disiplin sistemnya (komitmen palette, keberanian grid, kejujuran
   struktur). Treatment komponen (shadow tombol, display face) itu baju dan
   tidak dipindahkan.
4. **Craft floor.** Setiap referensi dicek ke daftar Refuse di
   `craft-floor.md`. Pola yang kena larangan ditandai "tolak".
5. **Standing exit.** Standar kategori tetap dicatat sebagai pintu keluar
   yang tenang, bukan rekomendasi.

Catatan proses: `impeccable concept-seed` belum bisa dijalankan karena repo
belum punya `PRODUCT.md` (outputnya: `NO_PRODUCT_MD`). Jadi daftar di bawah
belum diundi. Langkah resminya ada di section 7.

## 2. Rut kategori

| Rut                                        | Bentuknya                                                                                                                                | Contoh nyata                                                        |
| ------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| Halaman yang selalu dibuat kategori ini    | Badge "New" kecil, headline di tengah, subcopy, dua tombol (Get Started / View Components), grid kartu demo                              | [ui.shadcn.com](https://ui.shadcn.com), dan landing JustUI sekarang |
| Kebalikan yang mudah ditebak               | Hero gelap bergaya terminal, glow neon, ASCII art                                                                                        | [ghostty.org](https://ghostty.org)                                  |
| Kluster AI yang dekat dengan Ink and Paper | (a) hairline editorial ala koran, display serif italic, label mono kecil ber-tracking. (b) tinta datar, kotak hitam, shadow offset keras | Disebut di `new-work.md` section 4 sebagai tanda self-check gagal   |

Kenapa poin terakhir penting: Ink and Paper itu monokrom dan hangat. Tanpa
world yang kuat, hasilnya gampang jatuh ke kluster (a). Neobrutalism adalah
preset produk yang nyata, jadi shadow offset keras hanya sah ketika halaman
sedang mendemokan preset itu, bukan sebagai gaya default halaman
(`craft-floor.md`: "Hard offset shadows outside a world that is actually
neobrutalist").

Pola di landing dan 404 sekarang yang kena craft floor:

| Pola sekarang                                                   | Aturan Impeccable                                                       |
| --------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Tagline mono kecil di atas H1 ("Copy-paste Flutter components") | Kicker atau eyebrow di atas heading: dilarang total, tanpa pengecualian |
| "404" mono kecil di atas judul di `not-found-view.tsx`          | Sama, kicker                                                            |
| `WhatYouGet`: tiga kartu sama besar ikon + judul + teks         | Kartu sama besar sebagai struktur halaman: default yang ditolak         |
| Label mono untuk kesan "teknis"                                 | Monospace sebagai kostum, bukan untuk kode atau data                    |

## 3. Tujuh world untuk landing (urut resonansi)

Catatan 2026-10-17: urutan di bawah adalah urutan resonansi awal. Kalau
dukungan banyak preset dijadikan syarat, urutannya berubah (section 10.4).

Mekanisme yang harus dibawa setiap world dalam satu kalimat: **kamu ambil
satu komponen, file-nya mendarat di project kamu, dan file itu milikmu.**

Keluarga material yang tercakup: cetak dan publikasi (3, 4, 6), instruksi
dan perakitan (1, 5), gambar teknis dan legal (2), katalog dan arsip (7).

### W1. Kit model plastik: runner (sprue) dan lembar instruksi

- **Kenapa cocok:** semua part tercetak di satu runner, kamu potong hanya yang
  kamu butuh, dan setiap part punya kode huruf dan angka. Ini persis
  `justui add button`: 30 komponen di satu rangka, kamu ambil satu, sisanya
  tetap di runner.
- **Tampilannya:** dasar kertas, gambar garis tinta, kode part (A1, A2, B7),
  panah langkah. Signature: rangka runner berisi miniatur komponen hidup;
  memotong satu part memperlihatkan perintahnya dan file yang mendarat.
- **Rujukan:** konvensi manual Tamiya (identifikasi part pakai huruf sprue
  dan nomor, cross-check parts list) lewat arsip
  [manuals.plus](https://manuals.plus/asin/B000LFQYAY); istilah runner, sprue
  dan tree di [FAQ Round 2](https://www.round2corp.com/faq/).
- **Disiplin yang diambil:** satu sistem penomoran yang konsisten dari
  rangka sampai langkah perakitan.
- **Risiko:** gambar kit bergaya ilustrasi berbayang itu "picture" dan
  dilarang kalau dibuat SVG (`craft-floor.md`: real illustration or none).
  Runner harus geometri yang bisa dispesifikasi persis, atau komponen asli.
- **Catatan verifikasi:** situs resmi Tamiya mengembalikan halaman error 500
  saat dicek (2026-10-16). Sumbernya sekunder.

### W2. Lembar gambar paten

- **Kenapa cocok:** regulasi gambar paten AS mewajibkan tinta hitam di atas
  putih, angka referensi untuk setiap bagian, dan garis penunjuk yang tidak
  bersilangan. Itu Ink and Paper secara harfiah, dan cara yang jujur untuk
  memperlihatkan anatomi komponen (role apa mengecat bagian mana).
- **Tampilannya:** kertas, garis tinta tunggal, "FIG. 1", angka referensi
  dengan leader line, teks keterangan bernomor. Signature: Button digambar
  sebagai figure paten; tiap angka menunjuk ke role token
  (`inverse`, `onInverse`, `focusRing`), dan mengganti preset menggambar ulang
  figure-nya.
- **Rujukan:** [37 CFR 1.84 di Cornell LII](https://www.law.cornell.edu/cfr/text/37/1.84)
  (aturan tinta hitam); ringkasan aturan angka referensi di
  [BlueIron IP](https://blueironip.com/?p=9652) (sumber sekunder).
- **Disiplin yang diambil:** setiap label punya garis ke benda yang
  dijelaskan, dan angka yang sama berarti bagian yang sama di semua figure.
- **Risiko:** leader line dan angka harus berupa geometri dan teks asli, bukan
  ilustrasi. Hati-hati jangan jatuh ke kluster "hairline editorial".

### W3. Ex libris (bookplate)

- **Kenapa cocok:** bookplate adalah tanda kepemilikan yang ditempel di buku:
  "buku ini milik ...". Itu kata ketiga headline sekarang: "Yours."
- **Tampilannya:** blok kecil berbingkai, nama pemilik sebagai pusat,
  dicetak satu warna. Signature: file Dart yang mendarat diberi kepala
  bertuliskan nama project user, seperti bookplate.
- **Rujukan:** [koleksi bookplate digital UConn Archives](https://blogs.lib.uconn.edu/archives/2009/03/04/mesmerizing-miniatures-bookplates-digital-collection/),
  [Ex Libris Collection Museum of Applied Arts Budapest](https://collections.imm.hu/pdfexport/75904-ex-libris-bookplate-),
  [catatan V&A lewat Museum Data Service](https://museumdata.uk/objects/34e20734-d055-380e-809c-934f92aa2fa0).
- **Disiplin yang diambil:** satu objek kecil yang menanggung seluruh makna.
- **Risiko:** ukiran dan ornamen menggoda untuk dibuat SVG ilustratif
  (dilarang). Pakai bookplate tipografis saja.

### W4. Standards manual (NYCTA 1970 dan Unigrid NPS)

- **Kenapa cocok:** design system yang dicetak sebagai buku aturan. Unigrid
  memakai satu band judul hitam di setiap brosur Taman Nasional AS; NYCTA
  manual mengatur seluruh signage subway. JustUI juga sebuah sistem yang
  dibagikan sebagai aturan yang kamu salin.
- **Tampilannya:** band hitam penuh lebar, grid modular yang terlihat, judul
  dibalik putih di atas hitam. Signature: band `inverse` sebagai kepala setiap
  section, dan preset diganti seperti membalik halaman manual.
- **Rujukan:** [standardsmanual.com](https://standardsmanual.com) (penerbit
  reissue NYCTA), [studio Order](https://order.design/project/nycta-graphics-standards-manual-reissue),
  [Creative Review](https://www.creativereview.co.uk/nycta-graphics-standards-manual-reissue/),
  esai Unigrid di [blakecrosley.com](https://blakecrosley.com/blog/design-philosophy-massimo-vignelli)
  (sekunder), catatan museum di [Google Arts & Culture](https://artsandculture.google.com/asset/edison/lgFwy0lDWgS_pA).
- **Disiplin yang diambil:** satu grid dan satu band yang diulang tanpa
  pengecualian.
- **Risiko:** Helvetica plus band hitam adalah klise "Swiss". Situs
  standardsmanual.com sendiri pakai oranye sebagai aksen; itu tidak dibawa.

### W5. Instruksi perakitan tanpa kata (IKEA)

- **Kenapa cocok:** produk datang terurai, kamu yang merakit, dan instruksinya
  bekerja tanpa bahasa. Cocok untuk audiens dua bahasa (en dan id) dan alur
  `install -> init -> add`.
- **Tampilannya:** gambar barang jadi di halaman pertama, checklist alat,
  langkah bergambar, figur manusia sederhana. Signature: tiga langkah besar
  yang masing-masing memperlihatkan hasil nyata, bukan ikon.
- **Rujukan:** [Wordless Instructions, Justin Zhuang](https://justinzhuang.com/posts/wordless-instructions/);
  buku seni BAEBEL yang mencampur halaman manual IKEA (catatan di
  [0x0a.li](https://0x0a.li/en/text/baebel)).
- **Disiplin yang diambil:** gambar barang jadi dulu, baru langkahnya.
- **Risiko:** nomor langkah hanya sah karena urutannya memang membawa
  informasi (`craft-floor.md`: section numbers unless the sequence carries
  information). Figur kartun dilarang sebagai SVG ilustratif.

### W6. Spesimen type foundry

- **Kenapa cocok:** foundry menjual font dengan memperlihatkan font itu
  bekerja di skala display. Komponen bisa dijual dengan cara yang sama:
  setiap baris adalah komponen hidup di skala besar, dan "Buy" diganti
  perintah `justui add`.
- **Tampilannya (diverifikasi via screenshot):**
  [klim.co.nz/fonts](https://klim.co.nz/fonts/) memakai daftar baris penuh
  lebar, nama font raksasa di kiri, gaya dan tautan Buy di kanan, tiap baris
  dengan field warna sendiri. Situs Klim dirancang Springload dengan prinsip
  Swiss di CSS grid dan spesimen yang diacak tiap refresh
  ([Webby](https://www.webbyawards.com/crafted-with-code/klim-type-foundry-website),
  [Red Dot](https://red-dot.org/project/klim-type-foundry-49210)).
  [commercialtype.com](https://commercialtype.com) memakai band warna penuh
  per keluarga dengan tester teks sendiri.
  [abcdinamo.com](https://abcdinamo.com) memakai gambar garis hitam putih dan
  spesimen yang bisa diajak "chat"
  ([AIGA Eye on Design](https://eyeondesign.aiga.org/why-type-foundry-dinamo-releases-their-fonts-as-if-they-were-albums/)).
- **Disiplin yang diambil:** produk yang ditampilkan sebesar-besarnya dan
  bekerja sungguhan, bukan screenshot.
- **Risiko:** field warna Klim dan Commercial Type tidak boleh dibawa. Di
  Ink and Paper, ritmenya jadi baris kertas dan baris `inverse` bergantian.

### W7. Katalog industri (McMaster-Carr)

- **Kenapa cocok:** katalog yang tujuannya membuat orang cepat ketemu part
  lalu kembali kerja. Foto produk hitam putih, tanpa banner, tanpa carousel.
- **Tampilannya (diverifikasi via screenshot):**
  [mcmaster.com](https://www.mcmaster.com) memakai sidebar kategori, grid
  thumbnail kecil abu-abu, judul section dengan garis tipis, kepadatan
  tinggi. Analisis kecepatannya di
  [unsung.aresluna.org](https://www.unsung.aresluna.org/everything-possible-to-make-this-website-as-fast-as-they-can/).
- **Disiplin yang diambil:** kecepatan sebagai fitur dan kepadatan yang
  berani.
- **Risiko:** ini lebih ke rasa Operate daripada Persuade. Cocok untuk satu
  section daftar komponen, lemah sebagai first viewport. Hijau McMaster
  tidak dibawa.

### Kandidat dari alat (rut, maksimal satu)

- **Terminal.** [ghostty.org](https://ghostty.org) membungkus hero di jendela
  terminal dengan ASCII art. Landing JustUI sekarang juga sudah punya
  terminal interaktif. Impeccable menghitung ini sebagai rut untuk surface
  Persuade. Dicatat supaya tidak dipilih tanpa sadar.

## 4. Kebutuhan Persuade yang harus dibawa world mana pun

Dari `mode-persuade.md`:

1. **Aksi kategori dalam bentuk kerjanya di first viewport.** Untuk JustUI itu
   perintah install yang bisa langsung di-copy (curl, PowerShell, cargo),
   bukan tombol yang melempar ke halaman lain. Tautan dekoratif tidak dihitung.
2. **Hook satu baris.** "One command. One file. Yours." sudah kuat. Jangan
   diganti tanpa izin (Impeccable: tanya dulu sebelum mengganti copy faktual).
3. **Demonstrasikan sesuatu yang hanya produk ini bisa buktikan.** Kandidat
   bukti: file Dart yang benar-benar mendarat (pohon file sebelum dan
   sesudah), komponen yang sama di dua preset, file tanpa import dependency.
4. **World menjadi pembawa halaman, bukan gambar halaman.** Navigasi tetap
   terbaca sebagai link, aksi utama jelas bisa diklik, section berikutnya
   dimulai sebagai section.
5. **Klaim tidak boleh dikarang.** Jumlah bintang GitHub, jumlah pengguna,
   benchmark: hanya yang ada datanya. Data demo boleh dibuat tapi diberi label.

## 5. Referensi 404

404 mewarisi world landing. Isinya harus menyebut masalahnya dan jalan
keluarnya (`craft-floor.md`: errors name the problem and the recovery).

Revisi 2026-10-16: referensi v1 (ilovetypography, GitHub, katalog kartu NSW)
dibuang. NSW tidak bisa dibuka sama sekali, dan dua lainnya terlalu biasa.
Penggantinya dipilih dengan satu syarat: 404 itu harus jadi perpanjangan
world situsnya sendiri, bukan template "Page not found" yang ditempel.

Cara cek: setiap URL di bawah dibuka di Chromium 1440x900. Interaksinya dites
dengan drag atau gerakan mouse, lalu dibandingkan dua screenshot.

### 5.1 Referensi terpilih (urut kekuatan)

| #   | Referensi                                                                     | Yang terjadi (terverifikasi)                                                                                                                 | Disiplin yang diambil                                                                                   | Yang tidak dibawa                                              |
| --- | ----------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| 1   | [Figma](https://www.figma.com/this-page-does-not-exist-404x)                  | Angka "404" hitam besar ditampilkan sebagai path vektor dengan node. Node bisa di-drag dan bentuk hurufnya ikut berubah (dites)              | 404 yang membuktikan produknya: pengunjung yang tersesat tetap bisa mencoba mekanisme intinya           | Node biru (aksen); tombol CTA hitam penuh di header            |
| 2   | [Standards Manual](https://standardsmanual.com/this-page-does-not-exist-404x) | "404 St" ditulis raksasa seperti nama stasiun subway NYC, lalu satu kalimat besar: halaman tidak ada, pakai menu, atau pulang                | Lelucon yang lahir dari world-nya sendiri, dalam vocabulary world itu                                   | Aksen oranye pada cart                                         |
| 3   | [Norgram](https://www.norgram.co/404)                                         | "404" hitam setinggi viewport, dipotong jadi irisan horizontal yang bergeser; latar garis vertikal tipis. Tidak ada teks lain (dites)        | Komitmen skala: angkanya adalah halaman. Satu gerakan yang diorkestrasi                                 | Tidak ada jalan keluar yang terlihat (gagal aturan recovery)   |
| 4   | [Scope Typeface](https://scope-typeface.com/error.html)                       | Layar hitam penuh kata "ERROR" diset dalam typeface yang dijual, lalu menghilang mengikuti mouse (dites). Satu tombol "Back to Scope"        | 404 sebagai spesimen produk: yang dijual adalah materialnya                                             | Hitam total sebagai canvas (Ink and Paper melarang pure black) |
| 5   | [SpiralDB](https://spiraldb.com/404)                                          | Bidang isometrik bergaris dengan kubus wireframe yang bergerak (dites), lalu "PAGE NOT FOUND" raksasa kiri bawah dan "Go back home" di kanan | Komposisi dua bagian: gambar teknis di atas, pernyataan besar plus recovery di bawah. Semuanya geometri | Kubus generik tanpa makna produk                               |
| 6   | [Klim Type Foundry](https://klim.co.nz/this-page-does-not-exist-404x)         | Bentuk hitam putih generatif hasil cacahan glyph, bergerak di antara dua frame (dites). Header tetap: "Page not found"                       | Seni generatif dari material produknya sendiri, tetap monokrom                                          | Tidak ada recovery di first viewport                           |

Pendukung (komposisi saja):

- [Pentagram](https://www.pentagram.com/this-page-does-not-exist-404x): digit
  "4", "0", "4" raksasa tersebar ke tiga sudut viewport, kalimat penjelas di
  kiri. Digitnya diam (dites, tidak bereaksi ke mouse). Merah penuhnya tidak
  dibawa.
- [Dinamo](https://abcdinamo.com/this-page-does-not-exist-404x): ilustrasi
  garis tangan asli di world situsnya. Bukti bahwa ilustrasi yang benar-benar
  dibuat orang itu sah (`craft-floor.md`: real illustration or none). Copy-nya
  memakai kata kasar dan tidak dibawa.
- [404s.design](https://www.404s.design): galeri kurasi lebih dari 100 halaman
  404, sumber kandidat di atas (Norgram, Scope, SpiralDB).

### 5.2 Dicek dan ditolak

| Halaman                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | Alasan                                                                                   |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------- |
| [Speakeasy](https://www.speakeasy.com/404)                                                                                                                                                                                                                                                                                                                                                                                                                                           | Angka 404 abu-abu sangat pucat di atas putih: tidak lolos kontras AAA                    |
| [Coder](https://coder.com/404), [Ethan+](https://ethanplus.ai/404), [Edoardo Lunardi](https://www.edoardolunardi.dev/404), [Gagan Devagiri](https://www.gagandevagiri.com/404), [CodeRabbit](https://www.coderabbit.ai/our404)                                                                                                                                                                                                                                                       | Terminal, BIOS, pixel arcade: kostum alat developer, rut di surface Persuade             |
| [++hellohello](https://www.hellohello.is/404)                                                                                                                                                                                                                                                                                                                                                                                                                                        | Pecahan foto kantor yang melayang; JustUI tidak punya foto produk yang setara            |
| [Feldman Studio](https://feldman.studio/this-page-does-not-exist-404x)                                                                                                                                                                                                                                                                                                                                                                                                               | Game snake yang disebut artikel tidak muncul saat dites; yang terlihat hanya "404" kecil |
| [Commercial Type](https://commercialtype.com/this-page-does-not-exist-404x), [Teenage Engineering](https://teenage.engineering/this-page-does-not-exist-404x), [IKEA](https://www.ikea.com/us/en/this-page-does-not-exist-404x), [Stripe](https://stripe.com/this-page-does-not-exist-404x), [Apple](https://www.apple.com/this-page-does-not-exist-404x), [Cosmos](https://www.cosmos.so/this-page-does-not-exist-404x), [rauno.me](https://rauno.me/this-page-does-not-exist-404x) | Template "page not found" biasa, atau kartu sama besar (Stripe)                          |
| [Katalog kartu State Library NSW](https://scanned-card-catalogue.sl.nsw.gov.au/card/design)                                                                                                                                                                                                                                                                                                                                                                                          | Tidak bisa dibuka                                                                        |

### 5.3 Yang diambil untuk 404 JustUI

1. **404 yang membuktikan produk (dari Figma).** Path yang diminta
   diperlakukan sebagai nama komponen: "`/xyz` tidak ada di registry", lalu
   komponen asli terdekat ditampilkan hidup dan bisa langsung di-copy
   perintah `justui add`-nya. Jalan keluar dan bukti mekanisme ada di satu
   tempat. Data registry nyata, tidak dikarang.
2. **Lelucon dari vocabulary world (dari Standards Manual).** 404 ditulis
   dalam bahasa world yang terpilih nanti (lihat tabel per world di bawah),
   bukan "Oops".
3. **Angka sebagai halaman (dari Norgram dan Pentagram).** Kalau ada angka,
   angkanya sebesar viewport dan bergerak sekali, bukan teks 404 kecil di
   atas judul (itu kicker, dilarang).
4. **Recovery selalu terlihat (dari SpiralDB).** Norgram dan Klim keren
   tapi tidak menyediakan jalan keluar di first viewport; JustUI harus.

Terjemahan per world (ide, belum desain):

| World               | 404 versi world itu                                                                      |
| ------------------- | ---------------------------------------------------------------------------------------- |
| W1 runner           | Slot kosong di runner dengan kode part-nya; "part ini tidak ada di kit" plus daftar part |
| W2 paten            | "FIG. 404" dengan leader line ke ruang kosong; keterangan berisi path yang diminta       |
| W3 bookplate        | Bookplate tanpa nama pemilik                                                             |
| W4 standards manual | Halaman manual yang hilang dari urutan, dengan indeks di bawahnya                        |
| W6 spesimen         | Baris spesimen yang mengetik path yang diminta, diikuti komponen terdekat                |

## 6. Standing exit (standar kategori)

Kalau nanti kamu memilih jalan yang familiar, Impeccable minta dua atau tiga
produk sebagai patokan craft, lalu standar kategori dikerjakan dengan
kualitas penuh tanpa ironi. Kandidat patokan yang sudah dicek:

| Produk                                                                 | Patokan apa                                                                                   |
| ---------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| [ui.shadcn.com](https://ui.shadcn.com) (screenshot)                    | Monokrom, demo komponen asli di bawah hero. Ini juga persis rut kategori                      |
| [base-ui.com](https://base-ui.com) (screenshot)                        | Headline rata kiri, link bergaris bawah, prosa yang tenang, hampir tanpa chrome               |
| [vercel.com/geist](https://vercel.com/geist/introduction) (screenshot) | Grid bergaris tipis dengan tanda plus di sudut. Hati-hati: grid overlay dilarang tanpa alasan |

Situs yang dicek tapi tidak dipakai: [htmx.org](https://htmx.org) (dokumen
polos, bukan Persuade), [are.na](https://www.are.na) (daftar a/b/c yang
menarik, tapi aksen biru navy), [merchantandmills.com](https://merchantandmills.com)
(dicari untuk world pola jahit, ternyata sekarang foto fashion berwarna),
[press.stripe.com](https://press.stripe.com) (rak buku WebGL tidak ter-render
di browser headless, perlu dilihat manual),
[teenage.engineering/guides/ep-133](https://teenage.engineering/guides/ep-133)
(manual yang indah, tapi aksen oranye dan banyak warna).

## 7. Langkah berikutnya sesuai Impeccable

1. `$impeccable init`: wawancara singkat lalu tulis `PRODUCT.md` (user, tugas,
   mekanisme, bukti yang ada, komitmen brand termasuk Ink and Paper dan DP-6).
   Tanpa file ini `concept-seed` menolak jalan.
2. `$impeccable shape /[lang]` atau permintaan redesign biasa: new-work
   membaca daftar tujuh world ini, lalu `concept-seed --scope direction --mode persuade`
   mengundi direction. Undiannya bisa jatuh ke world mana pun, termasuk
   challenger dari katalog Impeccable sendiri.
3. Hasil undian ditulis sebagai direction contract di surface brief, baru
   build, finish review, lalu `DESIGN.md`.

## 8. Konflik yang perlu kamu putuskan

1. **Font.** `new-work.md` section 4 menyebut Plus Jakarta Sans dan IBM Plex
   sebagai default training data untuk surface Persuade, dan memakainya butuh
   alasan yang tidak bisa dipenuhi font lain. DP-6 sudah mengunci Plus Jakarta
   Sans untuk semua teks (2026-10-16), dengan IBM Plex Mono hanya untuk teks
   monospace seperti perintah install. Impeccable bilang brief menang, jadi
   ini tetap dihormati. Kalau kamu mau landing punya display face sendiri,
   itu perubahan DP-6 dan harus diputuskan eksplisit.
2. **Kicker di landing dan 404 sekarang.** Impeccable melarangnya total.
   Redesign harus menghapusnya.
3. **Neobrutalism sebagai gaya halaman.** Shadow offset keras hanya sah
   saat halaman mendemokan preset neobrutalism, bukan sebagai gaya landing.

## 9. Bukti visual lokal

Screenshot 1440x900 dari setiap situs yang dicek ada di scratchpad sesi ini
(tidak di-commit):
`/tmp/claude-1000/-home-yourblooo-development-justui/b4a57eb4-ecd0-4fd2-8707-249ef775d9eb/scratchpad/refs/`.
Folder itu akan hilang setelah sesi selesai.

## 10. Uji multi-preset (2026-10-17)

Pertanyaan: apakah referensi di dokumen ini masih cocok kalau JustUI punya
banyak preset, masing-masing dengan karakter sendiri?

### 10.1 Fakta yang diverifikasi

1. **Docs sekarang mengunci model dua preset.**
   `apps/docs/src/components/providers/preset-provider.tsx` hanya menerima
   `'neobrutalism'` atau `'default'`, lalu memasang `theme-neobrutalism` di
   `<html>` dan `<body>`. Script inline di `src/app/[lang]/layout.tsx:61`
   juga hanya mengenal `'neobrutalism'`. `what-you-get.tsx` memasang dua
   sampel tetap, `simulator-harness.tsx` memakai ternary dua nilai, dan
   navbar memakai `PresetToggle` dua posisi.
2. **Preset switcher me-reskin seluruh situs, termasuk landing.** Class-nya
   dipasang di root, jadi chrome landing ikut berubah setiap kali preset
   diganti.
3. **Token set per preset sudah bisa dipakai scoped.** `globals.css`
   mendefinisikan `.preset-default` dan `.theme-neobrutalism` sebagai token
   set lengkap, dan keduanya sudah dipasang per region di `what-you-get` dan
   `simulator-harness`.
4. **Preseden eksternal: shadcn/ui.** Sejak Desember 2025 shadcn punya
   beberapa style
   ([changelog shadcn create](https://ui.shadcn.com/docs/changelog/2025-12-shadcn-create),
   [ringkasan shadcnblocks](https://www.shadcnblocks.com/blog/shadcn-component-styles-vega-nova-maia-lyra-mira)).
   Dicek langsung di [ui.shadcn.com/create](https://ui.shadcn.com/create)
   (2026-10-17): menu style berisi delapan nama (Vega, Nova, Maia, Lyra,
   Mira, Luma, Sera, Rhea). Mengganti Nova ke Lyra hanya mengubah area
   preview (radius jadi None, lebih rapat). Nav atas dan panel kontrol tetap
   identik.
5. **Batas kontrak preset JustUI.** Preset hanya boleh mengubah shape, motion
   dan part mapping, tidak boleh menambah hue (`02-design-spec.md` section 1;
   P3 FR-3.1). Kontrak itu tidak punya spacing atau density, tidak punya
   typography, dan alpha hanya boleh untuk scrim dan shadow
   (`02-design-spec.md` 5.1 rule 5).

### 10.2 Preset uji

Dua preset nyata dan lima preset hipotetis. Yang hipotetis hanya dipakai
untuk menguji referensi, bukan rencana. Sumbunya diambil dari style shadcn
yang terverifikasi di atas.

| ID  | Preset                   | Ciri                                                 | Bisa dibuat dengan kontrak sekarang?                         |
| --- | ------------------------ | ---------------------------------------------------- | ------------------------------------------------------------ |
| T1  | default (nyata)          | Garis tipis, shadow ink lembut, motion standar       | Ya                                                           |
| T2  | neobrutalism (nyata)     | Border ink 2.5px, shadow offset keras, motion instan | Ya                                                           |
| T3  | bulat lega (mirip Maia)  | Radius besar, ruang lega, shadow lembut              | Sebagian: radius ya, ruang lega tidak (spacing bukan preset) |
| T4  | rapat (mirip Mira/Nova)  | Padat untuk data                                     | Tidak: density bukan bagian kontrak preset                   |
| T5  | kotak datar (mirip Lyra) | Radius nol, tanpa shadow                             | Ya, kecuali font mono Lyra (bertentangan dengan DP-6)        |
| T6  | motion-led               | Gerak pegas, shape tenang                            | Ya (`defaultMotion`)                                         |
| T7  | glass                    | Permukaan tembus pandang, blur                       | Tidak: alpha dibatasi untuk scrim dan shadow                 |

### 10.3 Kriteria

| ID  | Kriteria                 | Lolos kalau                                                                                                                 |
| --- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------- |
| K1  | Bingkai, bukan kostum    | Chrome world tidak memakai ciri khas preset mana pun (shadow offset keras, border ink tebal, pill, radius nol mutlak, blur) |
| K2  | Memperlihatkan yang asli | Preset tampil sebagai komponen hidup. Gambar garis tidak bisa memperlihatkan shadow lembut, density atau motion             |
| K3  | Skala ke N preset        | Slot preset berupa daftar atau urutan, bukan pasangan dua                                                                   |
| K4  | Tidak butuh reskin       | World tetap terbaca tanpa harus ikut berubah tiap preset diganti                                                            |

### 10.4 Hasil: tujuh world landing

| World                  | K1                                                                                                   | K2                                                                    | K3                                         | K4                                         | Vonis                                       |
| ---------------------- | ---------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | ------------------------------------------ | ------------------------------------------ | ------------------------------------------- |
| W6 spesimen foundry    | Lolos. Di klim.co.nz/fonts chrome tetap netral, tiap baris memakai font-nya sendiri                  | Lolos, setiap baris komponen hidup                                    | Lolos, foundry memuat puluhan keluarga     | Lolos                                      | **Paling tahan. Naik ke posisi 1**          |
| W1 runner kit model    | Lolos kalau rangka hairline netral; outline ink tebal terbaca neobrutalism                           | Bersyarat: part harus komponen hidup, bukan gambar garis              | Lolos: satu runner per preset (A, B, C...) | Lolos                                      | Lolos dengan syarat                         |
| W5 instruksi perakitan | Lolos                                                                                                | Bersyarat: hasil tiap langkah harus komponen hidup                    | Lolos, alurnya sama untuk semua preset     | Lolos                                      | Lolos dengan syarat                         |
| W3 bookplate           | Lolos                                                                                                | Tidak relevan (soal kepemilikan, bukan preset)                        | Tidak relevan                              | Lolos                                      | Netral; cocok sebagai detail, bukan etalase |
| W7 katalog industri    | Lolos                                                                                                | Lemah: di ukuran thumbnail, shadow dan motion hilang                  | Lolos                                      | Lolos                                      | Bersyarat; hanya untuk daftar komponen      |
| W4 standards manual    | Berisiko: band hitam plus radius nol terbaca seperti T5, pengunjung bisa mengira JustUI = gaya datar | Lolos kalau tiap bab berisi komponen hidup                            | Lolos: satu bab per preset                 | Gagal kalau di-reskin: band membulat di T3 | Turun; aman hanya dengan chrome tetap       |
| W2 gambar paten        | Berisiko: estetika garis tinta paling dekat dengan T2 dan T5                                         | Gagal untuk T3, T4, T6, T7: gambar garis hanya memperlihatkan outline | Lolos (FIG. 1 sampai N)                    | Lolos                                      | **Turun. Hanya untuk section anatomi role** |
| Terminal (rut)         | Lolos                                                                                                | Gagal: output teks tidak bisa memperlihatkan preset                   | -                                          | Lolos                                      | Tetap ditolak                               |

Catatan W2: angka referensi yang menunjuk ke part (`primaryBg`, `primaryFg`,
dan seterusnya) justru berguna, karena part mapping memang berbeda per preset
(`resolveParts`). Jadi gambar paten tetap berguna untuk menjelaskan anatomi,
tapi tidak bisa jadi world yang memamerkan preset.

Urutan baru kalau multi-preset dijadikan syarat: W6, W1, W5, W3, W7, W4, W2.
Urutan ini hanya masukan untuk `concept-seed`; undian tetap jalan.

### 10.5 Hasil: referensi 404

Semua referensi 404 terpilih berbasis tipografi atau geometri, bukan gaya
preset, jadi semuanya lolos K1, K3 dan K4. Dua catatan:

- **Ide registry ala Figma** (path diperlakukan sebagai nama komponen, lalu
  komponen terdekat tampil hidup) lolos K2 dengan syarat: komponennya
  dirender dalam preset yang terakhir dipilih pengunjung (`justui-preset` di
  localStorage) atau default, dan tidak boleh ada preset yang di-hardcode.
- **Gerak angka besar ala Norgram** harus memakai motion milik situs, bukan
  motion preset. Kalau ikut `defaultMotion`, angkanya akan diam di T2
  (instan) dan memantul di T6.

### 10.6 Temuan di luar referensi

Ketakutan lu benar, tapi sumber masalah utamanya bukan di referensi.
Masalahnya ada di cara situs memakai preset:

1. **Chrome situs ikut preset.** Dengan N preset, world landing harus tampil
   benar dalam N kulit, padahal Impeccable minta satu world yang memiliki
   halaman. Usulan: chrome landing dan 404 tetap ("house style" Ink and
   Paper dengan bahasa bentuknya sendiri, tidak sama dengan preset mana pun).
   Preset hanya hidup di region panggung lewat token set scoped yang sudah
   ada. Ini yang dilakukan shadcn /create (10.1 item 4). Docs shell perlu
   keputusan terpisah, karena P6 sekarang memetakan border shell per preset.
2. **Pemilih preset dua posisi.** `PresetToggle`, `preset-provider.tsx`,
   script inline, `what-you-get` dan `simulator-harness` semuanya menganggap
   dua preset. Dengan N preset perlu pemilih berbentuk daftar (shadcn memakai
   menu berisi delapan item), dan daftar presetnya harus datang dari data
   yang di-generate, bukan ditulis tangan.
3. **M10 tidak menghitung biaya di docs.** M10 mengecualikan docs app, padahal
   setiap preset baru sekarang menyentuh minimal lima file docs (item 2).
   Usulan PRD: P1 generator mengeluarkan daftar preset ke
   `tokens.generated.ts` dan satu class per preset ke
   `tokens.generated.css` dari map `presets`, bukan nama
   `.theme-neobrutalism` yang ditulis eksplisit (FR-1.5), lalu docs membaca
   daftar itu.
4. **Kontrak preset membatasi "karakter unik".** Preset hanya bisa beda di
   shape, border, shadow, motion, emphasis dan part. Density (T4), ruang lega
   (T3), font (Lyra) dan glass (T7) tidak bisa jadi preset dengan kontrak
   sekarang. Kalau kamu mau preset seberagam style shadcn, kontrak P3 FR-3.1
   dan aturan alpha di `02-design-spec.md` harus diubah lebih dulu.

### 10.7 Perlu kamu putuskan

1. Chrome landing dan 404: tetap (rekomendasi) atau ikut preset?
2. Docs shell: ikut preset seperti sekarang, atau ikut pola yang sama?
3. Ubah PRD untuk daftar preset hasil generate (10.6 item 3)?
4. Apakah kontrak preset perlu dibuka untuk density, spacing atau font
   (10.6 item 4)? Ini menyentuh DP-6 dan aturan alpha.

Belum ada perubahan kode atau PRD fase karena temuan ini; semuanya menunggu
keputusan di atas.
