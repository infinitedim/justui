import { Navbar } from '@/components/organisms/navbar';
import { Footer } from '@/components/organisms/footer';
import { CatalogTemplate } from '@/components/templates';
import { components } from '@/lib/components-data';
import { fetchStarCount } from '@/lib/github';
import {
  getHomepageDictionary,
  type HomepageDictionary,
} from '@/lib/homepage-translations';
import { ComponentsCatalogClient } from './components-catalog-client';
import { localeStaticParams } from '@/lib/i18n';

function CatalogHeader({ t, count }: { t: HomepageDictionary; count: number }) {
  return (
    <>
      <p className="text-accent mb-3 font-mono text-sm">
        {count} {t.componentsPageCount}
      </p>
      <h1 className="text-foreground text-4xl font-medium tracking-tight sm:text-5xl">
        {t.componentsPageTitle}
      </h1>
      <p className="text-secondary mt-4 max-w-xl text-base">
        {t.componentsPageDescription}
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
