/**
 * Content for every catalog preview, written as screens from one example
 * app: "Relasi", the CRM a coffee distributor's sales team uses. One
 * scenario across all mocks makes the catalog read like a product instead of
 * a set of unrelated demos. Names, amounts and dates stay the same in both
 * locales; only the wording changes.
 */

type Stage = 'lead' | 'qualified' | 'proposal' | 'won';

export interface CrmStrings {
  stages: Readonly<Record<Stage, string>>;
  button: { label: string; logged: (count: number) => string };
  iconButton: { call: string; email: string; star: string; starred: string };
  input: {
    label: string;
    value: string;
    invalid: string;
  };
  avatar: { online: string; offline: string; toggle: string };
  avatarGroup: { label: string; more: (count: number) => string };
  select: { label: string };
  progress: { label: string; detail: string };
  accordion: {
    items: readonly { title: string; body: string }[];
  };
  toggle: { label: string; mine: string; overdue: string; starred: string };
  checkbox: { label: string };
  radio: { label: string; phone: string; email: string };
  radioGroup: { label: string; low: string; medium: string; high: string };
  switchMock: { label: string; on: string; off: string };
  card: { company: string; value: string; owner: string; due: string };
  separator: { open: string; won: string; lost: string };
  scrollArea: { label: string; items: readonly string[] };
  resizable: {
    label: string;
    listTitle: string;
    detailTitle: string;
    listItems: readonly string[];
    detail: string;
  };
  carousel: {
    label: string;
    previous: string;
    next: string;
    slides: readonly { company: string; detail: string }[];
    position: (index: number, total: number) => string;
  };
  skeleton: { label: string };
  slider: { label: string };
  breadcrumb: { label: string; items: readonly string[] };
  tabs: {
    label: string;
    items: readonly { id: string; label: string; body: string }[];
  };
  bottomNav: {
    label: string;
    items: readonly { id: string; label: string }[];
  };
  sidebar: {
    label: string;
    collapse: string;
    expand: string;
    items: readonly { id: string; label: string }[];
  };
  toast: { trigger: string; title: string; body: string; dismiss: string };
  dialog: {
    trigger: string;
    title: string;
    body: string;
    cancel: string;
    confirm: string;
  };
  sheet: {
    trigger: string;
    title: string;
    phone: string;
    lastContact: string;
    dismiss: string;
  };
  tooltip: { trigger: string; bubble: string };
  table: {
    caption: string;
    company: string;
    stage: string;
    value: string;
    sortByValue: string;
  };
  datePicker: { label: string; value: string };
  dateRangePicker: { label: string; value: string; days: string };
  timePicker: { label: string };
}

