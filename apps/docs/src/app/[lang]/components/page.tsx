import { Navbar } from '@/components/navbar';
import { components } from '@/lib/components-data';
import { fetchStarCount } from '@/lib/github';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { ComponentsCatalogClient } from './components-catalog-client';

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
        <div className="mb-10">
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

        {/* Living Component Catalog with Search, Category Filter, and Micro-Simulators */}
        <ComponentsCatalogClient
          components={components}
          lang={lang}
          dictionary={t}
        />
      </main>
    </div>
  );
}

export async function generateStaticParams() {
  return [{ lang: 'id' }, { lang: 'en' }];
}
