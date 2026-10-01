export type HomepageDictionary = {
  tagline: string;
  heroTitle: string;
  heroDescription: string;
  getStarted: string;
  browseComponents: string;
  componentsHeading: string;
  componentsSubheading: string;
  componentsAll: string;
  navHome: string;
  navDocs: string;
  navComponents: string;
  navStudio: string;
  searchPlaceholder: string;
  toggleTheme: string;
  changeLanguage: string;
  copyCommand: string;
  togglePreset: string;
  componentsPageTitle: string;
  terminalTitle: string;
  terminalShortcuts: string;
  terminalChipInit: string;
  terminalChipAddButton: string;
  terminalChipAddMulti: string;
  terminalChipPreset: string;
  installTabCurl: string;
  installTabPowershell: string;
  installTabCargo: string;
  stageClear: string;
  stageEmptyTitle: string;
  stageEmptyDescription: string;
  stageEmptyCta: string;
  stagePreviewTab: string;
  stageCodeTab: string;
  wygHeading: string;
  wygDescription: string;
  wygCard1Title: string;
  wygCard1Desc: string;
  wygCard2Title: string;
  wygCard2Desc: string;
  wygCard3Title: string;
  wygCard3Desc: string;
  copied: string;
  componentsPageDescription: (count: number) => string;
  mainNavigation: string;
  homeLinkLabel: string;
  installTabsLabel: string;
  copyInstallCommand: string;
  presetLabel: string;
  terminalRegionLabel: string;
  terminalChipsLabel: string;
  terminalInputLabel: string;
  stageRegionLabel: string;
  stageViewModeLabel: string;
  viewportGroupLabel: string;
  viewportMobile: string;
  viewportTablet: string;
  viewportDesktop: string;
};

export const homepageTranslations: Readonly<
  Record<string, HomepageDictionary>
