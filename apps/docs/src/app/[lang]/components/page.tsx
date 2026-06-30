import Link from 'next/link';
import type { Route } from 'next';
import { Navbar } from '@/components/navbar';
import { components } from '@/lib/components-data';
import { fetchStarCount } from '@/lib/github';
import { getHomepageDictionary } from '@/lib/homepage-translations';

export default async function ComponentsPage({
  params,
}: {
  params: Promise<{ lang: string }>;
}) {
  const { lang } = await params;
  const starCount = await fetchStarCount();
  const t = getHomepageDictionary(lang);

  return (
    <div className="min-h-screen bg-background text-foreground">
      <Navbar starCount={starCount} lang={lang} />

      <main className="mx-auto max-w-6xl px-4 py-16 sm:px-6 lg:px-8">
        {/* Header section */}
        <div className="mb-12">
          <p className="mb-3 font-mono text-sm text-accent">
            {components.length} {t.componentsPageCount}
          </p>
          <h1 className="text-4xl font-medium tracking-tight text-foreground sm:text-5xl">
            {t.componentsPageTitle}
          </h1>
          <p className="mt-4 max-w-xl text-base text-secondary">
            {t.componentsPageDescription}
          </p>
        </div>

        {/* Grid komponen */}
        <div className="grid grid-cols-2 gap-3 md:grid-cols-3 lg:grid-cols-4">
          {components.map((component) => (
            <Link
              key={component.slug}
              href={`/${lang}/docs/components/${component.slug}` as Route}
              className="group rounded-lg border border-border p-4 transition-colors hover:border-accent-dark hover:bg-accent-muted"
            >
              <h2 className="text-sm font-medium text-foreground">
                {component.name}
              </h2>
              <p className="mt-2 text-xs leading-5 text-muted">
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

