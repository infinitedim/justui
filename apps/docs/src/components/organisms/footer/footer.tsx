import Link from 'next/link';
import { FaGithub } from 'react-icons/fa';
import { cn } from '@/lib/cn';
import type { FooterProps } from './footer.types';

interface FooterDict {
  tagline: string;
  resourcesHeading: string;
  docsIntro: string;
  docsCli: string;
  docsTheming: string;
  docsComponents: string;
  communityHeading: string;
  github: string;
  issues: string;
  changelog: string;
  license: string;
  copyright: string;
  bottomNote: string;
}

const FOOTER_TRANSLATIONS: Record<string, FooterDict> = {
  en: {
    tagline:
      'Zero-dependency, copy-paste Flutter UI components. Complete source code ownership.',
    resourcesHeading: 'Documentation',
    docsIntro: 'Introduction',
    docsCli: 'CLI Guide',
    docsTheming: 'Theming & Tokens',
    docsComponents: 'Component Catalog',
    communityHeading: 'Ecosystem',
    github: 'GitHub Repository',
    issues: 'Report an Issue',
    changelog: 'Releases & Changelog',
    license: 'MIT License',
    copyright: '(c) 2026 JustUI. Built for high-performance Flutter engineering.',
    bottomNote: 'Crafted with zero external runtime footprint.',
  },
  id: {
    tagline:
      'Pustaka komponen UI Flutter siap salin-tempel tanpa dependensi. Kepemilikan kode penuh.',
    resourcesHeading: 'Dokumentasi',
    docsIntro: 'Pengenalan',
    docsCli: 'Panduan CLI',
    docsTheming: 'Tema & Desain Token',
    docsComponents: 'Katalog Komponen',
    communityHeading: 'Ekosistem',
    github: 'Repositori GitHub',
    issues: 'Laporkan Masalah',
    changelog: 'Rilis & Changelog',
    license: 'Lisensi MIT',
    copyright: '(c) 2026 JustUI. Dibuat untuk rekayasa Flutter berkinerja tinggi.',
    bottomNote: 'Direkayasa tanpa jejak dependensi runtime eksternal.',
  },
};

export function Footer({ lang, className }: FooterProps) {
  const t = FOOTER_TRANSLATIONS[lang] ?? FOOTER_TRANSLATIONS.en;

  return (
    <footer
      role="contentinfo"
      aria-label="Site Footer"
      className={cn(
        'border-border/80 bg-card/60 border-t backdrop-blur-xs',
        className
      )}
    >
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8 lg:py-16">
        <div className="grid grid-cols-1 gap-10 md:grid-cols-12 lg:gap-12">
          {/* Column 1: Brand & Identity */}
          <div className="flex flex-col items-start md:col-span-6 lg:col-span-5">
            <Link
              href={`/${lang}`}
              className="group inline-flex items-center gap-2 font-mono text-lg font-bold tracking-tight"
            >
              <span className="text-foreground">just</span>
              <span className="text-accent">ui</span>
              <span className="bg-accent h-1.5 w-1.5 rounded-full" />
            </Link>

            <p className="text-muted mt-3 max-w-sm text-sm leading-relaxed">
              {t.tagline}
            </p>

            <div className="border-border/80 bg-background/80 mt-5 inline-flex items-center gap-2 rounded-full border px-3 py-1 font-mono text-xs">
              <span className="bg-accent h-2 w-2 rounded-full animate-pulse" />
              <span className="text-foreground font-medium">v0.14.0</span>
              <span className="text-muted">/</span>
              <span className="text-muted">Flutter 3.29+</span>
            </div>

            <p className="text-muted/80 mt-6 text-xs font-mono">
              {t.copyright}
            </p>
          </div>

          {/* Column 2: Documentation & Resources */}
          <div className="md:col-span-3 lg:col-span-3 lg:col-start-7">
            <h3 className="text-foreground font-mono text-xs font-semibold uppercase tracking-wider">
              {t.resourcesHeading}
            </h3>
            <ul className="mt-4 space-y-2.5 text-sm">
              <li>
                <Link
                  href={`/${lang}/docs/introduction`}
                  className="text-muted hover:text-foreground transition-colors"
                >
                  {t.docsIntro}
                </Link>
              </li>
              <li>
                <Link
                  href={`/${lang}/docs/cli`}
                  className="text-muted hover:text-foreground transition-colors"
                >
                  {t.docsCli}
                </Link>
              </li>
              <li>
                <Link
                  href={`/${lang}/docs/theming`}
                  className="text-muted hover:text-foreground transition-colors"
                >
                  {t.docsTheming}
                </Link>
              </li>
              <li>
                <Link
                  href={`/${lang}/components`}
                  className="text-muted hover:text-foreground transition-colors"
                >
                  {t.docsComponents}
                </Link>
              </li>
            </ul>
          </div>

          {/* Column 3: Ecosystem & Community */}
          <div className="md:col-span-3 lg:col-span-3">
            <h3 className="text-foreground font-mono text-xs font-semibold uppercase tracking-wider">
              {t.communityHeading}
            </h3>
            <ul className="mt-4 space-y-2.5 text-sm">
              <li>
                <a
                  href="https://github.com/infinitedim/justui"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-muted hover:text-foreground inline-flex items-center gap-1.5 transition-colors"
                >
                  <FaGithub className="h-3.5 w-3.5" aria-hidden="true" />
                  <span>{t.github}</span>
                </a>
              </li>
              <li>
                <a
                  href="https://github.com/infinitedim/justui/issues"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-muted hover:text-foreground transition-colors"
                >
                  {t.issues}
                </a>
              </li>
              <li>
                <a
                  href="https://github.com/infinitedim/justui/releases"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-muted hover:text-foreground transition-colors"
                >
                  {t.changelog}
                </a>
              </li>
              <li>
                <a
                  href="https://github.com/infinitedim/justui/blob/main/LICENSE"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-muted hover:text-foreground transition-colors"
                >
                  {t.license}
                </a>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom divider note */}
        <div className="border-border/60 mt-12 flex flex-col items-center justify-between gap-4 border-t pt-8 sm:flex-row text-xs text-muted font-mono">
          <span>{t.bottomNote}</span>
          <span>MIT License</span>
        </div>
      </div>
    </footer>
  );
}
