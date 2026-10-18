import Link from 'next/link';
import { GitHubMark } from '@/components/atoms/github-mark';
import { Wordmark } from '@/components/atoms/wordmark';
import { LocaleSwitch } from '@/components/molecules/locale-switch';
import { SearchTrigger } from '@/components/molecules/search-trigger';
import { ThemeToggle } from '@/components/molecules/theme-toggle';
import { localizedHref } from '@/lib/i18n';
import { GITHUB_URL } from '@/lib/site';
import { getSiteDictionary } from '@/lib/site-translations';
import { SiteNavMenu } from './site-nav-menu';
import type { SiteNavProps } from './site-nav.types';

const navLink =
  'text-ip-text-secondary hover:text-ip-text-primary text-sm font-medium';

/**
 * Sticky page nav for the landing and the 404. Below 960px the links and
 * search move into the menu panel. Show/hide uses a max/min variant pair
 * with no base display class: fumadocs-ui/style.css ships its own `.flex`,
 * `.hidden` and `.sr-only` later in the utilities layer, and those beat a
 * media variant on the same element.
 */
export function SiteNav({
  lang,
  localeHrefs,
  showSearch = true,
  prefetchLocales,
}: SiteNavProps) {
  const t = getSiteDictionary(lang);
  return (
    <header
      data-raster-sticky
      className="bg-ip-canvas border-ip-border-subtle sticky top-0 z-30 h-16 border-b"
    >
      <div className="mx-auto flex h-full max-w-[1440px] items-center justify-between gap-4 px-[clamp(20px,4vw,48px)]">
        <div className="flex items-center gap-10">
          <Link href={localizedHref(lang, '')} aria-label={t.homeLabel}>
            <Wordmark />
          </Link>
          <nav
            aria-label={t.mainNavigation}
            className="items-center gap-7 max-[960px]:hidden min-[960px]:flex"
          >
            <Link
              href={localizedHref(lang, '/docs/introduction')}
              className={navLink}
            >
              {t.docs}
            </Link>
            <Link
              href={{ pathname: localizedHref(lang, ''), hash: 'parts' }}
              className={navLink}
            >
              {t.components}
            </Link>
          </nav>
        </div>
        <div className="flex items-center gap-1.5">
          {showSearch ? (
            <div className="max-[960px]:hidden">
              <SearchTrigger label={t.search} />
            </div>
          ) : null}
          <LocaleSwitch
            lang={lang}
            label={t.language}
            hrefs={localeHrefs}
            prefetch={prefetchLocales}
          />
          <ThemeToggle toDarkLabel={t.toDark} toLightLabel={t.toLight} />
          <a
            href={GITHUB_URL}
            className="text-ip-text-secondary hover:bg-ip-hover hover:text-ip-text-primary flex h-9 items-center gap-2 rounded-[8px] px-2.5 text-sm font-medium"
          >
            <GitHubMark size={18} />
            <span className="max-[960px]:sr-only">{t.github}</span>
          </a>
          <SiteNavMenu lang={lang} showSearch={showSearch} />
        </div>
      </div>
    </header>
  );
}
