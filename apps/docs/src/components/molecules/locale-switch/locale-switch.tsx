import Link from 'next/link';
import { cn } from '@/lib/cn';
import { locales } from '@/lib/i18n';
import type { LocaleSwitchProps } from './locale-switch.types';

/**
 * EN / ID switch. Each locale is a link (a locale change is a navigation),
 * and the current one carries `aria-current` and the ink fill.
 */
export function LocaleSwitch({
  lang,
  label,
  hrefs,
  className,
}: LocaleSwitchProps) {
  return (
    <div
      role="group"
      aria-label={label}
      className={cn('flex items-center gap-0.5', className)}
    >
      {locales.map((locale) => (
        <Link
          key={locale}
          href={hrefs[locale]}
          hrefLang={locale}
          aria-current={locale === lang ? 'page' : undefined}
          className={cn(
            'flex h-8 items-center rounded-[6px] px-3 text-[13px] font-semibold uppercase transition-colors duration-150',
            locale === lang
              ? 'bg-ip-inverse text-ip-on-inverse'
              : 'text-ip-text-secondary hover:text-ip-text-primary'
          )}
        >
          {locale}
        </Link>
      ))}
    </div>
  );
}
