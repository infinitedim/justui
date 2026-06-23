## 2026-06-23T04:12:37Z

Kamu adalah teamwork_preview_worker. Tugasmu adalah menulis 5 dokumen panduan lanjutan di `/home/yourblooo/development/justui/apps/docs/content/docs/guides/` dalam Bahasa Indonesia:
1. `copy-paste-workflow.mdx`: Cara kerja model copy-paste komponen. Jelaskan mengapa JustUI memilih model copy-paste dibandingkan package pub.dev pihak ketiga, fleksibilitas modifikasi, zero-dependency, dan alur integrasi CLI.
2. `custom-theme.mdx`: Deep dive penyesuaian tema kustom & dynamic contrast. Jelaskan bagaimana menggunakan `JustThemeData.fromSeed` untuk menghasilkan tema dari satu warna seed merek, cara algoritma binary search lightness adjustment berjalan untuk menjamin kontras minimum >= 3.0:1 tanpa merusak warna asal, dan kapan adjustment ini di-bypass (preset neobrutalism).
3. `accessibility.mdx`: Pedoman aksesibilitas kontras WCAG AA. Jelaskan implementasi audit kontras di JustUI, pentingnya target sentuh minimal 48x48px, pembaca layar (semantics/aria-like), dan traversal keyboard.
4. `responsive-design.mdx`: Layout breakpoints (mobile, tablet, desktop) menggunakan `JustBreakpoints`. Jelaskan nilai batas breakpoints (sm 640px, md 768px, lg 1024px, xl 1280px, xxl 1536px) serta responsivitas bawaan komponen (seperti auto-collapse sidebar).
5. `migration.mdx`: Panduan migrasi versi. Jelaskan bagaimana mendeteksi versi komponen lokal vs remote menggunakan hash internal metadata yang diinjeksikan CLI, penyelesaian konflik jika ada modifikasi lokal, dan cara memperbarui komponen menggunakan perintah `justui diff` dan `justui update`.

Pastikan setiap berkas MDX diawali dengan YAML frontmatter dengan format:
---
title: [Judul Dokumen]
description: [Deskripsi Dokumen]
---

Tulis dokumen-dokumen ini secara lengkap, profesional, dan dalam Bahasa Indonesia yang baik dan benar tanpa TBD atau placeholder. Baca `/home/yourblooo/development/justui/.agents/explorer_m1/analysis.md` untuk informasi teknis yang akurat. Setelah selesai, tulis `handoff.md` di direktori kerjamu `/home/yourblooo/development/justui/.agents/worker_m4` dan kirim pesan penyelesaian ke parent orchestrator.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
