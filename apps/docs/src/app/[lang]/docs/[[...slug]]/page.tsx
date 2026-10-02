import { source } from '@/lib/source';
import {
  DocsPage,
  DocsBody,
  DocsTitle,
  DocsDescription,
} from 'fumadocs-ui/page';
import type { Metadata } from 'next';
import { notFound, redirect } from 'next/navigation';

import defaultMdxComponents from 'fumadocs-ui/mdx';
import { Tab, Tabs } from 'fumadocs-ui/components/tabs';
import { ButtonPlayground } from '@/components/docs/button-playground';
import { CheckoutDemo } from '@/components/docs/checkout-demo';
import { JustButtonPreview } from '@/components/docs/just-button-preview';

export async function generateMetadata({
  params,
}: {
  params: Promise<{ lang: string; slug?: string[] }>;
}): Promise<Metadata> {
  const { lang, slug } = await params;
  if (!slug || slug.length === 0) return {};
  const page = source.getPage(slug, lang);
  if (!page) return {};

  const cleanSlug = slug.join('/');
  const url = `/${lang}/docs/${cleanSlug}`;

  return {
    title: page.data.title,
    description: page.data.description,
    alternates: {
      canonical: url,
      languages: {
        en: `/en/docs/${cleanSlug}`,
        id: `/id/docs/${cleanSlug}`,
      },
    },
    openGraph: {
      title: `${page.data.title} | JustUI`,
      description: page.data.description,
      url,
      type: 'article',
    },
  };
}

export default async function Page({
  params,
}: {
  params: Promise<{ lang: string; slug?: string[] }>;
}) {
  const { lang, slug } = await params;
  if (!slug || slug.length === 0) {
    redirect(`/${lang}/docs/introduction`);
  }
  const page = source.getPage(slug, lang);

  if (!page) {
    notFound();
  }

  const MDX = page.data.body;

  return (
    <DocsPage toc={page.data.toc} full={page.data.full}>
      <DocsTitle>{page.data.title}</DocsTitle>
      <DocsDescription>{page.data.description}</DocsDescription>
      <DocsBody>
        <MDX
          components={{
            ...defaultMdxComponents,
            Tabs,
            Tab,
            ButtonPlayground,
            CheckoutDemo,
            JustButtonPreview,
          }}
        />
      </DocsBody>
    </DocsPage>
  );
}

export async function generateStaticParams() {
  return source.generateParams();
}
