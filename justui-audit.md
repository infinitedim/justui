# Audit Repositori JustUI

Laporan audit kode `infinitedim/justui`: kekurangan, inkonsistensi, dan hal yang perlu diperbaiki. Setiap temuan disertai bukti dan cara reproduce atau cara memeriksanya.

|                        |                                                                                                                                                                                                       |
| ---------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Branch**             | `83-official-interactive-web-showcase-and-documentation-site`                                                                                                                                         |
| **HEAD yang diaudit**  | `1ca735b` (style: format codebase and sort tailwind utility classes)                                                                                                                                  |
| **Tanggal verifikasi** | 29 September 2026                                                                                                                                                                                     |
| **Putaran**            | Ke-5. Semua temuan yang masih terbuka di putaran 4 (`b802627`) diverifikasi ulang terhadap 19 commit perbaikan `b802627..1ca735b`. Setiap temuan yang tersentuh punya blok **"Pembaruan putaran 5"**. |
| **Tool**               | rustc/cargo 1.94.1, Flutter 3.47.5 (Dart 3.13.4), Node 22.22.2, Bun 1.3.11 (lokal), Next.js 16 (`next build` + `next start`), Chromium Playwright, GitHub Actions                                     |

> **Catatan history.** Branch ini di-force-push setelah audit putaran 3, sehingga hash commit sebelum putaran 4 berubah. Laporan ini memakai hash **baru**:
>
> | Hash lama                                                                                                                         | Hash baru                                                                                                                         | Keterangan                                  |
> | --------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
> | `cb9593f`                                                                                                                         | `714c89f`                                                                                                                         | Baseline audit putaran 1                    |
> | `7fe10a9`                                                                                                                         | `f4c2876`                                                                                                                         | Baseline audit putaran 2 / batch rendah     |
> | `3269d7b`                                                                                                                         | `acb1730`                                                                                                                         | Akhir batch rendah                          |
> | `d62d790` `c6b6e89` `395ad64` `fd534b9` `74edc2a` `d2ce385` `8341da3` `7f4572f` `ceed1d7` `698cb3a` `75b3e1f` `5210ed9` `2453310` | `28aed53` `fbf990a` `136628b` `ecc48a8` `e64276c` `09bc9c1` `3deadbd` `de80755` `919ee84` `9b2f138` `30ffa9c` `a2b3589` `31fc74d` | Commit perbaikan batch rendah (urutan sama) |

