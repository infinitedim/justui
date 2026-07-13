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
    <div className="bg-background text-foreground min-h-screen">
      <Navbar starCount={starCount} lang={lang} />

      <main className="mx-auto max-w-6xl px-4 py-16 sm:px-6 lg:px-8">
        {/* Header section */}
        <div className="mb-12">
          <p className="text-accent mb-3 font-mono text-sm">
            {components.length} {t.componentsPageCount}
          </p>
          <h1 className="text-foreground text-4xl font-medium tracking-tight sm:text-5xl">
            {t.componentsPageTitle}
          </h1>
          <p className="text-secondary mt-4 max-w-xl text-base">
            {t.componentsPageDescription}
          </p>
        </div>

        {/* Grid komponen */}
        <div className="grid grid-cols-2 gap-3 md:grid-cols-3 lg:grid-cols-4">
          {components.map((component) => (
            <Link
              key={component.slug}
              href={`/${lang}/docs/components/${component.slug}` as Route}
              className="group border-border hover:border-accent-dark hover:bg-accent-muted rounded-lg border p-4 transition-colors"
            >
              <h2 className="text-foreground text-sm font-medium">
                {component.name}
              </h2>
              <p className="text-muted mt-2 text-xs leading-5">
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
