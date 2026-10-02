import type { Metadata } from 'next';
import { Navbar } from '@/components/organisms/navbar';
import { Footer } from '@/components/organisms/footer';
import { CatalogTemplate } from '@/components/templates';
import { components } from '@/lib/components-data';
import { fetchStarCount } from '@/lib/github';
import {
  formatMessage,
  getHomepageDictionary,
  type HomepageDictionary,
} from '@/lib/homepage-translations';
import { ComponentsCatalogClient } from './components-catalog-client';
import { localeStaticParams } from '@/lib/i18n';

export async function generateMetadata({
  params,
}: {
  params: Promise<{ lang: string }>;
}): Promise<Metadata> {
  const { lang } = await params;
  const t = getHomepageDictionary(lang);
  const url = `/${lang}/components`;

  return {
    title: t.componentsPageTitle,
    description: formatMessage(t.componentsPageDescription, {
      count: components.length,
    }),
    alternates: {
      canonical: url,
      languages: {
        en: '/en/components',
        id: '/id/components',
      },
    },
    openGraph: {
      title: `${t.componentsPageTitle} | JustUI`,
      description: formatMessage(t.componentsPageDescription, {
        count: components.length,
      }),
      url,
    },
  };
}

function CatalogHeader({ t, count }: { t: HomepageDictionary; count: number }) {
  return (
    <>
      <h1 className="text-foreground text-4xl font-medium tracking-tight sm:text-5xl">
        {t.componentsPageTitle}
      </h1>
      <p className="text-secondary mt-4 max-w-xl text-base">
        {formatMessage(t.componentsPageDescription, { count })}
      </p>
    </>
  );
}

export default async function ComponentsPage({
  params,
}: {
  params: Promise<{ lang: string }>;
}) {
  const { lang } = await params;
  const starCount = await fetchStarCount();
  const t = getHomepageDictionary(lang);

  return (
    <CatalogTemplate
      navbar={<Navbar starCount={starCount} lang={lang} />}
      header={<CatalogHeader t={t} count={components.length} />}
      catalog={
        <ComponentsCatalogClient
          components={components}
          lang={lang}
          dictionary={t}
        />
      }
      footer={<Footer lang={lang} />}
    />
  );
}

export async function generateStaticParams() {
  return localeStaticParams();
}
