import { i18n } from '@/lib/i18n';
import { uiTranslations } from 'fumadocs-ui/i18n';
import type { BaseLayoutProps } from 'fumadocs-ui/layouts/shared';

export const translations = i18n
  .translations()
  .extend(uiTranslations())
  .add({
    id: {
      displayName: 'Bahasa Indonesia',
      'Search(search dialog)': 'Cari...',
      'Search(search trigger)': 'Cari',
      'No results found(search dialog)': 'Tidak ada hasil ditemukan',
      'Last updated on(page footer)': 'Terakhir diperbarui pada',
      'On this page(table of contents)': 'Pada halaman ini',
      'No Headings(table of contents)': 'Tidak ada heading',
      'Choose a language(language switcher)': 'Pilih bahasa',
      'Next Page(pagination)': 'Selanjutnya',
      'Previous Page(pagination)': 'Sebelumnya',
      'Edit on GitHub(edit page)': 'Edit di GitHub',
    },
    en: {
      displayName: 'English',
    },
  });

export function baseOptions(lang: string): BaseLayoutProps {
  return {
    nav: {
      title: (
        <span className="font-mono text-sm font-medium">
          <span className="text-white">just</span>
          <span className="text-accent">ui</span>
        </span>
      ),
      url: `/${lang}`,
    },
    githubUrl: 'https://github.com/infinitedim/justui',
    links: [
      { text: 'Docs', url: `/${lang}/docs`, active: 'nested-url' },
      {
        text: 'Components',
        url: `/${lang}/docs/components`,
        active: 'nested-url',
      },
    ],
    i18n: true,
  };
}
