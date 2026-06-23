## 2026-06-23T04:02:19Z
Kamu adalah teamwork_preview_explorer. Tugasmu adalah menganalisis codebase JustUI untuk mendukung pembuatan dokumen panduan (Getting Started, Tokens, Guides) dan halaman dokumentasi komponen UI (15 komponen) berbasis MDX dalam Bahasa Indonesia.
Secara khusus:
1. Analisis package `just_ui_tokens`:
   - Daftar dan deskripsi visual primitives (colors, spacing, typography, radius, shadows, animations).
   - Penjelasan detail algoritma/metode audit aksesibilitas kontras di `colors_accessibility.dart` (termasuk formula dan extension `contrastRatioWith` dan `isAccessibleWith`).
2. Analisis package `just_ui_core`:
   - Mekanisme Aspect-Based Rebuilds menggunakan `InheritedModel<JustThemeAspect>` dan method extension context (`context.justColors`, `context.justTypo`, `context.justSpacing`).
   - Implementasi lazy-cached Material `ThemeData` representation.
   - Dynamic contrast enforcement melalui `JustThemeData.fromSeed` (bagaimana Lightness disesuaikan secara dinamis).
   - Praktik terbaik konsumsi tema (listener vs `context.readTheme()`).
3. Analisis ke-15 komponen Flutter di `packages/just_ui_core/lib/src/components/`:
   - Untuk setiap komponen, ekstraksi:
     - Nama class utama (misal `JustButton`, `JustIconButton`, `JustInput`, dsb.).
     - Semua parameter/properties constructor (nama property, tipe data Dart, nilai default, dan kegunaannya).
     - Contoh kode Dart/Flutter yang valid untuk memanggil komponen tersebut (Basic & Advanced).
     - Detail internal styling, variant, preset (e.g., default vs neobrutalism), dan integrasi aksesibilitas/kontras.
4. Analisis package `just_ui_cli`:
   - Struktur file dan cara kerja copy-paste scaffolding.
   - Daftar perintah CLI beserta parameter dan kegunaannya: `init`, `add`, `remove`, `diff`, `update`, `doctor`.
5. Tulis laporan temuan yang sangat lengkap, detail, terstruktur, tanpa TBD atau placeholder, ke berkas `/home/yourblooo/development/justui/.agents/explorer_m1/analysis.md`.
6. Tulis `handoff.md` di direktori kerjamu setelah selesai, lalu kirim pesan selesaimu ke parent orchestrator.
Direktori kerjamu adalah `/home/yourblooo/development/justui/.agents/explorer_m1`.
