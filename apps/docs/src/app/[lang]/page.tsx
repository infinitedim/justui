import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { LandingHero } from '@/components/organisms/landing-hero';
import { SiteFooter } from '@/components/organisms/site-footer';
import { SiteNav } from '@/components/organisms/site-nav';
import { InstallOsProvider } from '@/components/providers/install-os-provider';
import { InkPaperPage } from '@/components/templates/ink-paper-page';
import { isLocale, localeStaticParams, localizedHref } from '@/lib/i18n';
import { getLandingDictionary } from '@/lib/landing-translations';

export function generateStaticParams() {
  return localeStaticParams();
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ lang: string }>;
}): Promise<Metadata> {
  const { lang } = await params;
  const t = getLandingDictionary(lang);
  return {
    title: t.metaTitle,
    description: t.heroDescription,
    alternates: {
      canonical: `/${lang}`,
      languages: { en: '/en', id: '/id' },
    },
    openGraph: {
      title: `${t.metaTitle} | JustUI`,
      description: t.heroDescription,
      url: `/${lang}`,
    },
  };
}

export default async function HomePage({
  params,
}: {
  params: Promise<{ lang: string }>;
}) {
  const { lang } = await params;
  if (!isLocale(lang)) notFound();
  const localeHrefs = {
    en: localizedHref('en', ''),
    id: localizedHref('id', ''),
  };
  return (
    <InkPaperPage
      nav={<SiteNav lang={lang} localeHrefs={localeHrefs} />}
      footer={<SiteFooter lang={lang} />}
    >
      <InstallOsProvider>
        <LandingHero lang={lang} />
      </InstallOsProvider>
    </InkPaperPage>
  );
}
