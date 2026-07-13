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
    <div className="bg-background text-foreground min-h-screen">
      <Navbar starCount={starCount} lang={lang} />

      <main>
        <section className="mx-auto flex max-w-3xl flex-col items-center justify-center px-4 py-20 text-center sm:px-6 lg:px-8 lg:py-24">
          <div className="flex max-w-2xl flex-col items-center">
            <p className="text-accent mb-5 font-mono text-sm font-medium">
              {t.tagline}
            </p>
            <h1 className="text-foreground text-5xl font-medium tracking-tight sm:text-6xl lg:text-7xl">
              {t.heroTitle}
            </h1>
            <p className="text-secondary mt-6 text-lg leading-8">
              {t.heroDescription}
            </p>

            <div className="mt-8 flex flex-col justify-center gap-3 sm:flex-row">
              <Link
                href={`/${lang}/docs/introduction`}
                className="bg-accent hover:bg-accent-deep inline-flex h-10 items-center justify-center rounded-md px-4 text-sm font-medium text-[#1a2e05] transition-colors"
              >
                {t.getStarted}
              </Link>
              <Link
                href={`/${lang}/docs/components`}
                className="hover:border-accent-dark hover:bg-accent-muted border-border text-foreground inline-flex h-10 items-center justify-center rounded-md border bg-transparent px-4 text-sm font-medium transition-colors"
              >
                {t.browseComponents}
              </Link>
            </div>

            <div className="mt-6 w-full">
              <InstallSnippet lang={lang} />
            </div>
          </div>
        </section>

        <section className="border-border bg-muted/10 w-full border-y py-4">
          <ShowcaseFrame />
        </section>

        <section className="mx-auto max-w-6xl px-4 py-16 sm:px-6 lg:px-8">
          <h2 className="text-foreground mb-8 text-2xl font-medium">
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