> **Catatan kerahasiaan.** Commit `0c3b5a6` ikut meng-commit laporan putaran 4 ke root repo (`justui-audit.md`). Laporan ini memuat rincian kelemahan keamanan (misalnya #12, registry tanpa signature). Kalau repo ini publik, pertimbangkan untuk memindahkannya ke tempat privat.

**Legenda tingkat**

- **Kritis:** merusak fungsi utama untuk user, atau berisiko keamanan langsung.
- **Tinggi:** bug nyata atau celah proses yang perlu segera ditangani.
- **Sedang:** inkonsistensi atau utang teknis yang bisa menimbulkan bug.
- **Rendah:** kebersihan kode atau dokumentasi.

**Legenda status**

- **Terbuka:** masih berlaku di HEAD.
- **Sebagian:** sebagian sudah diperbaiki.
- **Selesai:** diperbaiki, disertai commit dan bukti verifikasinya.
- **Baru (putaran N):** ditemukan pada putaran N.

---

## Ringkasan

### Jumlah temuan

| Tingkat   | Terbuka | Sebagian | Selesai |  Total |
| --------- | ------: | -------: | ------: | -----: |
| Kritis    |       2 |        0 |       5 |      7 |
| Tinggi    |      16 |        1 |       3 |     20 |
| Sedang    |       1 |        8 |      13 |     22 |
| Rendah    |       0 |        1 |      13 |     14 |
| **Total** |  **19** |   **10** |  **34** | **63** |

### Perubahan dibanding putaran 4

**Selesai di putaran 5 (17):** #14, #16, #17, #18, #19, #20, #21, #22, #23, #24, #26, #41, #43, #47, #57, #58, #59.

**Sebagian (10):** #15, #25, #38, #42, #45, #46, #48, #49, #55, #56.

**Belum berubah (15):** #34, #35, #36, #37, #39, #40, #06, #07, #08, #09, #10, #11, #12, #13, #54.

**Temuan baru (4):**

- **#60 (Tinggi):** `apply_changesets_cargo.sh` punya error sintaks sejak awal, sehingga bump versi CLI di release selalu gagal. Bug ini baru terlihat setelah #22 diperbaiki.
- **#61 (Tinggi):** tes `dart_formatter` (dari perbaikan #56) mengasumsikan `dart` terpasang, sehingga `CLI — Test` dan `CLI — Coverage` merah.
- **#62 (Tinggi):** CI di-pin ke Bun 1.3.11 (perbaikan #24), padahal `bun.lock` berformat `lockfileVersion: 2`. Akibatnya `nextjs-ci` gagal saat install, dan semua pengecekan docs di-skip.
- **#63 (Sedang):** registry drift pada `just_progress.dart` (efek perbaikan #17), dan `generate_checksums.dart --dry-run` tetap exit 0, sehingga step CI baru tidak menangkapnya.

**Status CI di HEAD `1ca735b` ([run 36422652123](https://github.com/infinitedim/justui/actions/runs/36422652123)): merah di 4 job.**

| Job               | Penyebab                                                                                          |
| ----------------- | ------------------------------------------------------------------------------------------------- |
| `dart-flutter-ci` | 72 + 3 tes Flutter gagal ([#54](#f54)). Ini kegagalan yang benar, karena CI kini menjalankan tes. |
| `nextjs-ci`       | `bun install` gagal ([#62](#f62))                                                                 |
| `CLI — Test`      | Tes `dart_formatter` gagal tanpa Dart ([#61](#f61))                                               |
| `CLI — Coverage`  | Penyebab sama dengan `CLI — Test` ([#61](#f61))                                                   |

`CLI — Check`, `Clippy`, `Cargo Audit`, dan `Build` hijau.

### Hasil pengecekan di HEAD `1ca735b`

| Pemeriksaan                                                             | Cakupan                                         | Hasil                                                                            |
| ----------------------------------------------------------------------- | ----------------------------------------------- | -------------------------------------------------------------------------------- |
| `cargo clippy --workspace --all-targets -- -D warnings`                 | CLI Rust                                        | bersih                                                                           |
| `cargo test --workspace` (lokal, `dart` di PATH)                        | 136 unit, 41 integrasi, 3 konsistensi registry  | lulus semua                                                                      |
| `cargo test` tanpa `dart` di PATH (setara CI)                           | `dart_formatter`                                | **1 gagal** ([#61](#f61))                                                        |
| `cargo audit --deny warnings` (CI)                                      | `Cargo.lock`                                    | hijau (rustls 0.23.45)                                                           |
| `dart run melos list`                                                   | root workspace                                  | 4 paket (`just_ui_core`, `just_ui_tokens`, `preview`, `showcase`)                |
| `dart format --set-exit-if-changed .`                                   | 490 file                                        | 0 berubah                                                                        |
| `dart run tools/generate_checksums.dart --dry-run`                      | registry vs `packages/core`                     | **drift 1 file, tapi exit 0** ([#63](#f63))                                      |
| `flutter test` di `packages/core`                                       | 429 tes                                         | **357 lulus / 72 gagal** ([#54](#f54))                                           |
| `flutter test` di `packages/tokens`                                     | 56 tes                                          | **53 lulus / 3 gagal** ([#54](#f54))                                             |
| E2E CLI: `init` + `add --all` + `flutter analyze`                       | 157 file, neobrutalism, `dart_target: standard` | 0 error, 0 warning, 14 info `unnecessary_import` (exit 1, [#55](#f55))           |
| E2E CLI: `dart format lib` pada output CLI                              | 157 file                                        | 3 berubah ([#56](#f56))                                                          |
| E2E CLI: `justui list` setelah `add --all`                              | 38 komponen                                     | 38 `[Installed]` ([#59](#f59) selesai)                                           |
| Simulasi release: `apply_changesets.dart` → `apply_changesets_cargo.sh` | `.changeset-polyglot/`                          | Dart OK; **Cargo gagal parse** ([#60](#f60))                                     |
| `bun install --frozen-lockfile` dengan Bun 1.3.11 (CI)                  | `bun.lock`                                      | **gagal** ([#62](#f62))                                                          |
| `vitest run` (lokal)                                                    | docs, 27 file                                   | 555 tes lulus                                                                    |
| `eslint .` / `tsc --noEmit` (lokal)                                     | docs                                            | bersih / lulus                                                                   |
| `next build`                                                            | docs                                            | sukses, 103/103 halaman                                                          |
| `next start` + `curl`                                                   | routing                                         | `/fr/docs/*` masih 500; `/robots.txt` dan path acak masih 200 HTML ([#34](#f34)) |

---

## Daftar temuan

| #           | Judul                                                                                                 | Tingkat | Status                              | Area                               |
| ----------- | ----------------------------------------------------------------------------------------------------- | ------- | ----------------------------------- | ---------------------------------- |
| [#34](#f34) | Segmen `[lang]` menerima nilai apa saja: 500 di docs, soft-200 di path lain, cache ISR tercemar       | Kritis  | Terbuka                             | `apps/docs` (routing)              |
| [#35](#f35) | Perintah instalasi di homepage tidak berfungsi                                                        | Kritis  | Terbuka                             | `apps/docs` (konten)               |
| [#06](#f06) | Tema dihitung ulang setiap kali diakses; cache `ThemeData` hampir tidak pernah kena                   | Tinggi  | Terbuka                             | `packages/core` (theme)            |
| [#07](#f07) | 50 pemanggilan `JustThemeProvider.of(context)` tanpa aspek                                            | Tinggi  | Terbuka                             | `packages/core` (komponen)         |
| [#08](#f08) | Theme extension komponen tidak pernah didaftarkan di core                                             | Tinggi  | Terbuka                             | `packages/core`                    |
| [#09](#f09) | Default haptic tidak konsisten, dan fallback preset tidak pernah tercapai                             | Tinggi  | Terbuka                             | `packages/core`                    |
| [#10](#f10) | Error CLI keluar dengan exit code 0                                                                   | Tinggi  | Terbuka                             | CLI Rust                           |
| [#11](#f11) | Flag global `--quiet`, `--no-color`, `--json` tidak pernah dibaca                                     | Tinggi  | Terbuka                             | CLI Rust                           |
| [#12](#f12) | Integritas registry hanya melindungi dari korupsi transfer                                            | Tinggi  | Terbuka                             | CLI Rust (supply chain)            |
| [#13](#f13) | Neobrutalism: translasi saat ditekan tidak sama dengan offset bayangan                                | Tinggi  | Terbuka                             | `packages/core` + `apps/docs`      |
| [#36](#f36) | Metadata SEO nyaris kosong dan sama di semua halaman                                                  | Tinggi  | Terbuka                             | `apps/docs` (SEO)                  |
| [#37](#f37) | Contoh kode di docs meng-import package yang tidak dimiliki user                                      | Tinggi  | Terbuka                             | `apps/docs` (konten), Theme Studio |
| [#38](#f38) | Snippet Dart di katalog komponen memakai API yang tidak ada                                           | Tinggi  | Sebagian (putaran 5)                | `apps/docs` (katalog)              |
| [#39](#f39) | Theme Studio: resolver warna tidak sama dengan Flutter, dan klaim aksesibilitasnya keliru             | Tinggi  | Terbuka                             | `apps/docs` (Studio)               |
| [#40](#f40) | Ekspor CLI dari Studio tidak bisa mereproduksi tema                                                   | Tinggi  | Terbuka                             | `apps/docs` (Studio) + CLI         |
| [#54](#f54) | 75 tes Flutter gagal, dan tersembunyi karena CI tidak menjalankannya                                  | Tinggi  | Terbuka                             | `packages/core`, `packages/tokens` |
| [#60](#f60) | `apply_changesets_cargo.sh` error sintaks, sehingga bump versi CLI di release selalu gagal            | Tinggi  | Baru (putaran 5)                    | release                            |
| [#61](#f61) | Tes `dart_formatter` mengasumsikan `dart` terpasang, sehingga `CLI — Test` dan `CLI — Coverage` merah | Tinggi  | Baru (putaran 5)                    | CLI Rust (tes) / CI                |
| [#62](#f62) | CI di-pin ke Bun 1.3.11, yang tidak bisa membaca `bun.lock` (lockfileVersion 2)                       | Tinggi  | Baru (putaran 5)                    | CI docs                            |
| [#15](#f15) | Default path berbeda di setiap dokumen                                                                | Sedang  | Sebagian (putaran 5)                | dokumentasi                        |
| [#25](#f25) | Pengecekan registry di CI                                                                             | Sedang  | Sebagian (putaran 5)                | CI                                 |
| [#42](#f42) | Terjemahan tidak konsisten dan navigasi berbeda antarbagian                                           | Sedang  | Sebagian (putaran 5)                | `apps/docs` (i18n)                 |
| [#45](#f45) | State Studio: tema default berkedip, dan umpan balik salin tidak jujur                                | Sedang  | Sebagian (putaran 5)                | `apps/docs` (Studio)               |
| [#46](#f46) | `PresetProvider` mengakses localStorage tanpa pengaman dan menyebabkan kedip                          | Sedang  | Sebagian (putaran 5)                | `apps/docs`                        |
| [#48](#f48) | Daftar komponen diketik manual di tiga tempat, dan terminal simulasi menampilkan path yang salah      | Sedang  | Sebagian (putaran 5)                | `apps/docs`                        |
| [#49](#f49) | Celah pengujian yang membiarkan bug di atas lolos                                                     | Sedang  | Sebagian (putaran 5)                | `apps/docs` (tes)                  |
| [#55](#f55) | Kode hasil CLI memicu `unnecessary_import`, sehingga `flutter analyze` user gagal                     | Sedang  | Sebagian (putaran 5)                | CLI Rust (import rewriter)         |
| [#63](#f63) | Registry drift (`just_progress.dart`), dan `generate_checksums.dart --dry-run` tetap exit 0           | Sedang  | Baru (putaran 5)                    | registry / CI                      |
| [#56](#f56) | Output CLI tidak mengikuti `dart format`                                                              | Rendah  | Sebagian (putaran 5)                | CLI Rust                           |
| [#21](#f21) | Melos 8 mengabaikan `melos.yaml`: job Dart di CI hijau tanpa menjalankan apa pun                      | Tinggi  | Selesai (putaran 5)                 | CI / tooling Dart                  |
| [#22](#f22) | Pipeline Changesets rusak: kedua changeset yang ada ditolak, job release akan gagal                   | Tinggi  | Selesai (putaran 5)                 | release                            |
| [#58](#f58) | `rustls 0.23.43` rentan (RUSTSEC-2026-0285), job `cargo audit` merah                                  | Tinggi  | Selesai (putaran 5)                 | CLI Rust (dependency)              |
| [#14](#f14) | AGENTS.md: sudah dirombak, tapi masih ada klaim yang salah                                            | Sedang  | Selesai (putaran 5)                 | dokumentasi                        |
| [#16](#f16) | README tidak lengkap                                                                                  | Sedang  | Selesai (putaran 5)                 | dokumentasi                        |
| [#17](#f17) | CONTRIBUTING menyebut aturan "enforced in CI" yang tidak pernah dicek                                 | Sedang  | Selesai (putaran 5)                 | dokumentasi / kualitas kode        |
| [#18](#f18) | Kategori di registry dan di docs tidak sama                                                           | Sedang  | Selesai (putaran 5)                 | registry + `apps/docs`             |
| [#19](#f19) | CHANGELOG berhenti di 0.6.0 dan isinya tidak sesuai kode                                              | Sedang  | Selesai (putaran 5)                 | dokumentasi / release              |
| [#20](#f20) | Folder preset registry berisi duplikat, dan file shared saling timpa                                  | Sedang  | Selesai (putaran 5)                 | registry                           |
| [#23](#f23) | Cache Cargo di CI menyimpan folder yang salah                                                         | Sedang  | Selesai (putaran 5)                 | CI                                 |
| [#24](#f24) | Sisa debugging dan versi tool yang tidak di-pin                                                       | Sedang  | Selesai (putaran 5)                 | CI / release                       |
| [#26](#f26) | Dependabot tidak sesuai struktur repo                                                                 | Sedang  | Selesai (putaran 5)                 | CI                                 |
| [#41](#f41) | Link internal rusak                                                                                   | Sedang  | Selesai (putaran 5)                 | `apps/docs`                        |
| [#43](#f43) | Dua sistem pencarian dengan kualitas berbeda                                                          | Sedang  | Selesai (putaran 5)                 | `apps/docs`                        |
| [#47](#f47) | `bun run type-check` gagal di clone yang masih bersih                                                 | Sedang  | Selesai (putaran 5)                 | `apps/docs` (tooling)              |
| [#59](#f59) | `justui list` selalu melaporkan komponen terpasang sebagai "Outdated / Modified"                      | Sedang  | Selesai (putaran 5)                 | CLI Rust                           |
| [#57](#f57) | AGENTS.md tertinggal dari perbaikan batch rendah                                                      | Rendah  | Selesai (putaran 5)                 | dokumentasi                        |
| [#01](#f01) | CLI menulis import yang tidak bisa di-resolve untuk hampir semua komponen                             | Kritis  | Selesai                             | —                                  |
| [#02](#f02) | `dart_target: standard` tidak berfungsi                                                               | Kritis  | Selesai                             | —                                  |
| [#03](#f03) | `registryDependencies` tidak cocok dengan import sebenarnya                                           | Kritis  | Selesai                             | —                                  |
| [#04](#f04) | Tes docs rusak akibat resolusi merge yang gagal                                                       | Kritis  | Selesai                             | —                                  |
| [#05](#f05) | `justui upgrade` mengganti binary tanpa verifikasi checksum                                           | Kritis  | Selesai                             | —                                  |
| [#27](#f27) | `apps/showcase` masih template counter, tapi build 41 MB-nya ikut di-commit                           | Rendah  | Selesai                             | —                                  |
| [#28](#f28) | Folder `.agents/skills` berisi skill yang tidak berhubungan                                           | Rendah  | Selesai (dengan catatan, lihat #57) | —                                  |
| [#29](#f29) | Konfigurasi docs site                                                                                 | Rendah  | Selesai                             | —                                  |
| [#30](#f30) | Dua implementasi `buildPressEffect`                                                                   | Rendah  | Selesai                             | —                                  |
| [#31](#f31) | Kode mati di CLI                                                                                      | Rendah  | Selesai                             | —                                  |
| [#32](#f32) | Method dan file yang terlalu besar                                                                    | Rendah  | Selesai                             | —                                  |
| [#33](#f33) | Sisa komentar tugas review di `generate_checksums.dart`                                               | Rendah  | Selesai                             | —                                  |
| [#44](#f44) | Shortcut ⌘K salah terdeteksi di Safari dan Firefox untuk Mac                                          | Rendah  | Selesai                             | —                                  |
| [#50](#f50) | Migrasi struktur atomic setengah jalan                                                                | Rendah  | Selesai                             | —                                  |
| [#51](#f51) | Kode mati dan daftar locale yang tersebar                                                             | Rendah  | Selesai                             | —                                  |
| [#52](#f52) | Syntax highlighter buatan sendiri dan tab tanpa pola ARIA lengkap                                     | Rendah  | Selesai                             | —                                  |
| [#53](#f53) | 11 cast `as Route` mematikan manfaat `typedRoutes`                                                    | Rendah  | Selesai                             | —                                  |

---

## Lampiran A: setup lingkungan reproduce

Semua langkah reproduce di bawah menganggap setup berikut. Jalankan dari root repo kecuali disebutkan lain.

```bash
# 1. CLI dari HEAD
cargo build --release -p justui
export JUSTUI=$PWD/target/release/justui

# 2. Flutter/Dart (sandbox ini: /opt/flutter-sdk/flutter/bin). Di mesin sendiri cukup `flutter` di PATH.
#    AGENTS.md meminta HOME khusus kalau HOME read-only:  export HOME=$PWD/.home

# 3. Proyek Flutter kosong untuk uji CLI
flutter create --platforms web /tmp/e2e/app && cd /tmp/e2e/app
$JUSTUI init -y --preset neobrutalism --color-space oklch --dart-target standard
# pakai registry lokal di repo (bukan GitHub main) supaya yang diuji = HEAD:
sed -i "s#^registry_url:.*#registry_url: /path/ke/justui/registry#" justui.config.yaml

# 4. Docs produksi lokal
cd apps/docs && bun install && bun run build && bunx next start -p 3470
#    (di sandbox, build dilakukan di salinan `git archive HEAD apps/docs` karena
#     Turbopack menolak node_modules yang di-symlink)

# 5. Baseline sebelum perbaikan (untuk temuan berstatus Selesai)
git worktree add /tmp/base-r1 714c89f   # baseline putaran 1  (#01-#05)
git worktree add /tmp/base-r2 f4c2876   # baseline batch rendah (#27-#33, #44, #50-#53)
git worktree add /tmp/base-r4 b802627   # baseline putaran 4 (sebelum perbaikan putaran 5)
```

---

---

## Temuan terbuka: Kritis

<a id="f34"></a>

### #34 — Segmen `[lang]` menerima nilai apa saja: 500 di docs, soft-200 di path lain, cache ISR tercemar

**Tingkat:** Kritis · **Status:** Terbuka · **Area:** `apps/docs` (routing) · **File:** `apps/docs/src/app/[lang]/layout.tsx`, `apps/docs/src/app/[lang]/docs/layout.tsx`

**Deskripsi**

Tidak ada `export const dynamicParams = false`, dan layout `[lang]` tidak memvalidasi locale. Hanya `studio/page.tsx` yang memanggil `notFound()` untuk locale tak dikenal. Akibatnya:

- segmen apa pun di posisi pertama URL dianggap locale;
- halaman docs crash untuk locale tak dikenal;
- path lain dirender sebagai homepage lalu disimpan ke cache ISR.

**Bukti** (`next start` dari build HEAD, lalu `curl -s -o /dev/null -w '%{http_code} %{content_type}'`)

```text
/en                        200  text/html; charset=utf-8
/fr                        200  text/html; charset=utf-8        <- homepage Inggris
/fr/docs/introduction      500  text/plain                      <- "Internal Server Error"
/robots.txt                200  text/html; charset=utf-8        <- HTML homepage, bukan robots
/sitemap.xml               200  text/html; charset=utf-8
/favicon.ico               200  text/html; charset=utf-8
/wp-login.php              200  text/html; charset=utf-8
/install.sh                200  text/html; charset=utf-8
/xx/studio                 404  text/html; charset=utf-8        <- hanya studio yang memvalidasi
```

Log server saat `/fr/docs/introduction` diminta:

```text
⨯ TypeError: Cannot use 'in' operator to search for 'root' in undefined
```

Penyebabnya, `docs/layout.tsx` meneruskan `tree={source.pageTree[lang]}`, yang bernilai `undefined` untuk `lang` di luar `en`/`id`.

Isi `.next/server/app/` **setelah** probe di atas. Setiap path acak menjadi entri cache di disk:

```text
favicon.ico.html  fr.html  install.sh.html  robots.txt.html  sitemap.xml.html  wp-login.php.html  (+ .meta .rsc .segments)
```

Folder `apps/docs/public/` sudah tidak ada (terhapus bersama build showcase di `a2b3589`), jadi memang tidak ada `robots.txt`, `sitemap.xml`, maupun favicon statis.

**Cara reproduce**

1. Build dan jalankan docs (Lampiran A langkah 4).
2. Jalankan perintah berikut:

   ```bash
   for p in /fr /fr/docs/introduction /robots.txt /favicon.ico /wp-login.php; do
     printf '%-24s ' $p; curl -s -o /dev/null -w '%{http_code} %{content_type}\n' http://localhost:3470$p
   done
   ls apps/docs/.next/server/app | grep -E '^(fr|robots|wp-login|favicon)'
   ```

3. **Diharapkan:** 404 untuk semua path di atas. **Aktual:** 200 dengan HTML, atau 500, dan file cache baru muncul.

**Dampak**

- Crawler menerima HTML sebagai pengganti `robots.txt`.
- Bot yang memindai path acak (misalnya `/wp-login.php`) memaksa render di server, dan cache disk tumbuh tanpa batas.
- User yang salah ketik locale melihat halaman error 500.

**Saran perbaikan**

- Tambahkan `export const dynamicParams = false` di `app/[lang]/layout.tsx`, atau validasi dengan `isLocale()` dari `src/lib/i18n.ts` lalu panggil `notFound()`.
- Tambahkan `app/robots.ts`, `app/sitemap.ts`, dan `app/icon.(png|svg)`.
- Tambahkan tes E2E untuk `/fr`, `/robots.txt`, dan path acak.

**Pembaruan putaran 5**

Diverifikasi ulang di `1ca735b` (`next build` + `next start`): **belum berubah**. `docs/[[...slug]]/page.tsx` kini memanggil `notFound()` untuk slug yang tidak ada, tapi `docs/layout.tsx:16` (`source.pageTree[lang]`) sudah crash lebih dulu.

```text
/fr                      200 text/html
/fr/docs/introduction    500 text/plain      (log: TypeError … 'root' in undefined)
/robots.txt              200 text/html
/favicon.ico             200 text/html
/wp-login.php            200 text/html
/install.sh              200 text/html
```

---

<a id="f35"></a>

### #35 — Perintah instalasi di homepage tidak berfungsi

**Tingkat:** Kritis · **Status:** Terbuka · **Area:** `apps/docs` (konten) · **File:** `apps/docs/src/components/molecules/install-tabs/install-tabs.tsx:19,29`

**Deskripsi**

Tab instalasi di homepage menampilkan dua perintah, dan keduanya tidak bisa dipakai. README juga memakai URL yang berbeda.

**Bukti**

```ts
// install-tabs.tsx
19:    command: 'curl -fsSL https://justui.vercel.app/install.sh | bash',
29:    command: 'cargo install justui',
```

```text
# README.md:65 (versi lain lagi)
curl -fsSL https://raw.githubusercontent.com/infinitedim/justui/main/packages/cli/install/install.sh | sh
```

- `cargo install justui`: crate `justui` tidak ada di crates.io.

  ```text
  $ curl -s https://crates.io/api/v1/crates/justui -H "User-Agent: audit"
  {"errors":[{"detail":"crate `justui` does not exist"}]}
  ```

- `https://justui.vercel.app/install.sh`: tidak ada file `install.sh` di app docs, dan tidak ada rewrite. Kalau domain itu melayani app ini, #34 menunjukkan `/install.sh` dijawab **200 text/html** berisi homepage, sehingga yang di-pipe ke `bash` adalah HTML:

  ```text
  $ curl -s http://localhost:3470/install.sh | head -c 60
  <!DOCTYPE html><html><head><meta charSet="utf-8"/><meta name
  ```

**Cara reproduce**

1. `grep -n "command:" apps/docs/src/components/molecules/install-tabs/install-tabs.tsx`
2. `curl -s https://crates.io/api/v1/crates/justui -H "User-Agent: audit"` (butuh internet). Domain `justui.dev` tidak bisa dijangkau dari sandbox audit, jadi perilaku live-nya belum diverifikasi.
3. Dengan server lokal (Lampiran A): `curl -s http://localhost:3470/install.sh | head -c 60`.

**Dampak:** calon user yang mengikuti instruksi pertama di homepage langsung gagal. Pada skenario terburuk, `bash` mengeksekusi HTML.

**Saran perbaikan:** samakan dengan README (URL `raw.githubusercontent.com/.../install.sh`), atau terbitkan crate dan sajikan `install.sh` lewat route handler (`app/install.sh/route.ts`) dengan `Content-Type: text/plain`.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah**. Malah ada tab baru `irm https://justui.vercel.app/install.ps1 | iex` (`install-tabs.tsx:24`), yang bermasalah dengan cara yang sama.

---

## Temuan terbuka: Tinggi

<a id="f06"></a>

### #06 — Tema dihitung ulang setiap kali diakses; cache `ThemeData` hampir tidak pernah kena

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** `packages/core` (theme) · **File:** `packages/core/lib/src/theme/theme_provider.dart:88-125`, `packages/core/lib/src/theme/theme_data_material.dart:5-13`

**Deskripsi**

Getter `JustThemeProviderState.theme` menghitung ulang tema setiap dipanggil: override high-contrast, `animations.resolve()`, `spacing.resolve(width)`, `radius.resolve(width)`, lalu `copyWith()`. Hasilnya instance baru. `toThemeData()` memakai `Expando` yang berbasis **identitas** objek, jadi cache-nya hampir tidak pernah kena.

**Bukti**

```dart
// theme_provider.dart
 88  JustThemeData get theme {
 ...
112      final JustThemeData resolvedTheme = isHighContrast
113          ? baseTheme.applyHighContrastOverrides()
114          : baseTheme;
116      final double width = MediaQuery.maybeSizeOf(context)?.width ?? 1024.0;
117      final JustMotionProfile resolvedAnimations = resolvedTheme.animations
118          .resolve(context);
120      return resolvedTheme.copyWith(                 // instance baru setiap panggilan
121        spacing: resolvedTheme.spacing.resolve(width),
122        radius: resolvedTheme.radius.resolve(width),
123        animations: resolvedAnimations,
124      );

// theme_data_material.dart
  5  final Expando<ThemeData> _themeDataCache = Expando<ThemeData>();
 12    return _themeDataCache[this] ??= _buildMaterialTheme();   // key = identitas `this`
```

`JustButton.build` sendiri mengakses `.theme` 4 kali per build (`just_button.dart:227, 239-250`):

```dart
227    final JustThemeData customTheme = JustThemeProvider.of(context).theme;
239    final JustColorScheme colors = JustThemeProvider.of(context, aspect: .colors).theme.colors;
243    final JustTypographyScheme typography = JustThemeProvider.of(context, aspect: .typography).theme.typography;
247    final JustSpacingScheme spacing = JustThemeProvider.of(context, aspect: .spacing).theme.spacing;
```

AGENTS.md:77 masih mengklaim cache ini "eliminating object allocations across build loops".

**Cara reproduce** (sudah dijalankan untuk laporan ini)

1. Simpan sebagai `packages/core/test/zz_audit_probe_06_test.dart`:

   ```dart
   import 'package:flutter/widgets.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:just_ui_core/just_ui_core.dart';

   void main() {
     testWidgets('audit #06', (WidgetTester tester) async {
       late JustThemeProviderState s;
       await tester.pumpWidget(JustThemeProvider(
         lightTheme: JustThemeData.light,
         darkTheme: JustThemeData.dark,
         child: Builder(builder: (BuildContext c) { s = JustThemeProvider.of(c); return const SizedBox(); }),
       ));
       print('identical(theme, theme) = ${identical(s.theme, s.theme)}; '
           'identical(toThemeData(), toThemeData()) = ${identical(s.theme.toThemeData(), s.theme.toThemeData())}');
     });
   }
   ```

2. Jalankan `cd packages/core && flutter test test/zz_audit_probe_06_test.dart`, lalu hapus file tesnya.
3. Output aktual:

   ```text
   identical(theme, theme) = false; identical(toThemeData(), toThemeData()) = false
   ```

   **Diharapkan:** `true; true`.

**Dampak:** alokasi objek dan perhitungan resolve berulang di setiap build semua komponen. Ini bertentangan dengan target "zero heap allocations in layout/paint loops".

**Saran perbaikan:** hitung tema yang sudah di-resolve sekali per perubahan input (mode, brightness, high-contrast, lebar breakpoint, reduce-motion), simpan di state (misalnya di `didChangeDependencies`), dan kembalikan instance yang sama dari getter.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah** (`theme_provider.dart:120` masih `copyWith` per panggilan).

---

<a id="f07"></a>

### #07 — 50 pemanggilan `JustThemeProvider.of(context)` tanpa aspek

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** `packages/core` (komponen) · **File:** `packages/core/lib/src/components/**`

**Deskripsi:** `JustThemeProvider.of(context)` tanpa `aspect:` membuat widget berlangganan ke **semua** aspek tema. Ini bertentangan dengan AGENTS.md §3.1 dan CONTRIBUTING aturan G.

**Bukti**

```text
$ grep -rn "JustThemeProvider.of(context)" packages/core/lib/src/components | wc -l
50
$ grep -rc "JustThemeProvider.of(context)" packages/core/lib/src/components --include=*.dart | grep -v ':0' | sort -t: -k2 -nr | head -8
sidebar/just_sidebar.dart:5
input/just_input.dart:4
breadcrumb/just_breadcrumb.dart:4
sheet/just_sheet.dart:3
toast/just_toast.dart:2
time_picker/_time_picker_spinner.dart:2
dialog/just_dialog.dart:2
button/just_button.dart:2
```

Contoh, `just_button.dart:226-227`:

```dart
    // Using context.justTheme which resolves InheritedModel aspects properly
    final JustThemeData customTheme = JustThemeProvider.of(context).theme;   // komentar tidak sesuai kode
```

**Cara memeriksa:** perintah `grep` di atas. Untuk membuktikan dampaknya, bungkus komponen dengan `Builder` yang menghitung rebuild, lalu ubah hanya `spacing` di tema. Komponen tetap rebuild.

**Dampak:** perubahan aspek apa pun (misalnya resize yang mengubah spacing) me-rebuild semua komponen. Mekanisme `InheritedModel` jadi tidak berguna.

**Saran perbaikan:** ganti dengan `context.justColors` / `justTypo` / `justSpacing`, atau `of(context, aspect: …)`. Untuk data yang dipakai di callback, pakai `context.readTheme()`. Tambahkan lint kustom atau tes grep di CI.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah** (masih 50 pemanggilan).

---

<a id="f08"></a>

### #08 — Theme extension komponen tidak pernah didaftarkan di core

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** `packages/core` · **File:** `packages/core/lib/src/theme/theme_data_material.dart:22-24`

**Deskripsi:** 29 file komponen membaca `Theme.of(context).extension<Just…Theme>()`, tapi daftar `extensions` di core kosong. Daftar itu hanya diisi CLI di proyek user lewat anchor `// CLI:REGISTER_EXTENSIONS`. Di core, `apps/preview`, dan tes, semua extension bernilai `null`, sehingga tema per komponen tidak pernah teruji.

**Bukti**

```dart
// theme_data_material.dart
22      extensions: const <ThemeExtension<dynamic>>[
23        // CLI:REGISTER_EXTENSIONS
24      ],
```

```text
$ grep -rln "extension<Just" packages/core/lib/src/components | wc -l
29
```

**Cara reproduce:** di `apps/preview`, tambahkan `debugPrint('${Theme.of(context).extension<JustButtonTheme>()}')` di usecase button, lalu jalankan. Output-nya `null`.

**Dampak:** jalur kode "theme extension" hanya hidup di proyek user. Bug di sana (misalnya #09) tidak bisa tertangkap di repo ini.

**Saran perbaikan:** tetap pertahankan anchor untuk CLI, tapi daftarkan default extension di `apps/preview` dan di helper tes, misalnya `JustThemeData.toThemeData(extensions: …)` atau wrapper `Theme` di preview/test harness.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah** (`extensions` di core masih kosong; `apps/preview` tidak mendaftarkan extension).

---

<a id="f09"></a>

### #09 — Default haptic tidak konsisten, dan fallback preset tidak pernah tercapai

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** `packages/core` · **File:** `packages/core/lib/src/components/button/just_button.dart:233-236`, `button/just_button_theme.dart`

**Deskripsi**

- Button memakai `presetTokens.showsDefaultBorder` (atribut **visual**) sebagai default haptic. Checkbox dan switch memakai `selectionHapticDefault`.
- `JustButtonTheme.enableHaptic` bertipe non-nullable dengan default `false`, sehingga begitu extension didaftarkan oleh CLI, rantai `??` selalu berhenti di theme dan nilai preset tidak pernah terpakai.

**Bukti**

```dart
// just_button.dart
233    final bool effectiveHaptic =
234        enableHaptic ??
235        buttonTheme?.enableHaptic ??        // non-null setelah extension terdaftar -> selalu false
236        presetTokens.showsDefaultBorder;    // tidak pernah tercapai di proyek user
```

```dart
// just_button_theme.dart
27  final bool enableHaptic = false,                 // non-nullable
30  static const JustButtonTheme defaults = JustButtonTheme();

// app hasil `justui init && add --all` (lib/core/theme/theme_data_material.dart)
49      extensions: const <ThemeExtension<dynamic>>[
50        JustButtonTheme.defaults,                 // disuntik CLI -> enableHaptic == false
```

**Cara reproduce**

1. Di app hasil CLI (Lampiran A, preset neobrutalism), jalankan `grep -n "JustButtonTheme" lib/core/theme/theme_data_material.dart`. Hasilnya `JustButtonTheme.defaults` ada di daftar extensions.
2. Tambahkan `debugPrint` di `just_button.dart` untuk `effectiveHaptic`, lalu tekan tombol. Nilainya `false`, padahal neobrutalism mengaktifkan haptic lewat `showsDefaultBorder`.

**Dampak:** perilaku haptic berbeda antara repo (preview) dan proyek user, dan berbeda antar komponen.

**Saran perbaikan:** jadikan `JustButtonTheme.enableHaptic` bertipe `bool?`, dan pakai satu token `presetTokens.selectionHapticDefault` untuk semua komponen.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah** (`just_button.dart:233-236`, `just_button_theme.dart:27`).

---

<a id="f10"></a>

### #10 — Error CLI keluar dengan exit code 0

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** CLI Rust · **File:** `packages/cli/src/commands/add.rs:59-64` (dan pola yang sama di `commands/`)

**Deskripsi:** pola `logger::error(...); return Ok(());` membuat kegagalan dilaporkan sebagai sukses ke shell dan CI.

**Bukti**

```rust
// add.rs
59    if !config_path.exists() {
60        logger::error(
61            "Project not initialized. Please run \"justui init\" in the root directory first.",
62        );
63        return Ok(());
64    }
```

```text
$ grep -rn "logger::error" packages/cli/src/commands | wc -l
44
$ grep -rn -A1 "logger::error" packages/cli/src/commands | grep -c "return Ok(())"
20

$ cd "$(mktemp -d)" && justui add button; echo "exit=$?"
✗ Error: Project not initialized. Please run "justui init" in the root directory first.
exit=0
```

**Cara reproduce:** perintah terakhir di atas, dengan binary dari HEAD.

**Dampak:** skrip dan CI yang memanggil `justui add` / `update` tidak bisa mendeteksi kegagalan.

**Saran perbaikan:** kembalikan `Err(anyhow!(…))` (atau `bail!`) dan biarkan `main` mencetak error lalu `process::exit(1)`. Tambahkan tes integrasi `assert_cmd` dengan `.failure()`.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah** (masih 20 pola `logger::error` + `return Ok(())`).

---

<a id="f11"></a>

### #11 — Flag global `--quiet`, `--no-color`, `--json` tidak pernah dibaca

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** CLI Rust · **File:** `packages/cli/src/main.rs:32-41`

**Deskripsi:** ketiga flag didefinisikan sebagai `global = true` dan muncul di `--help`, tapi tidak ada kode yang membacanya. `--json` di `list` adalah flag subcommand terpisah (`main.rs:197`).

**Bukti**

```rust
// main.rs
32    #[arg(short = 'q', long = "quiet", global = true)]
33    quiet: bool,
36    #[arg(long = "json", global = true)]
37    json: bool,
41    no_color: bool,
```

```text
$ grep -rn "cli\.quiet\|cli\.no_color\|cli\.json" packages/cli/src
(tidak ada hasil)

# di TTY (dipaksa dengan `script`), --no-color tetap mengeluarkan kode ANSI:
$ script -qc "justui --no-color add x" /dev/null | cat -v
^[[31m✗ Error: Project not initialized. …^[[0m

# --json --quiet tetap mencetak kotak dekoratif:
$ justui --quiet --no-color --json view button
╔══════════════════════════════════════════════╗
║  button (v0.14.0)                            ║
```

**Cara reproduce:** perintah di atas di direktori kosong, dengan binary HEAD. Catatan tambahan: `justui diff <komponen>` bahkan mengeluarkan kode warna ANSI (`[36m│ @@ …`) saat output di-pipe ke file, jadi deteksi TTY pun tidak konsisten antar command.

**Dampak:** flag yang terdokumentasi di `--help` tidak berfungsi. Otomasi yang mengandalkan `--json` atau `--quiet` menerima output dekoratif.

**Saran perbaikan:** teruskan nilai flag ke `logger` (misalnya state global `OnceLock`), hormati `NO_COLOR`, dan implementasikan output JSON per command, atau hapus flag yang belum didukung.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah** (tidak ada pemakaian `cli.quiet`, `cli.no_color`, maupun `cli.json`).

---

<a id="f12"></a>

### #12 — Integritas registry hanya melindungi dari korupsi transfer

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** CLI Rust (supply chain) · **File:** `packages/cli/src/config.rs:20-21`, `packages/cli/src/commands/add.rs:432-433`

**Deskripsi:** checksum yang dicek `add` diambil dari `index.json` di branch `main`, yaitu sumber yang sama dengan file komponennya. Siapa pun yang bisa mengubah file komponen di `main` (atau di mirror / `registry_url` kustom) juga bisa mengubah checksum-nya. Tidak ada signature, dan tidak ada pin versi registry terhadap versi CLI.

**Bukti**

```rust
// config.rs
20    pub const DEFAULT_REGISTRY_URL: &'static str =
21        "https://raw.githubusercontent.com/infinitedim/justui/main/registry";

// add.rs
432        let downloaded_hash = sha256_hex(content.as_bytes());
433        let expected_hash = file.checksum.replace("sha256:", "").trim().to_string();   // dari index.json yang sama
```

**Cara memeriksa**

- Baca kedua lokasi di atas.
- Uji manual: salin `registry/` ke folder lain, ubah `components/badge/default/just_badge.dart`, perbarui checksum-nya di `index.json` (atau jalankan `generate_checksums.dart` di salinan itu), lalu set `registry_url` ke folder tersebut. `justui add badge` menerima file yang sudah diubah tanpa peringatan.

**Dampak:** kompromi pada branch `main` atau URL registry langsung menyebar ke kode sumber proyek user. Kode itu di-copy, bukan dependency yang bisa diaudit lewat lockfile.

**Saran perbaikan:**

- Pin registry ke tag versi CLI (`…/v{CARGO_PKG_VERSION}/registry`).
- Tanda tangani `index.json` (minisign/sigstore) dan verifikasi dengan public key yang di-embed di binary.
- Tampilkan peringatan kalau `registry_url` bukan default.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah** (`config.rs:20-21` masih `…/main/registry`, tanpa signature).

---

<a id="f13"></a>

### #13 — Neobrutalism: translasi saat ditekan tidak sama dengan offset bayangan

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** `packages/core` + `apps/docs` · **File:** `packages/core/lib/src/theme/schemes/shadow_scheme.dart:142-182`, `packages/core/lib/src/theme/preset_tokens.dart:320`, `button/just_icon_button.dart:168-173`, `apps/docs/src/lib/theme/color-resolver.ts:246-247`

**Deskripsi:** efek tekan neobrutalism seharusnya menggeser elemen sejauh offset bayangannya, supaya bayangan "tertelan" (AGENTS §10.2). Offset bayangan bervariasi 2–12 px, tapi translasi di-hardcode 4 px.

**Bukti**

```dart
// NeobrutalismShadowScheme (shadow_scheme.dart)
142  xs:  offset: const Offset(2.0, 2.0),
150  sm:  offset: const Offset(4.0, 4.0),
158  md:  offset: const Offset(6.0, 6.0),
166  lg:  offset: const Offset(8.0, 8.0),
174  xl:  offset: const Offset(10.0, 10.0),
182  xxl: offset: const Offset(12.0, 12.0),

// preset_tokens.dart:320
    final Offset offset = customOffset ?? const Offset(4.0, 4.0);

// just_icon_button.dart:171-173 — ukuran xs memakai bayangan xs (2 px) tetapi translasi tetap 4 px
                defaultShadows = size == JustButtonSize.xs
                    ? customTheme.shadows.xs
                    : customTheme.shadows.sm;
```

Sementara itu di docs:

- Studio memakai `borderWidth = '2.5px'` dan `shadowSolid = '4px 4px 0px …'` (`color-resolver.ts:246-247`).
- Mockup memakai kelas Tailwind `translate-x-1 translate-y-1` (4 px, `phone-mockup-canvas.tsx:206`) dengan bayangan berbeda.

Jadi ada tiga sumber nilai yang berbeda.

**Cara reproduce:** di `apps/preview` dengan tema "Neobrutalism Light", buka `JustIconButton` ukuran `xs` lalu tekan-tahan. Tombol bergeser 4 px sementara bayangannya hanya 2 px, sehingga tombol "menembus" posisi bayangan sejauh 2 px. `JustCard` hover (`shadows.md`, 6 px) juga tidak sinkron dengan press 4 px.

**Dampak:** efek tekan terlihat meleset dan berbeda antar komponen dan antara docs dan Flutter. Ini bertentangan dengan pedoman preset sendiri.

**Saran perbaikan:** turunkan translasi dari offset bayangan yang dipakai komponen (`customOffset: shadows.first.offset`), dan jadikan nilai docs/Studio diturunkan dari token yang sama.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah** (`preset_tokens.dart:320` masih `Offset(4.0, 4.0)`).

---

<a id="f36"></a>

### #36 — Metadata SEO nyaris kosong dan sama di semua halaman

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** `apps/docs` (SEO) · **File:** `apps/docs/src/app/layout.tsx:18`, `apps/docs/src/components/html-lang.tsx`, `apps/docs/src/app/[lang]/studio/page.tsx:19`

**Deskripsi**

Hanya ada satu `export const metadata` di root layout. Satu-satunya `generateMetadata` ada di studio. Atribut `<html lang>` baru dipasang di client lewat `useEffect`. Tidak ada canonical, `hreflang`, Open Graph, maupun `metadataBase`.

**Bukti** (HTML hasil `next build` di `.next/server/app/`, di-parse dengan Python)

```text
file                             <title>                  description (50 char)                 <html> attr  canonical hreflang og
en.html                          JustUI Documentation     Beautiful, accessible, copy-paste…    (kosong)     False     False    False
id.html                          JustUI Documentation     Beautiful, accessible, copy-paste…    (kosong)     False     False    False
en/docs/introduction.html        JustUI Documentation     Beautiful, accessible, copy-paste…    (kosong)     False     False    False
id/docs/theming.html             JustUI Documentation     Beautiful, accessible, copy-paste…    (kosong)     False     False    False
en/docs/components/button.html   JustUI Documentation     Beautiful, accessible, copy-paste…    (kosong)     False     False    False
id/components.html               JustUI Documentation     Beautiful, accessible, copy-paste…    (kosong)     False     False    False
en/studio.html                   Theme Studio - JustUI    Configure your design tokens…         (kosong)     False     False    False
id/studio.html                   Theme Studio - JustUI    Konfigurasi design token secara…      (kosong)     False     False    False
```

```tsx
// src/app/[lang]/studio/page.tsx:19 — kedua cabang identik
    title: isId ? 'Theme Studio - JustUI' : 'Theme Studio - JustUI',

// src/components/html-lang.tsx:11-12 — lang hanya di client
export function HtmlLang({ lang }: { lang: string }) {
  useEffect(() => {
```

**Cara reproduce**

```bash
cd apps/docs && bun run build
for f in en id en/docs/introduction id/docs/theming; do
  grep -o '<title>[^<]*</title>' .next/server/app/$f.html; grep -o '<html[^>]*>' .next/server/app/$f.html
done
grep -rn "generateMetadata\|export const metadata" src/app
```

**Dampak:** semua halaman docs tampil dengan judul identik di hasil pencarian dan tab browser. Mesin pencari tidak tahu versi bahasa mana yang kanonik. Screen reader dan crawler tanpa JS menerima dokumen tanpa `lang`.

**Saran perbaikan**

- Tambahkan `generateMetadata` di `[lang]/layout.tsx` (title template, `alternates.languages`, `metadataBase`) dan di `docs/[[...slug]]/page.tsx` (judul dari frontmatter).
- Render `lang` langsung di `<html>` dengan memindahkan root layout ke `[lang]/layout.tsx`.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah**. `en.html`, `id/docs/theming.html`, dan `en/docs/components/button.html` masih bertitel `JustUI Documentation`, dan `<html suppressHydrationWarning>` di `app/layout.tsx:34` masih tanpa `lang`.

---

<a id="f37"></a>

### #37 — Contoh kode di docs meng-import package yang tidak dimiliki user

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** `apps/docs` (konten), Theme Studio · **File:** `apps/docs/content/docs/**`, `apps/docs/src/components/organisms/code-export-drawer/code-generators.ts:86`

**Deskripsi**

Model copy-paste berarti user tidak pernah memasang `just_ui_core` atau `just_ui_tokens`. CLI mengekstrak keduanya ke `lib/core` dan `lib/tokens`, dengan import `package:<app>/core/just_ui_core.dart`. Konten docs dan ekspor Dart di Theme Studio tetap memakai nama package monorepo.

**Bukti**

```text
$ grep -rn "import 'package:just_ui_core/just_ui_core.dart';"     apps/docs/content/docs | wc -l
146
$ grep -rn "import 'package:just_ui_tokens/just_ui_tokens.dart';" apps/docs/content/docs | wc -l
92
$ grep -rn "package:just_ui" apps/docs/src --include=*.ts | grep -v test
src/components/organisms/code-export-drawer/code-generators.ts:86:import 'package:just_ui_core/just_ui_core.dart';
```

Hasil CLI yang sebenarnya (`justui init` di app bernama `e2e_app`):

```text
lib/core/just_ui_core.dart            -> import 'package:e2e_app/core/just_ui_core.dart';
lib/core/theme/just_theme.dart
```

**Cara reproduce**

1. Ikuti Lampiran A langkah 3 (app `app`).
2. Tempel salah satu snippet dari `content/docs/en/theming.mdx` ke `lib/main.dart`, lalu `flutter analyze`.
3. **Diharapkan:** snippet bisa langsung dipakai. **Aktual** (diuji di app `e2e_app`):

   ```text
   error • Target of URI doesn't exist: 'package:just_ui_core/just_ui_core.dart'. • uri_does_not_exist
   ```

**Dampak:** hampir setiap contoh kode di docs gagal dikompilasi kalau disalin apa adanya.

**Saran perbaikan:** tulis import sebagai `package:your_app/core/just_ui_core.dart`, atau pakai placeholder yang dijelaskan sekali di halaman instalasi. Ubah juga `generateDart` di Studio agar menerima nama package, atau memakai path relatif.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah** (146 + 92 import; `code-generators.ts:89`).

---

<a id="f38"></a>

### #38 — Snippet Dart di katalog komponen memakai API yang tidak ada

**Tingkat:** Tinggi · **Status:** Sebagian (putaran 5) · **Area:** `apps/docs` (katalog) · **File:** `apps/docs/src/lib/components-data.ts`

**Deskripsi:** snippet ini ditampilkan di modal "View Dart code" lengkap dengan tombol salin, tapi beberapa kelas dan parameter yang dipakai tidak ada di `packages/core`.

**Bukti**

| Baris di `components-data.ts` | Snippet                                                                    | Kenyataan di `packages/core`                                                                                                                                                     |
| ----------------------------- | -------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 323-329                       | `JustToast.show(context, title: 'Success', message: …, variant: .success)` | Tidak ada kelas `JustToast`. Yang ada `JustToastController.show({required String message, ToastVariant variant, …})` (`just_toast.dart:108`), tanpa `context` dan tanpa `title`. |
| 335-343                       | `JustDialog(title:, content:, actions: [...])`                             | Tidak ada widget `JustDialog`, hanya `JustDialogController` dan `JustDialogScope`.                                                                                               |
| 349-353                       | `JustSheet(side: .right, title:, child:)`                                  | Tidak ada widget `JustSheet`, hanya `JustSheetController` dan `JustSheetScope`.                                                                                                  |
| 97-98                         | `JustSelectItem(value:, label:)`                                           | Nama yang benar `JustSelectOption<T>` (`just_select.dart:17`).                                                                                                                   |
| 36, 339-340                   | `JustButton(label:, variant:)` tanpa `onPressed`                           | `onPressed` wajib: `required final VoidCallback? onPressed` (`just_button.dart:54`).                                                                                             |

```text
$ grep -rn "class JustToast\b\|class JustDialog\b\|class JustSheet\b\|class JustSelectItem" packages/core/lib
(tidak ada hasil)
```

**Cara reproduce**

1. Buka `/en/components`, kartu Toast, lalu "View Dart code", dan salin snippet-nya.
2. Tempel ke app hasil `justui add toast dialog sheet select button` (Lampiran A), lalu `flutter analyze`.
3. **Aktual** (`flutter analyze` pada file berisi snippet katalog, di app hasil `justui add --all`):

   ```text
   error • Undefined name 'JustToast'. • undefined_identifier
   error • The function 'JustDialog' isn't defined. • undefined_function
   error • The function 'JustSheet' isn't defined. • undefined_function
   error • The function 'JustSelectItem' isn't defined. • undefined_function
   error • The named parameter 'onPressed' is required, but there's no corresponding argument. • missing_required_argument
   ```

**Dampak:** katalog adalah pintu masuk utama. Snippet yang salah membuat user mengira library rusak.

**Saran perbaikan:** generate snippet dari sumber yang dianalisis, misalnya file `.dart` contoh di `apps/preview` atau `apps/showcase` yang ikut `flutter analyze`. Minimal, tambahkan tes yang meng-compile setiap `dartSnippet` di sandbox showcase.

**Pembaruan putaran 5: sebagian diperbaiki**

Snippet `JustButton` sudah memakai `onPressed` (`components-data.ts:41, 50`). Snippet berikut masih memakai API yang tidak ada:

```text
components-data.ts:84-85   JustSelectItem(value: …, label: …)
components-data.ts:246     JustToast.show(
components-data.ts:255     JustDialog(
components-data.ts:266     JustSheet(
```

---

<a id="f39"></a>

### #39 — Theme Studio: resolver warna tidak sama dengan Flutter, dan klaim aksesibilitasnya keliru

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** `apps/docs` (Studio) · **File:** `apps/docs/src/lib/theme/color-resolver.ts:144-148, 202-270`

**Deskripsi**

Ada empat masalah terpisah:

1. Parameter color space tidak dipakai.
2. Rasio kontras dibulatkan dulu sebelum dibandingkan dengan ambang.
3. Warna state gagal ambang untuk semua seed.
4. Accent memakai seed mentah tanpa jaminan kontras, padahal komentar di kode menulis "guaranteed accessible … matching JustThemeData.fromSeed".

**Bukti** (kode)

```ts
// color-resolver.ts
144 export function contrastRatio(color1: string, color2: string): number {
148   return Math.round(ratio * 10) / 10;          // dibulatkan 1 desimal
202 export function resolveTokens(seedColor, isDark, preset = 'default',
206   _colorSpace: ColorSpace = 'hsl'               // tidak pernah dipakai
230   const accent = normSeed;                      // seed mentah
258   // State colors (guaranteed accessible against background matching JustThemeData.fromSeed)
263   const warning = adjustLightnessForContrast(warningBase, background, 3.0);
264   const error   = adjustLightnessForContrast(errorBase,   background, 4.5);
```

**Bukti** (skrip `probe-39.ts`, dijalankan dengan `bun run`; rasio "exact" dihitung ulang dengan rumus WCAG tanpa pembulatan)

```text
1) color space diabaikan (#3b82f6, light, default):
   hsl   292 chars, sama dengan hsl: true
   oklch 292 chars, sama dengan hsl: true
   hsluv 292 chars, sama dengan hsl: true
2) pembulatan: contrastRatio("#777777","#ffffff") = 4.5 | exact = 4.478
3) scan 4096 seed: error(light/default) < 4.5 di 4096 seed (min 4.485); warning(light/neo) < 3.0 di 4096 seed (min 2.953)
   contoh #3b82f6: error #e61414 rasio tampil 4.5 exact 4.485
4) seed default lime #a3e635: accent #a3e635 vs background #f8fafc = 1.44:1
```

**Cara reproduce**

1. Simpan skrip berikut sebagai `apps/docs/probe-39.ts`:

   ```ts
   import {
     resolveTokens,
     contrastRatio,
   } from "./src/lib/theme/color-resolver";
   const lum = (h: string) => {
     const c = [1, 3, 5]
       .map((i) => parseInt(h.slice(i, i + 2), 16) / 255)
       .map((v) => (v <= 0.03928 ? v / 12.92 : ((v + 0.055) / 1.055) ** 2.4));
     return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
   };
   const exact = (a: string, b: string) => {
     const [x, y] = [lum(a), lum(b)].sort((p, q) => q - p);
     return (x + 0.05) / (y + 0.05);
   };
   for (const cs of ["hsl", "oklch", "hsluv"] as const)
     console.log(
       cs,
       JSON.stringify(resolveTokens("#3b82f6", false, "default", cs)),
     );
   console.log(
     contrastRatio("#777777", "#ffffff"),
     exact("#777777", "#ffffff"),
   );
   const t = resolveTokens("#3b82f6", false, "default");
   console.log(
     "error",
     t.error,
     contrastRatio(t.error, t.background),
     exact(t.error, t.background),
   );
   const n = resolveTokens("#3b82f6", false, "neobrutalism");
   console.log("warning", n.warning, exact(n.warning, n.background));
   const l = resolveTokens("#a3e635", false, "default");
   console.log("accent", exact(l.accent, l.background));
   ```

2. `cd apps/docs && bun run probe-39.ts`
3. **Diharapkan:** output berbeda per color space; error ≥ 4.5 dan warning ≥ 3.0. **Aktual:** seperti bukti di atas.
4. Di UI: buka `/en/studio`. Badge kontras hijau "4.5:1" tetap muncul untuk token `error`.

**Dampak:** preview Studio tidak mencerminkan tema yang dihasilkan Flutter, dan UI melaporkan lolos WCAG untuk warna yang sebenarnya gagal. Ini bertentangan dengan core tenet "strict WCAG AA contrast enforcement".

**Saran perbaikan**

- Port logika `JustThemeData.fromSeed`, termasuk engine OKLCH dan HSLuv dari `packages/tokens`, ke TypeScript.
- Bandingkan rasio **sebelum** dibulatkan; pembulatan hanya untuk tampilan.
- Naikkan kontras accent seperti `borderFocus` di Flutter.
- Tambahkan tes properti: scan seed dan pastikan semua ambang terpenuhi.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah** (`color-resolver.ts:150` masih membulatkan, dan `:211` `_colorSpace` masih tidak dipakai).

---

<a id="f40"></a>

### #40 — Ekspor CLI dari Studio tidak bisa mereproduksi tema

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** `apps/docs` (Studio) + CLI · **File:** `apps/docs/src/components/organisms/code-export-drawer/code-generators.ts:43, 96-100`, `packages/cli/src/main.rs:65-107`

**Deskripsi:** tab "CLI" di drawer ekspor hanya menghasilkan preset dan color space. Seed color dan mode gelap hilang, dan CLI memang tidak punya flag untuk seed. Ekspor YAML juga meng-hardcode `dart_target`.

**Bukti**

```ts
// code-generators.ts
 96 export function generateCli(
 97   state: Pick<ThemeStudioState, 'preset' | 'colorSpace'>
 98 ): string {
 99   return `justui init --preset ${state.preset} --color-space ${state.colorSpace}`;
100 }
 43 dart_target: standard            // di generateYaml, selalu
```

```text
$ grep -n "seed" packages/cli/src/main.rs
(tidak ada hasil: subcommand Init hanya punya --preset, --color-space, --dart-target)
```

**Cara reproduce**

1. Buka `/en/studio`, set seed `#e11d48` dan mode gelap, lalu buka Export dan pilih tab CLI.
2. Output-nya `justui init --preset default --color-space hsl`.
3. Jalankan perintah itu di app baru dengan `-y`. `lib/core/theme/just_theme.dart` berisi seed default `#3b82f6`, bukan `#e11d48`.

**Dampak:** fitur utama Studio (desain lalu ekspor) tidak menghasilkan tema yang didesain.

**Saran perbaikan:** tambahkan `--seed <hex>` (dan opsional `--dark`) ke `justui init`, lalu sertakan di `generateCli`. Ambil `dart_target` dari state atau hapus dari YAML ekspor.

**Pembaruan putaran 5**

Diverifikasi ulang: **belum berubah** (`code-generators.ts:99-103`, dan `main.rs` tanpa `--seed`).

---

<a id="f54"></a>

### #54 — 75 tes Flutter gagal, dan tersembunyi karena CI tidak menjalankannya

**Tingkat:** Tinggi · **Status:** Terbuka · **Area:** `packages/core`, `packages/tokens` · **File:** lihat tabel

**Deskripsi**

`flutter test` di `packages/core` menghasilkan 357 lulus / 72 gagal, dan di `packages/tokens` 53 lulus / 3 gagal. Kegagalan ini sudah ada sejak baseline `f4c2876`; batch rendah tidak menambah maupun mengurangi daftarnya (dibandingkan per nama tes). Karena #21, CI tetap hijau.

**Bukti** (`flutter test --reporter expanded`, HEAD `b802627`)

```text
packages/core   : 00:38 +357 -72: Some tests failed.
packages/tokens : +53 -3: Some tests failed.
```

| File tes                            | Gagal | Contoh error pertama (dikutip dari output)                                                                                                                                     |
| ----------------------------------- | ----: | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `carousel_test.dart`                |    27 | `dependOnInheritedWidgetOfExactType<_InheritedTheme>() … was called before _JustCarouselState.initState() completed.`, yaitu **bug kode**: `Theme.of` dipanggil di `initState` |
| `dialog_test.dart`                  |    12 | `JustThemeProvider was not found in the widget tree.` (tes membungkus `MaterialApp` tanpa `JustThemeProvider`)                                                                 |
| `scroll_area_test.dart`             |     7 | `Expected: no matching candidates  Actual: Found 1 widget with type "JustPressable"`                                                                                           |
| `date_picker_test.dart`             |     7 | `A RenderFlex overflowed by 148 pixels on the bottom.` di `_date_picker_calendar.dart:365`                                                                                     |
| `resizable_test.dart`               |     6 | `RangeError (index): Index out of range: index should be less than 1: 1` (finder `.at(1)`)                                                                                     |
| `accessibility_semantics_test.dart` |     5 | `Expected: has semantics with label: Submit Action with actions: [tap] … flags: isButton,isEnabled`                                                                            |
| `input_widgets_test.dart`           |     4 | `Found 0 widgets with type "TextField"` di `input_widgets_test.dart:32`                                                                                                        |
| `shared_components_test.dart`       |     3 | `Bad state: Too many elements` di `shared_components_test.dart:262`                                                                                                            |
| `theme_test.dart`                   |     1 | `fromSeed … respects contrast`: Expected `Color(red: 0.0078, green: 0.0235, blue: 0.0902)`, Actual `Color(red: 0.0275, green: 0.0353, blue: 0.0275)`                           |
| `tokens/test/colors_test.dart`      |     3 | `Light and Dark semantic schemes match specification` (Expected hitam, Actual `0.0078/0.0235/0.0902`), `dampChromaHueAware …`, `maxChromaForLH … AT the gamut boundary`        |

**Cara reproduce**

```bash
cd packages/core   && flutter test --reporter expanded 2>&1 | tail -3
cd packages/tokens && flutter test --reporter expanded 2>&1 | tail -3
# ringkasan per file:
flutter test --reporter expanded 2>&1 | grep -E '\[E\]$' | sed -E 's#.*/test/##; s#: .*##' | sort | uniq -c | sort -rn
```

**Dampak:** sebagian kegagalan adalah bug nyata di komponen: carousel membaca theme di `initState`, dan date picker overflow 148 px. Sebagian lagi tes yang basi terhadap API atau spesifikasi warna. Tanpa CI yang jalan (#21), tidak ada yang tahu mana yang mana.

**Saran perbaikan:** perbaiki #21 dulu supaya kegagalan terlihat. Lalu triase per file: perbaiki bug (carousel, date picker) atau perbarui tes yang basi (dialog tanpa provider, ekspektasi warna token).

**Pembaruan putaran 5**

Diverifikasi ulang di `1ca735b`: **belum berubah**, `packages/core` masih `+357 -72` dan `packages/tokens` masih `+53 -3`. Setelah #21 diperbaiki, kegagalan ini **terlihat** di CI: step "Run Tests" di job `dart-flutter-ci` gagal (run [36422652123](https://github.com/infinitedim/justui/actions/runs/36422652123)). Ini menjadi salah satu dari empat penyebab CI merah di HEAD.

---

<a id="f60"></a>

### #60 — `apply_changesets_cargo.sh` error sintaks, sehingga bump versi CLI di release selalu gagal

**Tingkat:** Tinggi · **Status:** Baru (putaran 5) · **Area:** release · **File:** `tools/apply_changesets_cargo.sh:100-102`, `.github/workflows/release.yaml:60-65`

**Deskripsi:** quoting di baris `awk` tidak seimbang, jadi bash tidak bisa mem-parse skrip ini sama sekali. Bug ini sudah ada sejak baseline putaran 1 (`714c89f`) tapi tidak pernah terlihat, karena release selalu gagal lebih awal di `changeset version` (#22). Setelah #22 diperbaiki dan changeset dipindah ke `.changeset-polyglot/` (berisi 2 changeset dengan `justui_cli`/`just_ui_core`), step "Apply Rust CLI version bump" akan dijalankan dan gagal.

**Bukti**

```bash
# apply_changesets_cargo.sh:100-102
awk 'BEGIN{done=0} /^version = "[0-9]+\.[0-9]+\.[0-9]+"/ && !done {
  print "version = \"'"$NEW_VERSION"\""; done=1; next
} {print}' "$CARGO_TOML" > "$TEMP_FILE"
```

```text
$ bash -n tools/apply_changesets_cargo.sh; echo "exit $?"
tools/apply_changesets_cargo.sh: line 107: unexpected EOF while looking for matching `"'
exit 2
# sama di b802627 dan 714c89f (exit 2)

# simulasi alur release di worktree terpisah pada HEAD 1ca735b:
$ dart run tools/apply_changesets.dart
just_ui_core: 0.14.0 → 0.14.1 (patch)
  ✔ Updated packages/core/pubspec.yaml
  ✔ Updated registry/index.json to 0.14.1
$ bash tools/apply_changesets_cargo.sh
justui_cli bump to apply: patch
justui_cli: 0.14.0 → 0.14.1 (patch)
tools/apply_changesets_cargo.sh: line 107: unexpected EOF while looking for matching `"'
```

Terlihat bahwa bash sempat mengeksekusi baris-baris awal sebelum gagal di bagian `awk`. `Cargo.toml` tidak diubah.

**Cara reproduce:** `bash -n tools/apply_changesets_cargo.sh`. Untuk alur lengkapnya: `git worktree add /tmp/rel HEAD && cd /tmp/rel && dart run tools/apply_changesets.dart && bash tools/apply_changesets_cargo.sh`.

**Dampak:** begitu branch ini masuk `main`, job `apply-changesets` gagal di step Rust. Karena step "Commit version bumps" tidak dijalankan, bump Dart yang sudah terjadi pun hilang.

**Saran perbaikan:** ganti bagian `awk` dengan `sed -i.bak -E "0,/^version = \"[0-9]+\.[0-9]+\.[0-9]+\"/s//version = \"$NEW_VERSION\"/" "$CARGO_TOML"`, atau oper versi lewat `awk -v v="$NEW_VERSION" '… print "version = \"" v "\"" …'`. Tambahkan `bash -n tools/*.sh` (atau `shellcheck`) ke CI, plus job dry-run yang menjalankan kedua skrip apply terhadap `.changeset-polyglot/` di setiap PR.

---

<a id="f61"></a>

### #61 — Tes `dart_formatter` mengasumsikan `dart` terpasang, sehingga `CLI — Test` dan `CLI — Coverage` merah

**Tingkat:** Tinggi · **Status:** Baru (putaran 5) · **Area:** CLI Rust (tes) / CI · **File:** `packages/cli/src/utils/dart_formatter.rs:60-99`

**Deskripsi:** perbaikan #56 (`6eed671`) menambahkan `dart format` otomatis setelah file ditulis. Kalau binary `dart` tidak ada, formatter diam-diam dilewati, dan itu memang perilaku yang benar untuk user. Masalahnya, tes `format_and_refresh_metadata_reformats_and_updates_local_hash` mewajibkan isinya berubah. Runner job Rust di CI tidak memasang Dart, jadi tes ini selalu gagal di sana.

**Bukti**

```rust
// dart_formatter.rs:95-98
        assert_ne!(
            meta.local_hash, pre_format_hash,
            "dart format must have changed this deliberately-unformatted input"
        );
```

GitHub Actions run [36422652123](https://github.com/infinitedim/justui/actions/runs/36422652123) (`1ca735b`), job `CLI — Test`:

```text
thread 'utils::dart_formatter::tests::format_and_refresh_metadata_reformats_and_updates_local_hash' panicked at
packages/cli/src/utils/dart_formatter.rs:95:9:
assertion `left != right` failed: dart format must have changed this deliberately-unformatted input
  left: "464f42afd9a5796622e73b2c7ad0c5987fb8473288ea7ff3b406e0a6b8a63160"
 right: "464f42afd9a5796622e73b2c7ad0c5987fb8473288ea7ff3b406e0a6b8a63160"
test result: FAILED. 135 passed; 1 failed
```

Lokal dengan `dart` di PATH hasilnya `136 passed`. Tanpa `dart` di PATH:

```text
$ env PATH=/usr/bin:/bin:$HOME/.cargo/bin cargo test -p justui --lib dart_formatter
assertion `left != right` failed: dart format must have changed this deliberately-unformatted input
test result: FAILED. 1 passed; 1 failed
```

**Cara reproduce:** perintah terakhir di atas, di mesin atau container tanpa Flutter/Dart di PATH.

**Dampak:** dua job CLI di CI merah pada setiap push, termasuk PR yang tidak menyentuh CLI.

**Saran perbaikan:** lewati tes ini kalau `dart` tidak tersedia (cek `which dart` di awal tes lalu `return`, atau `#[ignore]` + job khusus). Atau pasang Flutter di job `CLI — Test`/`Coverage` (`subosito/flutter-action` dengan versi yang sama seperti job Dart).

---

<a id="f62"></a>

### #62 — CI di-pin ke Bun 1.3.11, yang tidak bisa membaca `bun.lock` (lockfileVersion 2)

**Tingkat:** Tinggi · **Status:** Baru (putaran 5) · **Area:** CI docs · **File:** `.github/workflows/ci.yaml:59`, `.github/workflows/release.yaml:30`, `bun.lock:2`

**Deskripsi:** perbaikan #24 (`8ee3139`) mem-pin `bun-version: "1.3.11"`. Masalahnya, `bun.lock` di root ditulis dengan format `lockfileVersion: 2` oleh Bun yang lebih baru (sudah sejak `a8b84fa`, sebelum audit). Bun 1.3.11 menolak format itu, dan `--frozen-lockfile` membuat install gagal. Semua step `nextjs-ci` setelahnya (lint, type-check, vitest, build, E2E) di-skip.

**Bukti**

```text
$ head -3 bun.lock
{
  "lockfileVersion": 2,
  "configVersion": 1,
```

Job `nextjs-ci`, run [36422652123](https://github.com/infinitedim/justui/actions/runs/36422652123):

```text
bun install v1.3.11 (af24e281)
2 |   "lockfileVersion": 2,
                         ^
error: Unknown lockfile version
    at bun.lock:2:22
UnknownLockfileVersion: failed to parse lockfile: 'bun.lock'
warn: Ignoring lockfile
error: lockfile had changes, but lockfile is frozen
##[error]Process completed with exit code 1.
```

**Cara reproduce:** `npx bun@1.3.11 install --frozen-lockfile` di root repo.

**Dampak:**

- `nextjs-ci` merah, dan tidak ada satu pun pengecekan docs yang jalan di CI.
- Karena itu, perbaikan docs putaran ini (#41, #43, #47, #49, …) dan E2E barunya belum pernah diverifikasi oleh CI. Di sandbox audit, lint, tsc, 555 tes vitest, dan build semuanya lulus.
- Job release juga memakai 1.3.11.

**Saran perbaikan:** pin ke versi Bun yang menulis lockfile ini (≥ 1.4.x, sama dengan versi yang dipakai kontributor), dan catat versinya di `package.json` `packageManager` supaya lokal dan CI sama.

---

## Temuan terbuka: Sedang

<a id="f15"></a>

### #15 — Default path berbeda di setiap dokumen

**Tingkat:** Sedang · **Status:** Sebagian (putaran 5) · **Area:** dokumentasi · **File:** `README.md`, `packages/cli/README.md`, `apps/docs/content/docs/**`

**Bukti**

```text
$ grep -rn "lib/ui\b\|lib/ui/\|lib/components/ui\|lib/theme/just_theme.dart" README.md packages/cli/README.md apps/docs/content CONTRIBUTING.md | wc -l
23
# per file:
  2 README.md                       (93: "default: `lib/ui`", 98: "`lib/theme/just_theme.dart`")
  5 packages/cli/README.md          (54, 56, 217, 220: components_dir: lib/ui, shared_dir: lib/ui/shared)
  2+2 content/docs/{en,id}/cli-setup.mdx
  3+3 content/docs/{en,id}/guides/copy-paste-workflow.mdx
  2+2 content/docs/{en,id}/installation.mdx
  1+1 content/docs/{en,id}/quick-start.mdx
```

Nilai yang sebenarnya ditulis `justui init` (app `e2e_app`):

```yaml
components_dir: lib/widgets
tokens_dir: lib/tokens
shared_dir: lib/widgets/shared
# dan file tema: lib/core/theme/just_theme.dart
```

**Cara reproduce:** jalankan perintah `grep` di atas, lalu bandingkan dengan `cat justui.config.yaml` di app hasil `justui init -y`.

**Dampak:** user mencari file di tempat yang salah, dan contoh `justui.config.yaml` di README CLI menghasilkan struktur yang berbeda dari default.

**Saran perbaikan:** jadikan `JustUIConfig::default()` satu-satunya sumber, lalu perbarui ke-23 lokasi. Idealnya, tambahkan tes docs yang mem-parse contoh YAML dan membandingkannya dengan output `justui init -y`.

**Pembaruan putaran 5: sebagian diperbaiki**

Sebagian besar diperbaiki di `1e3b33b` (dari 23 menjadi 6 kemunculan). Sisanya:

```text
apps/docs/content/docs/en/cli-setup.mdx:24     components_dir: lib/components/ui # Component code storage location
apps/docs/content/docs/en/cli-setup.mdx:131    … (for example, `lib/components/ui/bu…
apps/docs/content/docs/en/quick-start.mdx:94   … (for example, `lib/component…
apps/docs/content/docs/id/cli-setup.mdx:24     components_dir: lib/components/ui # Lokasi penyimpanan kode komponen
apps/docs/content/docs/id/cli-setup.mdx:131
apps/docs/content/docs/id/quick-start.mdx:94
```

---

<a id="f25"></a>

### #25 — Pengecekan registry di CI

**Tingkat:** Sedang · **Status:** Sebagian (putaran 5) · **Area:** CI · **File:** `.github/workflows/ci.yaml`, `packages/cli/tests/registry_consistency.rs`

**Sudah ada:** `registry_consistency.rs` (3 tes: import paket, import relatif, `registryDependencies`) ikut jalan di `cargo test` CI. `generate_checksums.dart` menolak deklarasi yang menyimpang.

**Belum ada:**

```text
$ grep -n "generate_checksums\|dry-run\|justui init\|add --all" .github/workflows/*.yaml
(tidak ada hasil)
```

- Tidak ada `dart run tools/generate_checksums.dart --dry-run` di CI untuk mendeteksi drift checksum. Di HEAD statusnya "All files in sync", tapi tidak ada yang menjaga.
- Tidak ada `flutter analyze` atas hasil `justui init && add --all`. Sandbox `apps/showcase` bisa dipakai untuk ini, tapi karena #21 tidak dianalisis di CI.

**Cara memeriksa:** perintah `grep` di atas.

**Dampak:** drift checksum dan kode hasil CLI yang tidak bisa dikompilasi (seperti #01 dulu) tidak tertangkap otomatis.

**Saran perbaikan:** tambahkan job: `generate_checksums.dart --dry-run`, lalu regenerasi `apps/showcase` dengan CLI build PR (AGENTS §6.2) dan jalankan `flutter analyze --fatal-infos && flutter test` di sana.

**Pembaruan putaran 5: sebagian diperbaiki**

- Step "Verify Registry Checksums" (`generate_checksums.dart --dry-run`) sudah ditambahkan di `ci.yaml:40-42`, tapi tidak pernah gagal. Lihat [#63](#f63).
- Belum ada `flutter analyze` atas output `justui init && add --all` (sandbox `apps/showcase` hanya dianalisis apa adanya, tanpa regenerasi dengan CLI dari PR).

---

<a id="f42"></a>

### #42 — Terjemahan tidak konsisten dan navigasi berbeda antarbagian

**Tingkat:** Sedang · **Status:** Sebagian (putaran 5) · **Area:** `apps/docs` (i18n) · **File:** lihat bukti

**Bukti**

```text
$ grep -rn "Search components, docs\|Close search\|No results found\|Cari dokumentasi\|Live Token Playground\|Hex color string\|Click to copy\|\"Notifications\"" apps/docs/src --include=*.tsx | grep -v test
src/components/search.tsx:23                                        placeholder="Cari dokumentasi..."      <- ID untuk semua locale
src/components/organisms/search-modal/search-modal.tsx:102          placeholder="Search components, docs..."
src/components/organisms/search-modal/search-modal.tsx:108          aria-label="Close search"
src/components/organisms/search-modal/search-modal.tsx:129          No results found.
src/app/[lang]/studio/studio-client.tsx:44                          Live Token Playground
src/components/organisms/theme-configurator/theme-configurator.tsx:199  aria-label="Hex color string"
src/components/organisms/theme-configurator/theme-configurator.tsx:295  title={`… - Click to copy`}
src/components/organisms/phone-mockup-canvas/phone-mockup-canvas.tsx:114 aria-label="Notifications"
```

Navigasi docs (`src/lib/layout.shared.tsx:39-44`) hanya berisi "Docs" dan "Components", tanpa terjemahan, tanpa link Studio, dan tanpa preset switcher. Navbar homepage punya semuanya.

**Cara reproduce:** buka `/id` lalu tekan ⌘K/Ctrl K. Placeholder dan "No results found." tampil dalam bahasa Inggris. Buka `/en/docs/introduction`: link navigasi berbeda dari navbar `/en`.

**Dampak:** pengalaman bilingual setengah jadi, dan label aksesibilitas tidak diterjemahkan.

**Saran perbaikan:** pindahkan semua string ke dictionary per locale (pola `getStudioDictionary`), dan bagikan definisi link navbar antara `Navbar` dan `baseOptions`.

**Pembaruan putaran 5: sebagian diperbaiki**

`d44d9ae` sudah menerjemahkan navigasi docs dan mockup ponsel, dan `26774f8` menghapus search modal yang hardcode. Masih tersisa:

```text
theme-configurator.tsx:252   aria-label="Hex color string"
theme-configurator.tsx:350   title={`… - Click to copy`}
studio-client.tsx:52         Live Token Playground
```

---

<a id="f45"></a>

### #45 — State Studio: tema default berkedip, dan umpan balik salin tidak jujur

**Tingkat:** Sedang · **Status:** Sebagian (putaran 5) · **Area:** `apps/docs` (Studio) · **File:** `apps/docs/src/lib/theme-studio-context.tsx:71-80, 128-131`, `apps/docs/src/components/organisms/theme-configurator/theme-configurator.tsx:86-99`, `apps/docs/src/lib/theme/color-resolver.ts:36`

**Bukti**

```tsx
// theme-studio-context.tsx — parameter URL baru dibaca setelah mount
71  useEffect(() => {
73    const parsed = deserializeStudioState(window.location.search);
74    if (parsed.seedColor) setSeedColorState(parsed.seedColor);
…
131        : 'https://justui.vercel.app/en/studio';          // fallback SSR; README memakai docs.justui.dev

// theme-configurator.tsx — "copied" tampil walau gagal
94    if (typeof navigator !== 'undefined' && navigator.clipboard) {
95      navigator.clipboard.writeText(hex).catch(() => {});
96      setCopiedToken(tokenName);

// color-resolver.ts — input tidak valid jatuh ke lime
36  return '#a3e635';
```

```tsx
// studio-client.tsx:24-33 — tombol share gagal diam-diam
      try { await navigator.clipboard.writeText(shareUrl); setCopiedShare(true); … }
      catch { /* Ignore clipboard failure in restricted environments */ }
```

**Cara reproduce**

1. Buka `/en/studio?seed=e11d48&dark=1&preset=neo`. Pada frame pertama tampil tema default (lime, terang, default) sebelum berganti. Ini terlihat jelas dengan throttling CPU 6× di DevTools.
2. Di input hex, hapus isinya lalu ketik `#a3` (belum selesai). Preview dan URL sesaat berubah ke lime `#a3e635`.
3. Buat `navigator.clipboard.writeText` gagal: buka DevTools, jalankan `navigator.clipboard.writeText = () => Promise.reject(new Error('x'))`, lalu klik swatch. Label "copied" tetap muncul walaupun tidak ada yang tersalin. Ini bisa langsung disimpulkan dari kode di baris 95-96, karena `setCopiedToken` dipanggil tanpa menunggu promise.

**Dampak:** link share tidak langsung tampil sesuai isinya, input terasa berkedip, dan umpan balik salin menyesatkan.

**Saran perbaikan:**

- Baca `searchParams` di `page.tsx` (server) dan teruskan sebagai state awal provider.
- Simpan draf input terpisah dari seed yang sudah divalidasi.
- Tampilkan "copied" hanya setelah `writeText` resolve, dan tampilkan pesan gagal di `catch`.
- Samakan domain fallback dengan README.

**Pembaruan putaran 5: sebagian diperbaiki**

`5bb98a8` memperbaiki dua hal:

- **Kedip awal:** `studio/page.tsx:35-65` membaca `searchParams` di server dan mengoper `initialSeedColor` dan kawan-kawan.
- **Salin swatch:** `theme-configurator.tsx:98-102` kini `await writeText` dengan `setCopyFailed` di `catch`.

Masih tersisa:

- Input hex masih menyimpan draf mentah (`handleHexInputChange` → `setSeedColor(val)`), jadi `#a3` sesaat jatuh ke `#a3e635`.
- Tombol share masih gagal diam-diam (`studio-client.tsx:35-37`: `catch { // Ignore clipboard failure … }`).
- Fallback URL masih `https://justui.vercel.app/en/studio` (`theme-studio-context.tsx:132`).

---

<a id="f46"></a>

### #46 — `PresetProvider` mengakses localStorage tanpa pengaman dan menyebabkan kedip

**Tingkat:** Sedang · **Status:** Sebagian (putaran 5) · **Area:** `apps/docs` · **File:** `apps/docs/src/components/providers/preset-provider.tsx:11, 30-48`

**Bukti**

```tsx
30  useEffect(() => {
31    // Read from localStorage on mount -- avoid SSR mismatch
32    const stored = localStorage.getItem(STORAGE_KEY) as JustUIPreset | null;   // tanpa try/catch
…
39  useEffect(() => {
43      document.body.classList.add('theme-neobrutalism');                        // baru setelah mount
47    localStorage.setItem(STORAGE_KEY, preset);                                  // tanpa try/catch
```

```text
$ grep -rn "export type JustUIPreset" apps/docs/src
src/components/providers/preset-provider.tsx:11:export type JustUIPreset = 'default' | 'neobrutalism';
src/lib/theme/color-resolver.ts:1:export type JustUIPreset = 'default' | 'neobrutalism';      <- tipe ganda, state ganda
```

**Cara reproduce**

1. Chrome: Settings → Privacy → "Block all cookies" (ini juga memblokir localStorage), lalu buka `/en`. `getItem` melempar `SecurityError`, dan karena provider membungkus root layout, halaman error.
2. Pilih preset Neobrutalism lalu reload. Sesaat halaman tampil dengan preset default.

**Dampak:** seluruh situs bisa crash di browser dengan storage terblokir, dan pengguna neobrutalism selalu melihat kedipan.

**Saran perbaikan:**

- Bungkus akses storage dengan `try/catch`.
- Set class preset sebelum hydration, lewat script inline kecil di `<head>` atau cookie yang dibaca di server.
- Satukan tipe dan state preset global dengan Studio.

**Pembaruan putaran 5: sebagian diperbaiki**

`3d551ad` membungkus akses storage dengan `try/catch` (`preset-provider.tsx:34, 53`). `app/layout.tsx:49` juga memasang script inline yang menambahkan class `theme-neobrutalism` sebelum hydration, lengkap dengan tes di `test/preset-provider.test.tsx`. Yang tersisa: tipe `JustUIPreset` masih didefinisikan dua kali (`preset-provider.tsx:11` dan `color-resolver.ts:1`), dan state preset global belum tersinkron dengan Studio.

---

<a id="f48"></a>

### #48 — Daftar komponen diketik manual di tiga tempat, dan terminal simulasi menampilkan path yang salah

**Tingkat:** Sedang · **Status:** Sebagian (putaran 5) · **Area:** `apps/docs` · **File:** `apps/docs/src/lib/components-data.ts`, `apps/docs/src/components/organisms/interactive-terminal/{levenshtein.ts,cli-parser.ts}`, `apps/docs/src/lib/search-data.ts`

**Bukti**

```text
# daftar komponen ada di tiga tempat (tidak ada yang diturunkan dari registry/index.json):
src/lib/components-data.ts                                   (katalog)
src/components/organisms/interactive-terminal/levenshtein.ts (REGISTRY_COMPONENT_NAMES)
src/lib/search-data.ts                                       (pencarian)

# cli-parser.ts
156:        { kind: 'info', text: 'Created lib/theme/just_theme.dart' },            <- CLI menulis lib/core/theme/just_theme.dart
255:          text: `Created lib/widgets/${name}/just_${name}.dart`,               <- time-picker -> just_time-picker.dart
```

Path yang sebenarnya ditulis CLI (app `e2e_app`):

```text
lib/core/theme/just_theme.dart
lib/widgets/time-picker/just_time_picker.dart
```

Kategori juga sudah menyimpang dari registry (lihat [#18](#f18)).

**Cara reproduce:** buka terminal interaktif di homepage, ketik `justui init` lalu `justui add time-picker`, dan bandingkan output-nya dengan `ls lib` di app hasil CLI sungguhan.

**Dampak:** docs mengajarkan path yang salah, dan setiap komponen baru harus ditambahkan manual di tiga tempat.

**Saran perbaikan:** generate `components.generated.json` dari `registry/index.json` saat build (nama, kategori, file), lalu pakai di katalog, terminal, dan pencarian. Pakai `files[0]` untuk nama file.

**Pembaruan putaran 5: sebagian diperbaiki**

`f6fa6c7` menambahkan `scripts/generate-components-data.ts`, yang menghasilkan `components.generated.ts` dari `registry/index.json`. Nama, slug, dan kategori kini diambil dari registry, dan `cli-parser.ts:156` sudah menulis `lib/core/theme/just_theme.dart`. Yang tersisa: `cli-parser.ts:255` masih `Created lib/widgets/${name}/just_${name}.dart`, sehingga `time-picker` menjadi `just_time-picker.dart` (seharusnya `just_time_picker.dart`).

---

<a id="f49"></a>

### #49 — Celah pengujian yang membiarkan bug di atas lolos

**Tingkat:** Sedang · **Status:** Sebagian (putaran 5) · **Area:** `apps/docs` (tes) · **File:** `apps/docs/e2e/navigation.spec.ts`, `apps/docs/vitest.config.ts:11`, `apps/docs/test/color-resolver.test.ts`

**Bukti**

```text
$ wc -l apps/docs/e2e/*.ts ; grep -c "test(" apps/docs/e2e/*.ts
29 apps/docs/e2e/navigation.spec.ts
2                                       <- hanya 2 tes E2E

# vitest.config.ts:11 — konten MDX tidak pernah ikut diuji
      'collections/server': path.resolve(…mock…)

# color-resolver.test.ts memakai contrastRatio yang sudah dibulatkan
96      expect(contrastRatio('#000000', '#ffffff')).toBe(21);
```

**Cara memeriksa:** baca file di atas. Tidak ada tes untuk `/fr` (#34), link footer (#41), metadata (#36), snippet (#38), atau ambang kontras exact (#39). Vitest tetap hijau: 25 file, 545 tes.

**Dampak:** CI docs hijau walaupun ada bug kritis di routing dan konten.

**Saran perbaikan:** tambahkan E2E untuk locale tak valid, crawl link internal, dan snapshot `<title>` per halaman. Tambahkan juga unit test kontras memakai rasio exact dan scan seed.

**Pembaruan putaran 5: sebagian diperbaiki**

`1d06416` menambah `e2e/footer-links.spec.ts` (2 tes) dan `e2e/search-dialog.spec.ts` (3 tes), jadi E2E naik dari 2 ke 7 tes. `test/components-data.test.ts` juga menjaga sinkronisasi dengan registry. Masih belum ada tes untuk locale tidak valid / 404 (#34), metadata per halaman (#36), snippet (#38), dan kontras exact (#39). E2E baru ini juga belum pernah jalan di CI karena [#62](#f62).

---

<a id="f55"></a>

### #55 — Kode hasil CLI memicu `unnecessary_import`, sehingga `flutter analyze` user gagal

**Tingkat:** Sedang · **Status:** Sebagian (putaran 5) · **Area:** CLI Rust (import rewriter) · **File:** `packages/cli/src/utils/import_rewriter.rs`, `apps/showcase/analysis_options.yaml`

**Deskripsi:** rewriter menyisakan import spesifik seperti `package:<app>/core/theme/preset_tokens.dart` di samping barrel `package:<app>/core/just_ui_core.dart` yang sudah mengekspornya. `flutter analyze` keluar non-zero walaupun yang ditemukan hanya info.

**Bukti** (app `e2e_app`, `init` neobrutalism/oklch/standard + `add --all`)

```text
$ flutter analyze; echo "exit=$?"
   info • The import of 'package:e2e_app/core/theme/preset_tokens.dart' is unnecessary because all of the used
          elements are also provided by the import of 'package:e2e_app/core/just_ui_core.dart'. … •
          lib/widgets/avatar-group/just_avatar_group.dart:3:8 • unnecessary_import
   info • The import of 'package:e2e_app/core/theme/theme_data.dart' is unnecessary … • just_avatar_group.dart:4:8
   …
47 issues found. (ran in 8.8s)
exit=1
$ grep -c unnecessary_import analyze.txt
47                                        <- semuanya unnecessary_import; 0 error, 0 warning
```

Sandbox `apps/showcase` saat ini mengabaikan diagnostik ini lewat `analyzer: errors: unnecessary_import: ignore`.

**Cara reproduce:** Lampiran A langkah 3, lalu `$JUSTUI add --all -y && flutter pub get && flutter analyze; echo $?`.

**Dampak:** CI user yang memakai `flutter analyze` (default exit non-zero untuk info) gagal setelah instalasi.

**Saran perbaikan:** saat rewrite, hapus import `core/...` spesifik kalau barrel `core/just_ui_core.dart` juga di-import, atau jangan menambahkan barrel. Tambahkan `flutter analyze --fatal-infos` pada sandbox showcase di CI, lalu hapus pengecualian di `analysis_options.yaml`.

**Pembaruan putaran 5: sebagian diperbaiki**

`073d9df` menghapus import yang sudah diekspor barrel `core`. Info `unnecessary_import` turun dari 47 ke 14, tapi `flutter analyze` masih exit 1. Sisanya adalah import `tokens/just_ui_tokens.dart` dan `core/theme/schemes/*`:

```text
lib/widgets/button/just_button.dart:6:8          package:v5_app/tokens/just_ui_tokens.dart          <- sudah di core/just_ui_core.dart
lib/widgets/radio-group/just_radio_group.dart:3:8 package:v5_app/core/theme/schemes/spacing_scheme.dart
lib/widgets/scroll-area/just_scroll_area.dart:12-14 shadow_scheme.dart, spacing_scheme.dart, just_ui_tokens.dart
lib/widgets/separator/just_separator.dart:4-5     spacing_scheme.dart, typography_scheme.dart
… (+ bottom-nav, icon-button, shared/just_focus_indicator, sheet, sidebar)
14 issues found.
```

---

<a id="f63"></a>

### #63 — Registry drift (`just_progress.dart`), dan `generate_checksums.dart --dry-run` tetap exit 0

**Tingkat:** Sedang · **Status:** Baru (putaran 5) · **Area:** registry / CI · **File:** `registry/components/progress/default/just_progress.dart`, `tools/generate_checksums.dart`, `.github/workflows/ci.yaml:40-42`

**Deskripsi:**

- Commit `e0ab51f` memperbaiki import Material di `packages/core/.../just_progress.dart` (#17), tapi registry tidak disinkronkan. User yang menjalankan `justui add progress` masih menerima versi lama.
- Step CI baru "Verify Registry Checksums" tidak menangkapnya, karena `--dry-run` hanya mencetak peringatan lalu keluar dengan kode 0.

**Bukti**

```text
$ diff registry/components/progress/default/just_progress.dart packages/core/lib/src/components/progress/just_progress.dart
3c3,4
< import 'package:flutter/material.dart';
---
> import 'package:flutter/material.dart' show Theme;
> import 'package:flutter/widgets.dart';

$ dart run tools/generate_checksums.dart --dry-run; echo "exit $?"
    [WARNING] components/progress/default/just_progress.dart differs from core source.
Drift summary (1 file(s)):
  - components/progress/default/just_progress.dart
Status: Differences detected between registry and core source.
exit 0
```

**Cara reproduce:** kedua perintah di atas dari root repo.

**Dampak:** step verifikasi di CI hijau palsu, dan registry yang dipakai user tertinggal dari core.

**Saran perbaikan:** jalankan `dart run tools/generate_checksums.dart` lalu commit hasilnya. Ubah skrip agar `exit(1)` kalau drift terdeteksi di mode `--dry-run` (atau tambahkan flag `--check`).

---

## Temuan terbuka: Rendah

<a id="f56"></a>

### #56 — Output CLI tidak mengikuti `dart format`

**Tingkat:** Rendah · **Status:** Sebagian (putaran 5) · **Area:** CLI Rust · **File:** `packages/cli/src/commands/init.rs` (template tema), `packages/cli/src/utils/import_rewriter.rs`, `constructor_transpiler.rs`

**Deskripsi:** 51 dari 154 file hasil `init` + `add --all` berubah saat di-`dart format`. Memformat file mengubah isinya, sehingga hash `local=` di header `justui-meta` tidak lagi cocok dan CLI menganggap file itu dimodifikasi user.

**Bukti** (app `e2e_app`)

```text
$ dart format --output=none --set-exit-if-changed lib; echo "exit=$?"
Changed lib/core/overlay/just_overlay_scope.dart
Changed lib/core/theme/just_theme.dart
Changed lib/core/theme/schemes/shadow_scheme.dart
…
Formatted 154 files (51 changed) in 1.02 seconds.
exit=1

# setelah `dart format lib/widgets/accordion/just_accordion.dart` (hanya menghapus satu baris kosong):
$ justui diff accordion
✓ just_accordion_style.dart: Up to date.
✓ just_accordion_theme.dart: Up to date.
✓ just_accordion_variants.dart: Up to date.
⚠ Warning: just_accordion.dart: Modified locally.
│ @@ -2,7 +2,6 @@
│  import 'package:e2e_app/core/just_ui_core.dart';
│ -
│  import '../shared/just_focus_indicator.dart';
```

**Cara reproduce:** Lampiran A langkah 3, lalu `$JUSTUI add --all -y`, `dart format lib`, dan `$JUSTUI diff accordion`.

**Dampak:** user yang menjalankan `dart format` (atau format-on-save di IDE) langsung membuat semua komponen dianggap dimodifikasi. `justui update` kemudian akan meminta konfirmasi atau melewati file yang sebenarnya tidak diubah.

**Saran perbaikan:** format output di CLI (panggil `dart format` di akhir `init`/`add` bila tersedia, atau hasilkan teks yang sudah sesuai formatter), dan hitung hash `local=` **setelah** format. Alternatifnya, normalisasi whitespace sebelum hashing.

**Pembaruan putaran 5: sebagian diperbaiki**

`6eed671` menjalankan `dart format` pada file hasil `add` dan memperbarui hash `local=`. Hasilnya, file yang berubah saat diformat turun dari 51 ke 3. Sisanya berasal dari template `init` yang tidak ikut diformat:

```text
$ dart format --output=none --set-exit-if-changed lib
Changed lib/core/overlay/just_overlay_scope.dart
Changed lib/core/theme/schemes/shadow_scheme.dart
Changed lib/core/theme/theme_data_material.dart
Formatted 157 files (3 changed)
```

Tes untuk fitur ini membuat CI merah di runner tanpa Dart. Lihat [#61](#f61).

---

## Diperbaiki di putaran 5

Diperbaiki oleh 19 commit `b802627..1ca735b` dan diverifikasi ulang di HEAD `1ca735b`. Bagian atas setiap temuan adalah kondisi sebelum perbaikan; bukti perbaikannya ada di blok "Pembaruan putaran 5".

<a id="f21"></a>

### #21 — Melos 8 mengabaikan `melos.yaml`: job Dart di CI hijau tanpa menjalankan apa pun

**Tingkat:** Tinggi (naik dari Sedang) · **Status:** Selesai (putaran 5) · **Area:** CI / tooling Dart · **File:** `pubspec.yaml`, `melos.yaml`, `.github/workflows/ci.yaml:36-50`

**Deskripsi**

Root `pubspec.yaml` memakai `melos: ^8.7.0`. Sejak Melos 7, konfigurasi dibaca dari `pubspec.yaml` (kunci `melos:` + Pub Workspaces `workspace:`), bukan dari `melos.yaml`. Karena root pubspec tidak punya `workspace:`, Melos tidak menemukan paket apa pun. Semua `melos exec` di CI berjalan di 0 paket dan selalu melaporkan SUCCESS.

**Bukti**

```yaml
# pubspec.yaml (root): tidak ada `workspace:` maupun `melos:`
name: justui
environment:
  sdk: ">=3.13.0 <4.0.0"
dev_dependencies:
  melos: ^8.7.0
```

Lokal (`dart run melos …` di root):

```text
$ dart run melos list
No packages were found with the current filters.

$ dart run melos bootstrap
 -> 0 packages bootstrapped

$ dart run melos exec --flutter --dir-exists=test -- "flutter test"
$ melos exec
  └> flutter test
     └> SUCCESS            (exit 0)
```

GitHub Actions, run [36379689330](https://github.com/infinitedim/justui/actions/runs/36379689330) di commit `b802627`, job `dart-flutter-ci`:

```text
04:55:36  Static Analysis   -> selesai dalam 1 detik
04:55:37  Run Tests         -> selesai dalam 1 detik
$ melos exec
  └> dart test
     └> RUNNING (in 0 packages)
     └> SUCCESS
```

**Cara reproduce**

1. Di root repo: `dart pub get && dart run melos list`. Hasilnya "No packages were found".
2. `dart run melos exec --flutter --dir-exists=test -- "flutter test"` langsung SUCCESS tanpa output tes.
3. Bandingkan dengan `cd packages/core && flutter test`: 357 lulus, 72 gagal (lihat #54).
4. Catatan: `melos bootstrap` menulis ulang `.idea/runConfigurations/*.xml`, jadi kembalikan dengan `git checkout .idea` setelah mencoba.

**Dampak**

- Tidak ada analisis statis maupun tes Dart/Flutter yang dijalankan di CI.
- Regresi Flutter (termasuk 75 tes gagal di #54) lolos ke `main` dengan badge hijau.
- Satu-satunya pengecekan Dart yang benar-benar jalan adalah `dart format`.

**Saran perbaikan**

- Migrasi ke Pub Workspaces: tambahkan `workspace: [packages/tokens, packages/core, apps/preview, apps/showcase]` di root pubspec, `resolution: workspace` di setiap paket, lalu pindahkan isi `melos.yaml` ke kunci `melos:` di root pubspec dan hapus `melos.yaml`.
- Tambahkan guard di CI yang gagal kalau jumlah paket 0 (misalnya `melos list --json | jq length`).

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `0c3b5a6` (migrasi ke Pub Workspaces).

- Root `pubspec.yaml` kini punya `workspace: [packages/tokens, packages/core, apps/preview, apps/showcase]` dan kunci `melos:`, setiap paket punya `resolution: workspace`, dan `melos.yaml` dihapus.

```text
$ dart run melos list
just_ui_core
just_ui_tokens
preview
showcase
```

- Di CI (run [36422652123](https://github.com/infinitedim/justui/actions/runs/36422652123)), step "Static Analysis" sekarang berjalan 22 detik dan "Run Tests" 48 detik, lalu **gagal**. Ini hasil yang benar, karena kegagalan #54 kini terlihat.

---

<a id="f22"></a>

### #22 — Pipeline Changesets rusak: kedua changeset yang ada ditolak, job release akan gagal

**Tingkat:** Tinggi · **Status:** Selesai (putaran 5) · **Area:** release · **File:** `.changeset/config.json`, `.changeset/fix-critical-cli-install.md`, `.changeset/low-severity-cleanup.md`, `.github/workflows/release.yaml:63-65`

**Deskripsi**

Changesets hanya mengenal paket npm di workspace Bun, yaitu `justui` (root) dan `docs`. Dua changeset yang ada memakai key paket Dart/Rust:

- `"justui_cli"` di `fix-critical-cli-install.md`;
- `"just_ui_core"` di `low-severity-cleanup.md`, yang ditulis di batch rendah (kesalahan saya pada putaran sebelumnya).

Blok `"packages": {...}` di `config.json` bukan opsi Changesets dan diabaikan.

**Bukti**

```text
$ bun changeset version            # atau: node node_modules/@changesets/cli/bin.js version
🦋 changeset v3.0.3
Error: Found changeset fix-critical-cli-install for package justui_cli which is not in the workspace
🦋 Exited with code 1

# setelah fix-critical-cli-install.md dipindahkan sementara:
Error: Found changeset low-severity-cleanup for package just_ui_core which is not in the workspace
🦋 Exited with code 1
```

```yaml
# release.yaml (jalan pada push ke main)
- name: Generate changelogs
  if: steps.check-changesets.outputs.count != '0'
  run: bun changeset version
```

**Cara reproduce**

1. Di salinan repo (perintah ini memodifikasi file): `bun install && bun changeset version`.
2. Pindahkan `fix-critical-cli-install.md` keluar dari `.changeset/` lalu ulangi. Error kedua muncul.

**Dampak**

- Begitu branch ini masuk `main`, job `apply-changesets` gagal di step "Generate changelogs".
- Bump versi dari `apply_changesets.dart` dan `apply_changesets_cargo.sh` sebelumnya tidak pernah ter-commit.
- Changelog tidak ter-generate.

**Saran perbaikan:** pilih salah satu.

- (a) Keluarkan changeset non-npm dari Changesets dan biarkan skrip Dart/Cargo membaca format sendiri, misalnya di folder `.changeset-polyglot/`.
- (b) Beri setiap paket `package.json` bayangan (`private: true`) dengan nama `just_ui_core`, `just_ui_tokens`, dan `justui_cli`, lalu daftarkan di `workspaces`.

Apa pun pilihannya, tambahkan `bun changeset status` ke CI PR.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `0c3b5a6`.

- Changeset Dart/Rust dipindah ke `.changeset-polyglot/`, dan blok `packages` yang tidak sah dihapus dari `.changeset/config.json`.
- `release.yaml` kini menghitung `npm_count` dan `poly_count` terpisah; `bun changeset version` hanya jalan kalau ada changeset npm.

Simulasi di worktree terpisah:

```text
$ dart run tools/apply_changesets.dart
just_ui_core: 0.14.0 → 0.14.1 (patch)
  ✔ Updated packages/core/pubspec.yaml
  ✔ Updated registry/index.json to 0.14.1
```

**Catatan:** step berikutnya, `apply_changesets_cargo.sh`, gagal karena bug sintaks lama yang sekarang baru terlihat. Lihat [#60](#f60).

---

<a id="f58"></a>

### #58 — `rustls 0.23.43` rentan (RUSTSEC-2026-0285), job `cargo audit` merah

**Tingkat:** Tinggi · **Status:** Selesai (putaran 5) · **Area:** CLI Rust (dependency) · **File:** `Cargo.lock`

**Deskripsi**

`cargo audit --deny warnings` di CI gagal karena `rustls` 0.23.43 (dependency transitif `reqwest`) terkena advisory RUSTSEC-2026-0285: "TLS 1.3 handshake messages incorrectly accepted across encryption level boundaries" (CVSS 5.3, medium). Perbaikannya tersedia di ≥ 0.23.45.

**Bukti**

```text
# Cargo.lock
name = "rustls"
version = "0.23.43"
```

Log job `CLI — Cargo Audit`, run [36379689330](https://github.com/infinitedim/justui/actions/runs/36379689330):

```text
error: 1 vulnerability found!
Crate:    rustls
Version:  0.23.43
Title:    TLS 1.3 handshake messages incorrectly accepted across encryption level boundaries
ID:       RUSTSEC-2026-0285
Severity: 5.3 (medium)
Solution: Upgrade to >=0.23.45
##[error]Process completed with exit code 1.
```

**Cara reproduce**

```bash
grep -A1 '^name = "rustls"$' Cargo.lock
cargo install cargo-audit && cargo audit --deny warnings
```

**Dampak:** CLI melakukan unduhan registry dan self-upgrade lewat TLS. Selain itu, CI di branch ini merah karena job ini.

**Saran perbaikan:** jalankan `cargo update -p rustls` (atau `cargo update`), commit `Cargo.lock`, lalu pastikan `cargo audit` hijau. Pertimbangkan Dependabot untuk `cargo` di root (lihat #26).

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `0c3b5a6`.

```text
$ grep -A1 '^name = "rustls"$' Cargo.lock
name = "rustls"
version = "0.23.45"
```

Job `CLI — Cargo Audit` di run [36422652123](https://github.com/infinitedim/justui/actions/runs/36422652123) **hijau**.

---

<a id="f14"></a>

### #14 — AGENTS.md: sudah dirombak, tapi masih ada klaim yang salah

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** dokumentasi · **File:** `AGENTS.md`

**Sudah benar:** path `packages/core` dan `tokens`, CLI Rust, `lib/widgets`, penjelasan transpiler, routing docs (§5.1), stage bridge tanpa iframe (§5.2), dan `apps/showcase` sebagai sandbox (§6.2, §13.3).

**Masih salah** (`grep -n` di HEAD):

```text
263, 266, 313, 318, 319, 391, 417   /home/yourblooo/development/justui/.home   <- path mesin pribadi
352   Update `init_command.rs` in `packages/cli`            <- file sebenarnya packages/cli/src/commands/init.rs
65, 67, 69, 71, 249, 251, 253, 255   "ightarrow$"         <- "\rightarrow" rusak jadi pindah baris + "ightarrow$"
77    … eliminating object allocations across build loops  <- tidak benar, lihat #06
363   Docs Unit Tests … `apps/docs/src/**/__tests__/`       <- lokasi sebenarnya apps/docs/test/
```

**Cara memeriksa:**

```bash
grep -n "/home/yourblooo\|init_command.rs\|ightarrow\|eliminating object\|__tests__" AGENTS.md
ls packages/cli/src/commands/ | grep init; ls apps/docs/test | head -3
```

**Dampak:** agen AI dan kontributor mengikuti instruksi yang salah (path HOME yang tidak ada, file yang tidak ada), dan tabel routing tidak terbaca.

**Saran perbaikan:** ganti path dengan `$PWD/.home` atau variabel, perbaiki nama file, ganti `$\rightarrow$` dengan `→`, dan koreksi klaim cache serta lokasi tes. Lihat juga #57.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `2d738e5`. Perintah pemeriksaan sekarang tidak menemukan apa pun:

```text
$ grep -n "/home/yourblooo\|init_command.rs\|ightarrow\|eliminating object\|__tests__" AGENTS.md
(tidak ada hasil)
```

---

<a id="f16"></a>

### #16 — README tidak lengkap

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** dokumentasi · **File:** `README.md:39-56, 125-156`

**Bukti**

```text
# Registry: 33 komponen publik (bukan internal/tokens/core)
$ python3 -c "import json;d=json.load(open('registry/index.json'));print(len([c for c in d['components'] if not c.get('internal') and c.get('category') not in ('tokens','core')]))"
33

# README "Available Components": hanya 16
Primitives:  button · icon-button · input · badge · avatar · checkbox · radio · switch
Layout:      card · separator · skeleton · scroll-area
Navigation:  tabs · breadcrumb · sidebar · bottom-nav

# Tabel "All CLI Commands": init, add, list, search, info, view, diff, update, create
# main.rs juga punya: Version (58), Preset (108), Upgrade (245), Doctor (259)  -> tidak ada di README

# Struktur monorepo menyebut folder yang tidak ada:
README.md:52  └── docs/                # Phase specs and architecture decisions
$ ls -d docs
ls: cannot access 'docs': No such file or directory
```

**Cara memeriksa:** perintah di atas, ditambah `grep -nE "^\s+(Version|Preset|Upgrade|Doctor)" packages/cli/src/main.rs`.

**Dampak:** README (halaman GitHub dan npm) menyembunyikan separuh komponen dan empat command.

**Saran perbaikan:** generate daftar komponen dari `index.json` (skrip di `tools/`), lengkapi tabel command, dan hapus `docs/` dari diagram.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `dc643f5`. README kini mencantumkan 33 komponen dan command `preset`, `upgrade`, dan `doctor` (baris 137-139). Folder `docs/` fiktif sudah dihapus dari diagram struktur.

---

<a id="f17"></a>

### #17 — CONTRIBUTING menyebut aturan "enforced in CI" yang tidak pernah dicek

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** dokumentasi / kualitas kode · **File:** `CONTRIBUTING.md:27, 122-190`

**Deskripsi:** `CONTRIBUTING.md:122` menulis "These rules are enforced in CI and in code review. PRs that violate them will not be merged." CI tidak mengecek satu pun aturan itu (dan dengan #21, bahkan `flutter analyze` tidak jalan), dan kode di `packages/core` melanggar beberapa di antaranya.

**Bukti** (`packages/core/lib/src/components`, HEAD)

| Aturan CONTRIBUTING                           | Pemeriksaan                                                                                                | Hasil                           |
| --------------------------------------------- | ---------------------------------------------------------------------------------------------------------- | ------------------------------- |
| §4.A Material import wajib `show`             | `grep -rn "^import 'package:flutter/material.dart';"`                                                      | `progress/just_progress.dart:3` |
| Baris 27, "no hardcoded values"               | `grep -rn "Color(0x" \| wc -l`                                                                             | 60                              |
| Baris 27, "no hardcoded values"               | `grep -rn "Duration(milliseconds" \| wc -l`                                                                | 29                              |
| §4.D `ValueNotifier` alih-alih `setState`     | `setState(` vs `ValueNotifier`                                                                             | 53 vs 13                        |
| §4.F `RepaintBoundary` di komponen beranimasi | file dengan `AnimationController\|AnimatedContainer\|AnimatedBuilder` vs yang juga punya `RepaintBoundary` | 23 vs 11                        |
| §4.G aspek, bukan theme penuh                 | lihat #07                                                                                                  | 50 pemanggilan                  |

**Cara memeriksa:** jalankan perintah di tabel dari `packages/core/lib/src/components`.

**Dampak:** kontributor diberi klaim palsu tentang penjaga kualitas, dan kode referensi sendiri tidak memenuhi aturan.

**Saran perbaikan:** ubah kalimat menjadi "diperiksa saat code review", atau implementasikan pengecekannya (custom lint via `custom_lint` / skrip grep di CI). Setelah itu bereskan pelanggaran yang ada.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `e0ab51f`.

- `CONTRIBUTING.md:122` kini berbunyi "These are our conventions, checked in code review. CI currently only runs …".
- Pelanggaran import Material di `just_progress.dart` diperbaiki (`show Theme`).

Pelanggaran konvensi lain (hardcoded color/duration, `setState`) sekarang dinyatakan jujur sebagai konvensi review, bukan aturan yang dicek CI.

**Catatan:** perubahan `just_progress.dart` belum disinkronkan ke registry. Lihat [#63](#f63).

---

<a id="f18"></a>

### #18 — Kategori di registry dan di docs tidak sama

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** registry + `apps/docs` · **File:** `registry/index.json`, `apps/docs/src/lib/components-data.ts`

**Bukti** (skrip Python yang mencocokkan `slug` dan `category` di kedua file)

```text
icon-button: registry=composite docs=primitive
slider:      registry=forms     docs=form
table:       registry=primitive docs=composite
```

**Cara reproduce**

```bash
python3 - <<'EOF'
import json,re
d={x['name']:x.get('category') for x in json.load(open('registry/index.json'))['components']}
src=open('apps/docs/src/lib/components-data.ts').read()
for s,c in re.findall(r"slug: '([\w-]+)',[^}]*?category: '(\w+)'",src,re.S):
    if s in d and d[s]!=c: print(f'{s}: registry={d[s]} docs={c}')
EOF
```

**Dampak:** filter kategori di katalog, `justui list --category`, dan `justui search` memberi hasil berbeda.

**Saran perbaikan:** turunkan kategori docs dari registry (#48), lalu tentukan satu kosakata (`forms` atau `form`).

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `f6fa6c7`. Kategori kini diambil dari `registry/index.json` lewat `components.generated.ts`, dan tesnya ada di `test/components-data.test.ts`.

```text
$ python3 (skrip pembanding di atas)
mismatch: []
```

---

<a id="f19"></a>

### #19 — CHANGELOG berhenti di 0.6.0 dan isinya tidak sesuai kode

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** dokumentasi / release · **File:** `CHANGELOG.md`

**Bukti**

```text
CHANGELOG.md:7    ## [0.6.0] - 2026-08-18                              <- entri terbaru
packages/cli/Cargo.toml:3      version = "0.14.0"
packages/core/pubspec.yaml:3   version: 0.14.0

CHANGELOG.md:20   Migrated the security scanning workflow job in CI from `cargo-deny` to `trivy` …
$ grep -c trivy .github/workflows/*.yaml            -> 0 di ketiga workflow

CHANGELOG.md:22   Upgraded … `reqwest` to 0.13 …
packages/cli/Cargo.toml:21     reqwest = { version = "0.12", … }
```

**Cara memeriksa:** perintah `grep`/`sed` di atas.

**Dampak:** delapan minor version tanpa catatan rilis, dan catatan yang ada pun keliru. Ini juga gejala dari #22.

**Saran perbaikan:** perbaiki pipeline changesets (#22), lalu tulis ulang entri 0.7–0.14 dari `git log`.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `978864e`. CHANGELOG kini berisi entri 0.7.0 sampai 0.14.0 (`## [0.14.0] - 2026-09-13` di baris 7). Klaim trivy dan reqwest 0.13 masih ada di entri historis 0.5.0 (baris 105, 107). Karena itu catatan masa lalu, tidak dianggap blocker.

---

<a id="f20"></a>

### #20 — Folder preset registry berisi duplikat, dan file shared saling timpa

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** registry · **File:** `registry/components/*/{default,neobrutalism}/`, `registry/components/shared/default/`, `registry/index.json`

**Deskripsi**

1. Semua file yang ada di `default/` dan `neobrutalism/` identik byte per byte. Pemisahan per preset tidak memberi nilai, tapi menggandakan checksum dan ukuran.
2. **Diperbarui:** klaim sebelumnya bahwa file group untuk `button`, `avatar`, dan `radio` hanya ada di `default/` sudah tidak berlaku; kedua folder kini lengkap.
3. **Baru:** komponen shared punya dua versi file dengan isi berbeda (`_shared_X.dart` dan `just_X.dart`). Keduanya didaftarkan, lalu dinormalisasi ke nama lokal yang sama, sehingga file kedua menimpa yang pertama tanpa peringatan.

**Bukti**

```text
# (1) perbandingan filecmp semua pasangan default/ vs neobrutalism/
pasangan identik 39 berbeda 0
hanya di default: []

# (3) index.json, komponen _shared_pressable
"default": [
  {"name": "just_pressable.dart",    "path": "components/shared/default/just_pressable.dart",    "checksum": "sha256:0a91c2…"},
  {"name": "_shared_pressable.dart", "path": "components/shared/default/_shared_pressable.dart", "checksum": "sha256:c1670f…"}
]
# jumlah baris berbeda antar pasangan (diff | grep -c '^[<>]'):
pressable: 8   focus_indicator: 24   overlay_transition: 8   progress_spinner: 8   tooltip_overlay: 0

$ diff registry/components/shared/default/_shared_pressable.dart registry/components/shared/default/just_pressable.dart
52c52
<     _statesListenable = .merge(<Listenable?>[
---
>     _statesListenable = .merge([
…

# di app hasil CLI hanya ada satu file, berisi versi _shared_ (yang terakhir ditulis):
$ ls lib/widgets/shared/
just_focus_indicator.dart  just_overlay_transition.dart  just_pressable.dart  just_progress_spinner.dart  just_tooltip_overlay.dart
$ grep -c "<Listenable?>\[" lib/widgets/shared/just_pressable.dart
1
```

**Cara reproduce:** jalankan perbandingan `filecmp` (atau `diff -rq registry/components/button/default registry/components/button/neobrutalism`), `diff` pasangan shared di atas, lalu `justui add button` dan periksa isi `lib/widgets/shared/just_pressable.dart`.

**Dampak:** ukuran dan checksum registry dua kali lipat tanpa manfaat. File mana yang dipasang bergantung pada urutan array di `index.json`, sehingga `diff`/`update` bisa membandingkan dengan file yang salah.

**Saran perbaikan:**

- Simpan file preset hanya kalau memang berbeda (fallback ke `default/`).
- Pilih satu penamaan shared, hapus duplikatnya, lalu tambahkan cek di `generate_checksums.dart` dan `registry_consistency.rs` agar tidak ada dua file yang dinormalisasi ke nama lokal yang sama.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `38af1d7`.

```text
$ find registry/components -type d -name neobrutalism | wc -l
0                                         <- file preset identik dihapus; CLI jatuh ke default/
$ ls registry/components/shared/default/
_shared_focus_indicator.dart  _shared_overlay_transition.dart  _shared_pressable.dart  _shared_progress_spinner.dart  _shared_tooltip_overlay.dart
# index.json `_shared_pressable` -> hanya satu entri: _shared_pressable.dart
```

`add --all` dengan preset neobrutalism tetap menghasilkan 157 file dan 0 error `flutter analyze`.

---

<a id="f23"></a>

### #23 — Cache Cargo di CI menyimpan folder yang salah

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** CI · **File:** `.github/workflows/ci.yaml:115, 149, 203, 235, 268`

**Bukti**

```text
$ grep -n "target" .github/workflows/ci.yaml
115:            packages/cli/target
149:            packages/cli/target
203:            packages/cli/target
235:            packages/cli/target
268:            packages/cli/target

$ head -2 Cargo.toml
[workspace]
members = ["packages/cli"]            <- build workspace masuk ke ./target
$ ls -d target packages/cli/target
ls: cannot access 'packages/cli/target': No such file or directory
target
```

**Cara reproduce:** `cargo build` di root, lalu `ls -d target packages/cli/target`.

**Dampak:** cache build tidak pernah dipulihkan, sehingga setiap job Rust mengompilasi ulang dari nol (±30–90 detik per job, 5 job).

**Saran perbaikan:** ganti path cache ke `target`, atau pakai `Swatinem/rust-cache@v2`.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `8ee3139`. Path cache di `ci.yaml` (baris 117, 151, 205, 237) kini `target`.

---

<a id="f24"></a>

### #24 — Sisa debugging dan versi tool yang tidak di-pin

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** CI / release · **File:** `.github/workflows/release.yaml:30, 38, 121`, `.github/workflows/ci.yaml:20, 62`, `.fvmrc`

**Bukti**

```text
release.yaml:121:      - name: Debug — find binary
ci.yaml:20:          channel: "stable"
ci.yaml:62:          bun-version: latest
release.yaml:30:          bun-version: latest
release.yaml:38:          channel: "stable"
$ cat .fvmrc
{ "flutter": "stable" }
```

**Cara memeriksa:** `grep -n -i "debug\|bun-version\|channel:" .github/workflows/*.yaml; cat .fvmrc`.

**Dampak:** build tidak reprodusibel. Contoh nyata: Flutter di CI berpindah ke 3.47.5 tanpa perubahan di repo. Step debug membocorkan struktur runner ke log rilis.

**Saran perbaikan:** pin `flutter-version`, `bun-version`, dan versi di `.fvmrc`, lalu hapus step debug.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `8ee3139`.

```text
ci.yaml:20       flutter-version: "3.47.5"
ci.yaml:59       bun-version: "1.3.11"
release.yaml:30  bun-version: "1.3.11"
release.yaml:38  flutter-version: "3.47.5"
.fvmrc           { "flutter": "3.47.5" }
```

Step "Debug — find binary" sudah dihapus.

**Catatan:** pin Bun 1.3.11 terlalu lama untuk `bun.lock`. Lihat [#62](#f62).

---

<a id="f26"></a>

### #26 — Dependabot tidak sesuai struktur repo

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** CI · **File:** `.github/dependabot.yml`

**Bukti**

```yaml
- package-ecosystem: "npm"
  directory: "/apps/docs" # lockfile ada di root: bun.lock; apps/docs/bun.lock tidak ada
- package-ecosystem: "cargo"
  directory: "/packages/cli" # Cargo.lock ada di root workspace
- package-ecosystem: "pub"
  directory: "/apps/showcase" # ada, tapi /apps/preview tidak terdaftar
```

```text
$ ls bun.lock apps/docs/bun.lock
ls: cannot access 'apps/docs/bun.lock': No such file or directory
bun.lock
```

**Cara memeriksa:** `cat .github/dependabot.yml; ls bun.lock apps/docs/bun.lock Cargo.lock packages/cli/Cargo.lock`.

**Dampak:** update keamanan untuk dependency docs dan Rust tidak diusulkan dengan benar. Contohnya `rustls` di #58, yang baru ketahuan dari `cargo audit`.

**Saran perbaikan:** set npm/bun ke `/`, cargo ke `/`, dan tambahkan `pub` untuk `/apps/preview`.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `8ee3139`. `.github/dependabot.yaml` kini mengarahkan `cargo` dan `npm` ke `/`, dan menambahkan `pub` untuk `/apps/preview`.

---

<a id="f41"></a>

### #41 — Link internal rusak

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** `apps/docs` · **File:** `apps/docs/src/components/organisms/footer/footer.tsx:114`, `apps/docs/content/docs/{en,id}/{introduction,quick-start}.mdx`

**Deskripsi**

- Footer mengarah ke `/{lang}/docs/cli`, padahal halamannya `cli-setup`.
- Empat file MDX memakai link tanpa locale (`/docs/installation`), yang di-redirect ke versi Inggris.

**Bukti**

```tsx
// footer.tsx:114
                  href={`/${lang}/docs/cli`}
```

```text
$ ls apps/docs/content/docs/en | grep -i cli
cli-setup.mdx

$ curl -s -o /dev/null -w '%{http_code}\n' http://localhost:3470/en/docs/cli          -> 404
$ curl -s -o /dev/null -w '%{http_code}\n' http://localhost:3470/en/docs/cli-setup    -> 200

# halaman hasil build yang memuat link footer rusak:
$ grep -rlE 'href="/(en|id)/docs/cli"' .next/server/app --include=*.html
en.html  id.html  en/components.html  id/components.html  en/studio.html  id/studio.html

# link MDX tanpa locale:
content/docs/en/introduction.mdx:18  [Installation](/docs/installation)
content/docs/en/quick-start.mdx:12   [Installation](/docs/installation)
content/docs/id/introduction.mdx:18  [Instalasi](/docs/installation)
content/docs/id/quick-start.mdx:12   [Instalasi](/docs/installation)
$ curl -s -o /dev/null -w '%{http_code} %{redirect_url}\n' http://localhost:3470/docs/installation
307 http://localhost:3470/en/docs/installation                <- pembaca /id dilempar ke bahasa Inggris
```

**Cara reproduce:** perintah di atas pada server lokal (Lampiran A). Di browser: buka `/id/docs/introduction`, klik "Instalasi", dan URL menjadi `/en/docs/installation`.

**Dampak:** link footer yang tampil di halaman utama berakhir 404, dan pembaca bahasa Indonesia berpindah bahasa tanpa sadar.

**Saran perbaikan:** ganti ke `/${lang}/docs/cli-setup`, pakai link relatif (`./installation`) di MDX, dan tambahkan crawler link di E2E (#49).

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `08ea987`. `footer.tsx:116` kini `/${lang}/docs/cli-setup`, dan link MDX memakai locale.

```text
$ curl -s -o /dev/null -w '%{http_code}' http://localhost:3480/en/docs/cli-setup   -> 200
$ grep -o 'href="/id/docs/installation"' .next/server/app/id/docs/introduction.html
href="/id/docs/installation"
```

E2E baru: `e2e/footer-links.spec.ts`.

---

<a id="f43"></a>

### #43 — Dua sistem pencarian dengan kualitas berbeda

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** `apps/docs` · **File:** `apps/docs/src/components/organisms/search-modal/search-modal.tsx`, `apps/docs/src/lib/search-data.ts`, `apps/docs/src/components/search.tsx`

**Deskripsi**

- Homepage, katalog, dan studio memakai `SearchModal`, yang hanya mencocokkan judul dari daftar statis `search-data.ts`.
- Halaman docs memakai pencarian full-text fumadocs lewat `/api/search`.
- `CustomSearchDialog` (`search.tsx`) hanya dipakai di tes.
- `SearchModal` tidak punya focus trap, tidak mengembalikan fokus ke pemicu, dan tidak memakai pola combobox/listbox.

**Bukti**

```text
$ grep -rn "CustomSearchDialog\|from '@/components/search'" apps/docs/src apps/docs/test
src/components/search.tsx:16:export default function CustomSearchDialog(props: SharedProps) {
test/search.test.tsx:3:import CustomSearchDialog from '../src/components/search';     <- hanya tes

$ grep -n "role=\|aria-activedescendant\|focus()" apps/docs/src/components/organisms/search-modal/search-modal.tsx
45:    inputRef.current?.focus();
91:        role="dialog"                   <- tidak ada role=combobox/listbox/option, tidak ada aria-activedescendant
```

**Cara reproduce**

1. Di `/en`, tekan Ctrl K dan ketik kata yang hanya muncul di isi halaman docs, bukan di judul (misalnya "dot shorthand"). `SearchModal` hanya mencocokkan daftar judul di `search-data.ts`, jadi hasilnya kosong.
2. Bandingkan dengan `curl 'http://localhost:3470/api/search?query=dot%20shorthand'`, yang dipakai pencarian di halaman docs dan mencari di isi halaman.
3. Buka modal di homepage lalu tekan Tab berulang. Fokus keluar dari modal ke halaman di belakangnya.

**Dampak:** hasil pencarian bergantung pada halaman tempat user berada, dan user screen reader tidak tahu item mana yang terpilih.

**Saran perbaikan:** pakai satu backend (`/api/search`) untuk kedua UI, hapus `search.tsx` kalau tidak dipakai, lalu implementasikan pola WAI-ARIA combobox dengan focus trap.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `26774f8`. `organisms/search-modal` dihapus, dan navbar kini membuka `CustomSearchDialog` (`src/components/search.tsx`, pencarian full-text fumadocs lewat `/api/search`). Dengan begitu, homepage dan docs memakai backend dan komponen dialog yang sama (termasuk focus trap dari fumadocs). E2E baru: `e2e/search-dialog.spec.ts`.

---

<a id="f47"></a>

### #47 — `bun run type-check` gagal di clone yang masih bersih

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** `apps/docs` (tooling) · **File:** `apps/docs/package.json`, `apps/docs/src/lib/source.ts:2`

**Deskripsi:** modul virtual `collections/server` berasal dari folder `.source/`, yang baru dibuat oleh `fumadocs-mdx` saat `dev` atau `build`. Tidak ada skrip `postinstall`, dan CI tidak menjalankan `type-check` terpisah.

**Bukti** (salinan bersih `git archive HEAD apps/docs` + `node_modules`)

```text
$ ls -a | grep source
source.config.ts                       <- belum ada .source/
$ tsc --project tsconfig.json --noEmit
src/lib/source.ts(2,22): error TS2307: Cannot find module 'collections/server' or its corresponding type declarations.
exit 2

$ grep -n "type-check\|tsc" .github/workflows/ci.yaml
(tidak ada hasil)
```

**Cara reproduce:** `git clone … && cd justui && bun install && cd apps/docs && bun run type-check`.

**Dampak:** kontributor baru langsung melihat error. Error tipe di luar yang dicek `next build` juga tidak pernah tertangkap CI.

**Saran perbaikan:** tambahkan `"postinstall": "fumadocs-mdx"` (atau `"type-check": "fumadocs-mdx && tsc --noEmit"`), lalu jalankan `type-check` di job `nextjs-ci`.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `8ee3139`.

- `apps/docs/package.json` kini punya `"postinstall": "fumadocs-mdx"`.
- `ci.yaml:71-74` menambahkan step "Type Check" (`bun run type-check`).

Lokal: `tsc --noEmit` exit 0. Step CI-nya belum pernah jalan karena install gagal ([#62](#f62)).

---

<a id="f59"></a>

### #59 — `justui list` selalu melaporkan komponen terpasang sebagai "Outdated / Modified"

**Tingkat:** Sedang · **Status:** Selesai (putaran 5) · **Area:** CLI Rust · **File:** `packages/cli/src/commands/list/mod.rs:153-194`

**Deskripsi**

`get_component_status` menghitung SHA-256 dari isi file **lokal**, yang sudah di-rewrite importnya dan di-transpile ke constructor standar, lalu membandingkannya dengan `checksum` di `index.json`. Checksum itu adalah hash file registry **mentah**. Karena isinya pasti berbeda, status `Installed` tidak pernah tercapai.

Perintah `diff` dan `update` memakai hash `registry=`/`local=` di header `justui-meta`, sehingga hasilnya benar. Logika yang sama sudah ada di baseline `f4c2876` (`list.rs:811-833`), jadi ini bukan regresi dari refactor #31.

**Bukti**

```rust
// list/mod.rs
174                let local_clean =
175                    crate::utils::import_rewriter::strip_metadata(&content.replace("\r\n", "\n"));
176                let local_hash = sha256_hex(local_clean.as_bytes());                         // hash konten hasil rewrite
177                let expected_hash = file.checksum.replace("sha256:", "").trim().to_string(); // hash registry mentah
178                if local_hash == expected_hash {
```

Di app yang baru saja di-`justui add` dan belum disentuh:

```text
$ justui list | grep -E "button |badge |select "
  button               v0.14.0   [Outdated / Modified] (primitive)
  badge                v0.14.0   [Outdated / Modified] (primitive)
  select               v0.14.0   [Outdated / Modified] (primitive)
$ justui list | grep -oE "\[[^]]*\]" | sort | uniq -c        # app hasil add --all
     38 [Outdated / Modified]
$ justui diff badge
✓ just_badge_style.dart: Up to date.
✓ just_badge_variants.dart: Up to date.
✓ just_badge.dart: Up to date.
$ justui update
✓ All components are up-to-date!
```

**Cara reproduce:** Lampiran A langkah 3, lalu `justui add badge -y && justui list | grep badge`.

**Dampak:** TUI dan output `list` menyesatkan user, karena semua komponen terlihat perlu di-update. Tes `list` tidak menangkapnya karena fixture memakai file tanpa rewrite.

**Saran perbaikan:** baca hash `registry=` dari header `justui-meta` lalu bandingkan dengan checksum registry (untuk status outdated), dan bandingkan hash konten dengan `local=` (untuk status modified), seperti di `diff.rs`. Tambahkan tes integrasi `add` lalu `list`.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `98d70b6` (status `list` dibaca dari header `justui-meta`).

```text
# app baru, init neobrutalism/oklch/standard + add --all dengan binary HEAD
$ justui list | grep -oE "\[[^]]*\]" | sort | uniq -c
     38 [Installed   ]
```

---

<a id="f57"></a>

### #57 — AGENTS.md tertinggal dari perbaikan batch rendah

**Tingkat:** Rendah · **Status:** Selesai (putaran 5) · **Area:** dokumentasi · **File:** `AGENTS.md:33, 197, 250`, §14

**Deskripsi:** tiga hal di AGENTS.md tidak ikut diperbarui saat batch rendah dan commit sesudahnya.

- §7.2 masih menyebut aturan routing `_shared_theme_provider` → `lib/theme`, padahal cabang itu dihapus di #31 (`28aed53`).
- Jumlah usecase preview masih 28, padahal sudah 30 sejak #32 menambah carousel dan resizable.
- `b802627` menambahkan kembali `.agents/skills/senior-architect`, tapi katalog §14 tidak mencantumkannya.

**Bukti**

```text
$ grep -n "_shared_theme_provider" AGENTS.md
250:2. `name == "_shared_theme_provider"` $
$ git grep -c "_shared_theme_provider" HEAD -- packages/cli
(0 hasil)

$ grep -n "28 use" AGENTS.md
33:│   ├── preview/            # [Flutter] Widgetbook 3 interactive component workbench (28 use cases)
197:- Contains 28 use-case files under `apps/preview/lib/usecases/`.
$ ls apps/preview/lib/usecases | wc -l
30

$ git ls-tree -d --name-only HEAD .agents/skills/ | grep senior-architect
.agents/skills/senior-architect
$ grep -c "senior-architect" AGENTS.md
0
```

**Cara memeriksa:** perintah di atas.

**Dampak:** agen AI mengikuti aturan routing yang sudah tidak ada, dan katalog skill tidak lengkap.

**Saran perbaikan:** hapus langkah 2 di §7.2 (dan rapikan panah, lihat #14), ubah 28 menjadi 30, lalu tambahkan `senior-architect` ke tabel §14 atau hapus skill-nya bila memang tidak dipakai.

**Pembaruan putaran 5: sudah diperbaiki**

Diperbaiki di `2d738e5`.

```text
$ grep -n "_shared_theme_provider" AGENTS.md        -> (tidak ada)
$ grep -n "use-case files" AGENTS.md
193:- Contains 30 use-case files under `apps/preview/lib/usecases/`.
$ grep -c "senior-architect" AGENTS.md              -> 1
```

---

## Diperbaiki sebelum putaran 5

Baseline putaran 1 adalah `714c89f`, baseline batch rendah adalah `f4c2876`.

<a id="f01"></a>

### #01 — CLI menulis import yang tidak bisa di-resolve untuk hampir semua komponen

**Tingkat:** Kritis · **Status:** Selesai · **Diperbaiki di:** `fe1e760` (fix: verify SHA256 … / import rewriter) · **File:** `packages/cli/src/utils/import_rewriter.rs`

**Deskripsi (sebelum):** sejak komponen core meng-import path internal seperti `package:just_ui_core/src/theme/preset_tokens.dart`, rewriter hanya mengambil nama file terakhir, padahal file core diekstrak lengkap dengan subfoldernya (`lib/core/theme/…`).

**Bukti (sebelum, `714c89f`)**: CLI dibangun dari baseline, lalu `init -y` + `add button select date-picker` di app baru `r1_app`, dilanjutkan `flutter analyze`:

```text
error • Target of URI doesn't exist: 'package:r1_app/core/theme_data.dart'.    • lib/widgets/button/just_button.dart:5:8
error • Target of URI doesn't exist: 'package:r1_app/core/preset_tokens.dart'. • lib/widgets/button/just_icon_button.dart:5:8
error • Target of URI doesn't exist: 'package:r1_app/core/theme_data.dart'.    • lib/widgets/button/just_icon_button.dart:6:8
19 issues found.   (16 error: 8 uri_does_not_exist, 3 undefined_identifier, 3 undefined_class, …)

$ ls lib/core/theme
just_theme.dart  preset_tokens.dart  schemes  theme_aspects.dart  theme_data.dart  theme_data_material.dart
# file ada di core/theme/, import menunjuk core/
```

**Cara reproduce (sebelum)**

```bash
git worktree add /tmp/base-r1 714c89f
CARGO_TARGET_DIR=/tmp/t-r1 cargo build --release -p justui --manifest-path /tmp/base-r1/Cargo.toml
flutter create --platforms web /tmp/r1_app && cd /tmp/r1_app
/tmp/t-r1/release/justui init -y --preset default
sed -i "s#^registry_url:.*#registry_url: /tmp/base-r1/registry#" justui.config.yaml
/tmp/t-r1/release/justui add button select date-picker -y && flutter pub get && flutter analyze
```

**Verifikasi fix (HEAD)**

- Langkah yang sama dengan binary dan registry HEAD (app `h2_app`, `add button select date-picker badge`) menghasilkan **0 error**. Yang tersisa hanya 12 info `unnecessary_import` (#55).
- `add --all` di `e2e_app` juga 0 error dan 0 warning.
- `cargo test` → `registry_consistency` 3/3 lulus.

---

<a id="f02"></a>

### #02 — `dart_target: standard` tidak berfungsi

**Tingkat:** Kritis · **Status:** Selesai · **Diperbaiki di:** `fe1e760` · **File:** `packages/cli/src/utils/constructor_transpiler.rs` (`transpile_to_standard_constructor`, `apply_dart_target`)

**Deskripsi (sebelum):** file registry ditulis dengan sintaks primary constructor eksperimental (`class const X({…})`), sedangkan CLI hanya punya transpiler satu arah, dari standard ke primary. User dengan `dart_target: standard` tetap menerima sintaks primary.

**Bukti (sebelum, `714c89f`)**: app `r2_app`, `init -y --dart-target standard` + `add badge`:

```text
$ grep dart_target justui.config.yaml
dart_target: standard
$ grep -rln "class const" lib | wc -l
6
lib/core/overlay/just_overlay_scope.dart:7:class const JustOverlayScope<T extends JustOverlayController>({
lib/core/theme/theme_data.dart:23:class const JustThemeData({
lib/core/theme/schemes/shadow_scheme.dart:101:final class const TintedShadowScheme({

# Dengan SDK constraint default Flutter 3.47.5 (sdk: ^3.13.4) analyze masih lolos, karena
# language version 3.13 sudah mendukung fitur ini. Dengan constraint yang lebih rendah:
$ sed -i 's/sdk: \^3.13.4/sdk: ^3.10.0/' pubspec.yaml && flutter pub get && flutter analyze
error • This requires the 'primary-constructors' language feature to be enabled. Try updating your
        pubspec.yaml to set the minimum SDK constraint to 3.13.0 or higher …
11 issues found.
```

**Cara reproduce (sebelum):** seperti #01 dengan `init -y --preset default --dart-target standard`, `add badge`, lalu turunkan `sdk:` di pubspec app ke `^3.10.0`.

**Verifikasi fix (HEAD):** app `h2_app` dengan `sdk: ^3.10.0` dan `--dart-target standard`, lalu `add button select date-picker badge`:

```text
$ grep -rln "class const" lib | wc -l
0
$ flutter analyze | grep -c " error "
0
```

---

<a id="f03"></a>

### #03 — `registryDependencies` tidak cocok dengan import sebenarnya

**Tingkat:** Kritis · **Status:** Selesai · **Diperbaiki di:** `fe1e760` · **File:** `registry/index.json`, `packages/cli/tests/registry_consistency.rs`

**Deskripsi (sebelum)**

| Komponen                     | Masalah                                                                       |
| ---------------------------- | ----------------------------------------------------------------------------- |
| `date-picker`, `time-picker` | Import `../dialog/` dan `../sheet/` tanpa dideklarasikan                      |
| `avatar`                     | Import `_shared_pressable` dan `_shared_focus_indicator` tanpa dideklarasikan |
| `_shared_tooltip_overlay`    | Bergantung ke komponen publik `tooltip`, tanpa dideklarasikan                 |
| `date-range-picker`          | Deklarasi berlebih: `_shared_focus_indicator` tidak dipakai                   |

**Bukti (sebelum, `714c89f`)**: `add date-picker` di `r1_app`:

```text
$ ls lib/widgets
button  date-picker  select  shared                       <- dialog/ dan sheet/ tidak ikut terpasang
error • Target of URI doesn't exist: '../dialog/just_dialog.dart'. • lib/widgets/date-picker/just_date_picker.dart:6:8
error • Target of URI doesn't exist: '../sheet/just_sheet.dart'.   • lib/widgets/date-picker/just_date_picker.dart:9:8
error • Undefined class 'JustSheetController'.                     • lib/widgets/date-picker/just_date_picker.dart:435:19
error • Undefined class 'JustDialogController'.                    • lib/widgets/date-picker/just_date_picker.dart:702:11
```

**Cara reproduce (sebelum):** langkah #01, lalu `ls lib/widgets` dan `flutter analyze`.

**Verifikasi fix (HEAD)**

- `add date-picker` di `h2_app` kini ikut memasang dependency-nya: `ls lib/widgets` → `badge button date-picker dialog select shared sheet`, dan `flutter analyze` 0 error.
- `cargo test --test registry_consistency` → 3 passed.

---

<a id="f04"></a>

### #04 — Tes docs rusak akibat resolusi merge yang gagal

**Tingkat:** Kritis · **Status:** Selesai · **Diperbaiki di:** `66b641f`, `257563a` · **File:** `apps/docs/test/navbar.test.tsx` (sekarang berada di `test/navbar.test.tsx` untuk `organisms/navbar`)

**Deskripsi (sebelum):** merge commit menyisipkan baris duplikat (`it(` ganda, `const closeBtn` ganda, objek yang tidak ditutup).

**Bukti (sebelum, `714c89f`)**

```text
$ git show 714c89f:apps/docs/test/navbar.test.tsx | sed -n '170,181p'
  it('closes search modal via close button and handles keyboard navigation', () => {
  it('closes search modal via close button and handles keyboard navigation', () => {
    render(<Navbar starCount={100} lang="en" />);
    fireEvent.keyDown(document, { ctrlKey: true, key: 'k' });

    const closeBtn = screen.getByRole('button', {
      name: /close search/i,
    const closeBtn = screen.getByRole('button', {
      name: /close search/i,
    });
    fireEvent.click(closeBtn);
    fireEvent.click(closeBtn);

$ tsc --noEmit --jsx react-jsx --isolatedModules --skipLibCheck navbar-r1.test.tsx | grep -c TS1005
9
navbar-r1.test.tsx(178,11): error TS1005: ':' expected.
navbar-r1.test.tsx(180,7):  error TS1005: ',' expected.
```

**Cara reproduce (sebelum):** `git show 714c89f:apps/docs/test/navbar.test.tsx > /tmp/n.tsx && apps/docs/node_modules/.bin/tsc --noEmit --jsx react-jsx --isolatedModules --skipLibCheck /tmp/n.tsx`.

**Verifikasi fix (HEAD)**

```text
$ cd apps/docs && bunx vitest run
 Test Files  25 passed (25)
      Tests  545 passed (545)
$ bunx eslint .        -> exit 0
```

Job `nextjs-ci` di run [36379689330](https://github.com/infinitedim/justui/actions/runs/36379689330) juga hijau.

---

<a id="f05"></a>

### #05 — `justui upgrade` mengganti binary tanpa verifikasi checksum

**Tingkat:** Kritis · **Status:** Selesai · **Diperbaiki di:** `fe1e760` · **File:** `packages/cli/src/commands/upgrade.rs`

**Bukti (sebelum, `714c89f`)**

```rust
// upgrade.rs:303-310
pub fn execute_upgrade(client: &reqwest::blocking::Client, download_url: &str, clean_tag: &str) -> Result<()> {
    let unpacked_bytes = download_and_unpack(client, download_url)?;
    replace_current_executable(&unpacked_bytes)                    // langsung menimpa, tanpa verifikasi
        .context("Failed to replace current executable with updated binary")?;
```

```text
$ git show 714c89f:packages/cli/src/commands/upgrade.rs | grep -n -i "sha256\|checksum" | head -2
227:        // Avoid non-archive metadata/checksum files
228:        if name.ends_with(".sha256")                            <- satu-satunya penyebutan: melewati aset .sha256
```

**Verifikasi fix (HEAD)**

```text
$ grep -n "fn verify_sha256\|verify_sha256(\|SHA256SUMS" packages/cli/src/commands/upgrade.rs
274:const CHECKSUM_MANIFEST: &str = "SHA256SUMS";
295:fn verify_sha256(bytes: &[u8], manifest: &str, asset_name: &str) -> Result<()> {
360:    verify_sha256(&bytes, &manifest, &asset_name)?;           <- dipanggil sebelum replace_current_executable
```

Tes terkait di `upgrade_tests.rs` (`test_verify_sha256`, `test_checksum_manifest_location`, dan `test_execute_upgrade_rejects_checksum_mismatch`, yang memakai server rilis lokal dengan manifest palsu) ikut di 130 unit test yang lulus.

**Cara reproduce:** bandingkan `git show 714c89f:packages/cli/src/commands/upgrade.rs | sed -n '300,312p'` dengan `sed -n '340,365p' packages/cli/src/commands/upgrade.rs`, lalu jalankan `cargo test -p justui upgrade` (menjalankan ketiga tes di atas).

---

<a id="f27"></a>

### #27 — `apps/showcase` masih template counter, tapi build 41 MB-nya ikut di-commit

**Tingkat:** Rendah · **Status:** Selesai · **Diperbaiki di:** `a2b3589`

**Sebelum (`f4c2876`)**

```text
$ git ls-tree -r --name-only f4c2876 apps/docs/public/showcase | wc -l
44                                  (±41 MB build web, tidak direferensikan dari src mana pun)
$ git show f4c2876:apps/showcase/lib/main.dart | grep -c "_incrementCounter"
3                                   (template counter Flutter)
```

**Verifikasi fix (HEAD)**

```text
$ git ls-tree -r --name-only HEAD apps/docs/public/showcase | wc -l
0
$ grep -n "^class " apps/showcase/lib/main.dart
25:class ShowcaseApp extends StatelessWidget {
49:class ComponentGallery extends StatefulWidget {
```

`apps/showcase` kini hasil `justui init && add --all` dari registry lokal. `flutter analyze` di sana 0 error, dan `flutter test` (smoke test galeri) lulus. Lihat AGENTS §6.2 untuk cara regenerasinya.

---

<a id="f28"></a>

### #28 — Folder `.agents/skills` berisi skill yang tidak berhubungan

**Tingkat:** Rendah · **Status:** Selesai (dengan catatan, lihat [#57](#f57)) · **Diperbaiki di:** `31fc74d`

```text
                       f4c2876    HEAD (b802627)
file di .agents          231          37
folder skill              38          19
```

`du -sh .agents` di HEAD: 572K (sebelumnya ±2,3 MB). Commit `b802627` kemudian menambahkan lagi `senior-architect` (7 file), yang tidak tercatat di katalog AGENTS.md §14.

**Cara memeriksa:** `for r in f4c2876 HEAD; do git ls-tree -r --name-only $r .agents | wc -l; done`.

---

<a id="f29"></a>

### #29 — Konfigurasi docs site

**Tingkat:** Rendah · **Status:** Selesai · **Diperbaiki di:** `30ffa9c`

| Aspek                                                  | Sebelum (`f4c2876`)                                                               | HEAD                                                                                                               |
| ------------------------------------------------------ | --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| `vercel.json`                                          | `"/api/search"` **dan** catch-all `"/api/(.*)"` yang memaksa `no-store` (bentrok) | satu aturan: `"/api/((?!search$).*)"`                                                                              |
| Header `/api/search`                                   | ditimpa `no-store`                                                                | `cache-control: public, s-maxage=60, stale-while-revalidate=300` (diverifikasi dengan `curl -D -` ke `next start`) |
| `proxy.ts` no-op                                       | ada (`apps/docs/proxy.ts`)                                                        | dihapus                                                                                                            |
| Header `immutable` 1 tahun untuk semua `.js/.png/.svg` | ada di `next.config.ts`                                                           | dihapus (Next sudah menangani `/_next/static`)                                                                     |
| Dependency tidak terpakai                              | `lenis`, `class-variance-authority`, `@orama/orama`                               | dihapus; `zod` kini dipakai untuk `stageBridgeEventSchema`                                                         |

**Cara memeriksa:** `git show f4c2876:apps/docs/vercel.json | grep source; grep source apps/docs/vercel.json; curl -s -D - -o /dev/null "http://localhost:3470/api/search?query=button" | grep -i cache-control`.

---

<a id="f30"></a>

### #30 — Dua implementasi `buildPressEffect`

**Tingkat:** Rendah · **Status:** Selesai · **Diperbaiki di:** `09bc9c1`

**Sebelum:** `JustThemeData.buildPressEffect` (`theme_data.dart:90-118`) punya implementasi sendiri, terpisah dari `JustPresetTokens.buildPressEffect`. Button memakai versi preset tokens, icon-button memakai versi theme.

**HEAD** (`theme_data.dart:94-106`):

```dart
  Widget buildPressEffect({required Widget child, required bool isPressed, double scaleFactor = 0.97, Offset? translationOffset}) {
    return presetTokens.buildPressEffect(
      child: child, isPressed: isPressed, animations: animations,
      customOffset: translationOffset, customScale: scaleFactor,
    );
```

Tes paritas per preset ada di `packages/core/test/theme_schemes_test.dart`. Tes itu lulus; ia bukan bagian dari 72 kegagalan di #54.

**Cara memeriksa:** `git show f4c2876:packages/core/lib/src/theme/theme_data.dart | sed -n '90,118p'` (implementasi lama) vs `sed -n '94,107p' packages/core/lib/src/theme/theme_data.dart`, lalu `cd packages/core && flutter test test/theme_schemes_test.dart`.

---

<a id="f31"></a>

### #31 — Kode mati di CLI

**Tingkat:** Rendah · **Status:** Selesai · **Diperbaiki di:** `28aed53`

| Aspek                                                   | Sebelum (`f4c2876`)                                                 | HEAD                                                 |
| ------------------------------------------------------- | ------------------------------------------------------------------- | ---------------------------------------------------- |
| Cabang `_shared_theme_provider` (tidak ada di registry) | 15 kemunculan (`add.rs` 7, `list.rs` 4, `diff.rs` 2, `update.rs` 2) | 0                                                    |
| Logika penempatan file                                  | 5 salinan                                                           | `RegistryComponent::install_dir` / `local_file_name` |
| `#[allow(dead_code)]`                                   | 10                                                                  | 0                                                    |
| Modul dikompilasi dua kali                              | `main.rs`: `mod commands; mod config; mod registry; mod utils;`     | `use justui_cli::{commands, utils};`                 |
| String campur bahasa                                    | `add.rs:533 "(file baru)"`                                          | `"(new file)"`                                       |

**Verifikasi:** `cargo clippy --workspace --all-targets -- -D warnings` bersih. Unit test lib: `130 passed` sekali saja (bin `src/main.rs`: `0 passed`), bukan lagi 129 × 2.

Catatan: AGENTS.md §7.2 belum ikut diperbarui (#57). Bug status di `list` (#59) sudah ada sebelum refactor ini.

---

<a id="f32"></a>

### #32 — Method dan file yang terlalu besar

**Tingkat:** Rendah · **Status:** Selesai · **Diperbaiki di:** `fbf990a` (CLI), `3deadbd` (Flutter)

| Aspek                | Sebelum (`f4c2876`)                                             | HEAD                                                                                            |
| -------------------- | --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| `add.rs`             | 2103 baris                                                      | 874 (+ `add_tests.rs`)                                                                          |
| `upgrade.rs`         | 1340 baris                                                      | 775 (+ `upgrade_tests.rs`)                                                                      |
| `list.rs`            | 1828 baris, satu file                                           | `list/{mod.rs, ui.rs, tests.rs}` (1834 total)                                                   |
| Timeout registry     | `timeout(3s)`, `connect_timeout(2s)` (`registry.rs:120-121`)    | default 15 s / 5 s, bisa diatur lewat `JUSTUI_HTTP_TIMEOUT` (`registry.rs:100-111`)             |
| `JustButton`         | `StatefulWidget` + `_JustButtonState` yang hanya berisi `build` | `StatelessWidget`, dengan `_buttonMetrics` dan resolver warna bersama `resolveJustButtonColors` |
| Build select / input | 499 / 418 baris                                                 | dipecah jadi `_SelectSearchField`, `_SelectOptionTile`, `_InputHelperRow`, dan helper ukuran    |
| Usecase preview      | 28 (tanpa carousel/resizable)                                   | 30                                                                                              |

**Verifikasi:** `dart analyze packages/core` bersih, registry "All files in sync", dan daftar tes Flutter yang gagal identik dengan baseline (tidak ada regresi).

---

<a id="f33"></a>

### #33 — Sisa komentar tugas review di `generate_checksums.dart`

**Tingkat:** Rendah · **Status:** Selesai · **Diperbaiki di:** `e64276c`

```text
# sebelum
$ git grep -n "Poin" f4c2876 -- tools/generate_checksums.dart
423:  // Poin 1 + 4: hash-based drift check …
446:  // Poin 2: pattern matching over the FileOrigin enum …
458:  // Poin 5: mutation is isolated …
# HEAD
$ git grep -c "Poin" HEAD -- tools/generate_checksums.dart
(0)
$ grep -n "resolveSymbolicLinksSync" tools/generate_checksums.dart
25:      .resolveSymbolicLinksSync();                        <- menggantikan extension canonicalPath() yang tidak mengkanonikalisasi
$ dart run tools/generate_checksums.dart --dry-run
Status: All files in sync.
```

**Cara memeriksa:** jalankan ketiga perintah di atas dari root repo.

---

<a id="f44"></a>

### #44 — Shortcut ⌘K salah terdeteksi di Safari dan Firefox untuk Mac

**Tingkat:** Rendah · **Status:** Selesai · **Diperbaiki di:** `136628b`

**Sebelum:** `navbar.tsx:132`, `const platform = navigator.userAgentData?.platform.toLowerCase();`. `userAgentData` hanya ada di Chromium, jadi Safari/Firefox di Mac menampilkan "Ctrl K".

**HEAD:** `src/lib/platform.ts`, `isApplePlatform()` dengan fallback `userAgentData?.platform || platform || userAgent`, lalu regex `/Mac|iPhone|iPad/`. Tesnya di `test/platform.test.ts` (termasuk skenario Safari tanpa `userAgentData`) dan ikut di 545 tes vitest yang lulus.

**Cara memeriksa:** `git show f4c2876:apps/docs/src/components/navbar.tsx | sed -n '130,134p'`, lalu `cd apps/docs && bunx vitest run test/platform.test.ts`. Untuk uji manual, buka `/en` di Safari atau Firefox macOS; tombol pencarian menampilkan ⌘K.

---

<a id="f50"></a>

### #50 — Migrasi struktur atomic setengah jalan

**Tingkat:** Rendah · **Status:** Selesai · **Diperbaiki di:** `de80755`

```text
                                             f4c2876                          HEAD
.gitkeep di src/components                     9                                0
navbar / search-modal                   src/components/*.tsx       organisms/navbar/{navbar.tsx,navbar.types.ts,index.ts}
                                                                   organisms/search-modal/{search-modal.tsx,…types.ts,index.ts}
hero-graphic.tsx (tidak direferensikan)       ada                            dihapus
```

Navbar kini dirakit dari molekul `LanguageSwitcher`, `PresetToggle`, `ThemeSwitcher`, `SearchBar`, dan `GitHubPill`. Search modal memakai `SearchResultItem`. Delapan atom/molekul yang tidak dipakai dihapus beserta tesnya.

**Cara memeriksa:** `git ls-tree -r --name-only f4c2876 apps/docs/src/components | grep -c .gitkeep` (9) vs `HEAD` (0), dan `ls apps/docs/src/components/organisms/{navbar,search-modal}`.

---

<a id="f51"></a>

### #51 — Kode mati dan daftar locale yang tersebar

**Tingkat:** Rendah · **Status:** Selesai · **Diperbaiki di:** `ecc48a8`

```text
# sebelum
f4c2876:apps/docs/next.config.ts:49:              const _supportedLocales = ['en', 'id'];
f4c2876:apps/docs/src/app/[lang]/studio/page.tsx:9: const validLangs = ['en', 'id'] as const;
f4c2876:apps/docs/src/lib/i18n.ts:5:                languages: ['en', 'id'],
(+ tiga generateStaticParams yang menulis ulang daftar, getDictionary yang hanya dipakai tes,
 default params HomePage, export searchData yang tidak dipakai)
# HEAD
HEAD:apps/docs/src/lib/i18n.ts:5:  export const locales = ['en', 'id'] as const;   <- satu-satunya sumber
```

**Cara memeriksa:** `git grep -n "\['en', 'id'\]\|_supportedLocales\|validLangs" HEAD -- apps/docs/src apps/docs/next.config.ts`.

---

<a id="f52"></a>

### #52 — Syntax highlighter buatan sendiri dan tab tanpa pola ARIA lengkap

**Tingkat:** Rendah · **Status:** Selesai · **Diperbaiki di:** `9b2f138`

**Sebelum:** `code-highlighter.tsx` berisi 240 baris tokenizer manual. Tab ekspor memakai `role="tab"` tanpa `aria-controls`, tanpa tabpanel, dan tanpa navigasi panah.

**HEAD** (`code-export-drawer.tsx`):

```text
4:   import { DynamicCodeBlock } from 'fumadocs-ui/components/dynamic-codeblock';   <- Shiki
8:   import { useRovingTabs } from '@/lib/use-roving-tabs';
70:  const { registerTab, onKeyDown } = useRovingTabs(tabIds, tab, setTab);
98:  aria-controls={panelId}
129: role="tabpanel"
```

Diverifikasi di Chromium terhadap build produksi (putaran 3): token ter-highlight Shiki, dan ArrowLeft/ArrowRight/Home/End memindahkan fokus serta tab aktif.

**Cara memeriksa:** `git show f4c2876:apps/docs/src/components/organisms/code-export-drawer/code-highlighter.tsx | wc -l` (240; file ini sudah tidak ada di HEAD), `grep -n "DynamicCodeBlock\|aria-controls\|tabpanel" apps/docs/src/components/organisms/code-export-drawer/code-export-drawer.tsx`. Di browser: `/en/studio`, buka Export, fokuskan tab, lalu tekan panah kanan.

---

<a id="f53"></a>

### #53 — 11 cast `as Route` mematikan manfaat `typedRoutes`

**Tingkat:** Rendah · **Status:** Selesai · **Diperbaiki di:** `919ee84`

```text
$ git grep -c "as Route" f4c2876 -- apps/docs/src | awk -F: '{s+=$NF} END{print s}'
11
$ git grep -n "as Route" HEAD -- apps/docs/src
apps/docs/src/lib/i18n.ts:36:  return `/${lang}${path}` as Route;       <- satu titik konversi terpusat (localizedHref)
```

`tsc --noEmit` lulus dengan typed routes aktif.

**Cara memeriksa:** kedua perintah `git grep` di atas, lalu `cd apps/docs && bunx fumadocs-mdx && bunx tsc --noEmit`.

---

## Urutan perbaikan yang disarankan

Diurutkan dari yang paling mendesak.

1. **Hijaukan CI lagi.** Sekarang CI benar-benar menguji, tapi ada tiga masalah yang menutupi hasilnya:
   - Pin Bun ke versi yang bisa membaca `bun.lock` ([#62](#f62)).
   - Buat tes `dart_formatter` di-skip kalau Dart tidak ada, atau pasang Flutter di job Rust ([#61](#f61)).
   - Buat `generate_checksums.dart --dry-run` exit non-zero saat drift, lalu sinkronkan `just_progress.dart` ([#63](#f63)).
2. **Buka blokir release.** Perbaiki quoting `awk` di `apply_changesets_cargo.sh`, lalu tambahkan `bash -n` / `shellcheck` dan dry-run skrip apply ke CI ([#60](#f60)).
3. **Triase 75 tes Flutter yang gagal**, yang sekarang terlihat di CI ([#54](#f54)): perbaiki bug nyata (carousel `initState`, date picker overflow) dan tes yang basi.
4. **Hentikan crash dan cache poisoning di docs.** Validasi locale di `[lang]/layout.tsx` (`dynamicParams = false` / `notFound()`) sebelum `source.pageTree[lang]` dipakai, lalu tambahkan `robots.ts`, `sitemap.ts`, dan icon ([#34](#f34)).
5. **Perbaiki jalur onboarding.**
   - Perintah instalasi di homepage, termasuk tab `install.ps1` yang baru ([#35](#f35)).
   - Import di docs ([#37](#f37)).
   - Sisa snippet katalog ([#38](#f38)).
   - Sisa path `lib/components/ui` ([#15](#f15)).
6. **Samakan Studio dengan Flutter.**
   - `fromSeed`, perbandingan kontras tanpa pembulatan, dan flag `--seed` ([#39](#f39), [#40](#f40)).
   - Sisa state Studio dan preset ([#45](#f45), [#46](#f46)).
7. **Perbaiki perilaku CLI.**
   - Exit code dan flag global ([#10](#f10), [#11](#f11)).
   - Sisa `unnecessary_import` dan format template `init` ([#55](#f55), [#56](#f56)).
8. **Performa tema.** Cache tema yang sudah di-resolve, pakai aspek, dan daftarkan extension di preview/test ([#06](#f06), [#07](#f07), [#08](#f08), [#09](#f09), [#13](#f13)).
9. **Keamanan supply chain registry.** Pin versi dan tanda tangan ([#12](#f12)).
10. **Docs lainnya.** SEO ([#36](#f36)), sisa i18n ([#42](#f42)), terminal simulasi ([#48](#f48)), dan E2E untuk locale, 404, dan metadata ([#49](#f49)), plus `flutter analyze` atas output CLI di CI ([#25](#f25)).
