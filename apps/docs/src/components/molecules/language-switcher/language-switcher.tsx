'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/cn';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { switchLocalePath, type Locale } from '@/lib/i18n';
import type { LanguageSwitcherProps } from './language-switcher.types';

/**
 * Language switcher molecule. Swaps between en/id by rewriting the URL path segment.
 * Styled as a small button so it matches the preset / theme toggles.
 */
export function LanguageSwitcher({ lang, className }: LanguageSwitcherProps) {
  const pathname = usePathname() ?? '';
  const otherLang: Locale = lang === 'en' ? 'id' : 'en';
  const otherLabel = otherLang.toUpperCase();
  const t = getHomepageDictionary(lang);
  const otherPath = switchLocalePath(pathname, otherLang);

  return (
    <Link
      href={otherPath}
      className={cn(
        'just-press bg-card text-foreground inline-flex h-7 items-center px-2.5 font-mono text-xs',
        'rounded-(--just-radius-md) border-(length:--just-border-width) border-border shadow-xs',
        className
      )}
      aria-label={t.changeLanguage}
    >
      {otherLabel}
    </Link>
  );
}
