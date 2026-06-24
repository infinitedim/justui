# JustUI — Agent Onboarding & Codebase Manual

Selamat datang! Berkas ini dibuat sebagai **single source of truth** bagi AI Agent untuk memahami arsitektur, struktur proyek, dan batasan lingkungan pengembangan (constraints) JustUI tanpa perlu menganalisis seluruh codebase dari awal.

---

## 1. Project Overview & Philosophy

**JustUI** adalah Flutter UI component library dengan filosofi **copy-paste model** (terinspirasi dari shadcn/ui).
* User **tidak menginstall** library ini sebagai package pub.dev pihak ketiga.
* User menggunakan CLI tool (`just_ui_cli`) untuk menyalin kode sumber komponen secara langsung ke dalam direktori proyek mereka sendiri.
* Desain arsitektur diutamakan pada **Zero-dependency footprint** (tidak memakai library eksternal pub.dev selain bawaan Flutter) dan **Visual & Performance Excellence**.

---

## 2. Monorepo Structure

```
justui/
├── packages/
│   ├── just_ui_tokens/     # Design system tokens (colors, spacing, typography, dll.)
│   ├── just_ui_core/       # Theming engine, context extensions, & optimisasi rebuild
│   └── just_ui_cli/        # Command-Line Interface (scaffolding & copy-paste workflow)
├── docs/                   # Spesifikasi desain & fungsionalitas per fase
├── melos.yaml
└── pubspec.yaml
```

---

## 3. Architecture & Key Features (Milestone I & II)

### packages/just_ui_tokens
* **Visual Primitives**: Menyediakan konstanta compile-time (`const`) untuk `Colors`, `Spacing`, `Typography`, `Radius`, `Shadows`, dan `Animation` (Duration & Curves).
* **Accessibility Contrast Auditor (`colors_accessibility.dart`)**:
  * Menyediakan extension method pada `Color`: `contrastRatioWith` dan `isAccessibleWith`.
  * Memenuhi standar WCAG AA (kontras $\ge$ 4.5:1 untuk teks normal, $\ge$ 3.0:1 untuk komponen/teks besar).

### packages/just_ui_core
* **Aspect-Based Rebuilds (`InheritedModel`)**:
  * Menggunakan `JustThemeProvider` dengan `InheritedModel<JustThemeAspect>`.
  * Mengurangi overhead rebuild widget tree dengan memastikan perubahan aspek spesifik (misal: warna ketika toggle tema) hanya merender ulang widget yang mendengarkan aspek tersebut (`context.justColors`).
* **Lazy-Cached Material `ThemeData`**:
  * Nilai Flutter `ThemeData` diterjemahkan secara malas (*lazily*) dan disimpan di memori. Pemanggilan `.toThemeData()` berulang kali mengembalikan instance yang identik, menghilangkan overhead kalkulasi di setiap build.
* **Seeding & Contrast Enforcement (`JustThemeData.fromSeed`)**:
  * Memungkinkan inisialisasi tema kustom dari satu warna seed via HSL color scale.
  * Menjamin kontras warna primer (`borderFocus`) dinamis tetap memenuhi rasio kontras $\ge$ 3.0:1 terhadap background dengan memanipulasi nilai lightness warna secara otomatis di runtime.
* **Transition TIMING & Curves**:
  * `JustThemeProvider` mengekspos `transitionDuration` (default: `JustDuration.normal`) dan `transitionCurve` (default: `JustCurves.default_`).

### Best Practices for Theme Consumption (Penting!)
Untuk mempertahankan performa render yang optimal, AI Agent wajib menggunakan extension method dari `BuildContext` dengan aspek yang tepat ketika membangun widget/komponen baru:
* **Gunakan aspek spesifik** saat mengambil token di dalam metode `build`:
  * `context.justColors` untuk warna (misal: `context.justColors.background`) -> Hanya merender ulang widget jika warna berubah.
  * `context.justTypo` untuk teks (misal: `context.justTypo.bodyMd`) -> Hanya merender ulang widget jika typography berubah.
  * `context.justSpacing` untuk spacing (misal: `context.justSpacing.md`) -> Hanya merender ulang widget jika spacing berubah.
* **Hindari** penggunaan `context.justTheme` di dalam widget kecil, kecuali jika widget tersebut memang membutuhkan banyak aspek sekaligus. Memanggil `context.justTheme` akan meregistrasikan listener ke *seluruh* aspek tema, sehingga widget akan dibangun ulang saat aspek apa pun berubah.
* **Gunakan API non-registering** di dalam callback (seperti `onPressed`, `onTap`, dll.):
  * `context.readTheme()` -> Mengambil data tema secara langsung tanpa mendaftarkan listener rebuild ke context.

