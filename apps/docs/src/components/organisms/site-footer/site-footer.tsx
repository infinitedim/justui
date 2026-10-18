import Link from 'next/link';
import { Wordmark } from '@/components/atoms/wordmark';
import { localizedHref } from '@/lib/i18n';
import { GITHUB_URL } from '@/lib/site';
import { getSiteDictionary } from '@/lib/site-translations';
import type { SiteFooterProps } from './site-footer.types';

const link = 'text-ip-text-secondary hover:text-ip-text-primary text-sm';

/** Wordmark, license line and three links. */
export function SiteFooter({ lang }: SiteFooterProps) {
  const t = getSiteDictionary(lang);
  return (
    <footer
      aria-label={t.footerLabel}
      className="border-ip-border-subtle border-t"
    >
      <div className="mx-auto flex max-w-[1440px] flex-wrap items-start justify-between gap-6 px-[clamp(20px,4vw,48px)] py-10">
        <div className="flex flex-col gap-1.5">
          <Wordmark />
          <p className="text-ip-text-secondary text-sm">{t.license}</p>
        </div>
        <nav aria-label={t.footerLabel} className="flex flex-wrap gap-7">
          <Link
            href={localizedHref(lang, '/docs/introduction')}
            className={link}
          >
            {t.docs}
          </Link>
          <Link
            href={{ pathname: localizedHref(lang, ''), hash: 'parts' }}
            className={link}
          >
            {t.components}
          </Link>
          <a href={GITHUB_URL} className={link}>
            {t.github}
          </a>
        </nav>
      </div>
    </footer>
  );
}
