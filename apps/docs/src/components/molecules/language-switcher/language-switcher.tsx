'use client';

import Link from 'next/link';
import type { Route } from 'next';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/cn';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import type { LanguageSwitcherProps } from './language-switcher.types';

/**
 * Language switcher molecule. Swaps between en/id by rewriting the URL path segment.
 * Extracted from the old navbar LanguageSwitcher.
 */
export function LanguageSwitcher({ lang, className }: LanguageSwitcherProps) {
  const pathname = usePathname() ?? '';
  const otherLang = lang === 'en' ? 'id' : 'en';
  const otherLabel = lang === 'en' ? 'ID' : 'EN';
  const t = getHomepageDictionary(lang);

  const otherPath = pathname
    ? pathname.replace(new RegExp(`^/(id|en)(?=/|$)`), `/${otherLang}`)
    : `/${otherLang}`;

  return (
    <Link
      href={otherPath as Route}
      className={cn(
        'inline-flex h-7 items-center rounded-full px-2.5 font-mono text-[11px] transition-colors',
        'border-border border-(length:--just-border-width)',
        'text-muted hover:text-foreground',
        className
      )}
      aria-label={t.changeLanguage}
    >
      {otherLabel}
    </Link>
  );
}