---

## 4. Coding Style & Syntax Rules (Penting!)

Semua agent wajib mematuhi aturan gaya penulisan kode berikut agar konsisten dengan codebase yang sudah ada:

1. **Patuhi Gaya Penulisan Kode yang Ada:** Jangan mengubah gaya penulisan, struktur indentasi, formatting, atau pengorganisasian kode yang sudah terbentuk di dalam repositori ini.
2. **Penggunaan Dart Dot Shorthand (Constructor Shorthands):**
   * Repositori ini memanfaatkan fitur **dot shorthand** (tersedia pada Dart 3.10 ke atas) untuk mempersingkat pemanggilan konstruktor static/factory bawaan Flutter ketika tipe datanya sudah dideklarasikan secara statis oleh parameter (misalnya `BorderRadius`, `EdgeInsets`, dll.).
   * Contoh penulisan shorthand:
     ```dart
     borderRadius: .all(radius.lg)  // JANGAN UBAH ke BorderRadius.all!
     padding: .symmetric(horizontal: spacing.md)  // JANGAN UBAH ke EdgeInsets.symmetric!
     ```
   * **Aturan Mutlak:** Jika Anda melihat sintaksis shorthand yang berawalan titik seperti `.all(...)` atau `.symmetric(...)`, **jangan sekali-kali memodifikasinya atau mengembalikannya ke bentuk panjang (verbose)**.

---

## 5. Development & Sandbox Constraints (Sangat Penting!)

Ketika bekerja di sandbox ini, harap perhatikan aturan lingkungan berikut:

1. **Offline Environment (No Internet)**:
   * Sandbox tidak memiliki koneksi internet, sehingga `dart pub get` atau `flutter pub get` standar akan gagal karena tidak bisa mengakses pub.dev.
   * **Penyelesaian**: Dependensi antar package lokal sudah dikonfigurasi secara offline di `.dart_tool/package_config.json`. **Jangan pernah menghapus atau menimpa folder `.dart_tool` secara ceroboh.**
2. **Dart Telemetry & Read-Only filesystem**:
   * Menjalankan tool Dart/Flutter dapat memicu error penulisan file telemetri di direktori HOME bawaan system.
   * **Solusi**: Selalu override `HOME` ke folder project lokal (`~/development/justui/.home`) saat menjalankan tool CLI Dart.
3. **Static Analysis & Lint Checks**:
   * Gunakan perintah berikut dari root proyek untuk memverifikasi kebersihan kode:
     ```bash
     export HOME=/home/yourblooo/development/justui/.home && dart analyze packages/just_ui_core
     export HOME=/home/yourblooo/development/justui/.home && dart analyze packages/just_ui_tokens
     ```
