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
  const otherLang = lang === 'id' ? 'en' : 'id';
  const otherLabel = lang === 'id' ? 'EN' : 'ID';

  const otherPath = pathname.replace(
    new RegExp(`^/(id|en)(?=/|$)`),
    `/${otherLang}`
  );

  return (
    <Link
      href={otherPath as Route}
      className="inline-flex h-7 items-center rounded-full border border-(--color-gray) px-2.5 font-mono text-[11px] text-(--color-gray-2) transition-colors hover:text-white"
      aria-label={`Ganti ke ${otherLabel}`}
    >
      {otherLabel}
    </Link>
  );
}

function ThemeSwitcher() {
  const { resolvedTheme, setTheme } = useTheme();
  const [mounted, setMounted] = useState(false);

  useEffect(() => setMounted(true), []);

  if (!mounted) return <div className="h-7 w-7" />;

  return (
    <button
      type="button"
      onClick={() => setTheme(resolvedTheme === 'dark' ? 'light' : 'dark')}
      className="inline-flex h-7 w-7 items-center justify-center rounded-full border border-(--color-gray) text-(--color-gray-2) transition-colors hover:text-white"
      aria-label="Toggle tema"
    >
      {resolvedTheme === 'dark' ? (
        <Sun size={13} aria-hidden="true" />
      ) : (
        <Moon size={13} aria-hidden="true" />
      )}
    </button>
  );
}

export function Navbar({ starCount, lang }: NavbarProps) {
  const links = [
    { label: 'Home', href: `/${lang}`, activeHref: '/' },
    { label: 'Docs', href: `/${lang}/docs`, activeHref: '/docs' },
    {
      label: 'Components',
      href: `/${lang}/components`,
      activeHref: '/components',
    },
  ];

  const pathname = usePathname();
  const [open, setOpen] = useState(false);
  const [shortcut, setShortcut] = useState('Ctrl K');

  useEffect(() => {
    const platform = navigator.platform.toLowerCase();
    setShortcut(platform.includes('mac') ? '⌘K' : 'Ctrl K');

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
      <header className="border-[ rgb(51_51_51/0.3)] sticky top-0 z-40 h-14 border-b bg-black/80 backdrop-blur-sm">
        <div className="mx-auto flex h-full max-w-6xl items-center justify-between px-4 sm:px-6 lg:px-8">
          <Link
            href={`/${lang}` as Route}
            aria-label="JustUI home"
            className="shrink-0"
          >
            <span className="font-mono text-sm font-medium text-white">
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
                    ? 'text-sm text-white transition-colors'
                    : 'text-sm text-(--color-gray-2) transition-colors hover:text-white'
                }
              >
                {link.label}
              </Link>
            ))}
          </nav>

          <div className="flex items-center gap-2">
            <LanguageSwitcher lang={lang} />
            <ThemeSwitcher />
            <button
              type="button"
              className="hidden items-center gap-3 rounded-full border border-(--color-gray) bg-transparent px-3 py-1.5 font-mono text-xs text-(--color-gray-2) transition-colors hover:text-white sm:flex"
              onClick={() => setOpen(true)}
              aria-label="Buka pencarian"
            >
              <span>Search...</span>
              <kbd className="rounded border border-(--color-gray) px-1.5 py-0.5 font-mono text-[10px] text-(--color-gray-2)">
                {shortcut}
              </kbd>
            </button>
            <a
              href={githubUrl}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 rounded-full border border-(--color-gray) bg-transparent px-3 py-1.5 font-mono text-xs text-(--color-gray-2) transition-colors hover:text-white"
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
