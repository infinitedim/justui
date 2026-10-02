import type { GeneratedComponentCategory } from './components.generated';

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
  homeLinkLabel: string;
  mainNavigation: string;
  presetLabel: string;
  searchPlaceholder: string;
  toggleTheme: string;
  changeLanguage: string;
  copyCommand: string;
  copied: string;
  togglePreset: string;
  componentsPageTitle: string;
  /** `{count}` is replaced with the number of components in the registry. */
  componentsPageDescription: string;
  terminalRegionLabel: string;
  terminalNote: string;
  terminalTry: string;
  terminalInputLabel: string;
  terminalShortcuts: string;
  installTabCurl: string;
  installTabPowershell: string;
  installTabCargo: string;
  stageRegionLabel: string;
  stageViewLabel: string;
  stagePreviewTab: string;
  stageCopyCode: string;
  stageEmpty: string;
  wygHeading: string;
  wygDescription: string;
  wygCard1Title: string;
  wygCard1Desc: string;
  wygCard2Title: string;
  wygCard2Desc: string;
  wygCard3Title: string;
  wygCard3Desc: string;
  catalogSearchPlaceholder: string;
  catalogSearchLabel: string;
  catalogCategoryLabel: string;
  catalogAllCategories: string;
  catalogCategories: Record<GeneratedComponentCategory, string>;
  /** `{query}` is replaced with what the visitor typed. */
  catalogNoResults: string;
  /** `{shown}` and `{total}` are replaced with counts. */
  catalogShowing: string;
  catalogResetFilters: string;
  catalogCopyCli: string;
  catalogViewCode: string;
  catalogViewDocs: string;
  catalogCodeTitle: string;
  catalogCloseCode: string;
  notFoundTitle: string;
  notFoundBody: string;
  notFoundHome: string;
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
    homeLinkLabel: 'JustUI homepage',
    mainNavigation: 'Main navigation',
    presetLabel: 'Preset',
    searchPlaceholder: 'Search...',
    toggleTheme: 'Toggle theme',
    changeLanguage: 'Switch to Indonesian',
    copyCommand: 'Copy install command',
    copied: 'Copied',
    togglePreset: 'Toggle preset',
    componentsPageTitle: 'Components',
    componentsPageDescription:
      '{count} components. Each one is a few Dart files the CLI copies into your project; after that the code is yours to change.',
    terminalRegionLabel: 'CLI simulator',
    terminalNote: 'simulated, nothing is written to disk',
    terminalTry: 'try:',
    terminalInputLabel: 'Type a justui command',
    terminalShortcuts: 'Tab completes, Up/Down for history',
    installTabCurl: 'macOS / Linux',
    installTabPowershell: 'Windows',
    installTabCargo: 'Cargo',
    stageRegionLabel: 'Component preview',
    stageViewLabel: 'Preview or source',
    stagePreviewTab: 'Preview',
    stageCopyCode: 'Copy widget.dart',
    stageEmpty: 'Nothing added yet. Run justui add <name> in the terminal.',
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
    catalogSearchPlaceholder: 'Search components',
    catalogSearchLabel: 'Search components',
    catalogCategoryLabel: 'Category',
    catalogAllCategories: 'All',
    catalogCategories: {
      primitive: 'Primitives',
      selection: 'Selection',
      layout: 'Layout',
      form: 'Forms',
      navigation: 'Navigation',
      overlay: 'Overlays',
      composite: 'Composite',
    },
    catalogNoResults: "Nothing matches '{query}'.",
    catalogShowing: 'Showing {shown} of {total}',
    catalogResetFilters: 'Reset filters',
    catalogCopyCli: 'Copy CLI command',
    catalogViewCode: 'Code',
    catalogViewDocs: 'Docs',
    catalogCodeTitle: 'Example',
    catalogCloseCode: 'Close',
    notFoundTitle: 'Page not found.',
    notFoundBody: 'The link may be old, or the page moved. Try one of these:',
    notFoundHome: 'Home',
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
    homeLinkLabel: 'Beranda JustUI',
    mainNavigation: 'Navigasi utama',
    presetLabel: 'Preset',
    searchPlaceholder: 'Cari...',
    toggleTheme: 'Ubah tema',
    changeLanguage: 'Ganti ke Bahasa Inggris',
    copyCommand: 'Salin perintah instalasi',
    copied: 'Tersalin',
    togglePreset: 'Ganti preset',
    componentsPageTitle: 'Komponen',
    componentsPageDescription:
      '{count} komponen. Masing-masing berupa beberapa file Dart yang disalin CLI ke proyekmu; setelah itu kodenya milikmu untuk diubah.',
    terminalRegionLabel: 'Simulator CLI',
    terminalNote: 'simulasi, tidak menyentuh disk',
    terminalTry: 'coba:',
    terminalInputLabel: 'Ketik perintah justui',
    terminalShortcuts: 'Tab melengkapi, Atas/Bawah untuk riwayat',
    installTabCurl: 'macOS / Linux',
    installTabPowershell: 'Windows',
    installTabCargo: 'Cargo',
    stageRegionLabel: 'Pratinjau komponen',
    stageViewLabel: 'Pratinjau atau source',
    stagePreviewTab: 'Pratinjau',
    stageCopyCode: 'Salin widget.dart',
    stageEmpty:
      'Belum ada yang ditambahkan. Jalankan justui add <nama> di terminal.',
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
    catalogSearchPlaceholder: 'Cari komponen',
    catalogSearchLabel: 'Cari komponen',
    catalogCategoryLabel: 'Kategori',
    catalogAllCategories: 'Semua',
    catalogCategories: {
      primitive: 'Primitif',
      selection: 'Pilihan',
      layout: 'Tata letak',
      form: 'Formulir',
      navigation: 'Navigasi',
      overlay: 'Overlay',
      composite: 'Komposit',
    },
    catalogNoResults: "Tidak ada yang cocok dengan '{query}'.",
    catalogShowing: 'Menampilkan {shown} dari {total}',
    catalogResetFilters: 'Atur ulang filter',
    catalogCopyCli: 'Salin perintah CLI',
    catalogViewCode: 'Kode',
    catalogViewDocs: 'Docs',
    catalogCodeTitle: 'Contoh',
    catalogCloseCode: 'Tutup',
    notFoundTitle: 'Halaman tidak ditemukan.',
    notFoundBody:
      'Mungkin tautannya sudah lama, atau halamannya pindah. Coba salah satu ini:',
    notFoundHome: 'Beranda',
  },
} as const;

export function getHomepageDictionary(lang: string): HomepageDictionary {
  return homepageTranslations[lang] ?? homepageTranslations.en;
}

/** Replaces `{name}` placeholders in a dictionary string. */
export function formatMessage(
  template: string,
  values: Record<string, string | number>
): string {
  return template.replace(/\{(\w+)\}/g, (whole, key: string) =>
    key in values ? String(values[key]) : whole
  );
}