export const crmEn: CrmStrings = {
  stages: {
    lead: 'Lead',
    qualified: 'Qualified',
    proposal: 'Proposal',
    won: 'Won',
  },
  button: {
    label: 'Log call',
    logged: (count) =>
      count === 1 ? '1 call logged today' : `${count} calls logged today`,
  },
  iconButton: {
    call: 'Call Rina Wulandari',
    email: 'Email Rina Wulandari',
    star: 'Star contact',
    starred: 'Starred',
  },
  input: {
    label: 'Work email',
    value: 'rina@kopisenja.id',
    invalid: 'Enter an address like name@company.com.',
  },
  avatar: {
    online: 'Rina is online',
    offline: 'Rina is offline',
    toggle: 'Toggle Rina Wulandari status',
  },
  avatarGroup: {
    label: 'Deal team',
    more: (count) => `${count} more people`,
  },
  select: { label: 'Deal stage' },
  progress: {
    label: 'Q3 target',
    detail: 'Rp 412 jt of Rp 600 jt',
  },
  accordion: {
    items: [
      {
        title: 'Company',
        body: 'Kopi Senja, 4 outlets in Bandung. Orders every 2 weeks.',
      },
      {
        title: 'Notes',
        body: 'Wants a sample of the new Gayo roast before the next order.',
      },
    ],
  },
  toggle: {
    label: 'Filter deals',
    mine: 'Mine',
    overdue: 'Overdue',
    starred: 'Starred',
  },
  checkbox: { label: 'Send proposal to Hotel Arunika' },
  radio: { label: 'Preferred channel', phone: 'Phone', email: 'Email' },
  radioGroup: {
    label: 'Priority',
    low: 'Low',
    medium: 'Medium',
    high: 'High',
  },
  switchMock: { label: 'Follow-up reminders', on: 'On', off: 'Off' },
  card: {
    company: 'Hotel Arunika',
    value: 'Rp 18.450.000',
    owner: 'Owner: Dewi Lestari',
    due: 'Proposal due Thu, 17 Sep',
  },
  separator: { open: 'Open', won: 'Won', lost: 'Lost' },
  scrollArea: {
    label: 'Activity',
    items: [
      'Called Rina, asked for Gayo samples',
      'Proposal sent to Hotel Arunika',
      'Bagas moved Warung Nusantara to Qualified',
      'Meeting booked with Dewi for Thursday',
      'Invoice INV-2291 paid',
      'Note added to Kopi Senja',
    ],
  },
  resizable: {
    label: 'Pipeline and contact detail',
    listTitle: 'Pipeline',
    detailTitle: 'Kopi Senja',
    listItems: ['Kopi Senja', 'Hotel Arunika', 'Warung Nusantara'],
    detail: 'Qualified, Rp 7.200.000',
  },
  carousel: {
    label: 'Top accounts this month',
    previous: 'Previous account',
    next: 'Next account',
    slides: [
      { company: 'Hotel Arunika', detail: 'Rp 42.900.000 in 3 orders' },
      { company: 'Kopi Senja', detail: 'Rp 18.450.000 in 5 orders' },
      { company: 'Warung Nusantara', detail: 'Rp 7.200.000 in 2 orders' },
    ],
    position: (index, total) => `${index} of ${total}`,
  },
  skeleton: { label: 'Loading contacts' },
  slider: { label: 'Win probability' },
  breadcrumb: {
    label: 'Breadcrumb',
    items: ['Contacts', 'Kopi Senja', 'Deals'],
  },
  tabs: {
    label: 'Contact sections',
    items: [
      { id: 'overview', label: 'Overview', body: 'Last order 3 Sep, 24 kg.' },
      { id: 'deals', label: 'Deals', body: '2 open, 1 won this quarter.' },
      { id: 'notes', label: 'Notes', body: 'Prefers calls after 14:00.' },
    ],
  },
  bottomNav: {
    label: 'Sections',
    items: [
      { id: 'pipeline', label: 'Pipeline' },
      { id: 'contacts', label: 'Contacts' },
      { id: 'tasks', label: 'Tasks' },
    ],
  },
  sidebar: {
    label: 'Relasi navigation',
    collapse: 'Collapse sidebar',
    expand: 'Expand sidebar',
    items: [
      { id: 'pipeline', label: 'Pipeline' },
      { id: 'contacts', label: 'Contacts' },
      { id: 'reports', label: 'Reports' },
    ],
  },
  toast: {
    trigger: 'Mark as won',
    title: 'Deal moved to Won',
    body: 'Hotel Arunika, Rp 18.450.000',
    dismiss: 'Dismiss notification',
  },
  dialog: {
    trigger: 'Delete contact',
    title: 'Delete this contact?',
    body: 'Rina Wulandari and 3 notes will be removed.',
    cancel: 'Cancel',
    confirm: 'Delete',
  },
  sheet: {
    trigger: 'Quick view',
    title: 'Bagas Pratama',
    phone: '+62 812 4471 0932',
    lastContact: 'Last contacted 3 days ago',
    dismiss: 'Close',
  },
  tooltip: {
    trigger: 'Last contact',
    bubble: 'Called 3 days ago by Dewi',
  },
  table: {
    caption: 'Open deals',
    company: 'Company',
    stage: 'Stage',
    value: 'Value',
    sortByValue: 'Sort by value',
  },
  datePicker: { label: 'Follow-up date', value: 'Thu, 17 Sep 2026' },
  dateRangePicker: {
    label: 'Report period',
    value: '1 Sep - 15 Sep 2026',
    days: '15 days',
  },
  timePicker: { label: 'Call at' },
};

