'use client';

import { useEffect } from 'react';

/**
 * Sets document.documentElement.lang on the client.
 * Required because <html lang> is now rendered in the root layout (which doesn't
 * know the locale), so we update it here to keep the attribute correct for
 * accessibility and SEO after hydration.
 */
export function HtmlLang({ lang }: { lang: string }) {
  useEffect(() => {
    document.documentElement.lang = lang;
  }, [lang]);

  return null;
}
