'use client';

import { Menu, Search, X } from 'lucide-react';
import Link from 'next/link';
import type { Route } from 'next';
import { usePathname } from 'next/navigation';
import { useEffect, useMemo, useState } from 'react';
import { cn } from '@/lib/cn';
import { CLI_VERSION } from '@/lib/components.generated';
import { githubUrl } from '@/lib/github';
import { localizedHref } from '@/lib/i18n';
import { isApplePlatform } from '@/lib/platform';
import { LogoMark } from '@/components/atoms/logo-mark';
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
  const versionSlug = CLI_VERSION.split('.').slice(0, 2).join('.');

  const links: Array<{ label: string; href: Route; activeHref: string }> = [
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
      <header className="border-border bg-background/90 sticky top-0 z-40 h-14 border-b-(length:--just-border-width) backdrop-blur-sm">
        <div className="mx-auto flex h-full max-w-6xl items-center justify-between px-4 sm:px-6 lg:px-8">
          {/* Left Brand and Navigation Cluster */}
          <div className="flex items-center gap-4 sm:gap-6">
            <div className="flex items-center gap-2.5">
              <Link
                href={`/${lang}`}
                aria-label={t.homeLinkLabel}
                className="flex items-center gap-2 focus-visible:outline-hidden"
              >
                <LogoMark size={20} />
                <span className="font-mono text-sm font-semibold tracking-tight">
                  <span className="text-foreground">Just</span>
                  <span className="text-accent-text">UI</span>
                </span>
              </Link>
              <span
                className="border-border bg-card text-muted max-sm:hidden inline-flex rounded-(--just-radius-xs) border-(length:--just-border-width) px-1.5 py-0.5 font-mono text-xs leading-none shadow-xs"
                aria-label="Library version"
              >
                v{versionSlug}-beta
              </span>
            </div>

            <div
              className="bg-border max-md:hidden block h-4 w-px"
              aria-hidden="true"
            />

            <nav
              className="flex max-md:hidden items-center gap-1"
              aria-label={t.mainNavigation}
            >
              {links.map((link) => {
                const active = activeHref === link.activeHref;
                return (
                  <Link
                    key={link.href}
                    href={link.href}
                    className={cn(
                      'just-press rounded-(--just-radius-md) px-3 py-1.5 text-xs font-medium transition-colors',
                      'border-(length:--just-border-width)',
                      active
                        ? 'border-border bg-card text-foreground font-semibold shadow-xs'
                        : 'border-transparent text-muted hover:border-border/60 hover:bg-card/60 hover:text-foreground'
                    )}
                  >
                    {link.label}
                  </Link>
                );
              })}
            </nav>
          </div>

          {/* Right Utility and Controls Cluster */}
          <div className="flex items-center gap-2 sm:gap-2.5">
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

            <div
              className="bg-border max-sm:hidden block h-4 w-px"
              aria-hidden="true"
            />

            <div className="flex items-center gap-1.5 sm:gap-2">
              <PresetToggle
                label={t.togglePreset}
                className="inline-flex max-lg:hidden"
              />
              <ThemeSwitcher label={t.toggleTheme} />
            </div>

            <div
              className="bg-border max-md:hidden block h-4 w-px"
              aria-hidden="true"
            />

            <div className="flex items-center gap-1.5 sm:gap-2">
              <LanguageSwitcher lang={lang} />
              <GitHubPill href={githubUrl} starCount={starCount} />
            </div>

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

        {/* Mobile Navigation Drawer */}
        {mobileOpen ? (
          <div
            data-testid="mobile-navigation-drawer"
            className="border-border bg-background fixed inset-x-0 top-14 z-40 border-b-(length:--just-border-width) px-4 py-4 shadow-md md:hidden"
          >
            <nav
              className="flex flex-col gap-1.5 text-sm"
              aria-label={t.mainNavigation}
            >
              {links.map((link) => (
                <Link
                  key={link.href}
                  href={link.href}
                  onClick={() => setMobileOpen(false)}
                  className={
                    activeHref === link.activeHref
                      ? 'bg-accent text-accent-foreground rounded-(--just-radius-md) border-(length:--just-border-width) border-border px-3 py-2.5 font-medium transition-colors'
                      : 'text-muted hover:text-foreground hover:bg-card rounded-(--just-radius-md) px-3 py-2.5 transition-colors'
                  }
                >
                  {link.label}
                </Link>
              ))}
            </nav>
            <div className="border-border mt-4 flex items-center justify-between gap-3 border-t-(length:--just-border-width) pt-4">
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
