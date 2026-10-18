'use client';

// Client leaf: the narrow-screen menu opens and closes.
import { useState } from 'react';
import Link from 'next/link';
import { Menu, X } from 'lucide-react';
import { useSearchContext } from 'fumadocs-ui/contexts/search';
import { localizedHref } from '@/lib/i18n';
import { getSiteDictionary } from '@/lib/site-translations';
import type { SiteNavMenuProps } from './site-nav.types';

const item =
  'text-ip-text-primary flex h-12 w-full items-center text-left text-base font-semibold';

/** Menu button and panel shown below 960px. */
export function SiteNavMenu({ lang, showSearch }: SiteNavMenuProps) {
  const t = getSiteDictionary(lang);
  const [open, setOpen] = useState(false);
  const { setOpenSearch } = useSearchContext();
  const Icon = open ? X : Menu;
  return (
    <div className="min-[960px]:hidden">
      <button
        type="button"
        aria-label={open ? t.closeMenu : t.menu}
        aria-expanded={open}
        aria-controls="site-nav-menu"
        onClick={() => setOpen(!open)}
        className="text-ip-text-primary flex size-10 cursor-pointer items-center justify-center rounded-[8px]"
      >
        <Icon size={20} aria-hidden="true" />
      </button>
      <nav
        id="site-nav-menu"
        aria-label={t.mainNavigation}
        hidden={!open}
        className="bg-ip-canvas border-ip-border-subtle absolute inset-x-0 top-16 flex flex-col border-b px-[clamp(20px,4vw,48px)] pt-2 pb-4"
      >
        <Link href={localizedHref(lang, '/docs/introduction')} className={item}>
          {t.docs}
        </Link>
        <Link
          href={localizedHref(lang, '/docs/components')}
          onClick={() => setOpen(false)}
          className={item}
        >
          {t.components}
        </Link>
        {showSearch ? (
          <button
            type="button"
            // The menu stays open under the dialog so focus can return
            // to this button when search closes.
            onClick={() => setOpenSearch(true)}
            className={item}
          >
            {t.search}
          </button>
        ) : null}
      </nav>
    </div>
  );
}
