import type { Metadata } from 'next';
import { notFound } from 'next/navigation';
import { PartsIndex } from '@/components/organisms/parts-index';
import { SiteFooter } from '@/components/organisms/site-footer';
import { SiteNav } from '@/components/organisms/site-nav';
import { InkPaperPage } from '@/components/templates/ink-paper-page';
import { getComponentsPageDictionary } from '@/lib/components-page-translations';
import { formatMessage } from '@/lib/format-message';
import { isLocale, localeStaticParams, localizedHref } from '@/lib/i18n';
import { PART_COUNT } from '@/lib/parts';

const PATH = '/docs/components';

export function generateStaticParams() {
  return localeStaticParams();
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ lang: string }>;
}): Promise<Metadata> {
  const { lang } = await params;
  const t = getComponentsPageDictionary(lang);
  const description = formatMessage(t.metaDescription, { count: PART_COUNT });
  return {
    title: t.metaTitle,
    description,
    alternates: {
      canonical: `/${lang}${PATH}`,
      languages: { en: `/en${PATH}`, id: `/id${PATH}` },
    },
    openGraph: {
      title: `${t.metaTitle} | JustUI`,
      description,
      url: `/${lang}${PATH}`,
    },
  };
}

/**
 * The components page: every part on the runner in the Ink and Paper
 * shell, outside the Fumadocs layout that the `(fumadocs)` group applies
 * to the other docs pages.
 */
export default async function ComponentsPage({
  params,
}: {
  params: Promise<{ lang: string }>;
}) {
  const { lang } = await params;
  if (!isLocale(lang)) notFound();
  const localeHrefs = {
    en: localizedHref('en', PATH),
    id: localizedHref('id', PATH),
  };
  return (
    <InkPaperPage
      nav={<SiteNav lang={lang} localeHrefs={localeHrefs} />}
      footer={<SiteFooter lang={lang} />}
    >
      <PartsIndex lang={lang} />
    </InkPaperPage>
  );
}
