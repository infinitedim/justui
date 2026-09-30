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
  copied: string;
  togglePreset: string;
  componentsPageTitle: string;
  componentsPageDescription: string;
  componentsPageCount: string;
  terminalTitle: string;
  terminalBadge: string;
  terminalShortcuts: string;
  terminalChipInit: string;
  terminalChipAddButton: string;
  terminalChipAddMulti: string;
  terminalChipPreset: string;
  installTabCurl: string;
  installTabPowershell: string;
  installTabCargo: string;
  stageBadge: string;
  stageClear: string;
  stageEmptyTitle: string;
  stageEmptyDescription: string;
  stageEmptyCta: string;
  stageInteractTip: string;
  stageEmptyState: string;
  stagePreviewTab: string;
  stageCodeTab: string;
  presetCleanPrecision: string;
  presetNeobrutalism: string;
  wygHeading: string;
  wygDescription: string;
  wygCard1Title: string;
  wygCard1Desc: string;
  wygCard2Title: string;
  wygCard2Desc: string;
  wygCard3Title: string;
  wygCard3Desc: string;
  /** Legacy bento keys, kept until the bento components are deleted. */
  bentoBadge: string;
  bentoHeading: string;
  bentoDescription: string;
  bentoCard1Title: string;
  bentoCard1Desc: string;
  bentoCard2Title: string;
  bentoCard2Desc: string;
  bentoCard3Title: string;
  bentoCard3Desc: string;
  bentoCard4Title: string;
  bentoCard4Desc: string;
  bentoCard5Title: string;
  bentoCard5Desc: string;
  catalogSearchPlaceholder: string;
  catalogAllCategories: string;
  catalogNoResults: string;
  catalogResetFilters: string;
  catalogCopyCli: string;
  catalogViewCode: string;
  catalogViewDocs: string;
  catalogPresetLabel: string;
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
    copied: 'Copied!',
    togglePreset: 'Toggle preset',
    componentsPageTitle: 'Components',
    componentsPageDescription:
      'All components are ready to use. Copy, paste, and customize directly in your Flutter project.',
    componentsPageCount: 'components available',
    terminalTitle: 'justui@v0.14.0 ~ /my-flutter-app',
    terminalBadge: 'CLI Simulator',
    terminalShortcuts: '[Tab] Autocomplete | [Up/Down] History | [Enter] Run',
    terminalChipInit: 'justui init',
    terminalChipAddButton: 'justui add button',
    terminalChipAddMulti: 'justui add switch card',
    terminalChipPreset: 'justui preset apply neobrutalism',
    installTabCurl: 'macOS / Linux',
    installTabPowershell: 'Windows',
    installTabCargo: 'Cargo',
    stageBadge: 'Live Flutter Canvas',
    stageClear: 'Clear',
    stageEmptyTitle: 'Flutter Canvas Ready',
    stageEmptyDescription:
      'Run commands in the terminal to copy components into your project and preview them live here.',
    stageEmptyCta: 'Run: justui add button',
    stageInteractTip:
      'Tip: Click or interact with widgets above to test state animations.',
    stageEmptyState:
      'Run a command in the terminal to see components appear here.',
    stagePreviewTab: 'Preview',
    stageCodeTab: 'Flutter Code',
    presetCleanPrecision: 'Clean Precision',
    presetNeobrutalism: 'Neobrutalism',
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
    bentoBadge: 'THE ENGINE ROOM',
    bentoHeading: 'Engineered for Extreme Performance',
    bentoDescription:
      'Built with core Flutter principles: zero-allocation paint loops, aspect-based InheritedModel isolation, and WCAG AA contrast compliance.',
    bentoCard1Title: 'Zero-Dependency Footprint',
    bentoCard1Desc:
      'No pub.dev dependency bloat. Pure Flutter primitives directly copied into your workspace.',
    bentoCard2Title: 'Dynamic Contrast Auditor',
    bentoCard2Desc:
      'Real-time WCAG AA ratio calculation with OKLCH gamut awareness and lightness correction.',
    bentoCard3Title: 'Aspect-Based Rebuilds',
    bentoCard3Desc:
      'InheritedModel aspect isolation ensures widgets only rebuild when their targeted properties mutate.',
    bentoCard4Title: 'Neobrutalism Zero-Drift',
    bentoCard4Desc:
      'Offset-compensated inward borders and instant animation timing to prevent visual jitter.',
    bentoCard5Title: 'Dart 3 Expressive DX',
    bentoCard5Desc:
      'Dot-shorthand syntax and concise constructors for clean, idiomatic Flutter code.',
    catalogSearchPlaceholder: 'Search 33 components... (press "/" to focus)',
    catalogAllCategories: 'All',
    catalogNoResults: 'No components found matching your query.',
    catalogResetFilters: 'Reset filters',
    catalogCopyCli: 'Copy CLI command',
    catalogViewCode: 'View Dart code',
    catalogViewDocs: 'Documentation',
    catalogPresetLabel: 'Preset',
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
    copied: 'Tersalin!',
    togglePreset: 'Ganti preset',
    componentsPageTitle: 'Komponen',
    componentsPageDescription:
      'Semua komponen siap pakai. Copy, paste, dan sesuaikan langsung di project Flutter kamu.',
    componentsPageCount: 'komponen tersedia',
    terminalTitle: 'justui@v0.14.0 ~ /my-flutter-app',
    terminalBadge: 'Simulator CLI',
    terminalShortcuts: '[Tab] Autocomplete | [Up/Down] History | [Enter] Run',
    terminalChipInit: 'justui init',
    terminalChipAddButton: 'justui add button',
    terminalChipAddMulti: 'justui add switch card',
    terminalChipPreset: 'justui preset apply neobrutalism',
    installTabCurl: 'macOS / Linux',
    installTabPowershell: 'Windows',
    installTabCargo: 'Cargo',
    stageBadge: 'Kanvas Flutter Live',
    stageClear: 'Bersihkan',
    stageEmptyTitle: 'Kanvas Flutter Siap Digunakan',
    stageEmptyDescription:
      'Jalankan perintah di terminal untuk menyalin komponen ke proyekmu dan lihat pratinjaunya di sini.',
    stageEmptyCta: 'Jalankan: justui add button',
    stageInteractTip:
      'Tip: Klik atau interaksikan widget di atas untuk mencoba animasinya.',
    stageEmptyState:
      'Jalankan perintah di terminal untuk melihat komponen muncul di sini.',
    stagePreviewTab: 'Pratinjau',
    stageCodeTab: 'Kode Flutter',
    presetCleanPrecision: 'Presisi Bersih',
    presetNeobrutalism: 'Neobrutalisme',
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
    bentoBadge: 'RUANG MESIN ARSITEKTUR',
    bentoHeading: 'Direkayasa untuk Performa Ekstrem',
    bentoDescription:
      'Dibangun dengan prinsip inti Flutter: paint loop bebas alokasi, isolasi InheritedModel berbasis aspek, dan kepatuhan kontras WCAG AA.',
    bentoCard1Title: 'Jejak Nol-Dependensi',
    bentoCard1Desc:
      'Bebas dari beban dependensi pub.dev pihak ketiga. Primitif murni Flutter disalin langsung ke proyekmu.',
    bentoCard2Title: 'Auditor Kontras Dinamis',
    bentoCard2Desc:
      'Kalkulasi rasio WCAG AA seketika dengan kesadaran gamut OKLCH dan koreksi lightness otomatis.',
    bentoCard3Title: 'Rebuild Berbasis Aspek',
    bentoCard3Desc:
      'Isolasi aspek InheritedModel memastikan widget hanya render ulang saat properti targetnya berubah.',
    bentoCard4Title: 'Fisika Zero-Drift Neobrutalisme',
    bentoCard4Desc:
      'Kompensasi border ke dalam dan timing animasi instan untuk mencegah jitter visual saat ditekan.',
    bentoCard5Title: 'Pengalaman Pengembang Dart 3',
    bentoCard5Desc:
      'Sintaksis dot-shorthand dan konstruktor ringkas untuk kode Flutter yang bersih dan idiomatis.',
    catalogSearchPlaceholder: 'Cari 33 komponen... (tekan "/" untuk fokus)',
    catalogAllCategories: 'Semua',
    catalogNoResults: 'Tidak ada komponen yang cocok dengan pencarian Anda.',
    catalogResetFilters: 'Atur ulang filter',
    catalogCopyCli: 'Salin perintah CLI',
    catalogViewCode: 'Lihat kode Dart',
    catalogViewDocs: 'Dokumentasi',
    catalogPresetLabel: 'Preset',
  },
} as const;

export function getHomepageDictionary(lang: string): HomepageDictionary {
  return homepageTranslations[lang] ?? homepageTranslations.en;
}
