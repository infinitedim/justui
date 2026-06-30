export type HomepageDictionary = {
  tagline: string;
  heroTitle: string;
  heroDescription: string;
  getStarted: string;
  browseComponents: string;
  componentsHeading: string;
  navHome: string;
  navDocs: string;
  navComponents: string;
  searchPlaceholder: string;
  toggleTheme: string;
  changeLanguage: string;
  copyCommand: string;
  copied: string;
  componentsPageTitle: string;
  componentsPageDescription: string;
  componentsPageCount: string; // We can use string replacement or simple interpolation
};

export const homepageTranslations: Record<string, HomepageDictionary> = {
  en: {
    tagline: 'Copy-paste Flutter components',
    heroTitle: 'Copy. Paste. Ship.',
    heroDescription:
      'A zero-dependency, copy-paste component library for Flutter. No Material. No boilerplate. Just UI.',
    getStarted: 'Get started →',
    browseComponents: 'Browse components',
    componentsHeading: 'Components',
    navHome: 'Home',
    navDocs: 'Docs',
    navComponents: 'Components',
    searchPlaceholder: 'Search...',
    toggleTheme: 'Toggle theme',
    changeLanguage: 'Switch to Indonesian',
    copyCommand: 'Copy install command',
    copied: 'Copied!',
    componentsPageTitle: 'Components',
    componentsPageDescription:
      'All components are ready to use. Copy, paste, and customize directly in your Flutter project.',
    componentsPageCount: 'components available',
  },
  id: {
    tagline: 'Komponen Flutter siap salin-tempel',
    heroTitle: 'Salin. Tempel. Rilis.',
    heroDescription:
      'Pustaka komponen Flutter tanpa dependensi tambahan, tinggal salin-tempel. Tanpa Material. Tanpa boilerplate. Hanya UI.',
    getStarted: 'Mulai →',
    browseComponents: 'Jelajahi komponen',
    componentsHeading: 'Komponen',
    navHome: 'Beranda',
    navDocs: 'Dokumentasi',
    navComponents: 'Komponen',
    searchPlaceholder: 'Cari...',
    toggleTheme: 'Ubah tema',
    changeLanguage: 'Ganti ke Bahasa Inggris',
    copyCommand: 'Salin perintah instalasi',
    copied: 'Tersalin!',
    componentsPageTitle: 'Komponen',
    componentsPageDescription:
      'Semua komponen siap pakai. Copy, paste, dan sesuaikan langsung di project Flutter kamu.',
    componentsPageCount: 'komponen tersedia',
  },
};

export function getHomepageDictionary(lang: string): HomepageDictionary {
  return homepageTranslations[lang] ?? homepageTranslations.en;
}
