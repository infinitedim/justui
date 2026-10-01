import type { MetadataRoute } from 'next';
import { SITE_URL } from '@/lib/site';
import { source } from '@/lib/source';
import { locales, defaultLocale } from '@/lib/i18n';

const BASE_URL = SITE_URL;

export default function sitemap(): MetadataRoute.Sitemap {
  const entries: MetadataRoute.Sitemap = [];

  // Static pages per locale
  for (const lang of locales) {
    // Homepage
    entries.push({
      url: `${BASE_URL}/${lang}`,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: lang === defaultLocale ? 1.0 : 0.8,
    });

    // Components catalog
    entries.push({
      url: `${BASE_URL}/${lang}/components`,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.8,
    });

    // Studio
    entries.push({
      url: `${BASE_URL}/${lang}/studio`,
      lastModified: new Date(),
      changeFrequency: 'monthly',
      priority: 0.7,
    });
  }

  // Documentation pages from fumadocs source
  const pages = source.getPages();
  for (const page of pages) {
    const rawPath =
      page.url ??
      `/${page.locale ?? defaultLocale}${
        page.slugs.length > 0 ? `/docs/${page.slugs.join('/')}` : '/docs'
      }`;
    const cleanPath = rawPath.startsWith('/') ? rawPath : `/${rawPath}`;
    entries.push({
      url: `${BASE_URL}${cleanPath}`,
      lastModified: new Date(),
      changeFrequency: 'weekly',
      priority: 0.7,
    });
  }

  return entries;
}
