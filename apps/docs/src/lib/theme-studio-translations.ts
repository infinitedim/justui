export type StudioLanguage = 'en' | 'id';

export interface StudioDictionary {
  title: string;
  subtitle: string;
  seedColor: string;
  hexLabel: string;
  recentColors: string;
  mode: string;
  light: string;
  dark: string;
  preset: string;
  presetDefault: string;
  presetNeobrutalism: string;
  colorSpace: string;
  colorSpaceHint: string;
  colorSpaceHsl: string;
  colorSpaceOklch: string;
  colorSpaceHsluv: string;
  resolvedPalette: string;
  resolvedPaletteHint: string;
  /** `{target}` is replaced with the token the ratio is measured against. */
  contrastOn: string;
  seedTextTarget: string;
  copyToken: string;
  export: string;
  share: string;
  reset: string;
  copyCode: string;
  copied: string;
  copyFailed: string;
  tabCli: string;
  previewOrder: string;
  previewTitle: string;
  previewEmail: string;
  previewEmailValue: string;
  previewNotify: string;
  previewItem: string;
  previewItemMeta: string;
  previewBadge: string;
  previewSave: string;
  previewCancel: string;
  previewToast: string;
  lightness: string;
}

const studioDictionaries: Record<StudioLanguage, StudioDictionary> = {
  en: {
    title: 'Theme Studio',
    subtitle:
      'Pick one color. The studio derives light and dark palettes that pass AA, then gives you the config for justui init.',
    seedColor: 'Seed color',
    hexLabel: 'Seed color as hex',
    recentColors: 'Recent',
    mode: 'Mode',
    light: 'Light',
    dark: 'Dark',
    preset: 'Preset',
    presetDefault: 'default',
    presetNeobrutalism: 'neobrutalism',
    colorSpace: 'Color space',
    colorSpaceHint:
      'Sets color_space for JustThemeData.fromSeed in your app, which changes how tints of the seed are mixed. This preview always mixes in HSL.',
    colorSpaceHsl: 'HSL',
    colorSpaceOklch: 'OKLCH',
    colorSpaceHsluv: 'HSLuv',
    resolvedPalette: 'Resolved palette',
    resolvedPaletteHint: 'Click a token to copy its hex value.',
    contrastOn: 'on {target}',
    seedTextTarget: 'its text',
    copyToken: 'Copy {token}',
    export: 'Export',
    share: 'Share',
    reset: 'Reset',
    copyCode: 'Copy code',
    copied: 'Copied',
    copyFailed: 'Copy failed',
    tabCli: 'terminal',
    previewOrder: 'Order #1042',
    previewTitle: 'Shipping details',
    previewEmail: 'Email',
    previewEmailValue: 'name@example.com',
    previewNotify: 'Email me order updates',
    previewItem: 'Ceramic mug x2',
    previewItemMeta: 'Arrives Friday, $24.00',
    previewBadge: 'Paid',
    previewSave: 'Save',
    previewCancel: 'Cancel',
    previewToast: 'Address saved',
    lightness: 'Lightness',
  },
  id: {
    title: 'Theme Studio',
    subtitle:
      'Pilih satu warna. Studio menurunkan palet terang/gelap yang lolos AA, lalu memberi config untuk justui init.',
    seedColor: 'Warna dasar',
    hexLabel: 'Warna dasar dalam hex',
    recentColors: 'Terakhir dipakai',
    mode: 'Mode',
    light: 'Terang',
    dark: 'Gelap',
    preset: 'Preset',
    presetDefault: 'default',
    presetNeobrutalism: 'neobrutalism',
    colorSpace: 'Ruang warna',
    colorSpaceHint:
      'Mengatur color_space untuk JustThemeData.fromSeed di aplikasimu, yang mengubah cara turunan warna dasar dicampur. Pratinjau ini selalu mencampur dalam HSL.',
    colorSpaceHsl: 'HSL',
    colorSpaceOklch: 'OKLCH',
    colorSpaceHsluv: 'HSLuv',
    resolvedPalette: 'Palet hasil',
    resolvedPaletteHint: 'Klik token untuk menyalin nilai hex-nya.',
    contrastOn: 'di atas {target}',
    seedTextTarget: 'teksnya',
    copyToken: 'Salin {token}',
    export: 'Ekspor',
    share: 'Bagikan',
    reset: 'Atur ulang',
    copyCode: 'Salin kode',
    copied: 'Tersalin',
    copyFailed: 'Gagal menyalin',
    tabCli: 'terminal',
    previewOrder: 'Pesanan #1042',
    previewTitle: 'Detail pengiriman',
    previewEmail: 'Email',
    previewEmailValue: 'nama@contoh.com',
    previewNotify: 'Kirim kabar pesanan lewat email',
    previewItem: 'Mug keramik x2',
    previewItemMeta: 'Tiba hari Jumat, Rp 240.000',
    previewBadge: 'Lunas',
    previewSave: 'Simpan',
    previewCancel: 'Batal',
    previewToast: 'Alamat tersimpan',
    lightness: 'Kecerahan',
  },
};

export function getStudioDictionary(lang?: string): StudioDictionary {
  if (lang === 'id') {
    return studioDictionaries.id;
  }
  return studioDictionaries.en;
}
