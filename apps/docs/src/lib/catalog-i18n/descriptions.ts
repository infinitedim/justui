/**
 * One-sentence catalog descriptions, keyed by registry slug. Each sentence
 * names what the component does and the variants or props that actually
 * exist in packages/core/lib/src/components; no marketing adjectives.
 * `test/catalog-i18n.test.ts` checks both locales cover every slug.
 */
export type ComponentDescriptions = Readonly<Record<string, string>>;

export const descriptionsEn: ComponentDescriptions = {
  accordion: 'Collapsible sections in default or contained style.',
  avatar:
    'Image or initials avatar in six sizes, with online, away, busy or offline status.',
  'avatar-group': 'Overlapping avatars that collapse extras into a +N count.',
  badge: 'Status label in solid, outline, soft or dot style, in seven colors.',
  'bottom-nav': 'Bottom tab bar in fixed, shifting or floating style.',
  breadcrumb: 'Path of links to the current page; long trails collapse.',
  button:
    'Button in primary, secondary, ghost, destructive or link variant, in five sizes.',
  card: 'Container in elevated, outlined or filled style, with optional header and footer.',
  carousel: 'Paged slides with a dots, line or fraction indicator.',
  checkbox: 'Checkbox with checked, unchecked and indeterminate states.',
  'date-picker':
    'Date field that opens a calendar inline, in a modal or as a dropdown.',
  'date-range-picker': 'Picks a start and an end date from one calendar.',
  dialog: 'Modal dialog placed at the center, top or bottom of the screen.',
  'icon-button':
    'Icon-only button with an optional tooltip, using the button variants.',
  input:
    'Text field with text, password, search, number, textarea and OTP variants.',
  progress: 'Linear or circular progress indicator.',
  radio: 'Single radio button for one option in a set.',
  'radio-group': 'Radio options laid out in a row or a column.',
  resizable: 'Panes split by a line, grip or invisible drag handle.',
  'scroll-area': 'Scrollable area with a scrollbar styled by the theme.',
  select: 'Dropdown list of options; set searchable to filter them.',
  separator: 'Horizontal or vertical divider, with an optional label.',
  sheet: 'Panel that slides in from the top, bottom, left or right.',
  sidebar: 'Side navigation with nested items that collapses to icons.',
  skeleton: 'Wraps a widget and shows shimmer placeholders while loading.',
  slider: 'Slider for one value or a range, with optional steps.',
  switch: 'On/off switch in three sizes.',
  table:
    'Data table in default, striped or minimal style, with sortable columns.',
  tabs: 'Tabs in line, enclosed, pill or vertical style.',
  'time-picker':
    'Time field with a dial, spinner or typed input, in 12 or 24 hour format.',
  toast:
    'Short message in info, success, warning or error, at six screen positions.',
  toggle: 'Button that stays pressed until tapped again, in three sizes.',
  tooltip: 'Short label shown on hover or long-press, placed automatically.',
};

export const descriptionsId: ComponentDescriptions = {
  accordion: 'Bagian yang bisa dibuka-tutup, gaya default atau contained.',
  avatar:
    'Avatar gambar atau inisial dalam enam ukuran, dengan status online, away, busy, atau offline.',
  'avatar-group': 'Avatar bertumpuk; sisanya diringkas jadi hitungan +N.',
  badge: 'Label status gaya solid, outline, soft, atau dot, dalam tujuh warna.',
  'bottom-nav': 'Bar tab bawah gaya fixed, shifting, atau floating.',
  breadcrumb: 'Jejak tautan menuju halaman saat ini; jejak panjang diringkas.',
  button:
    'Tombol varian primary, secondary, ghost, destructive, atau link, dalam lima ukuran.',
  card: 'Wadah gaya elevated, outlined, atau filled, dengan header dan footer opsional.',
  carousel: 'Slide per halaman dengan indikator titik, garis, atau pecahan.',
  checkbox: 'Checkbox dengan status tercentang, kosong, dan indeterminate.',
  'date-picker':
    'Kolom tanggal yang membuka kalender inline, di modal, atau sebagai dropdown.',
  'date-range-picker': 'Memilih tanggal mulai dan selesai dari satu kalender.',
  dialog: 'Dialog modal di tengah, atas, atau bawah layar.',
  'icon-button':
    'Tombol ikon dengan tooltip opsional, memakai varian tombol yang sama.',
  input: 'Kolom teks varian text, password, search, number, textarea, dan OTP.',
  progress: 'Indikator progres linear atau melingkar.',
  radio: 'Satu tombol radio untuk satu opsi dalam sebuah pilihan.',
  'radio-group': 'Opsi radio yang disusun dalam baris atau kolom.',
  resizable: 'Panel yang dibagi pegangan garis, grip, atau tak terlihat.',
  'scroll-area': 'Area gulir dengan scrollbar yang mengikuti tema.',
  select: 'Daftar opsi dropdown; aktifkan searchable untuk menyaringnya.',
  separator: 'Pembatas horizontal atau vertikal, dengan label opsional.',
  sheet: 'Panel yang muncul dari atas, bawah, kiri, atau kanan.',
  sidebar:
    'Navigasi samping dengan item bertingkat yang bisa diciutkan jadi ikon.',
  skeleton:
    'Membungkus widget dan menampilkan placeholder shimmer saat memuat.',
  slider: 'Slider untuk satu nilai atau rentang, dengan langkah opsional.',
  switch: 'Sakelar on/off dalam tiga ukuran.',
  table:
    'Tabel data gaya default, striped, atau minimal, dengan kolom yang bisa diurutkan.',
  tabs: 'Tab gaya line, enclosed, pill, atau vertikal.',
  'time-picker':
    'Kolom waktu dengan dial, spinner, atau ketikan, format 12 atau 24 jam.',
  toast:
    'Pesan singkat info, success, warning, atau error, di enam posisi layar.',
  toggle: 'Tombol yang tetap tertekan sampai diketuk lagi, dalam tiga ukuran.',
  tooltip:
    'Label singkat saat hover atau tekan lama, posisinya diatur otomatis.',
};
