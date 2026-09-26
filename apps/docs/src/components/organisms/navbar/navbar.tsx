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
import { SearchModal } from '@/components/organisms/search-modal';
import { getHomepageDictionary } from '@/lib/homepage-translations';

import type { NavbarProps } from './navbar.types';

/** Shared sizing so the molecules keep the navbar's 32px control height. */
const NAV_PILL = 'h-8 border';

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

  return (
    <>
      <header className="border-border bg-background/80 sticky top-0 z-40 h-14 border-b backdrop-blur-sm">
        <div className="mx-auto flex h-full max-w-6xl items-center justify-between px-4 sm:px-6 lg:px-8">
          <Link href={`/${lang}`} aria-label="JustUI home" className="shrink-0">
            <span className="text-foreground font-mono text-sm font-medium">
              just
            </span>
            <span className="text-accent font-mono text-sm font-medium">
              ui
            </span>
          </Link>

          <nav className="hidden items-center gap-6 md:flex" aria-label="Main">
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

          <div className="flex items-center gap-2">
            <LanguageSwitcher lang={lang} className={NAV_PILL} />
            <PresetToggle
              label={t.togglePreset}
              className={`${NAV_PILL} w-8 justify-center px-0`}
            />
            <ThemeSwitcher
              label={t.toggleTheme}
              className={`${NAV_PILL} w-8 px-0`}
            />
            <button
              type="button"
              className="border-border text-muted hover:text-foreground inline-flex h-8 w-8 items-center justify-center rounded-full border bg-transparent transition-colors sm:hidden"
              onClick={() => setOpen(true)}
              aria-label={lang === 'en' ? 'Open search' : 'Buka pencarian'}
            >
              <Search size={14} aria-hidden="true" />
            </button>
            <SearchBar
              shortcut={shortcut}
              placeholder={t.searchPlaceholder}
              onActivate={() => setOpen(true)}
              label={lang === 'en' ? 'Open search' : 'Buka pencarian'}
              className="border"
            />
            <GitHubPill
              href={githubUrl}
              starCount={starCount}
              className="border"
            />
            <button
              type="button"
              className="border-border text-muted hover:text-foreground inline-flex h-8 w-8 items-center justify-center rounded-full border bg-transparent transition-colors md:hidden"
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
            className="border-border bg-background/95 fixed inset-x-0 top-14 z-40 border-b px-4 py-4 shadow-lg backdrop-blur-md md:hidden"
          >
            <nav
              className="flex flex-col gap-2 font-mono text-sm"
              aria-label="Mobile Navigation"
            >
              {links.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={() => setMobileOpen(false)}
                  className={
                    activeHref === link.activeHref
                      ? 'bg-accent-muted text-accent-dark dark:text-accent-light rounded-md px-3 py-2.5 font-medium transition-colors'
                      : 'text-muted hover:text-foreground hover:bg-card rounded-md px-3 py-2.5 transition-colors'
                  }
                >
                  {link.label}
                </Link>
              ))}
            </nav>
          </div>
        ) : null}
      </header>
      <SearchModal open={open} onOpenChange={setOpen} lang={lang} />
    </>
  );
}
