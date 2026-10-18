import { RootProvider } from 'fumadocs-ui/provider/next';
import { i18nProvider } from 'fumadocs-ui/i18n';
import { translations } from '@/lib/layout.shared';
import { HtmlLang } from '@/components/html-lang';
import { notFound } from 'next/navigation';
import { isLocale, localeStaticParams } from '@/lib/i18n';
import type { ReactNode } from 'react';
import { fontVariables } from '@/lib/fonts';

/**
 * Only the statically known locales are valid `[lang]` segments.
 * Any other value (e.g. `/fr`, `/robots.txt`, `/wp-login.php`) triggers 404.
 */
export const dynamicParams = false;

export function generateStaticParams() {
  return localeStaticParams();
}

export default async function LangLayout({
  params,
  children,
}: {
  params: Promise<{ lang: string }>;
  children: ReactNode;
}) {
  const lang = (await params).lang;

  // Belt-and-suspenders guard: dynamicParams=false handles the normal case,
  // but this protects against edge cases in development/ISR revalidation.
  if (!isLocale(lang)) notFound();

  return (
    <html lang={lang} suppressHydrationWarning>
      <head />
      <body
        className={`${fontVariables} bg-background text-foreground flex min-h-screen flex-col font-sans antialiased`}
      >
        {/* Update <html lang> on client-side route transitions */}
        <HtmlLang lang={lang} />
        {/*
         * theme={{ enabled: false }} -- ThemeProvider is already mounted in the
         * root layout. Disabling it here prevents a second (re-rendering) ThemeProvider
         * from being created on every locale navigation, which is what caused the
         * React 19 "Encountered a script tag" warning.
         */}
        <RootProvider
          theme={{ enabled: false }}
          i18n={i18nProvider(translations, lang)}
          // The app provides its own Ctrl+K search UI (Navbar ->
          // CustomSearchDialog). Without this, fumadocs' own default search
          // dialog stays mounted and bound to the same hotkey, so Ctrl+K opens
          // two independent, unstyled-vs-styled dialogs at once.
          search={{ enabled: false }}
        >
          {children}
        </RootProvider>
      </body>
    </html>
  );
}