> = {
  en: {
    tagline: 'Copy-paste Flutter components',
    heroTitle: 'One command. One file. Yours.',
    heroDescription:
      'Not a dependency. JustUI copies Flutter components into your project as plain source, so there is no package to upgrade, no Material, and nothing beyond the SDK.',
    getStarted: 'Get started',
    browseComponents: 'Browse components',
    componentsHeading: 'Components',
    componentsSubheading: 'Live previews, rendered with the active preset.',
    componentsAll: 'All components ->',
    navHome: 'Home',
    navDocs: 'Docs',
    navComponents: 'Components',
    navStudio: 'Studio',
    searchPlaceholder: 'Search...',
    toggleTheme: 'Toggle theme',
    changeLanguage: 'Switch to Indonesian',
    copyCommand: 'Copy install command',
    togglePreset: 'Toggle preset',
    componentsPageTitle: 'Components',
    terminalTitle: 'justui@v0.14.0 ~ /my-flutter-app',
    terminalShortcuts: '[Tab] Autocomplete | [Up/Down] History | [Enter] Run',
    terminalChipInit: 'justui init',
    terminalChipAddButton: 'justui add button',
    terminalChipAddMulti: 'justui add switch card',
    terminalChipPreset: 'justui preset apply neobrutalism',
    installTabCurl: 'macOS / Linux',
    installTabPowershell: 'Windows',
    installTabCargo: 'Cargo',
    stageClear: 'Clear',
    stageEmptyTitle: 'Flutter Canvas Ready',
    stageEmptyDescription:
      'Run commands in the terminal to copy components into your project and preview them live here.',
    stageEmptyCta: 'Run: justui add button',
    stagePreviewTab: 'Preview',
    stageCodeTab: 'Flutter Code',
    wygHeading: 'What you actually get',
    wygDescription: 'Three things the CLI does, shown as they work.',
    wygCard1Title: 'The source lands in your repo',
    wygCard1Desc:
      'Files are checksummed against the registry, then written to your components directory. Edit them freely.',
    wygCard2Title: 'Presets swap tokens, not components',
    wygCard2Desc:
      'The same widgets, rendered with two token sets. Border, shadow, radius and surface colors change; the components do not.',
    wygCard3Title: 'Text color follows the background',
    wygCard3Desc:
      'Drag a surface lightness. The theme picks whichever text color clears WCAG AA, and shows the measured ratio.',
    copied: 'Copied',
    componentsPageDescription: (count) =>
      `${count} Flutter components. Copy one into your project and change it however you like.`,
    mainNavigation: 'Main navigation',
    homeLinkLabel: 'JustUI home',
    installTabsLabel: 'Installation platform',
    copyInstallCommand: 'Copy install command',
    presetLabel: 'Preset',
    terminalRegionLabel: 'CLI simulator',
    terminalChipsLabel: 'Example commands',
    terminalInputLabel: 'Command',
    stageRegionLabel: 'Component preview',
    stageViewModeLabel: 'Preview or code',
    viewportGroupLabel: 'Preview width',
    viewportMobile: 'Mobile viewport',
    viewportTablet: 'Tablet viewport',
    viewportDesktop: 'Desktop viewport',
  },
  id: {
    tagline: 'Komponen Flutter siap salin-tempel',
    heroTitle: 'Satu perintah. Satu file. Milikmu.',
    heroDescription:
      'Bukan dependensi. JustUI menyalin komponen Flutter ke proyekmu sebagai source biasa, jadi tidak ada paket yang perlu di-upgrade, tanpa Material, dan tanpa apa pun di luar SDK.',
    getStarted: 'Mulai',
    browseComponents: 'Jelajahi komponen',
    componentsHeading: 'Komponen',
    componentsSubheading: 'Pratinjau langsung, dirender dengan preset aktif.',
    componentsAll: 'Semua komponen ->',
    navHome: 'Beranda',
    navDocs: 'Dokumentasi',
    navComponents: 'Komponen',
    navStudio: 'Studio',
    searchPlaceholder: 'Cari...',
    toggleTheme: 'Ubah tema',
    changeLanguage: 'Ganti ke Bahasa Inggris',
    copyCommand: 'Salin perintah instalasi',
    togglePreset: 'Ganti preset',
    componentsPageTitle: 'Komponen',
    terminalTitle: 'justui@v0.14.0 ~ /my-flutter-app',
    terminalShortcuts: '[Tab] Autocomplete | [Up/Down] History | [Enter] Run',
    terminalChipInit: 'justui init',
    terminalChipAddButton: 'justui add button',
    terminalChipAddMulti: 'justui add switch card',
    terminalChipPreset: 'justui preset apply neobrutalism',
    installTabCurl: 'macOS / Linux',
    installTabPowershell: 'Windows',
    installTabCargo: 'Cargo',
    stageClear: 'Bersihkan',
    stageEmptyTitle: 'Kanvas Flutter Siap Digunakan',
    stageEmptyDescription:
      'Jalankan perintah di terminal untuk menyalin komponen ke proyekmu dan lihat pratinjaunya di sini.',
    stageEmptyCta: 'Jalankan: justui add button',
    stagePreviewTab: 'Pratinjau',
    stageCodeTab: 'Kode Flutter',
    wygHeading: 'Yang sebenarnya kamu dapat',
    wygDescription: 'Tiga hal yang dilakukan CLI, ditampilkan langsung.',
    wygCard1Title: 'Source masuk ke repo-mu',
    wygCard1Desc:
      'File diverifikasi checksum terhadap registry, lalu ditulis ke direktori komponenmu. Ubah sesukamu.',
    wygCard2Title: 'Preset mengganti token, bukan komponen',
    wygCard2Desc:
      'Widget yang sama dirender dengan dua set token. Yang berubah adalah border, shadow, radius, dan warna permukaan; komponennya tidak.',
    wygCard3Title: 'Warna teks mengikuti latar',
    wygCard3Desc:
      'Geser tingkat terang permukaan. Tema memilih warna teks yang lolos WCAG AA dan menampilkan rasio yang diukur.',
    copied: 'Tersalin',
    componentsPageDescription: (count) =>
      `${count} komponen Flutter. Salin satu ke proyekmu, lalu ubah sesukamu.`,
    mainNavigation: 'Navigasi utama',
    homeLinkLabel: 'Beranda JustUI',
    installTabsLabel: 'Platform instalasi',
    copyInstallCommand: 'Salin perintah instalasi',
    presetLabel: 'Preset',
    terminalRegionLabel: 'Simulator CLI',
    terminalChipsLabel: 'Contoh perintah',
    terminalInputLabel: 'Perintah',
    stageRegionLabel: 'Pratinjau komponen',
    stageViewModeLabel: 'Pratinjau atau kode',
    viewportGroupLabel: 'Lebar pratinjau',
    viewportMobile: 'Tampilan ponsel',
    viewportTablet: 'Tampilan tablet',
    viewportDesktop: 'Tampilan desktop',
  },
} as const;

export function getHomepageDictionary(lang: string): HomepageDictionary {
  return homepageTranslations[lang] ?? homepageTranslations.en;
}
