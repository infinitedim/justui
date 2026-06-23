## 2026-06-23T04:12:37Z

Kamu adalah teamwork_preview_worker. Tugasmu adalah menulis 4 dokumen token desain di `/home/yourblooo/development/justui/apps/docs/content/docs/tokens/` dalam Bahasa Indonesia:
1. `colors.mdx`: Katalog palet warna & kontras rasio accessibility. Jelaskan skema warna mode terang/gelap, bagaimana extension `contrastRatioWith` dan `isAccessibleWith` digunakan untuk memverifikasi rasio kontras sesuai standar WCAG AA (>= 4.5:1 untuk teks normal, >= 3.0:1 untuk komponen/teks besar).
2. `typography.mdx`: Skala tipografi (font size, weight, line-height) menggunakan Inter dan JetBrains Mono. Jelaskan tentang Fluid Typography (`JustFluidTypography`) yang menskalakan ukuran font secara linier antara min/max screen width (640px hingga 1024px) serta adaptasi line height dinamis.
3. `spacing.mdx`: Nilai spacing, margin, dan padding berbasis kisi 4px (dari xxs 2px hingga huge 64px), serta kelas pembantu `JustGap` dan `JustSpacing.insets()`.
4. `shadows.mdx`: Galeri bayangan solid (neobrutalism) dan bayangan bertumpuk dua lapis (multi-layer shadows) untuk mode terang/gelap, termasuk cara generator bayangan warna seed bekerja.

Pastikan setiap berkas MDX diawali dengan YAML frontmatter dengan format:
---
title: [Judul Dokumen]
description: [Deskripsi Dokumen]
---

Tulis dokumen-dokumen ini secara lengkap, profesional, dan dalam Bahasa Indonesia yang baik dan benar tanpa TBD atau placeholder. Baca `/home/yourblooo/development/justui/.agents/explorer_m1/analysis.md` untuk informasi teknis yang akurat. Setelah selesai, tulis `handoff.md` di direktori kerjamu `/home/yourblooo/development/justui/.agents/worker_m3` dan kirim pesan penyelesaian ke parent orchestrator.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
