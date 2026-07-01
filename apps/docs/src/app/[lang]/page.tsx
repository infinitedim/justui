import Link from 'next/link';
import { ComponentCard } from '@/components/component-card';
import { ShowcaseFrame } from '@/components/showcase-frame';
import { InstallSnippet } from '@/components/install-snippet';
import { Navbar } from '@/components/navbar';
import { fetchStarCount } from '@/lib/github';
import { components } from '@/lib/components-data';
import { getHomepageDictionary } from '@/lib/homepage-translations';

export default async function HomePage({
  params = Promise.resolve({ lang: 'en' }),
}: {
  params?: Promise<{ lang: string }>;
} = {}) {
  const { lang } = await params;
  const starCount = await fetchStarCount();
  const t = getHomepageDictionary(lang);

  return (
    <div className="min-h-screen bg-background text-foreground">
      <Navbar starCount={starCount} lang={lang} />

      <main>
        <section className="mx-auto flex flex-col items-center justify-center text-center max-w-3xl px-4 py-20 sm:px-6 lg:px-8 lg:py-24">
          <div className="flex flex-col items-center max-w-2xl">
            <p className="text-accent mb-5 font-mono text-sm font-medium">
              {t.tagline}
            </p>
            <h1 className="text-5xl font-medium tracking-tight text-foreground sm:text-6xl lg:text-7xl">
              {t.heroTitle}
            </h1>
            <p className="mt-6 text-lg leading-8 text-secondary">
              {t.heroDescription}
            </p>

            <div className="mt-8 flex flex-col gap-3 sm:flex-row justify-center">
              <Link
                href={`/${lang}/docs/introduction`}
                className="bg-accent hover:bg-accent-deep inline-flex h-10 items-center justify-center rounded-md px-4 text-sm font-medium text-[#1a2e05] transition-colors"
              >
                {t.getStarted}
              </Link>
              <Link
                href={`/${lang}/docs/components`}
                className="hover:border-accent-dark hover:bg-accent-muted inline-flex h-10 items-center justify-center rounded-md border border-border bg-transparent px-4 text-sm font-medium text-foreground transition-colors"
              >
                {t.browseComponents}
              </Link>
            </div>

            <div className="mt-6 w-full">
              <InstallSnippet lang={lang} />
            </div>
          </div>
        </section>

        <section className="w-full border-y border-border py-4 bg-muted/10">
          <ShowcaseFrame />
        </section>

        <section className="mx-auto max-w-6xl px-4 py-16 sm:px-6 lg:px-8">
          <h2 className="mb-8 text-2xl font-medium text-foreground">
            {t.componentsHeading}
          </h2>
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-5">
            {components.map((component) => (
              <ComponentCard
                key={component.slug}
                component={component}
                lang={lang}
              />
            ))}
          </div>
        </section>
      </main>
    </div>
  );
}

