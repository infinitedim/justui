## 2026-06-23T04:12:37Z
Kamu adalah teamwork_preview_worker. Tugasmu adalah menulis 3 dokumen panduan utama di `/home/yourblooo/development/justui/apps/docs/content/docs/` dalam Bahasa Indonesia:
1. `quick-start.mdx`: Panduan langkah awal (5 menit) integrasi komponen JustUI ke aplikasi Flutter baru. Harus mencakup setup `JustThemeProvider` di root widget, penggunaan visual preset (seperti default atau neobrutalism), dan contoh penggunaan komponen pertama.
2. `theming.mdx`: Penjelasan konsep core theming engine dan context provider. Harus mendeskripsikan secara mendalam bagaimana Aspect-Based Rebuilds (`InheritedModel<JustThemeAspect>`) bekerja untuk menghemat rendering overhead, caching ThemeData menggunakan Expando, serta pembatasan konsumsi tema (menggunakan context.justColors, context.justTypo, dll. di build, dan context.readTheme() di callback).
3. `cli-setup.mdx`: Panduan konfigurasi dan penggunaan CLI tool (`justui init`, `add`, `list`, `diff`, `update`, `create`). Jelaskan cara kerja CLI dalam menyalin kode komponen secara lokal, cara kerja import rewriting, penanganan hash SHA-256 untuk memverifikasi integritas, integrasi pubspec, dan resolusi konflik modifikasi lokal. Catatan: jelaskan bahwa remove dan doctor tidak didukung secara langsung dan berikan solusinya.

Pastikan setiap berkas MDX diawali dengan YAML frontmatter dengan format:
---
title: [Judul Dokumen]
description: [Deskripsi Dokumen]
---

Tulis dokumen-dokumen ini secara lengkap, profesional, dan dalam Bahasa Indonesia yang baik dan benar tanpa TBD atau placeholder. Baca `/home/yourblooo/development/justui/.agents/explorer_m1/analysis.md` untuk informasi teknis yang akurat. Setelah selesai, tulis `handoff.md` di direktori kerjamu `/home/yourblooo/development/justui/.agents/worker_m2` dan kirim pesan penyelesaian ke parent orchestrator.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
