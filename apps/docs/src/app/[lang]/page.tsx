import Link from 'next/link';
import type { Route } from 'next';

export default async function HomePage({
  params,
}: {
  params: Promise<{ lang: string }>;
}) {
  const lang = (await params).lang;

  return (
    <div className="flex min-h-screen flex-col items-center justify-center bg-slate-50 p-6 dark:bg-slate-950">
      <main className="max-w-4xl space-y-8 text-center">
        {/* Header */}
        <div className="space-y-4">
          <h1 className="font-heading text-6xl font-extrabold tracking-tight text-slate-900 dark:text-slate-50">
            Just<span className="text-indigo-600 dark:text-indigo-400">UI</span>
          </h1>
          <p className="mx-auto max-w-2xl text-xl text-slate-600 dark:text-slate-300">
            Flutter UI component library built on the copy-paste philosophy. No
            third-party packages, zero-dependency footprint, and premium
            aesthetics.
          </p>
        </div>

        {/* Action Buttons */}
        <div className="flex justify-center gap-4">
          <Link
            href={`/${lang}/docs/introduction` as Route}
            className="rounded-lg bg-indigo-600 px-6 py-3 font-medium text-white shadow-md transition-colors hover:bg-indigo-700"
          >
            Baca Dokumentasi
          </Link>
          <a
            href="https://github.com/infinitedim/justui"
            target="_blank"
            rel="noopener noreferrer"
            className="rounded-lg border border-slate-200 bg-white px-6 py-3 font-medium text-slate-700 shadow-sm transition-colors hover:bg-slate-100 dark:border-slate-800 dark:bg-slate-900 dark:text-slate-300 dark:hover:bg-slate-800"
          >
            GitHub
          </a>
        </div>

        {/* Scaffolding Code Block */}
        <div className="mx-auto max-w-md rounded-xl border border-slate-800 bg-slate-900 p-6 text-left text-slate-100 shadow-lg">
          <div className="mb-2 flex items-center justify-between font-mono text-xs text-slate-500">
            <span>TERMINAL</span>
            <span>CLI</span>
          </div>
          <pre className="overflow-x-auto font-mono text-sm text-indigo-300">
            <code>dart pub global activate just_ui_cli</code>
          </pre>
          <pre className="mt-1 overflow-x-auto font-mono text-sm text-emerald-400">
            <code>just_ui init</code>
          </pre>
        </div>

        {/* Features Grid */}
        <div className="mt-12 grid gap-6 md:grid-cols-3">
          {/* Card 1 */}
          <div className="rounded-xl border border-slate-200 bg-white p-6 text-left shadow-sm transition-shadow hover:shadow-md dark:border-slate-800 dark:bg-slate-900">
            <h3 className="mb-2 text-lg font-bold text-slate-900 dark:text-slate-50">
              Zero-Dependency
            </h3>
            <p className="text-sm text-slate-600 dark:text-slate-400">
              Semua komponen dibuat murni menggunakan Flutter SDK bawaan,
              menjaga bundle size tetap minimal.
            </p>
          </div>

          {/* Card 2 */}
          <div className="rounded-xl border border-slate-200 bg-white p-6 text-left shadow-sm transition-shadow hover:shadow-md dark:border-slate-800 dark:bg-slate-900">
            <h3 className="mb-2 text-lg font-bold text-slate-900 dark:text-slate-50">
              Copy-Paste Model
            </h3>
            <p className="text-sm text-slate-600 dark:text-slate-400">
              Salin kode komponen langsung ke direktori Anda. Lakukan
              kustomisasi penuh tanpa terikat batasan library eksternal.
            </p>
          </div>

          {/* Card 3 */}
          <div className="rounded-xl border border-slate-200 bg-white p-6 text-left shadow-sm transition-shadow hover:shadow-md dark:border-slate-800 dark:bg-slate-900">
            <h3 className="mb-2 text-lg font-bold text-slate-900 dark:text-slate-50">
              Neobrutalism Style
            </h3>
            <p className="text-sm text-slate-600 dark:text-slate-400">
              Dukungan preset Neobrutalism visual dengan bayangan solid dan
              border tebal untuk UI modern yang memukau.
            </p>
          </div>
        </div>
      </main>
    </div>
  );
}
