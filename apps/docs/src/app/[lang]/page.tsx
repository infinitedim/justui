import Link from 'next/link';
import { ComponentCard } from '@/components/component-card';
import { BentoGrid } from '@/components/organisms/bento';
import { InstallTabs } from '@/components/molecules/install-tabs';
import { HeroInteractive } from '@/components/organisms/hero-interactive';
import { Footer } from '@/components/organisms/footer';
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
        {/* Asymmetric Split Hero */}
        <section className="mx-auto flex min-h-[calc(100dvh-4rem)] max-w-7xl flex-col justify-center px-4 py-12 sm:px-6 lg:px-8 lg:py-16">
          <div className="grid grid-cols-1 items-center gap-12 lg:grid-cols-12 lg:gap-8">
            {/* Left Col (5 cols): Narrative & Actions */}
            <div className="flex flex-col items-start text-left lg:col-span-5">
              <div className="border-border/80 bg-muted/30 mb-6 inline-flex items-center gap-2 rounded-full border px-3 py-1">
                <span className="bg-accent h-2 w-2 rounded-full" aria-hidden="true" />
                <span className="text-muted font-mono text-xs font-medium">
                  {t.tagline}
                </span>
              </div>
              <h1 className="text-foreground text-4xl font-medium tracking-tight sm:text-5xl lg:text-6xl">
                {t.heroTitle}
              </h1>
              <p className="text-secondary mt-5 max-w-lg text-base leading-relaxed sm:text-lg">
                {t.heroDescription}
              </p>

              <div className="mt-8 flex flex-wrap items-center gap-3">
                <Link
                  href={`/${lang}/docs/introduction`}
                  className="bg-accent hover:bg-accent-deep text-accent-foreground shadow-solid inline-flex h-10 items-center justify-center rounded-md px-5 text-sm font-medium transition-colors"
                >
                  <span>{t.getStarted}</span>
                  <svg
                    className="ml-2 h-4 w-4"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                    strokeWidth={2}
                    aria-hidden="true"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      d="M14 5l7 7m0 0l-7 7m7-7H3"
                    />
                  </svg>
                </Link>
                <Link
                  href={`/${lang}/components`}
                  className="hover:border-accent-dark hover:bg-accent-muted border-border text-foreground inline-flex h-10 items-center justify-center rounded-md border bg-transparent px-5 text-sm font-medium transition-colors"
                >
                  {t.browseComponents}
                </Link>
              </div>
            </div>

            {/* Right Col (7 cols): Interactive Workbench */}
            <div className="w-full lg:col-span-7">
              <HeroInteractive lang={lang} />
            </div>
          </div>
        </section>

        {/* Quick Install Strip */}
        <section className="border-border/60 bg-muted/10 border-y py-10">
          <div className="mx-auto max-w-4xl px-4 sm:px-6 lg:px-8">
            <InstallTabs lang={lang} />
          </div>
        </section>

        {/* Bento Grid */}
        <section className="mx-auto max-w-6xl px-4 py-20 sm:px-6 lg:px-8">
          <BentoGrid lang={lang} />
        </section>

        {/* Component Showcase Grid */}
        <section className="mx-auto max-w-6xl px-4 pb-24 sm:px-6 lg:px-8">
          <h2 className="text-foreground mb-8 text-2xl font-medium tracking-tight">
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

      <Footer lang={lang} />
    </div>
  );
}
