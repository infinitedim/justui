## 2026-06-23T04:22:34Z
Kamu adalah teamwork_preview_worker. Tugasmu adalah melakukan verifikasi kompilasi dan tipe data untuk website dokumentasi JustUI di `/home/yourblooo/development/justui/apps/docs`.
Secara khusus:
1. Jalankan `bun run type-check` (atau `tsc --project tsconfig.json --pretty --noEmit`) di direktori `apps/docs` dan pastikan tidak ada kesalahan tipe data TypeScript.
2. Jalankan `bun run build` di direktori `apps/docs` untuk memverifikasi bahwa Next.js dan Fumadocs membangun seluruh situs tanpa kesalahan MDX, TypeScript, atau link typedRoutes.
3. Catat output dari perintah tersebut dan laporkan hasilnya secara detail.
4. Tulis `handoff.md` di direktori kerjamu `/home/yourblooo/development/justui/.agents/worker_m7` dan kirim pesan penyelesaian ke parent orchestrator.

MANDATORY INTEGRITY WARNING:
DO NOT CHEAT. All implementations must be genuine. DO NOT hardcode test results, create dummy/facade implementations, or circumvent the intended task. A Forensic Auditor will independently verify your work. Integrity violations WILL be detected and your work WILL be rejected.
