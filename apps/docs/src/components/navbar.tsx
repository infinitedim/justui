'use client';

import { FaGithub } from 'react-icons/fa';
import { Moon, Sun } from 'lucide-react';
import Link from 'next/link';
import type { Route } from 'next';
import { usePathname } from 'next/navigation';
import { useEffect, useMemo, useState } from 'react';
import { useTheme } from 'next-themes';
import { githubUrl } from '@/lib/github';
import { SearchModal } from '@/components/search-modal';
import { getHomepageDictionary } from '@/lib/homepage-translations';
import { usePreset } from '@/lib/preset-context';

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
      className="inline-flex h-7 items-center rounded-full border border-border px-2.5 font-mono text-[11px] text-muted transition-colors hover:text-foreground"
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
      className="inline-flex h-7 w-7 items-center justify-center rounded-full border border-border text-muted transition-colors hover:text-foreground"
      aria-label={t.toggleTheme}
    >
      {resolvedTheme === 'dark' ? (
        <Sun size={13} aria-hidden="true" />
      ) : (
        <Moon size={13} aria-hidden="true" />
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
      className="inline-flex h-7 w-7 items-center justify-center rounded-full border border-border text-muted transition-colors hover:text-foreground"
      aria-label={t.togglePreset}
      title={isNeo ? 'Switch to Default preset' : 'Switch to Neobrutalism preset'}
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
    { label: t.navDocs, href: `/${lang}/docs`, activeHref: '/docs' },
    {
      label: t.navComponents,
      href: `/${lang}/components`,
      activeHref: '/components',
    },
  ];

  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const [shortcut, setShortcut] = useState('Ctrl K');

  useEffect(() => {
    const platform = navigator.userAgentData?.platform.toLowerCase();
    setShortcut(platform?.includes('mac') ? '⌘K' : 'Ctrl K');

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
    const normalized = pathname.replace(/^\/(id|en)(?=\/|$)/, '') || '/';
    if (normalized.startsWith('/components')) return '/components';
    if (normalized.startsWith('/docs')) return '/docs';
    return '/';
  }, [pathname]);

  return (
    <>
      <header className="sticky top-0 z-40 h-14 border-b border-border bg-background/80 backdrop-blur-sm">
        <div className="mx-auto flex h-full max-w-6xl items-center justify-between px-4 sm:px-6 lg:px-8">
          <Link
            href={`/${lang}` as Route}
            aria-label="JustUI home"
            className="shrink-0"
          >
            <span className="font-mono text-sm font-medium text-foreground">
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
                    ? 'text-sm text-foreground transition-colors'
                    : 'text-sm text-muted transition-colors hover:text-foreground'
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
              className="hidden items-center gap-3 rounded-full border border-border bg-transparent px-3 py-1.5 font-mono text-xs text-muted transition-colors hover:text-foreground sm:flex"
              onClick={() => setOpen(true)}
              aria-label={lang === 'en' ? 'Open search' : 'Buka pencarian'}
            >
              <span>{t.searchPlaceholder}</span>
              <kbd className="rounded border border-border px-1.5 py-0.5 font-mono text-[10px] text-muted">
                {shortcut}
              </kbd>
            </button>
            <a
              href={githubUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-full border border-border bg-transparent px-3 py-1.5 font-mono text-xs text-muted transition-colors hover:text-foreground"
            >
              <FaGithub size={14} aria-hidden="true" />
              <span>{formatStars(starCount)}</span>
            </a>
          </div>
        </div>
      </header>
      <SearchModal open={open} onOpenChange={setOpen} lang={lang} />
    </>
  );
}

