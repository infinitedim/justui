import type { Metadata } from 'next';
import { NotFoundRunner } from '@/components/organisms/not-found-runner';
import { fontVariables } from '@/lib/fonts';
import { notFoundTranslations } from '@/lib/not-found-translations';

export const metadata: Metadata = {
  title: notFoundTranslations.en.metaTitle,
  description: notFoundTranslations.en.description,
};

/**
 * The 404 for every unknown URL, prerendered once at build. Unknown
 * locales and unknown paths under a known locale both land here
 * (`dynamicParams = false` on `[lang]`), so the page reads its locale from
 * the path in the browser. The root layout renders no `<html>`, so this
 * page renders its own.
 */
export default function NotFound() {
  return (
    <html lang="en" suppressHydrationWarning>
      <head />
      <body
        className={`${fontVariables} flex min-h-screen flex-col antialiased`}
      >
        <NotFoundRunner />
      </body>
    </html>
  );
}