4. **Running Tests**:
   * Karena tidak adanya Flutter SDK lengkap di sandbox, perintah `flutter test` atau `dart test` langsung akan mengalami socket error/crash kompilasi FFI.
   * Unit test di [theme_test.dart](file:///home/yourblooo/development/justui/packages/just_ui_core/test/theme_test.dart) dan [tokens_test.dart](file:///home/yourblooo/development/justui/packages/just_ui_tokens/test/tokens_test.dart) telah ditulis dengan lengkap dan bersih. Pengujian harus dilakukan di environment lokal user (user-land) yang memiliki Flutter SDK terpasang:
     ```bash
     flutter test packages/just_ui_tokens
     flutter test packages/just_ui_core
     ```

---

## 6. Style Presets & Neobrutalism Guidelines

Ketika mengimplementasikan atau memodifikasi visual style preset kustom (seperti `neobrutalism`), AI Agent wajib mematuhi aturan berikut:

1. **Perhitungan Inner-Layout & Border Overlap**:
   * Karena `BoxDecoration` menggambarkan border ke bagian dalam (`BorderAlign.inside`), komponen dengan layout internal ketat (seperti track dan thumb pada `JustSwitch`) harus menyesuaikan dimensinya. 
   * Kurangi ukuran thumb secara dinamis sebesar `2 * borderWidth` di bawah preset `neobrutalism` dan offset peletakannya di stack (`Positioned(top: padding + borderWidth, left: padding + borderWidth)`) agar tidak melebihi batas border track.

2. **Mencegah Visual Drift (Jitter) Animasi Tekan**:
   * Untuk mencocokkan pergerakan posisi (translate) elemen dengan hilangnya bayangan solid (shadow offset collapsing) ketika ditekan, set durasi `AnimatedContainer` ke `animations.instant` (bukan `animations.fast`). Hal ini menjaga sinkronisasi pergerakan visual agar tidak terjadi pergeseran (drift).

3. **Pemberlakuan Kontras Dinamis & Warna Border**:
   * Di bawah preset `neobrutalism`, pertahankan kekhasan estetika dengan memaksa warna border tombol/input/container menjadi `colors.textPrimary` (hitam pekat di light mode, putih pekat di dark mode) di semua state (normal, hover, focused, error). Jangan biarkan warna border bertransisi ke warna primer/tinted.
   * Tebal border standar untuk komponen dan container (seperti Button, Card, Input, Sidebar, BottomNav, Breadcrumb dropdown) ditetapkan sebesar `2.5` (menggantikan rancangan awal `3.0` demi proporsi visual yang lebih seimbang).
   * Lewati (*bypass*) penyesuaian kontras HSL dinamis (`_makeAccessible`) khusus untuk default/focus border di preset `neobrutalism`.

4. **Kompatibilitas CLI**:
   * Ketika menambah preset baru, perbarui `init_command.dart` di `just_ui_cli` untuk mendukung pilihan preset via opsi `--preset` dan scaffold file `just_theme.dart` dengan preset yang sesuai.
   * Pastikan preset baru juga terdaftar di perbandingan `operator ==`, `hashCode`, dan metode `copyWith` pada `JustThemeData`.

---

## 7. Registry Shared Component Convention

### Pola Lama (DEPRECATED — jangan gunakan)
Komponen internal yang dipakai lintas komponen dulunya menggunakan prefix `_shared_*` pada nama dan diinstall ke folder terpisah per-komponen:
- nama: `_shared_pressable`
- dipasang ke: `lib/widgets/_shared_pressable/just_pressable.dart`

**Jangan buat komponen registry dengan prefix `_shared_*` — konvensi ini sudah dihapus.**

### Pola Baru (GUNAKAN INI)
Shared components kini dideteksi secara otomatis oleh CLI (`RegistryIndex.computeSharedComponents()`) berdasarkan jumlah dependent:

- **Kriteria shared**: komponen yang menjadi `registryDependencies` dari ≥ 2 komponen berbeda
- **Penempatan**: semua file komponen shared diletakkan **flat** di dalam `sharedDir`
- **Naming**: tanpa prefix khusus — nama komponen reguler (contoh: `pressable`, `base`)
- **Config**: `sharedDir` di `justui.config.yaml`, default `{componentsDir}/shared`

**Contoh hasil di project user:**
```
lib/widgets/
├── button/just_button.dart       # import '../shared/just_pressable.dart'
├── input/just_input.dart         # import '../shared/just_pressable.dart'
└── shared/
    └── just_pressable.dart       # dipakai oleh button + input → shared
```

---

## 8. Barrel Export & Shared File Rename Policy

### Theming Kernel Barrel Isolation
Untuk mencegah kebocoran visual/state komponen (barrel leakage) ke lokal copy di project user:
- Berkas `packages/just_ui_core/lib/just_ui_core.dart` **hanya boleh mengekspos core theming kernel** (seperti `JustThemeProvider`, `JustThemeData`, `JustThemeAspect`, dll.).
- **Dilarang keras mengekspos berkas komponen** (e.g. `JustButton`, `JustCard`, dll.) atau berkas private components barrel di dalam public barrel ini.
- Berkas `packages/just_ui_core/lib/src/components/components.dart` telah dihapus sepenuhnya. Semua test package internal dan file core internal harus mengimport berkas komponen secara langsung dari direktori source masing-masing (e.g. `import 'src/components/button/just_button.dart'`).

### CLI Shared File Copy-Renaming
- Berkas shared internal di package `just_ui_core` tetap menggunakan penamaan ber-prefix `_shared_` (e.g. `_shared_pressable.dart`).
- Saat CLI (`just_ui_cli`) menyalin file-file shared ini ke proyek user, prefix `_shared_` **wajib di-strip** menjadi `just_` (e.g. `just_pressable.dart`).
- Logika penggantian nama dan penyesuaian import path ini dikelola secara otomatis oleh `ImportRewriter.normalizeSharedFileName()`, `AddCommand`, `DiffCommand`, dan `UpdateCommand`. Agent tidak boleh mengubah heuristic ini atau membiarkan file dengan nama `_shared_*` tersalin ke folder lokal user.
