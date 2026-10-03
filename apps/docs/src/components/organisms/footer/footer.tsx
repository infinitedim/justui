import Link from 'next/link';
import { GitHubMark } from '@/components/atoms/github-mark';
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
  footerLabel: string;
}

const FOOTER_TRANSLATIONS: Record<string, FooterDict> = {
  en: {
    tagline: 'Flutter components you copy into your project. MIT licensed.',
    resourcesHeading: 'Docs',
    docsIntro: 'Introduction',
    docsCli: 'CLI setup',
    docsTheming: 'Theming',
    docsComponents: 'Components',
    communityHeading: 'Project',
    github: 'GitHub',
    issues: 'Issues',
    changelog: 'Releases',
    license: 'License',
    footerLabel: 'Site footer',
  },
  id: {
    tagline: 'Komponen Flutter yang kamu salin ke proyekmu. Lisensi MIT.',
    resourcesHeading: 'Dokumentasi',
    docsIntro: 'Pengenalan',
    docsCli: 'Setup CLI',
    docsTheming: 'Tema',
    docsComponents: 'Komponen',
    communityHeading: 'Proyek',
    github: 'GitHub',
    issues: 'Issue',
    changelog: 'Rilis',
    license: 'Lisensi',
    footerLabel: 'Kaki situs',
  },
};

const linkClass = 'text-secondary hover:text-foreground transition-colors';
const headingClass = 'text-foreground font-mono text-xs font-medium';

export function Footer({ lang, className }: FooterProps) {
  const t = FOOTER_TRANSLATIONS[lang] ?? FOOTER_TRANSLATIONS.en;
  const repo = 'https://github.com/infinitedim/justui';

  return (
    <footer
      role="contentinfo"
      aria-label={t.footerLabel}
      className={cn(
        'border-border bg-card/60 border-t border-t-(length:--just-border-width)',
        className
      )}
    >
      <div className="mx-auto grid max-w-6xl gap-8 px-4 py-12 sm:px-6 md:grid-cols-[2fr_1fr_1fr] lg:px-8">
        <div>
          <Link
            href={`/${lang}`}
            className="font-mono text-base font-medium tracking-tight"
          >
            <span className="text-foreground">just</span>
            <span className="text-accent-text">ui</span>
          </Link>
          <p className="text-secondary mt-3 max-w-sm text-sm leading-relaxed">
            {t.tagline}
          </p>
        </div>

        <div className="flex flex-col gap-2.5 text-sm">
          <h3 className={headingClass}>{t.resourcesHeading}</h3>
          <Link href={`/${lang}/docs/introduction`} className={linkClass}>
            {t.docsIntro}
          </Link>
          <Link href={`/${lang}/docs/cli-setup`} className={linkClass}>
            {t.docsCli}
          </Link>
          <Link href={`/${lang}/docs/theming`} className={linkClass}>
            {t.docsTheming}
          </Link>
          <Link href={`/${lang}/components`} className={linkClass}>
            {t.docsComponents}
          </Link>
        </div>

        <div className="flex flex-col gap-2.5 text-sm">
          <h3 className={headingClass}>{t.communityHeading}</h3>
          <a
            href={repo}
            target="_blank"
            rel="noopener noreferrer"
            className={cn(linkClass, 'inline-flex items-center gap-1.5')}
          >
            <GitHubMark className="h-3.5 w-3.5" aria-hidden="true" />
            <span>{t.github}</span>
          </a>
          <a
            href={`${repo}/issues`}
            target="_blank"
            rel="noopener noreferrer"
            className={linkClass}
          >
            {t.issues}
          </a>
          <a
            href={`${repo}/releases`}
            target="_blank"
            rel="noopener noreferrer"
            className={linkClass}
          >
            {t.changelog}
          </a>
          <a
            href={`${repo}/blob/main/LICENSE`}
            target="_blank"
            rel="noopener noreferrer"
            className={linkClass}
          >
            {t.license}
          </a>
        </div>
      </div>
    </footer>
  );
}
