import Link from 'next/link';
import type { Route } from 'next';
import { Navbar } from '@/components/navbar';
import { components } from '@/lib/components-data';
import { fetchStarCount } from '@/lib/github';

export default async function ComponentsPage({
  params,
}: {
  params: Promise<{ lang: string }>;
}) {
  const { lang } = await params;
  const starCount = await fetchStarCount();

  return (
    <div className="min-h-screen bg-black text-white">
      <Navbar starCount={starCount} lang={lang} />

      <main className="mx-auto max-w-6xl px-4 py-16 sm:px-6 lg:px-8">
        {/* Header section */}
        <div className="mb-12">
          <p className="mb -3 font-mono text-sm text-(--color-accent)">
            {components.length} komponen tersedia
          </p>
          <h1 className="text-4xl font-medium tracking-tight text-white sm:text-5xl">
            Components
          </h1>
          <p className="mt-4 max-w-xl text-base text-(--color-gray-2)">
            Semua komponen siap pakai. Copy, paste, dan sesuaikan langsung di
            project Flutter kamu.
          </p>
        </div>

        {/* Grid komponen */}
        <div className="grid grid-cols-2 gap-3 md:grid-cols-3 lg:grid-cols-4">
          {components.map((component) => (
            <Link
              key={component.slug}
              href={`/${lang}/docs/components/${component.slug}` as Route}
              className="group rounded-lg border border-[rgb(51_51_51/0.3)] p-4 transition-colors hover:border-(--color-accent-dark) hover:bg-(--color-accent-muted)"
            >
              <h2 className="text-sm font-medium text-white">
                {component.name}
              </h2>
              <p className="mt-2 text-xs leading-5 text-(--color-gray-2)">
                {component.description}
              </p>
            </Link>
          ))}
        </div>
      </main>
    </div>
  );
}

export async function generateStaticParams() {
  return [{ lang: 'id' }, { lang: 'en' }];
}
