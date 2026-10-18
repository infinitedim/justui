import { isLocale, type Locale } from '@/lib/i18n';

/** Copy shown inside the runner-kit demo parts (landing and 404). */
export interface KitDictionary {
  saveChanges: string;
  save: string;
  saveDraft: string;
  cancel: string;
  wifi: string;
  remember: string;
  project: string;
  badProject: string;
  sendTo: string;
  badEmail: string;
  volume: string;
  alertVolume: string;
  frequency: string;
  weekly: string;
  monthly: string;
  uploading: string;
  draft: string;
  tabs: readonly [string, string, string];
  saved: string;
  savedBody: string;
  notifSaved: string;
  notifications: string;
  notificationsBody: string;
  productUpdates: string;
  weeklyDigest: string;
  copy: string;
  accordionQuestion: string;
  accordionAnswer: string;
  discardTitle: string;
  discard: string;
  share: string;
  sidebar: readonly [string, string, string];
  bottomNav: readonly [string, string, string];
  part: string;
  folder: string;
  month: string;
  slide: string;
  slideAria: string;
  files: string;
  editor: string;
  settings: string;
}

export const kitTranslations = {
  en: {
    saveChanges: 'Save changes',
    save: 'Save',
    saveDraft: 'Save draft',
    cancel: 'Cancel',
    wifi: 'Wi-Fi',
    remember: 'Remember this device',
    project: 'Project name',
    badProject: 'Use lowercase letters, numbers and underscores.',
    sendTo: 'Send to',
    badEmail: 'Enter an email address, like team@example.com.',
    volume: 'Volume',
    alertVolume: 'Alert volume',
    frequency: 'Frequency',
    weekly: 'Weekly',
    monthly: 'Monthly',
    uploading: 'Uploading',
    draft: 'Draft',
    tabs: ['Account', 'Billing', 'Team'],
    saved: 'Saved',
    savedBody: 'Project settings updated.',
    notifSaved: 'Notification settings updated.',
    notifications: 'Notifications',
    notificationsBody: 'Choose what reaches your inbox.',
    productUpdates: 'Product updates',
    weeklyDigest: 'Weekly digest',
    copy: 'Copy',
    accordionQuestion: 'What is a runner?',
    accordionAnswer: 'One preset, with every part on it.',
    discardTitle: 'Discard changes?',
    discard: 'Discard',
    share: 'Share project',
    sidebar: ['Overview', 'Components', 'Settings'],
    bottomNav: ['Home', 'Search', 'Profile'],
    part: 'Part',
    folder: 'Folder',
    month: 'October',
    slide: 'Slide {index} of {total}',
    slideAria: 'Go to slide {index}',
    files: 'Files',
    editor: 'Editor',
    settings: 'Settings',
  },
  id: {
    saveChanges: 'Simpan perubahan',
    save: 'Simpan',
    saveDraft: 'Simpan draf',
    cancel: 'Batal',
    wifi: 'Wi-Fi',
    remember: 'Ingat perangkat ini',
    project: 'Nama project',
    badProject: 'Gunakan huruf kecil, angka, dan garis bawah.',
    sendTo: 'Kirim ke',
    badEmail: 'Masukkan alamat email, misalnya team@example.com.',
    volume: 'Volume',
    alertVolume: 'Volume notifikasi',
    frequency: 'Frekuensi',
    weekly: 'Mingguan',
    monthly: 'Bulanan',
    uploading: 'Mengunggah',
    draft: 'Draf',
    tabs: ['Akun', 'Tagihan', 'Tim'],
    saved: 'Tersimpan',
    savedBody: 'Pengaturan project diperbarui.',
    notifSaved: 'Pengaturan notifikasi diperbarui.',
    notifications: 'Notifikasi',
    notificationsBody: 'Pilih apa saja yang masuk ke inbox kamu.',
    productUpdates: 'Kabar produk',
    weeklyDigest: 'Ringkasan mingguan',
    copy: 'Salin',
    accordionQuestion: 'Apa itu runner?',
    accordionAnswer: 'Satu preset, dengan semua part di dalamnya.',
    discardTitle: 'Buang perubahan?',
    discard: 'Buang',
    share: 'Bagikan project',
    sidebar: ['Ringkasan', 'Komponen', 'Pengaturan'],
    bottomNav: ['Beranda', 'Cari', 'Profil'],
    part: 'Part',
    folder: 'Folder',
    month: 'Oktober',
    slide: 'Slide {index} dari {total}',
    slideAria: 'Ke slide {index}',
    files: 'File',
    editor: 'Editor',
    settings: 'Pengaturan',
  },
} satisfies Record<Locale, KitDictionary>;

/** Kit dictionary for a locale; unknown values fall back to English. */
export function getKitDictionary(lang: string): KitDictionary {
  return isLocale(lang) ? kitTranslations[lang] : kitTranslations.en;
}
