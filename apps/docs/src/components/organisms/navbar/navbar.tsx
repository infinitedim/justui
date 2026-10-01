'use client';

import { Menu, Search, X } from 'lucide-react';
import Link from 'next/link';
import type { Route } from 'next';
import { usePathname } from 'next/navigation';
import { useEffect, useMemo, useState } from 'react';
import { githubUrl } from '@/lib/github';
import { localizedHref } from '@/lib/i18n';
import { isApplePlatform } from '@/lib/platform';
import { GitHubPill } from '@/components/molecules/github-pill';
import { LanguageSwitcher } from '@/components/molecules/language-switcher';
import { PresetToggle } from '@/components/molecules/preset-toggle';
import { SearchBar } from '@/components/molecules/search-bar';
import { ThemeSwitcher } from '@/components/molecules/theme-switcher';
import CustomSearchDialog from '@/components/search';
import { getHomepageDictionary } from '@/lib/homepage-translations';

import type { NavbarProps } from './navbar.types';

/** Icon-only header button (mobile search / menu), same box model as the other controls. */
const ICON_BUTTON =
  'just-press bg-card text-foreground inline-flex h-7 w-7 items-center justify-center rounded-(--just-radius-md) border-(length:--just-border-width) border-border shadow-xs';

export function Navbar({ starCount, lang }: NavbarProps) {
  const t = getHomepageDictionary(lang);
  const links: Array<{ label: string; href: Route; activeHref: string }> = [
    { label: t.navHome, href: localizedHref(lang, ''), activeHref: '/' },
    {
      label: t.navDocs,
      href: localizedHref(lang, '/docs/introduction'),
      activeHref: '/docs',
    },
    {
      label: t.navComponents,
      href: localizedHref(lang, '/components'),
      activeHref: '/components',
    },
    {
      label: t.navStudio,
      href: localizedHref(lang, '/studio'),
      activeHref: '/studio',
    },
  ];

  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const [mobileOpen, setMobileOpen] = useState(false);
  const [shortcut, setShortcut] = useState('Ctrl K');

  useEffect(() => {
    setMobileOpen(false);
  }, [pathname]);

  useEffect(() => {
    setShortcut(isApplePlatform(navigator) ? 'Cmd K' : 'Ctrl K');

    function onKeyDown(event: KeyboardEvent) {
      if ((event.metaKey || event.ctrlKey) && event.key.toLowerCase() === 'k') {
        event.preventDefault();
        setOpen(true);
      }
    }

    document.addEventListener('keydown', onKeyDown);
    return () => document.removeEventListener('keydown', onKeyDown);
  }, []);

  const activeHref = useMemo(() => {
    const normalized =
      (pathname ?? '').replace(/^\/(id|en)(?=\/|$)/, '') || '/';
    if (normalized.startsWith('/components')) return '/components';
    if (normalized.startsWith('/docs')) return '/docs';
    if (normalized.startsWith('/studio')) return '/studio';
    return '/';
  }, [pathname]);

  const searchLabel = lang === 'en' ? 'Open search' : 'Buka pencarian';

  return (
    <>
      <header className="border-border bg-background/90 sticky top-0 z-40 h-14 border-b border-b-(length:--just-border-width) backdrop-blur-sm">
        <div className="mx-auto flex h-full max-w-6xl items-center justify-between px-4 sm:px-6 lg:px-8">
          <Link
            href={`/${lang}`}
            aria-label={t.homeLinkLabel}
            className="shrink-0"
          >
            <span className="text-foreground font-mono text-sm font-medium">
              just
            </span>
            <span className="text-accent-text font-mono text-sm font-medium">
              ui
            </span>
          </Link>

          <nav
            className="hidden items-center gap-6 md:flex"
            aria-label={t.mainNavigation}
          >
            {links.map((link) => (
              <Link
                key={link.href}
                href={link.href}
                className={
                  activeHref === link.activeHref
                    ? 'text-foreground text-sm transition-colors'
                    : 'text-muted hover:text-foreground text-sm transition-colors'
                }
              >
                {link.label}
              </Link>
            ))}
          </nav>

          <div className="flex items-center gap-2 sm:gap-3">
            <LanguageSwitcher lang={lang} />
            <PresetToggle
              label={t.togglePreset}
              className="hidden md:inline-flex"
            />
            <ThemeSwitcher label={t.toggleTheme} />
            <button
              type="button"
              className={`${ICON_BUTTON} sm:hidden`}
              onClick={() => setOpen(true)}
              aria-label={searchLabel}
            >
              <Search size={14} aria-hidden="true" />
            </button>
            <SearchBar
              shortcut={shortcut}
              placeholder={t.searchPlaceholder}
              onActivate={() => setOpen(true)}
              label={searchLabel}
            />
            <GitHubPill href={githubUrl} starCount={starCount} />
            <button
              type="button"
              className={`${ICON_BUTTON} md:hidden`}
              onClick={() => setMobileOpen((prev) => !prev)}
              aria-label={
                mobileOpen
                  ? lang === 'en'
                    ? 'Close navigation menu'
                    : 'Tutup menu navigasi'
                  : lang === 'en'
                    ? 'Open navigation menu'
                    : 'Buka menu navigasi'
              }
              aria-expanded={mobileOpen}
            >
              {mobileOpen ? (
                <X size={16} aria-hidden="true" />
              ) : (
                <Menu size={16} aria-hidden="true" />
              )}
            </button>
          </div>
        </div>
        {mobileOpen ? (
          <div
            data-testid="mobile-navigation-drawer"
            className="border-border bg-background fixed inset-x-0 top-14 z-40 border-b border-b-(length:--just-border-width) px-4 py-4 md:hidden"
          >
            <nav
              className="flex flex-col gap-2 text-sm"
              aria-label={t.mainNavigation}
            >
              {links.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={() => setMobileOpen(false)}
                  className={
                    activeHref === link.activeHref
                      ? 'bg-accent text-accent-foreground rounded-(--just-radius-md) px-3 py-2.5 font-medium transition-colors'
                      : 'text-muted hover:text-foreground hover:bg-card rounded-(--just-radius-md) px-3 py-2.5 transition-colors'
                  }
                >
                  {link.label}
                </Link>
              ))}
            </nav>
            <div className="border-border mt-4 flex items-center justify-between gap-3 border-t border-t-(length:--just-border-width) pt-4">
              <span className="text-muted text-sm">{t.presetLabel}</span>
              <PresetToggle label={t.togglePreset} />
            </div>
          </div>
        ) : null}
      </header>
      <CustomSearchDialog open={open} onOpenChange={setOpen} lang={lang} />
    </>
  );
}