export const crmId: CrmStrings = {
  stages: {
    lead: 'Prospek',
    qualified: 'Kualifikasi',
    proposal: 'Penawaran',
    won: 'Menang',
  },
  button: {
    label: 'Catat panggilan',
    logged: (count) => `${count} panggilan tercatat hari ini`,
  },
  iconButton: {
    call: 'Telepon Rina Wulandari',
    email: 'Kirim email ke Rina Wulandari',
    star: 'Tandai kontak',
    starred: 'Ditandai',
  },
  input: {
    label: 'Email kantor',
    value: 'rina@kopisenja.id',
    invalid: 'Tulis alamat seperti nama@perusahaan.com.',
  },
  avatar: {
    online: 'Rina sedang online',
    offline: 'Rina sedang offline',
    toggle: 'Ubah status Rina Wulandari',
  },
  avatarGroup: {
    label: 'Tim deal',
    more: (count) => `${count} orang lagi`,
  },
  select: { label: 'Tahap deal' },
  progress: {
    label: 'Target Q3',
    detail: 'Rp 412 jt dari Rp 600 jt',
  },
  accordion: {
    items: [
      {
        title: 'Perusahaan',
        body: 'Kopi Senja, 4 gerai di Bandung. Pesan setiap 2 minggu.',
      },
      {
        title: 'Catatan',
        body: 'Minta sampel roasting Gayo baru sebelum pesanan berikutnya.',
      },
    ],
  },
  toggle: {
    label: 'Saring deal',
    mine: 'Milikku',
    overdue: 'Terlambat',
    starred: 'Ditandai',
  },
  checkbox: { label: 'Kirim penawaran ke Hotel Arunika' },
  radio: { label: 'Kanal utama', phone: 'Telepon', email: 'Email' },
  radioGroup: {
    label: 'Prioritas',
    low: 'Rendah',
    medium: 'Sedang',
    high: 'Tinggi',
  },
  switchMock: { label: 'Pengingat tindak lanjut', on: 'Aktif', off: 'Mati' },
  card: {
    company: 'Hotel Arunika',
    value: 'Rp 18.450.000',
    owner: 'Pemilik: Dewi Lestari',
    due: 'Penawaran jatuh tempo Kam, 17 Sep',
  },
  separator: { open: 'Terbuka', won: 'Menang', lost: 'Kalah' },
  scrollArea: {
    label: 'Aktivitas',
    items: [
      'Menelepon Rina, minta sampel Gayo',
      'Penawaran dikirim ke Hotel Arunika',
      'Bagas memindahkan Warung Nusantara ke Kualifikasi',
      'Rapat dengan Dewi dijadwalkan Kamis',
      'Tagihan INV-2291 lunas',
      'Catatan ditambahkan ke Kopi Senja',
    ],
  },
  resizable: {
    label: 'Pipeline dan detail kontak',
    listTitle: 'Pipeline',
    detailTitle: 'Kopi Senja',
    listItems: ['Kopi Senja', 'Hotel Arunika', 'Warung Nusantara'],
    detail: 'Kualifikasi, Rp 7.200.000',
  },
  carousel: {
    label: 'Akun teratas bulan ini',
    previous: 'Akun sebelumnya',
    next: 'Akun berikutnya',
    slides: [
      { company: 'Hotel Arunika', detail: 'Rp 42.900.000 dari 3 pesanan' },
      { company: 'Kopi Senja', detail: 'Rp 18.450.000 dari 5 pesanan' },
      { company: 'Warung Nusantara', detail: 'Rp 7.200.000 dari 2 pesanan' },
    ],
    position: (index, total) => `${index} dari ${total}`,
  },
  skeleton: { label: 'Memuat kontak' },
  slider: { label: 'Peluang menang' },
  breadcrumb: {
    label: 'Breadcrumb',
    items: ['Kontak', 'Kopi Senja', 'Deal'],
  },
  tabs: {
    label: 'Bagian kontak',
    items: [
      {
        id: 'overview',
        label: 'Ringkasan',
        body: 'Pesanan terakhir 3 Sep, 24 kg.',
      },
      { id: 'deals', label: 'Deal', body: '2 terbuka, 1 menang kuartal ini.' },
      {
        id: 'notes',
        label: 'Catatan',
        body: 'Lebih suka ditelepon setelah 14.00.',
      },
    ],
  },
  bottomNav: {
    label: 'Bagian',
    items: [
      { id: 'pipeline', label: 'Pipeline' },
      { id: 'contacts', label: 'Kontak' },
      { id: 'tasks', label: 'Tugas' },
    ],
  },
  sidebar: {
    label: 'Navigasi Relasi',
    collapse: 'Ciutkan sidebar',
    expand: 'Lebarkan sidebar',
    items: [
      { id: 'pipeline', label: 'Pipeline' },
      { id: 'contacts', label: 'Kontak' },
      { id: 'reports', label: 'Laporan' },
    ],
  },
  toast: {
    trigger: 'Tandai menang',
    title: 'Deal dipindah ke Menang',
    body: 'Hotel Arunika, Rp 18.450.000',
    dismiss: 'Tutup notifikasi',
  },
  dialog: {
    trigger: 'Hapus kontak',
    title: 'Hapus kontak ini?',
    body: 'Rina Wulandari dan 3 catatan akan dihapus.',
    cancel: 'Batal',
    confirm: 'Hapus',
  },
  sheet: {
    trigger: 'Lihat cepat',
    title: 'Bagas Pratama',
    phone: '+62 812 4471 0932',
    lastContact: 'Terakhir dihubungi 3 hari lalu',
    dismiss: 'Tutup',
  },
  tooltip: {
    trigger: 'Kontak terakhir',
    bubble: 'Ditelepon Dewi 3 hari lalu',
  },
  table: {
    caption: 'Deal terbuka',
    company: 'Perusahaan',
    stage: 'Tahap',
    value: 'Nilai',
    sortByValue: 'Urutkan menurut nilai',
  },
  datePicker: { label: 'Tanggal tindak lanjut', value: 'Kam, 17 Sep 2026' },
  dateRangePicker: {
    label: 'Periode laporan',
    value: '1 Sep - 15 Sep 2026',
    days: '15 hari',
  },
  timePicker: { label: 'Telepon pukul' },
};
