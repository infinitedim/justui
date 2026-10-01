export type StudioLanguage = 'en' | 'id';

export interface StudioDictionary {
  title: string;
  subtitle: string;
  seedColor: string;
  mode: string;
  light: string;
  dark: string;
  preset: string;
  presetHint: string;
  exportFormatsLabel: string;
  hexInputLabel: string;
  copyTokenColor: (token: string) => string;
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
  copyFailed: string;
  contrastRatio: string;
  tabYaml: string;
  tabDart: string;
  tabCli: string;
  mockAppName: string;
  mockSearchPlaceholder: string;
  mockNotifications: string;
  mockFollowUpsTitle: string;
  mockFollowUpsSummary: string;
  mockLogCall: string;
  mockReminders: string;
  mockOn: string;
  mockOff: string;
  mockTabsLabel: string;
  mockTabPipeline: string;
  mockTabContacts: string;
  mockTabTasks: string;
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
    subtitle:
      'Pick one color. The studio derives light and dark palettes that pass WCAG AA, then gives you the config for justui init.',
    seedColor: 'Seed Color',
    mode: 'Mode',
    light: 'Light',
    dark: 'Dark',
    preset: 'Preset',
    presetHint: '(change it in the header)',
    exportFormatsLabel: 'Export format',
    hexInputLabel: 'Seed color hex value',
    copyTokenColor: (token) => `Copy ${token} color`,
    colorSpace: 'Color Space',
    colorSpaceHsl: 'HSL',
    colorSpaceOklch: 'OKLCH',
    colorSpaceHsluv: 'HSLuv',
    resolvedPalette: 'Resolved Palette',
    export: 'Export',
    share: 'Share',
    reset: 'Reset',
    copyCode: 'Copy code',
    copied: 'Copied',
    copyFailed: 'Copy failed',
    contrastRatio: 'Contrast',
    tabYaml: 'Config YAML',
    tabDart: 'Dart Code',
    tabCli: 'CLI Command',
    mockAppName: 'Relasi',
    mockSearchPlaceholder: 'Search contacts',
    mockNotifications: 'Notifications',
    mockFollowUpsTitle: "Today's follow-ups",
    mockFollowUpsSummary: '3 calls and 1 proposal due before 17:00.',
    mockLogCall: 'Log call',
    mockReminders: 'Follow-up reminders',
    mockOn: 'On',
    mockOff: 'Off',
    mockTabsLabel: 'Sections',
    mockTabPipeline: 'Pipeline',
    mockTabContacts: 'Contacts',
    mockTabTasks: 'Tasks',
    shareSuccess: 'Share link copied',
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
    subtitle:
      'Pilih satu warna. Studio menurunkan palet terang dan gelap yang lolos WCAG AA, lalu memberi config untuk justui init.',
    seedColor: 'Warna Dasar',
    mode: 'Mode',
    light: 'Terang',
    dark: 'Gelap',
    preset: 'Preset',
    presetHint: '(ubah lewat header)',
    exportFormatsLabel: 'Format ekspor',
    hexInputLabel: 'Nilai hex warna seed',
    copyTokenColor: (token) => `Salin warna ${token}`,
    colorSpace: 'Ruang Warna',
    colorSpaceHsl: 'HSL',
    colorSpaceOklch: 'OKLCH',
    colorSpaceHsluv: 'HSLuv',
    resolvedPalette: 'Palet Hasil',
    export: 'Ekspor',
    share: 'Bagikan',
    reset: 'Reset',
    copyCode: 'Salin kode',
    copied: 'Tersalin',
    copyFailed: 'Gagal menyalin',
    contrastRatio: 'Kontras',
    tabYaml: 'Config YAML',
    tabDart: 'Kode Dart',
    tabCli: 'Perintah CLI',
    mockAppName: 'Relasi',
    mockSearchPlaceholder: 'Cari kontak',
    mockNotifications: 'Notifikasi',
    mockFollowUpsTitle: 'Tindak lanjut hari ini',
    mockFollowUpsSummary:
      '3 panggilan dan 1 penawaran jatuh tempo sebelum 17.00.',
    mockLogCall: 'Catat panggilan',
    mockReminders: 'Pengingat tindak lanjut',
    mockOn: 'Aktif',
    mockOff: 'Mati',
    mockTabsLabel: 'Bagian',
    mockTabPipeline: 'Pipeline',
    mockTabContacts: 'Kontak',
    mockTabTasks: 'Tugas',
    shareSuccess: 'Tautan berbagi tersalin',
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
