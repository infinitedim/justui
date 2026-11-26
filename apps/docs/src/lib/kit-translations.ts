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
  add: string;
  bold: string;
  breadcrumb: string;
  sidebarLabel: string;
  bottomNavLabel: string;
  tabsLabel: string;
  daysLabel: string;
  slidesLabel: string;
  /** Weekday abbreviations from Monday (live date pickers). */
  weekdays: readonly [string, string, string, string, string, string, string];
  /** Screen reader name of a day cell: `{day}`, `{month}`, `{year}`. */
  dayLabel: string;
  /** Screen reader name of a resizable splitter: `{index}`. */
  splitterLabel: string;
  /** Screen reader name of the scroll area demo. */
  scrollAreaLabel: string;
  /** Screen reader name of the time picker demo. */
  timePickerLabel: string;
  /** Label for the hour segment in the time picker. */
  hourLabel: string;
  /** Label for the minute segment in the time picker. */
  minuteLabel: string;
  /** Label for the period segment in the time picker. */
  periodLabel: string;
  /** AM period label in the time picker. */
  amLabel: string;
  /** PM period label in the time picker. */
  pmLabel: string;
  /** Tooltip for switching the time picker to dial mode. */
  dialModeTooltip: string;
  /** Tooltip for switching the time picker to input mode. */
  inputModeTooltip: string;
  /** Tooltip for switching the time picker to spinner mode. */
  spinnerModeTooltip: string;
  /** Semantic label for increasing a time picker value. */
  nextValueLabel: string;
  /** Semantic label for decreasing a time picker value. */
  previousValueLabel: string;
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
    add: 'Add',
    bold: 'Bold',
    breadcrumb: 'Breadcrumb',
    sidebarLabel: 'Sections',
    bottomNavLabel: 'App navigation',
    tabsLabel: 'Settings sections',
    daysLabel: 'Days in October',
    slidesLabel: 'Slides',
    weekdays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    dayLabel: '{month} {day}, {year}',
    splitterLabel: 'Panel divider {index}',
    scrollAreaLabel: 'Scrollable component paths',
    timePickerLabel: 'Select time',
    hourLabel: 'Hour',
    minuteLabel: 'Minute',
    periodLabel: 'Period',
    amLabel: 'AM',
    pmLabel: 'PM',
    dialModeTooltip: 'Switch to dial mode',
    inputModeTooltip: 'Switch to input mode',
    spinnerModeTooltip: 'Switch to spinner mode',
    nextValueLabel: 'Next value',
    previousValueLabel: 'Previous value',
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
    add: 'Tambah',
    bold: 'Tebal',
    breadcrumb: 'Jejak navigasi',
    sidebarLabel: 'Bagian',
    bottomNavLabel: 'Navigasi aplikasi',
    tabsLabel: 'Bagian pengaturan',
    daysLabel: 'Hari di bulan Oktober',
    slidesLabel: 'Slide',
    weekdays: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
    dayLabel: '{day} {month} {year}',
    splitterLabel: 'Pemisah panel {index}',
    scrollAreaLabel: 'Daftar path komponen yang bisa digulir',
    timePickerLabel: 'Pilih waktu',
    hourLabel: 'Jam',
    minuteLabel: 'Menit',
    periodLabel: 'Periode',
    amLabel: 'AM',
    pmLabel: 'PM',
    dialModeTooltip: 'Ganti ke mode dial',
    inputModeTooltip: 'Ganti ke mode input',
    spinnerModeTooltip: 'Ganti ke mode spinner',
    nextValueLabel: 'Nilai berikutnya',
    previousValueLabel: 'Nilai sebelumnya',
  },
} satisfies Record<Locale, KitDictionary>;

/** Kit dictionary for a locale; unknown values fall back to English. */
export function getKitDictionary(lang: string): KitDictionary {
  return isLocale(lang) ? kitTranslations[lang] : kitTranslations.en;
}
