import type { Metadata } from 'next';
import Link from 'next/link';
import { ComponentPreviewGrid } from '@/components/organisms/component-preview-grid';
import { WhatYouGet } from '@/components/organisms/what-you-get';
import { InstallTabs } from '@/components/molecules/install-tabs';
import { HeroInteractive } from '@/components/organisms/hero-interactive';
import { Footer } from '@/components/organisms/footer';
import { Navbar } from '@/components/organisms/navbar';
import { LandingTemplate } from '@/components/templates';
import { fetchStarCount } from '@/lib/github';
import {
  getHomepageDictionary,
  type HomepageDictionary,
} from '@/lib/homepage-translations';
import { localeStaticParams } from '@/lib/i18n';

export async function generateMetadata({
  params,
}: {
  params: Promise<{ lang: string }>;
}): Promise<Metadata> {
  const { lang } = await params;
  const t = getHomepageDictionary(lang);
  return {
    title: t.heroTitle,
    description: t.heroDescription,
    alternates: {
      canonical: `/${lang}`,
      languages: {
        en: '/en',
        id: '/id',
      },
    },
    openGraph: {
      title: `${t.heroTitle} | JustUI`,
      description: t.heroDescription,
      url: `/${lang}`,
    },
  };
}

const ctaBase =
  'just-press inline-flex h-11 items-center justify-center rounded-(--just-radius-md) border-(length:--just-border-width) border-border px-6 text-sm font-medium whitespace-nowrap';

function HeroSection({ lang, t }: { lang: string; t: HomepageDictionary }) {
  return (
    <div className="flex flex-col items-center text-center">
      <p className="text-muted font-mono text-[13px]">{t.tagline}</p>

      <h1 className="text-foreground mt-5 text-4xl leading-none font-medium tracking-tight text-balance sm:text-5xl lg:text-6xl">
        {t.heroTitle}
      </h1>

      <p className="text-secondary mx-auto mt-6 max-w-2xl text-base leading-relaxed text-pretty sm:text-lg">
        {t.heroDescription}
      </p>

      <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
        <Link
          href={`/${lang}/docs/introduction`}
          className={`${ctaBase} bg-accent text-accent-foreground shadow-sm`}
        >
          {t.getStarted}
        </Link>
        <Link
          href={`/${lang}/components`}
          className={`${ctaBase} text-foreground hover:bg-accent-muted bg-transparent`}
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
      <div className="mb-8 flex flex-wrap items-end justify-between gap-4">
        <div>
          <h2 className="text-foreground text-3xl font-medium tracking-tight">
            {t.componentsHeading}
          </h2>
          <p className="text-secondary mt-2 text-[15px]">
            {t.componentsSubheading}
          </p>
        </div>
        <Link
          href={`/${lang}/components`}
          className="text-accent-text font-mono text-[13px] font-medium"
        >
          {t.componentsAll}
        </Link>
      </div>
      <ComponentPreviewGrid lang={lang} />
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
      whatYouGet={<WhatYouGet lang={lang} />}
      componentShowcase={<ComponentShowcase lang={lang} t={t} />}
      footer={<Footer lang={lang} />}
    />
  );
}

export async function generateStaticParams() {
  return localeStaticParams();
}
