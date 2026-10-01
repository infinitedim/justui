'use client';

import { useSyncExternalStore } from 'react';
import Link from 'next/link';
import { RootProvider } from 'fumadocs-ui/provider/next';
import { i18nProvider } from 'fumadocs-ui/i18n';
import { Navbar } from '@/components/organisms/navbar';
import { Footer } from '@/components/organisms/footer';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { defaultLocale, isLocale, localizedHref } from '@/lib/i18n';
import { translations } from '@/lib/layout.shared';

const noopSubscribe = () => () => {};

/**
 * Body of the root 404. It renders outside the [lang] layout, so it reads
 * the locale from the URL after hydration (/id/... stays Indonesian) and mounts the same
 * fumadocs provider the [lang] layout uses, which the navbar search needs.
 */
export function NotFoundView({ starCount }: { starCount: number | null }) {
  // The 404 is prerendered once, so the server cannot know the locale. The
  // server snapshot keeps hydration in English, then the URL decides.
  const segment = useSyncExternalStore(
    noopSubscribe,
    () => window.location.pathname.split('/')[1] ?? '',
    () => ''
  );
  const lang = isLocale(segment) ? segment : defaultLocale;
  const t = getHomepageDictionary(lang);

  const links = [
    { href: localizedHref(lang, ''), label: t.notFoundHome },
    { href: localizedHref(lang, '/docs/introduction'), label: t.navDocs },
    { href: localizedHref(lang, '/components'), label: t.navComponents },
    { href: localizedHref(lang, '/studio'), label: t.navStudio },
  ];

  return (
    <RootProvider
      theme={{ enabled: false }}
      i18n={i18nProvider(translations, lang)}
      search={{ enabled: false }}
    >
      <div className="bg-background text-foreground flex min-h-screen flex-col">
        <Navbar starCount={starCount} lang={lang} />
        <main className="mx-auto w-full max-w-6xl flex-1 px-4 py-24 sm:px-6 lg:px-8">
          <p className="text-secondary font-mono text-sm">404</p>
          <h1 className="text-foreground mt-3 text-4xl font-medium tracking-tight sm:text-5xl">
            {t.notFoundTitle}
          </h1>
          <p className="text-secondary mt-4 max-w-xl text-base">
            {t.notFoundBody}
          </p>
          <ul className="mt-6 flex flex-wrap gap-x-6 gap-y-2 text-base">
            {links.map((link) => (
              <li key={link.href}>
                <Link
                  href={link.href}
                  className="text-accent-text font-medium underline underline-offset-4"
                >
                  {link.label}
                </Link>
              </li>
            ))}
          </ul>
        </main>
        <Footer lang={lang} />
      </div>
    </RootProvider>
  );
}
