'use client';

import { FaGithub } from 'react-icons/fa';
import { Menu, Moon, Search, Sun, X } from 'lucide-react';
import Link from 'next/link';
import type { Route } from 'next';
import { usePathname } from 'next/navigation';
import { useEffect, useMemo, useState } from 'react';
import { useTheme } from 'next-themes';
import { githubUrl } from '@/lib/github';
import { SearchModal } from '@/components/search-modal';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { usePreset } from '@/components/providers';

interface NavbarProps {
  starCount: number | null;
  lang: string;
}

function formatStars(stars: number | null) {
  if (stars === null) return 'Stars';
  if (stars >= 1000) return `${(stars / 1000).toFixed(1)}k`;
  return stars.toString();
}

function LanguageSwitcher({ lang }: { lang: string }) {
  const pathname = usePathname();
  const otherLang = lang === 'en' ? 'id' : 'en';
  const otherLabel = lang === 'en' ? 'ID' : 'EN';
  const t = getHomepageDictionary(lang);

  const otherPath = pathname.replace(
    new RegExp(`^/(id|en)(?=/|$)`),
    `/${otherLang}`
  );

  return (
    <Link
      href={otherPath as Route}
      className="border-border text-muted hover:text-foreground inline-flex h-8 items-center rounded-full border px-2.5 font-mono text-[11px] transition-colors"
      aria-label={t.changeLanguage}
    >
      {otherLabel}
    </Link>
  );
}

function ThemeSwitcher({ lang }: { lang: string }) {
  const { resolvedTheme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);
  const t = getHomepageDictionary(lang);

  useEffect(() => setMounted(true), []);

  if (!mounted) return null;

  return (
    <button
      type="button"
      onClick={() => setTheme(resolvedTheme === 'dark' ? 'light' : 'dark')}
      className="border-border text-muted hover:text-foreground inline-flex h-8 w-8 items-center justify-center rounded-full border transition-colors"
      aria-label={t.toggleTheme}
    >
      {resolvedTheme === 'dark' ? (
        <Sun size={14} aria-hidden="true" />
      ) : (
        <Moon size={14} aria-hidden="true" />
      )}
    </button>
  );
}

function PresetSwitcher({ lang }: { lang: string }) {
  const { preset, setPreset } = usePreset();
  const [mounted, setMounted] = useState(false);
  const t = getHomepageDictionary(lang);

  useEffect(() => setMounted(true), []);

  if (!mounted) return null;

  const isNeo = preset === 'neobrutalism';

  return (
    <button
      type="button"
      onClick={() => setPreset(isNeo ? 'default' : 'neobrutalism')}
      className="border-border text-muted hover:text-foreground inline-flex h-8 w-8 items-center justify-center rounded-full border transition-colors"
      aria-label={t.togglePreset}
      title={
        isNeo ? 'Switch to Default preset' : 'Switch to Neobrutalism preset'
      }
    >
      <span className="font-mono text-[10px] font-bold">
        {isNeo ? 'N' : 'D'}
      </span>
    </button>
  );
}

export function Navbar({ starCount, lang }: NavbarProps) {
  const t = getHomepageDictionary(lang);
  const links = [
    { label: t.navHome, href: `/${lang}`, activeHref: '/' },
    {
      label: t.navDocs,
      href: `/${lang}/docs/introduction`,
      activeHref: '/docs',
    },
    {
      label: t.navComponents,
      href: `/${lang}/components`,
      activeHref: '/components',
    },
    {
      label: t.navStudio,
      href: `/${lang}/studio`,
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
    const platform = navigator.userAgentData?.platform.toLowerCase();
    setShortcut(platform?.includes('mac') ? 'Cmd K' : 'Ctrl K');

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
          <Link
            href={`/${lang}` as Route}
            aria-label="JustUI home"
            className="shrink-0"
          >
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
                href={link.href as Route}
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
            <LanguageSwitcher lang={lang} />
            <PresetSwitcher lang={lang} />
            <ThemeSwitcher lang={lang} />
            <button
              type="button"
              className="border-border text-muted hover:text-foreground inline-flex h-8 w-8 items-center justify-center rounded-full border bg-transparent transition-colors sm:hidden"
              onClick={() => setOpen(true)}
              aria-label={lang === 'en' ? 'Open search' : 'Buka pencarian'}
            >
              <Search size={14} aria-hidden="true" />
            </button>
            <button
              type="button"
              className="border-border text-muted hover:text-foreground hidden items-center gap-3 rounded-full border bg-transparent px-3 py-1.5 font-mono text-xs transition-colors sm:flex"
              onClick={() => setOpen(true)}
              aria-label={lang === 'en' ? 'Open search' : 'Buka pencarian'}
            >
              <span>{t.searchPlaceholder}</span>
              <kbd className="border-border text-muted rounded border px-1.5 py-0.5 font-mono text-[10px]">
                {shortcut}
              </kbd>
            </button>
            <a
              href={githubUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="border-border text-muted hover:text-foreground inline-flex items-center gap-2 rounded-full border bg-transparent px-3 py-1.5 font-mono text-xs transition-colors"
            >
              <FaGithub size={14} aria-hidden="true" />
              <span>{formatStars(starCount)}</span>
            </a>
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
                  href={link.href as Route}
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
