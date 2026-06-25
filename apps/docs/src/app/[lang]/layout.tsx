import { RootProvider } from 'fumadocs-ui/provider/next';
import { i18nProvider } from 'fumadocs-ui/i18n';
import { translations } from '@/lib/layout.shared';
import { HtmlLang } from '@/components/html-lang';
import type { ReactNode } from 'react';

export default async function LangLayout({
  params,
  children,
}: {
  params: Promise<{ lang: string }>;
  children: ReactNode;
}) {
  const lang = (await params).lang;

  return (
    <>
      {/* Update <html lang> on the client whenever the locale changes */}
      <HtmlLang lang={lang} />
      {/*
       * theme={{ enabled: false }} — ThemeProvider is already mounted in the
       * root layout. Disabling it here prevents a second (re-rendering) ThemeProvider
       * from being created on every locale navigation, which is what caused the
       * React 19 "Encountered a script tag" warning.
       */}
      <RootProvider
        theme={{ enabled: false }}
        i18n={i18nProvider(translations, lang)}
      >
        {children}
      </RootProvider>
    </>
  );
}
