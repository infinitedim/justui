export type StudioLanguage = 'en' | 'id';

export interface StudioDictionary {
  title: string;
  subtitle: string;
  seedColor: string;
  mode: string;
  light: string;
  dark: string;
  preset: string;
  presetDefault: string;
  presetNeobrutalism: string;
  colorSpace: string;
  colorSpaceHsl: string;
  colorSpaceOklch: string;
  colorSpaceHsluv: string;
  resolvedPalette: string;
  export: string;
  share: string;
  reset: string;
  copyCode: string;
  copied: string;
  contrastRatio: string;
  tabYaml: string;
  tabDart: string;
  tabCli: string;
  preview: string;
  components: string;
  button: string;
  card: string;
  welcomeBack: string;
  exploreComponents: string;
  getStarted: string;
  active: string;
  inactive: string;
  notifications: string;
  searchPlaceholder: string;
  shareSuccess: string;
  tokenBackground: string;
  tokenCard: string;
  tokenTextPrimary: string;
  tokenTextSecondary: string;
  tokenAccent: string;
  tokenBorder: string;
  tokenSuccess: string;
  tokenWarning: string;
  tokenError: string;
  lightness: string;
}

const studioDictionaries: Record<StudioLanguage, StudioDictionary> = {
  en: {
    title: 'Theme Studio',
    subtitle: 'Configure your design tokens visually and export production-ready code.',
    seedColor: 'Seed Color',
    mode: 'Mode',
    light: 'Light',
    dark: 'Dark',
    preset: 'Preset',
    presetDefault: 'Default',
    presetNeobrutalism: 'Neobrutalism',
    colorSpace: 'Color Space',
    colorSpaceHsl: 'HSL',
    colorSpaceOklch: 'OKLCH',
    colorSpaceHsluv: 'HSLuv',
    resolvedPalette: 'Resolved Palette',
    export: 'Export',
    share: 'Share',
    reset: 'Reset',
    copyCode: 'Copy code',
    copied: 'Copied!',
    contrastRatio: 'Contrast',
    tabYaml: 'Config YAML',
    tabDart: 'Dart Code',
    tabCli: 'CLI Command',
    preview: 'Device Preview',
    components: 'Components',
    button: 'Button',
    card: 'Card',
    welcomeBack: 'Welcome back',
    exploreComponents: 'Explore JustUI components',
    getStarted: 'Get Started',
    active: 'Active',
    inactive: 'Inactive',
    notifications: 'Notifications',
    searchPlaceholder: 'Search components...',
    shareSuccess: 'Shareable URL copied to clipboard!',
    tokenBackground: 'Background',
    tokenCard: 'Card Surface',
    tokenTextPrimary: 'Primary Text',
    tokenTextSecondary: 'Secondary Text',
    tokenAccent: 'Accent Primary',
    tokenBorder: 'Border Line',
    tokenSuccess: 'Success State',
    tokenWarning: 'Warning State',
    tokenError: 'Error State',
    lightness: 'Lightness',
  },
  id: {
    title: 'Theme Studio',
    subtitle: 'Konfigurasi design token secara visual dan ekspor kode siap produksi.',
    seedColor: 'Warna Dasar',
    mode: 'Mode',
    light: 'Terang',
    dark: 'Gelap',
    preset: 'Preset',
    presetDefault: 'Default',
    presetNeobrutalism: 'Neobrutalism',
    colorSpace: 'Ruang Warna',
    colorSpaceHsl: 'HSL',
    colorSpaceOklch: 'OKLCH',
    colorSpaceHsluv: 'HSLuv',
    resolvedPalette: 'Palet Hasil',
    export: 'Ekspor',
    share: 'Bagikan',
    reset: 'Reset',
    copyCode: 'Salin kode',
    copied: 'Tersalin!',
    contrastRatio: 'Kontras',
    tabYaml: 'Config YAML',
    tabDart: 'Kode Dart',
    tabCli: 'Perintah CLI',
    preview: 'Pratinjau Perangkat',
    components: 'Komponen',
    button: 'Tombol',
    card: 'Kartu',
    welcomeBack: 'Selamat datang kembali',
    exploreComponents: 'Jelajahi komponen JustUI',
    getStarted: 'Mulai Sekarang',
    active: 'Aktif',
    inactive: 'Nonaktif',
    notifications: 'Notifikasi',
    searchPlaceholder: 'Cari komponen...',
    shareSuccess: 'URL tautan berhasil disalin ke papan klip!',
    tokenBackground: 'Latar Belakang',
    tokenCard: 'Permukaan Kartu',
    tokenTextPrimary: 'Teks Utama',
    tokenTextSecondary: 'Teks Sekunder',
    tokenAccent: 'Aksen Utama',
    tokenBorder: 'Garis Batas',
    tokenSuccess: 'Status Sukses',
    tokenWarning: 'Status Peringatan',
    tokenError: 'Status Galat',
    lightness: 'Kecerahan',
  },
};

export function getStudioDictionary(lang?: string): StudioDictionary {
  if (lang === 'id') {
    return studioDictionaries.id;
  }
  return studioDictionaries.en;
}
