import { isLocale, type Locale } from '@/lib/i18n';
import type { JustUIPreset } from '@/lib/presets';

/**
 * Landing copy. `{name}` placeholders are filled with `formatMessage`;
 * counts always come from `src/lib/parts.ts`, never from the copy.
 */
export interface LandingDictionary {
  metaTitle: string;
  heroTitle: string;
  heroDescription: string;
  runners: string;
  presetNotes: Record<JustUIPreset, string>;
  partsCount: string;
  landsAs: string;
  cutTitle: string;
  cutLead: string;
  cutTail: string;
  cutEmpty: string;
  sharedMore: string;
  verify: string;
  before: string;
  after: string;
  runnersTitle: string;
  runnersLead: string;
  inHand: string;
  installTitle: string;
  stepInstall: string;
  stepInit: string;
  stepInitWrites: string;
  stepAdd: string;
  stepAddLands: string;
  moreFiles: string;
  featuresTitle: string;
  sourceTitle: string;
  sourceBody: string;
  dryRunNote: string;
  diffNote: string;
  tokensTitle: string;
  tokensBody: string;
  tokenColumn: string;
  textTitle: string;
  textBody: string;
  onPaper: string;
  onInk: string;
  partsTitle: string;
  partsLead: string;
  copyPart: string;
}

export const landingTranslations = {
  en: {
    metaTitle: 'One command. One file. Yours.',
    heroTitle: 'One command. One file. Yours.',
    heroDescription:
      'Not a dependency. JustUI copies Flutter components into your project as plain source, so there is no package to upgrade, no Material, and nothing beyond the SDK.',
    runners: 'Runners in this box',
    presetNotes: {
      default: 'Hairlines, soft ink shadow, 8px corners.',
      neobrutalism: '2.5px ink border, flat 4px offset shadow, square corners.',
    },
    partsCount: '{count} parts',
    landsAs: 'lands as',
    cutTitle: 'Cut one part. One file lands.',
    cutLead: 'Scroll to run',
    cutTail:
      '. The part leaves the runner and arrives in {dir} as plain Dart you own.',
    cutEmpty: 'cut',
    sharedMore: '+{count} files',
    verify:
      '{total} files written: {own} for {name}, {shared} shared dependencies. Each checked against the registry checksum',
    before: 'Before',
    after: 'After',
    runnersTitle: 'Same parts, two runners.',
    runnersLead:
      'One settings screen assembled from the same component files. Only the preset tokens differ.',
    inHand: 'In your hand',
    installTitle: 'Three steps, in order.',
    stepInstall: 'Install the CLI',
    stepInit: 'Set up your project',
    stepInitWrites: 'Writes',
    stepAdd: 'Cut a part',
    stepAddLands: 'Lands in',
    moreFiles: '+ {count} more files',
    featuresTitle: 'What you actually get',
    sourceTitle: 'Source in your repo, checked first.',
    sourceBody:
      "Every file is verified against the registry's SHA-256 checksum before it is written. After that it is ordinary Dart in your tree: edit it, rename it, delete it.",
    dryRunNote: 'Preview without writing to disk',
    diffNote: 'Compare your files against the registry',
    tokensTitle: 'Presets swap tokens, not components.',
    tokensBody:
      'A runner changes border, shadow, radius, motion, and which role paints which part. The widget file you copied stays the same.',
    tokenColumn: 'Token',
    textTitle: 'Text follows the background.',
    textBody:
      'Text color is resolved from the surface it sits on, so the same component stays legible on paper and on ink.',
    onPaper: 'On paper',
    onInk: 'On ink',
    partsTitle: 'Every part on the runner',
    partsLead: '{count} parts. Select one to copy its command.',
    copyPart: 'Copy justui add {name}',
  },
  id: {
    metaTitle: 'Satu perintah. Satu file. Milikmu.',
    heroTitle: 'Satu perintah. Satu file. Milikmu.',
    heroDescription:
      'Bukan dependency. JustUI menyalin komponen Flutter ke project kamu sebagai source biasa, jadi tidak ada package yang perlu di-upgrade, tanpa Material, dan tidak butuh apa pun selain SDK.',
    runners: 'Runner di dalam kotak ini',
    presetNotes: {
      default: 'Garis tipis, shadow tinta lembut, sudut 8px.',
      neobrutalism: 'Border tinta 2.5px, shadow offset datar 4px, sudut siku.',
    },
    partsCount: '{count} part',
    landsAs: 'mendarat sebagai',
    cutTitle: 'Potong satu part. Satu file mendarat.',
    cutLead: 'Gulir untuk menjalankan',
    cutTail:
      '. Part lepas dari runner dan tiba di {dir} sebagai Dart biasa milikmu.',
    cutEmpty: 'terpotong',
    sharedMore: '+{count} file',
    verify:
      '{total} file ditulis: {own} untuk {name}, {shared} dependency shared. Masing-masing dicek dengan checksum registry',
    before: 'Sebelum',
    after: 'Sesudah',
    runnersTitle: 'Part yang sama, dua runner.',
    runnersLead:
      'Satu layar pengaturan dirakit dari file komponen yang sama. Hanya token preset-nya yang berbeda.',
    inHand: 'Di tanganmu',
    installTitle: 'Tiga langkah, berurutan.',
    stepInstall: 'Pasang CLI',
    stepInit: 'Siapkan project',
    stepInitWrites: 'Menulis',
    stepAdd: 'Potong satu part',
    stepAddLands: 'Mendarat di',
    moreFiles: '+ {count} file lainnya',
    featuresTitle: 'Yang sebenarnya kamu dapat',
    sourceTitle: 'Source di repo kamu, dicek dulu.',
    sourceBody:
      'Setiap file diverifikasi dengan checksum SHA-256 dari registry sebelum ditulis. Setelah itu ia hanyalah Dart biasa di project kamu: edit, ganti nama, atau hapus.',
    dryRunNote: 'Pratinjau tanpa menulis ke disk',
    diffNote: 'Bandingkan file kamu dengan registry',
    tokensTitle: 'Preset menukar token, bukan komponen.',
    tokensBody:
      'Runner mengubah border, shadow, radius, motion, dan role mana yang mengecat bagian mana. File widget yang kamu salin tetap sama.',
    tokenColumn: 'Token',
    textTitle: 'Warna teks mengikuti background.',
    textBody:
      'Warna teks ditentukan dari permukaan tempatnya berada, jadi komponen yang sama tetap terbaca di kertas maupun tinta.',
    onPaper: 'Di kertas',
    onInk: 'Di tinta',
    partsTitle: 'Semua part di runner',
    partsLead: '{count} part. Pilih satu untuk menyalin perintahnya.',
    copyPart: 'Salin justui add {name}',
  },
} satisfies Record<Locale, LandingDictionary>;

/** Landing dictionary for a locale; unknown values fall back to English. */
export function getLandingDictionary(lang: string): LandingDictionary {
  return isLocale(lang) ? landingTranslations[lang] : landingTranslations.en;
}
