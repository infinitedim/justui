import { isLocale, type Locale } from '@/lib/i18n';

/** Chrome strings shared by the landing and the 404. */
export interface SiteDictionary {
  homeLabel: string;
  mainNavigation: string;
  docs: string;
  components: string;
  search: string;
  menu: string;
  closeMenu: string;
  toDark: string;
  toLight: string;
  language: string;
  github: string;
  os: string;
  copy: string;
  copied: string;
  copyInstall: string;
  copyCommand: string;
  presetLabel: string;
  footerLabel: string;
  license: string;
}

export const siteTranslations = {
  en: {
    homeLabel: 'justui home',
    mainNavigation: 'Main navigation',
    docs: 'Docs',
    components: 'Components',
    search: 'Search docs',
    menu: 'Menu',
    closeMenu: 'Close menu',
    toDark: 'Switch to dark mode',
    toLight: 'Switch to light mode',
    language: 'Language',
    github: 'GitHub',
    os: 'Operating system',
    copy: 'Copy',
    copied: 'Copied',
    copyInstall: 'Copy install command',
    copyCommand: 'Copy command',
    presetLabel: 'Preset',
    footerLabel: 'Site footer',
    license: 'MIT licensed. Source on GitHub.',
  },
  id: {
    homeLabel: 'Beranda justui',
    mainNavigation: 'Navigasi utama',
    docs: 'Dokumentasi',
    components: 'Komponen',
    search: 'Cari dokumentasi',
    menu: 'Menu',
    closeMenu: 'Tutup menu',
    toDark: 'Ganti ke mode gelap',
    toLight: 'Ganti ke mode terang',
    language: 'Bahasa',
    github: 'GitHub',
    os: 'Sistem operasi',
    copy: 'Salin',
    copied: 'Tersalin',
    copyInstall: 'Salin perintah instalasi',
    copyCommand: 'Salin perintah',
    presetLabel: 'Preset',
    footerLabel: 'Footer situs',
    license: 'Lisensi MIT. Source ada di GitHub.',
  },
} satisfies Record<Locale, SiteDictionary>;

/** Chrome dictionary for a locale; unknown values fall back to English. */
export function getSiteDictionary(lang: string): SiteDictionary {
  return isLocale(lang) ? siteTranslations[lang] : siteTranslations.en;
}
