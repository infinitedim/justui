import Link from 'next/link';
import { ComponentCard } from '@/components/component-card';
import { BentoGrid } from '@/components/organisms/bento';
import { InstallTabs } from '@/components/molecules/install-tabs';
import { HeroInteractive } from '@/components/organisms/hero-interactive';
import { Footer } from '@/components/organisms/footer';
import { Navbar } from '@/components/navbar';
import { LandingTemplate } from '@/components/templates';
import { fetchStarCount } from '@/lib/github';
import { components } from '@/lib/components-data';
import {
  getHomepageDictionary,
  type HomepageDictionary,
} from '@/lib/homepage-translations';
import { localeStaticParams } from '@/lib/i18n';

function HeroSection({ lang, t }: { lang: string; t: HomepageDictionary }) {
  return (
    <div className="flex flex-col items-center text-center">
      {/* Eyebrow badge: Monospace pill with live accent pulse dot */}
      <div className="border-border/80 bg-muted/20 mb-8 inline-flex items-center gap-2.5 rounded-full border px-3.5 py-1.5 transition-colors">
        <span className="relative flex h-2 w-2" aria-hidden="true">
          <span className="bg-accent absolute inline-flex h-full w-full animate-ping rounded-full opacity-75" />
          <span className="bg-accent relative inline-flex h-2 w-2 rounded-full" />
        </span>
        <span className="text-muted font-mono text-xs font-medium">
          {t.tagline}
        </span>
      </div>

      {/* Headline */}
      <h1 className="text-foreground text-5xl font-medium tracking-tight sm:text-6xl lg:text-7xl">
        {t.heroTitle}
      </h1>

      {/* Subtitle */}
      <p className="text-secondary mx-auto mt-6 max-w-2xl text-center text-base leading-relaxed sm:text-lg">
        {t.heroDescription}
      </p>

      {/* Action buttons */}
      <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
        <Link
          href={`/${lang}/docs/introduction`}
          className="bg-accent hover:bg-accent-deep text-accent-foreground shadow-solid inline-flex h-11 items-center justify-center rounded-md px-6 text-sm font-medium transition-all duration-150 hover:-translate-y-0.5 active:translate-y-0 active:scale-[0.98]"
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
          className="hover:border-accent-dark hover:bg-accent-muted border-border text-foreground inline-flex h-11 items-center justify-center rounded-md border bg-transparent px-6 text-sm font-medium transition-all duration-150 hover:-translate-y-0.5 active:translate-y-0 active:scale-[0.98]"
        >
          {t.browseComponents}
        </Link>
      </div>
    </div>
  );
}

function ComponentShowcase({
  lang,
  t,
}: {
  lang: string;
  t: HomepageDictionary;
}) {
  return (
    <>
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
    </>
  );
}

export default async function HomePage({
  params,
}: {
  params: Promise<{ lang: string }>;
}) {
  const { lang } = await params;
  const starCount = await fetchStarCount();
  const t = getHomepageDictionary(lang);

  return (
    <LandingTemplate
      navbar={<Navbar starCount={starCount} lang={lang} />}
      hero={<HeroSection lang={lang} t={t} />}
      workbench={<HeroInteractive lang={lang} />}
      installStrip={<InstallTabs lang={lang} />}
      bentoGrid={<BentoGrid lang={lang} />}
      componentShowcase={<ComponentShowcase lang={lang} t={t} />}
      footer={<Footer lang={lang} />}
    />
  );
}

export async function generateStaticParams() {
  return localeStaticParams();
}
