import { i18n } from '@/lib/i18n';
import { uiTranslations } from 'fumadocs-ui/i18n';
import type { BaseLayoutProps } from 'fumadocs-ui/layouts/shared';

export const translations = i18n
  .translations()
  .extend(uiTranslations())
  .add({
    id: {
      displayName: 'Bahasa Indonesia',
      search: 'Cari dokumentasi...',
      searchNoResult: 'Tidak ada hasil',
      searchEmpty: 'Ketik untuk mencari',
      lastUpdate: 'Terakhir diperbarui',
      toc: 'Daftar Isi',
      tocNoHeadings: 'Tidak ada heading',
      chooseLanguage: 'Pilih Bahasa',
      nextPage: 'Selanjutnya',
      previousPage: 'Sebelumnya',
      editOnGithub: 'Edit di GitHub',
    },
    en: {
      displayName: 'English',
    },
  });

export function baseOptions(_locale: string): BaseLayoutProps {
  return {
    nav: {
      title: 'JustUI Docs',
    },
    githubUrl: 'https://github.com/infinitedim/justui',
    i18n: true,
  };
}
