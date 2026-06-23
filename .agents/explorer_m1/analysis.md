# Analisis Temuan Codebase JustUI

Laporan ini menyajikan analisis mendalam terhadap codebase JustUI untuk mendukung pembuatan dokumen panduan (Getting Started, Tokens, Guides) dan halaman dokumentasi komponen UI (16 komponen) berbasis MDX dalam Bahasa Indonesia.

---

## 1. Analisis Package `just_ui_tokens`

Package `just_ui_tokens` berfungsi sebagai fondasi sistem desain JustUI. Package ini hanya menyediakan konstanta kompilasi (`const`) dan utilitas bebas dependensi pihak ketiga (hanya bergantung pada `package:flutter/widgets.dart` atau `painting.dart`).

### 1.1 Daftar dan Deskripsi Visual Primitives

#### Breakpoints (`breakpoints.dart`)
Mengatur transisi tata letak responsif berdasarkan lebar layar:
- `JustBreakpoints.sm` (640.0 px): Perangkat mobile lanskap atau tablet kecil.
- `JustBreakpoints.md` (768.0 px): Tablet potret (seperti iPad).
- `JustBreakpoints.lg` (1024.0 px): Tablet lanskap atau layar monitor desktop standar.
- `JustBreakpoints.xl` (1280.0 px): Layar monitor desktop lebar.
- `JustBreakpoints.xxl` (1536.0 px): Layar monitor resolusi tinggi/lebar.

#### Spacing (`spacing.dart`)
Menggunakan sistem kisi 4px untuk margin dan padding yang konsisten. Menyediakan konstanta numerik (`JustSpacing`) dan kelas pembantu `JustGap` yang langsung mengembalikan `SizedBox`:
- `xxs` / `JustGap.xxs`: 2.0 px (jarak mikro/ikon segaris).
- `xs` / `JustGap.xs`: 4.0 px (jarak ketat/elemen pembantu).
- `sm` / `JustGap.sm`: 8.0 px (jarak dasar antar blok konten).
- `md` / `JustGap.md`: 12.0 px (padding bawaan untuk lencana/kartu kecil).
- `lg` / `JustGap.lg`: 16.0 px (padding kontainer utama/margin halaman).
- `xl` / `JustGap.xl`: 24.0 px (padding kartu besar/judul halaman).
- `xxl` / `JustGap.xxl`: 32.0 px (jarak antar seksi halaman).
- `xxxl` / `JustGap.xxxl`: 48.0 px (batas batas tata letak halaman).
- `huge` / `JustGap.huge`: 64.0 px (jarak vertikal masif/tata letak halaman hero).
- `JustSpacing.insets()`: Utilitas pembuatan `EdgeInsets` berbasis token.

#### Radius (`radius.dart`)
Mengatur kelengkungan sudut untuk batas elemen. Menyediakan konstanta kelengkungan `Radius` (`JustRadius`) dan kelas pembantu `BorderRadius` (`JustBorderRadius`):
- `none`: 0.0 px (sudut tajam).
- `xs`: 2.0 px (sudut kelengkungan ekstra kecil).
- `sm`: 4.0 px (lencana/tag).
- `md`: 8.0 px (tombol/kolom input/kotak centang).
- `lg`: 12.0 px (kartu/banner).
- `xl`: 16.0 px (dialog/lembaran bottom-sheet).
- `xxl`: 24.0 px (bottom-sheet besar/modal utama).
- `full`: 9999.0 px (pil/avatar bulat sempurna).

#### Shadows (`shadows.dart`)
Mengatur bayangan bertumpuk dua lapis (*multi-layer BoxShadow*) untuk kedalaman visual. Menyediakan bayangan bawaan untuk mode terang (`xs`, `sm`, `md`, `lg`, `xl`, `xxl`) dan mode gelap (`xsDark`, `smDark`, `mdDark`, `lgDark`, `xlDark`, `xxlDark`).
- `JustShadows.generate(...)`: Menghasilkan bayangan dinamis bertumpuk dua lapis yang disesuaikan dengan warna seed merek (membuat bayangan berpendar lembut sewarna dengan warna merek).

#### Durations & Curves (`duration.dart` & `motion.dart`)
Mengatur waktu dan kurva pelandaian animasi:
- `JustDuration.instant`: 50ms (efek tekan tombol/umpan balik instan).
- `JustDuration.fast`: 150ms (transisi layang hover/fokus).
- `JustDuration.normal`: 250ms (transisi bawaan sakelar/skala/penciutan).
- `JustDuration.slow`: 400ms (transisi perpindahan halaman).
- `JustDuration.slower`: 600ms (animasi bertahap/terorkestrasi).
- `JustDuration.scaleForDistance(pixels)`: Menghitung durasi animasi secara dinamis berdasarkan jarak perpindahan piksel.
- `JustCurves.default_`: `Curves.easeInOut` (transisi umum).
- `JustCurves.enter`: `Curves.easeOut` (transisi masuk halaman).
- `JustCurves.exit`: `Curves.easeIn` (transisi keluar halaman).
- `JustCurves.spring`: `Curves.elasticOut` (pantulan organik).
- **Profil Gerakan (`JustMotionProfile`)**:
  Menyediakan profil `standard`, `expressive` (lebih elastis), `compact` (cepat/snappy), dan `reduced` (aksesibilitas: durasi nol dan kurva linear untuk pengguna yang sensitif terhadap animasi gerakan).

#### Typography (`typography.dart` & `typography_fluid.dart`)
Skala tipografi menggunakan font bawaan **Inter** dan monospace **JetBrains Mono**:
- Display: `displayLg` (48px, w700, tinggi 1.2), `displayMd` (36px, w700, tinggi 1.2), `displaySm` (30px, w600, tinggi 1.3).
- Heading: `headingLg` (24px, w600, tinggi 1.3), `headingMd` (20px, w600, tinggi 1.4), `headingSm` (16px, w600, tinggi 1.4).
- Body: `bodyLg` (18px, w400, tinggi 1.6), `bodyMd` (16px, w400, tinggi 1.6), `bodySm` (14px, w400, tinggi 1.5).
- Support: `caption` (12px, w400, tinggi 1.4), `overline` (11px, w500, tinggi 1.5, spasi huruf 0.55).
- **Fluid Typography (`JustFluidTypography`)**:
  - `fluid()`: Mengubah ukuran teks secara dinamis berdasarkan lebar layar (interpolasi linier antara `minSize` dan `maxSize` saat layar bergerak dari `minWidth` (640) ke `maxWidth` (1024)).
  - `withAdaptiveHeight()`: Menyesuaikan spasi baris secara dinamis berdasarkan ukuran teks akhir (teks kecil $\le$ 12px mendapatkan tinggi longgar 1.6, teks besar $\ge$ 36px mendapatkan tinggi rapat 1.15).

---

### 1.2 Algoritma Audit Aksesibilitas Kontras (`colors_accessibility.dart`)

JustUI mematuhi standar aksesibilitas **WCAG 2.0** untuk perhitungan rasio kontras warna demi kenyamanan keterbacaan teks.

#### Formula Rasio Kontras
Luminansi relatif ($L$) dihitung oleh Flutter melalui fungsi internal `Color.computeLuminance()`, menghasilkan nilai antara `0.0` (hitam pekat) dan `1.0` (putih pekat).
Formula rasio kontras WCAG 2.0 adalah:
$$\text{Rasio Kontras} = \frac{L_1 + 0.05}{L_2 + 0.05}$$
Di mana:
- $L_1$ adalah luminansi relatif warna yang lebih terang ($L_1 > L_2$).
- $L_2$ adalah luminansi relatif warna yang lebih gelap.
- Konstanta `0.05` ditambahkan untuk mencegah pembagian dengan nol ketika mendeteksi hitam pekat, serta mengimbangi adaptasi mata terhadap efek pendaran cahaya (*glare*).

#### Kode Implementasi Ekstensi `JustColorAccessibility`
```dart
extension JustColorAccessibility on Color {
  double contrastRatioWith(Color other) {
    final double l1 = computeLuminance();
    final double l2 = other.computeLuminance();

    if (l1 > l2) {
      return (l1 + 0.05) / (l2 + 0.05);
    } else {
      return (l2 + 0.05) / (l1 + 0.05);
    }
  }

  bool isAccessibleWith(Color other, {bool isLargeText = false}) {
    final double ratio = contrastRatioWith(other);
    return ratio >= (isLargeText ? 3.0 : 4.5);
  }
}
```
- **Teks Normal (Kontras $\ge$ 4.5:1)**: Standar WCAG AA untuk keterbacaan teks biasa.
- **Teks Besar / Komponen Visual (Kontras $\ge$ 3.0:1)**: Standar WCAG AA khusus untuk teks berukuran $\ge$ 18pt/24px (atau teks tebal $\ge$ 14pt/18.67px) dan elemen interaktif seperti border kolom fokus atau tombol.

---

## 2. Analisis Package `just_ui_core`

Package `just_ui_core` menyediakan mesin theming dinamis, integrasi Material ThemeData, dan optimalisasi rendering widget.

### 2.1 Mekanisme Aspect-Based Rebuilds

Untuk mencegah penurunan performa rendering (rebuild widget massal) saat tema berubah, JustUI mengimplementasikan optimalisasi aspek menggunakan `InheritedModel`.

#### Aspek yang Didukung (`JustThemeAspect`)
```dart
enum JustThemeAspect {
  colors,      // Hanya mendengarkan perubahan warna
  typography,  // Hanya mendengarkan perubahan font/gaya teks
  spacing,     // Hanya mendengarkan perubahan jarak
  radius,      // Hanya mendengarkan kelengkungan sudut
  shadows,     // Hanya mendengarkan bayangan kontainer
  animations,  // Hanya mendengarkan durasi/kurva animasi
  preset,      // Mendengarkan pergantian visual preset (default ↔ neobrutalism)
}
```

#### Cara Kerja di `JustThemeProvider`
Ketika suatu widget memanggil ekstensi context tertentu, `InheritedModel.inheritFrom<_JustThemeModel>(context, aspect: aspect)` meregistrasikan ketergantungan widget tersebut secara selektif. 

Metode evaluasi rebuild dalam model internal:
```dart
@override
bool updateShouldNotifyDependent(
  _JustThemeModel oldWidget,
  Set<JustThemeAspect> dependencies,
) {
  if (dependencies.contains(JustThemeAspect.colors) &&
      themeData.colors != oldWidget.themeData.colors) {
    return true;
  }
  // (Pemeriksaan serupa diulangi untuk seluruh aspek lainnya...)
  return false;
}
```
Jika hanya nilai warna (`colors`) yang berubah (misalnya pergantian mode terang ke gelap), widget yang hanya mengakses `context.justSpacing` **tidak akan di-rebuild**, menghemat siklus komputasi Flutter secara signifikan.

---

### 2.2 Implementasi Lazy-Cached Material `ThemeData`

JustUI tidak mewajibkan user menggunakan widget Material standar, namun menyediakan jembatan integrasi melalui metode ekstensi `.toThemeData()` pada kelas `JustThemeData`. Untuk menghindari kalkulasi ulang warna dan geometri di setiap build, JustUI menerapkan teknik lazy caching berbasis **weak references** menggunakan kelas `Expando`.

```dart
final Expando<ThemeData> _themeDataCache = Expando<ThemeData>();

extension JustThemeDataMaterialExtension on JustThemeData {
  ThemeData toThemeData() {
    return _themeDataCache[this] ??= _buildMaterialTheme();
  }
}
```
- **Lazy Evaluation**: Objek `ThemeData` tidak dibangun sebelum metode `toThemeData()` pertama kali dieksekusi.
- **Expando (Weak References)**: Kelas `Expando` mengaitkan instans `ThemeData` dengan instans `JustThemeData` secara lemah. Jika objek `JustThemeData` dibebaskan oleh *garbage collector*, cached `ThemeData` akan dihapus dari memori secara otomatis, menghindari penumpukan referensi memori (*memory leak*).

---

### 2.3 Dynamic Contrast Enforcement melalui `JustThemeData.fromSeed`

Saat menginisialisasi tema kustom menggunakan warna seed via `JustThemeData.fromSeed(Color seedColor)`, sistem meluncurkan algoritma optimisasi warna di latar belakang untuk menjamin kesesuaian kontras rasio WCAG AA secara dinamis terhadap warna latar belakang kontainer (`background`).

#### Algoritma Lightness Adjustment (`colors_dynamic.dart`)
Ketika rasio kontras awal tidak memenuhi rasio target minimum (`minRatio`, contoh: 3.0:1 untuk border fokus, 4.5:1 untuk teks normal):
1. **Deteksi Arah Kecerahan**: Program mengecek apakah warna latar belakang cenderung gelap atau terang (`bgLuminance < 0.5`). Jika latar belakang gelap, warna seed harus dibuat lebih terang (`makeLighter = true`). Jika latar belakang terang, warna seed harus dibuat lebih gelap (`makeLighter = false`).
2. **Binary Search (8 Iterasi)**: Menggunakan teknik pencarian biner pada rentang Lightness HSL untuk meminimalisasi perubahan saturasi dan hue warna seed asal:
   - Jika `makeLighter` aktif: batas bawah pencarian (`low`) diatur ke lightness awal, batas atas (`high`) disetel ke `1.0` (putih).
   - Jika `makeLighter` nonaktif: batas bawah (`low`) disetel ke `0.0` (hitam), batas atas (`high`) disetel ke lightness awal.
   - Program mencari titik tengah (`mid`), mengonversinya kembali menjadi warna RGB, mengevaluasi kontrasnya terhadap latar belakang, lalu memperkecil rentang pencarian hingga mendapatkan warna baru yang memenuhi kontras minimum dengan perubahan visual sesedikit mungkin.
3. **Fallback Aman**: Jika dalam 8 iterasi biner kontras tetap tidak tercapai, sistem secara otomatis memaksa warna tersebut menjadi pure putih (`0xFFFFFFFF`) di atas background gelap, atau pure hitam (`0xFF000000`) di atas background terang.

*Catatan: Algoritma penyesuaian kontras HSL dinamis ini secara otomatis diabaikan (*bypass*) jika preset visual yang dipilih adalah `neobrutalism`, demi menjaga estetika border hitam pekat khas neobrutalism.*

---

### 2.4 Praktik Terbaik Konsumsi Tema

1. **Gunakan Ekstensi Aspek Spesifik di dalam `build()`**:
   - ✅ `context.justColors.background` (Rebuild dipicu *hanya* saat warna berganti).
   - ✅ `context.justSpacing.md` (Rebuild dipicu *hanya* saat spasi berganti).
   - ❌ `context.justTheme` (Hindari ini di widget kecil karena akan mendaftarkan listener ke *seluruh* aspek tema).
2. **Gunakan API Bebas Rebuild di dalam Callback**:
   - Di dalam handler interaksi seperti `onPressed`, `onTap`, atau fungsi pembantu siklus hidup widget, gunakan `context.readTheme()` sebagai pengganti getter aktif. Metode `read()` mengambil data tema instan tanpa mendaftarkan widget sebagai pendengar perubahan pada pohon widget, mengeliminasi build berulang yang tidak diinginkan.

---

## 3. Analisis Komponen Flutter JustUI

Setiap komponen JustUI dirancang dengan kustomisasi tingkat tinggi, bebas dependensi Material eksternal, dan dilengkapi fitur aksesibilitas terintegrasi.

### 3.1 `JustButton`
Tombol interaktif utama dengan dukungan animasi sentuh terintegrasi.
- **Properties**:
  - `label` (`String`, required): Teks tombol.
  - `onPressed` (`VoidCallback?`, required): Callback tap (jika `null`, tombol otomatis dalam keadaan nonaktif).
  - `variant` (`JustButtonVariant`, default: `.primary`): Pilihan visual: `primary`, `secondary`, `ghost`, `destructive`, `link`.
  - `size` (`JustButtonSize`, default: `.md`): Klasifikasi geometri: `xs`, `sm`, `md`, `lg`, `xl`.
  - `leading` (`Widget?`, default: `null`): Ikon atau widget sebelum teks.
  - `trailing` (`Widget?`, default: `null`): Ikon atau widget setelah teks.
  - `isLoading` (`bool`, default: `false`): Jika true, menyembunyikan konten tombol dan menampilkan `JustProgressSpinner`.
  - `isDisabled` (`bool`, default: `false`): Jika true, menonaktifkan tombol secara visual dan fungsional.
  - `isFullWidth` (`bool`, default: `false`): Tombol meregang penuh horizontal.
  - `style` (`JustButtonStyle?`, default: `null`): Override gaya instan per unit tombol.
  - `enableHaptic` (`bool?`, default: `null`): Umpan balik getaran ringan (default aktif di neobrutalism).
- **Contoh Kode**:
  ```dart
  // Basic
  JustButton(
    label: 'Kirim Data',
    onPressed: () => print('Tapped'),
  )

  // Advanced (Destructive, Loading, dengan Ikon)
  JustButton.destructive(
    label: 'Hapus Akun',
    onPressed: _handleDelete,
    size: JustButtonSize.lg,
    isLoading: _isDeleting,
    leading: const Icon(Icons.delete),
    isFullWidth: true,
  )
  ```
- **Internal Styling & Aksesibilitas**:
  - Batas ukuran target sentuh dijamin minimal 48x48px (standar aksesibilitas seluler) via `ConstrainedBox` meskipun tombol bertipe `xs`/`sm`.
  - Animasi tekan tombol: default menggunakan `AnimatedScale` (mengecil ke skala 0.97). Neobrutalism menggunakan `AnimatedContainer` berdurasi instan (50ms) untuk menggeser posisi fisik tombol (transformasi translasi sumbu X/Y) selaras dengan keruntuhan bayangan padat dibelakangnya.
  - Ring fokus visual ditampilkan menggunakan komponen pembantu internal `FocusIndicator`.

### 3.2 `JustIconButton`
Tombol ikon tanpa label teks, dioptimalkan untuk keterbacaan pembaca layar (*screen reader*).
- **Properties**:
  - `icon` (`Widget`, required): Ikon di dalam tombol.
  - `onPressed` (`VoidCallback?`, required): Callback interaktif.
  - `variant` (`JustButtonVariant`, default: `.ghost`): Pilihan visual.
  - `size` (`JustButtonSize`, default: `.md`): Ukuran.
  - `tooltip` (`String?`, required): Deskripsi semantik tombol. Wajib diisi demi aksesibilitas.
  - `isLoading` (`bool`, default: `false`).
  - `isDisabled` (`bool`, default: `false`).
  - `style` (`JustButtonStyle?`, default: `null`).
  - `enableHaptic` (`bool?`, default: `null`).
- **Contoh Kode**:
  ```dart
  JustIconButton(
    icon: const Icon(Icons.share),
    tooltip: 'Bagikan postingan ini',
    onPressed: () => _sharePost(),
  )
  ```
- **Internal Styling & Aksesibilitas**:
  - Menyertakan ketegasan asersi pengembang (`assert(tooltip != null)`) untuk memastikan tidak ada tombol tanpa deskripsi suara.
  - Mengisolasi ikon dengan `IconTheme.merge` untuk meratakan pewarnaan ikon secara otomatis mengikuti kecerahan status interaktif (hover/press/disabled).

### 3.3 `JustInput`
Kolom input teks canggih yang mendukung label melayang (*floating label*), kloning fungsionalitas FormField, dan segmentasi digit OTP.
- **Properties**:
  - `label` (`String?`, default: `null`): Judul kolom input (otomatis melayang ke atas ketika kolom aktif/terisi).
  - `hint` (`String?`, default: `null`): Teks placeholder samar.
  - `helper` (`String?`, default: `null`): Teks panduan di bawah input.
  - `errorText` (`String?`, default: `null`): Pesan kesalahan validasi (mengaktifkan status merah).
  - `successText` (`String?`, default: `null`): Pesan konfirmasi sukses (mengaktifkan status hijau).
  - `controller` (`TextEditingController?`).
  - `focusNode` (`FocusNode?`).
  - `onChanged` (`ValueChanged<String>?`).
  - `onSubmitted` (`ValueChanged<String>?`).
  - `onTap` (`VoidCallback?`).
  - `prefix` / `prefixIcon` (`Widget?` / `IconData?`): Elemen visual di kiri kolom.
  - `suffix` / `suffixIcon` (`Widget?` / `IconData?`): Elemen visual di kanan kolom.
  - `maxLength` / `maxLines` / `minLines` (`int?`): Batasan panjang karakater dan tata letak garis input.
  - `obscureText` (`bool`, default: `false`): Menyembunyikan karakter input (seperti kata sandi).
  - `enabled` / `readOnly` / `autofocus` (`bool`).
  - `keyboardType` / `textInputAction` / `inputFormatters`.
  - `size` (`JustInputSize`, default: `.md`): Pilihan ukuran `sm`, `md`, `lg`.
  - `style` (`JustInputStyle?`).
  - `showClearButton` (`bool`, default: `false`): Menampilkan tombol hapus instan silang di kanan input ketika teks terisi.
- **Contoh Kode**:
  ```dart
  // Kata Sandi dengan Validator
  JustFormInput(
    label: 'Kata Sandi',
    hint: 'Masukkan minimal 8 karakter',
    variant: JustInputVariant.password,
    controller: _passwordController,
    validator: (val) => (val != null && val.length < 8) ? 'Terlalu pendek' : null,
  );

  // Segmentasi Kode OTP
  JustInput.otp(
    length: 6,
    onChanged: (otpCode) => print('Kode OTP: $otpCode'),
  );
  ```
- **Internal Styling & Aksesibilitas**:
  - Mengimplementasikan `EditableText` mentah bawaan Flutter secara langsung tanpa dibungkus `TextField` Material untuk menekan overhead rendering dan menjaga kemurnian sistem desain.
  - `JustInput.otp` secara cerdas mengelola pergeseran fokus otomatis dari kiri ke kanan saat digit terisi, dan mendistribusikan deret angka ketika mendeteksi aksi tempel teks (*paste code*) menggunakan pendengar keyboard `KeyboardListener` terintegrasi.
  - Mengirimkan instruksi vokal kesalahan aksesibilitas secara langsung kepada sistem operasi melalui pemanggilan utilitas `SemanticsService.announce()` saat `errorText` terdeteksi non-null.

### 3.4 `JustBadge`
Lencana visual mini untuk menandai status kategori atau pemberitahuan angka.
- **Properties**:
  - `label` (`String?`, default: `null`): Teks lencana. Jika diisi null, otomatis dirender menjadi lingkaran titik pemberitahuan kosong (*notification dot*).
  - `color` (`JustBadgeColor`, default: `.primary`): Skema status: `primary`, `secondary`, `success`, `warning`, `error`, `info`, `neutral`.
  - `variant` (`JustBadgeVariant`, default: `.solid`): Tipe gaya: `solid` (warna penuh), `soft` (warna redup transparan), `outline` (tanpa warna latar, dengan garis luar), `dot` (titik indikator).
  - `size` (`JustBadgeSize`, default: `.md`): Ukuran `sm`, `md`, `lg`.
  - `leading` (`Widget?`): Ikon di depan label.
  - `onDismiss` (`VoidCallback?`): Jika diisi, merender tanda silang di ujung kanan lencana untuk memicu aksi penghapusan.
  - `maxWidth` (`double?`): Lebar batas maksimal lencana (teks otomatis terpangkas dengan elipsis jika melebihi batas).
  - `pulse` (`bool`, default: `false`): Mengaktifkan animasi pendaran lingkaran membesar (*pulsing halo*) pada tipe dot menggunakan delegasi gambar performa tinggi `FlowDelegate`.
- **Contoh Kode**:
  ```dart
  // Lencana Status Soft
  JustBadge(
    label: 'Aktif',
    color: JustBadgeColor.success,
    variant: JustBadgeVariant.soft,
    leading: const Icon(Icons.check),
  )

  // Penumpukan Indikator Pemberitahuan
  JustBadge.overlay(
    child: const Icon(Icons.notifications),
    badge: const JustBadge.dot(color: JustBadgeColor.error, pulse: true),
  )
  ```

### 3.5 `JustAvatar` & `JustAvatarGroup`
Komponen foto profil lingkaran yang toleran terhadap kegagalan unduhan gambar.
- **Properties (`JustAvatar`)**:
  - `imageUrl` (`String?`): URL gambar profil pengguna.
  - `name` (`String?`): Nama pengguna (menghasilkan inisial otomatis dan menetapkan warna background acak terprediksi).
  - `icon` (`IconData?`): Ikon alternatif.
  - `size` (`JustAvatarSize`, default: `.md`): Geometri lingkaran (`xs` 24px hingga `xxl` 96px).
  - `shape` (`JustAvatarShape`, default: `.circle`): Bentuk avatar bulat (`circle`) atau melingkar bersudut (`square` bersudut `radius.xl`).
  - `statusDot` (`JustAvatarStatus?`): Titik indikator aktivitas (`online`, `offline`, `away`, `busy`).
  - `onTap` (`VoidCallback?`): Aksi ketuk.
- **Properties (`JustAvatarGroup`)**:
  - `avatars` (`List<JustAvatar>`, required): Daftar avatar yang digabungkan.
  - `maxDisplay` (`int`, default: `3`): Batas jumlah avatar yang tampil sebelum digantikan lencana sisa `+X`.
  - `overlap` (`double`, default: `8.0`): Jarak tumpang-tindih horizontal antar avatar.
- **Contoh Kode**:
  ```dart
  JustAvatarGroup(
    avatars: [
      JustAvatar(imageUrl: 'https://avatar1.png', name: 'Budi Santoso'),
      JustAvatar(name: 'Ahmad Faiz'),
      JustAvatar(icon: Icons.person_outline, name: 'Guest User'),
    ],
    maxDisplay: 2,
    size: JustAvatarSize.lg,
  )
  ```
- **Detail Desain & Keamanan**:
  - Warna latar belakang inisial dihitung secara deterministik: indeks warna = `name.hashCode.abs() % colors.length`. Menjamin pengguna dengan nama sama akan selalu mendapatkan warna latar belakang yang konsisten.
  - Jika URL gambar gagal dimuat atau sedang mengunduh, sistem beralih menampilkan teks inisial huruf besar awal nama (`_generateInitials`). Jika nama juga kosong, avatar menggambar sketsa profil tubuh dan kepala sendiri menggunakan kanvas lukis Flutter `PersonFallbackPainter` agar bebas dari ketergantungan paket ikon luar.
  - Anggota `JustAvatarGroup` dirender tumpuk-terbalik di dalam Stack (indeks akhir dirender di bawah indeks awal) sehingga avatar pengguna pertama selalu tampil di lapisan teratas secara utuh dengan aksen batas luar berwarna putih melingkar pemotong bayangan (*visual cutout*).

### 3.6 `JustCheckbox`
Indikator pilihan ganda bertema sistem desain dengan integrasi status campuran (*indeterminate*).
- **Properties**:
  - `value` (`bool?`, required): Status centang: `true` (aktif), `false` (mati), `null` (status gabungan/campuran).
  - `onChanged` (`ValueChanged<bool?>?`, required): Pemicu toggle status.
  - `label` (`Widget?`): Label teks pendamping.
  - `size` (`JustCheckboxSize`, default: `.md`): Skala ukuran `sm` (16px), `md` (20px), `lg` (24px).
  - `isDisabled` (`bool`, default: `false`).
  - `style` (`JustCheckboxStyle?`).
  - `focusNode` (`FocusNode?`).
- **Contoh Kode**:
  ```dart
  JustCheckbox(
    value: _isChecked,
    label: const Text('Saya menyetujui Ketentuan Layanan'),
    onChanged: (val) => setState(() => _isChecked = val),
  )
  ```
- **Internal Styling & Animasi**:
  - Gambar centang aktif (`_CheckmarkPainter`) dan bar horizontal campuran (`_IndeterminatePainter`) ditarik manual pada koordinat piksel kanvas dinamis yang dipicu perubahan nilai `AnimationController` untuk menghasilkan efek coretan menulis tangan yang mulus.
  - Tombol spasi (`Space`) dan Enter didaftarkan secara manual pada *key event handler* internal untuk memungkinkan fungsionalitas pencentangan bagi pengguna disabilitas yang menjelajah antarmuka hanya menggunakan keyboard.

### 3.7 `JustRadio` & `JustRadioGroup`
Komponen seleksi eksklusif satu opsi dalam sebuah grup pilihan.
- **Properties (`JustRadio`)**:
  - `value` (`T`, required): Nilai unik per radio.
  - `groupValue` (`T?`, required): Nilai aktif yang terpilih saat ini.
  - `onChanged` (`ValueChanged<T>?`, required): Callback pemilihan.
  - `label` (`Widget?`): Deskripsi di samping lingkaran.
- **Properties (`JustRadioGroup`)**:
  - `options` (`List<JustRadioOption<T>>`, required): Kontainer opsi yang tersedia.
  - `direction` (`Axis`, default: `.vertical`): Arah susunan opsi.
  - `spacing` (`double?`): Lebar spasi pemisah antar opsi.
- **Contoh Kode**:
  ```dart
  JustRadioGroup<String>(
    value: _selectedGender,
    options: const [
      JustRadioOption(value: 'L', label: Text('Laki-laki')),
      JustRadioOption(value: 'P', label: Text('Perempuan')),
    ],
    direction: Axis.horizontal,
    onChanged: (val) => setState(() => _selectedGender = val),
  )
  ```
- **Internal Gambar & Navigasi**:
  - Lingkaran titik tengah (`_RadioDotPainter`) membesar secara radial keluar dari pusat lingkaran selama animasi perubahan status.
  - Dilengkapi fitur keyboard traversal bawaan yang kompatibel dengan tombol navigasi standar.

### 3.8 `JustSwitch`
Sakelar biner interaktif dengan dukungan gerakan geser (*gesture drag*) yang responsif.
- **Properties**:
  - `value` (`bool`, required): Status aktif sakelar (true = ON, false = OFF).
  - `onChanged` (`ValueChanged<bool>?`, required): Callback.
  - `label` (`Widget?`).
  - `size` (`JustSwitchSize`, default: `.md`).
  - `thumbIcon` (`Widget? Function(bool value)?`): Kustomisasi ikon atau widget internal di dalam lingkaran thumb.
  - `activeColor` (`Color?`): Warna track saat ON.
- **Contoh Kode**:
  ```dart
  JustSwitch(
    value: _isNotificationEnabled,
    label: const Text('Izinkan Notifikasi'),
    thumbIcon: (val) => Icon(val ? Icons.check : Icons.close, size: 10),
    onChanged: (val) => setState(() => _isNotificationEnabled = val),
  )
  ```
- **Gestur & Kompensasi Neobrutalism**:
  - Membaca koordinat drag horizontal (`onHorizontalDragUpdate`) untuk melacak pergeseran jempol pengguna di atas track secara langsung. Jika gerakan dilepas (`onHorizontalDragEnd`) melewati batas 50% jarak lintasan, status sakelar otomatis berpindah ke nilai target yang baru secara elastis.
  - **Akurasi Dimensi Neobrutalism**: Sesuai dengan aturan `AGENTS.md`, kelonggaran thumb dihitung ulang secara ketat dengan mengurangi lebar fisik thumb sebesar `2 * tebal_border` agar thumb neobrutalism tidak pernah bergeser keluar dari area track yang memiliki garis tepi tebal dan datar.

### 3.9 `JustCard`
Kontainer berstruktur premium yang mendukung pemisahan header, badan, dan kaki kartu.
- **Properties**:
  - `child` (`Widget`, required): Konten inti kartu.
  - `variant` (`JustCardVariant`, default: `.elevated`): Pilihan tema: `elevated` (bayangan soft), `outlined` (border default), `filled` (background datar solid).
  - `header` / `footer` (`Widget?`): Komposisi area atas/bawah yang dipisahkan garis pembatas halus.
  - `onTap` (`VoidCallback?`): Jika disediakan, mengubah kartu menjadi tombol interaktif yang sensitif terhadap status hover/press.
- **Contoh Kode**:
  ```dart
  JustCard(
    variant: JustCardVariant.outlined,
    header: const JustCardTitle(child: Text('Laporan Analisis')),
    footer: JustButton(label: 'Unduh PDF', onPressed: () {}),
    child: const Text('Semua visual primitives dalam tokens telah berhasil diaudit.'),
  )
  ```
- **Konstruksi Semantik**:
  Menyediakan sub-widget semantik pendukung: `JustCardHeader`, `JustCardTitle`, `JustCardDescription`, `JustCardContent`, dan `JustCardFooter` untuk mempermudah penyusunan tata letak layout yang seimbang tanpa menulis kode padding manual.

### 3.10 `JustSeparator`
Garis pembatas tata letak responsif yang mendukung penyisipan label teks di bagian tengah.
- **Properties**:
  - `direction` (`Axis?`, default: `.horizontal`): Arah garis pembatas. Jika disetel `null`, separator bertindak responsif.
  - `breakpoint` (`double`, default: `640.0`): Batas lebar layar pembalik orientasi dari horizontal ke vertikal secara otomatis (jika responsif).
  - `thickness` (`double`, default: `1.0`): Ketebalan garis.
  - `color` (`Color?`): Warna garis.
  - `indent` / `endIndent` (`double`, default: `0.0`): Spasi kosong pemotong garis di bagian pangkal dan ujung.
  - `label` (`String?`): Label teks penengah garis pembatas (misalnya teks "ATAU" pada formulir login).
  - `labelStyle` (`TextStyle?`).
- **Contoh Kode**:
  ```dart
  JustSeparator(
    label: 'ATAU',
    thickness: 1.5,
    indent: 16.0,
    endIndent: 16.0,
  )
  ```

### 3.11 `JustScrollArea`
Kontainer gulir mandiri dengan bilah geser kustom, tepi transparan, dan pemicu muat data tanpa batas (*infinite scroll*).
- **Properties**:
  - `child` (`Widget`, required).
  - `direction` (`Axis`, default: `.vertical`).
  - `showScrollbar` (`bool`, default: `true`): Rander scrollbar kustom JustUI.
  - `fadeEdges` (`bool`, default: `false`): Efek tepi memudar transparan di batas atas dan bawah gulungan.
  - `fadeMode` (`JustScrollFadeMode`, default: `.overlay`): Metode efek transparan: `.overlay` (menaruh container bergradasi warna latar di atas viewport) atau `.shaderMask` (melakukan masking piksel alpha asli pada widget anak menggunakan `ShaderMask`).
  - `scrollToTopButton` (`bool`, default: `false`): Tampilkan tombol melayang kembali ke posisi awal.
  - `scrollToTopThreshold` (`double`, default: `400.0`): Jarak gulir minimum untuk memunculkan tombol kembali ke atas.
  - `onReachBottom` (`VoidCallback?`): Trigger callback muat data ketika sisa tinggi gulungan mendekati batas bawah (`reachBottomThreshold`).
  - `keyboardScrollStep` (`double`, default: `50.0`): Jarak tempuh piksel per ketukan tombol panah keyboard.
- **Contoh Kode**:
  ```dart
  JustScrollArea(
    fadeEdges: true,
    fadeMode: JustScrollFadeMode.shaderMask,
    scrollToTopButton: true,
    onReachBottom: () => _loadMoreData(),
    child: Column(children: _itemsList),
  )
  ```
- **Integrasi Keyboard & ShaderMask**:
  - Mengikat `FocusNode` untuk menangkap interaksi keyboard desktop: memetakan tombol `PageDown` dan `PageUp` untuk menggulir halaman sejauh ukuran tinggi viewport aktif, serta tombol panah atas/bawah untuk gulir halus.
  - Masking gradien `ShaderMask` dihitung secara dinamis menggunakan linear gradien multi-stop untuk mencegah teks atau gambar terpotong kasar di ujung batas layar.

### 3.12 `JustBreadcrumb`
Navigasi jejak hierarki halaman yang mendukung penciutan otomatis dan menu dropdown bertumpuk.
- **Properties**:
  - `items` (`List<JustBreadcrumbItem>`, required): Rangkaian link halaman hierarki.
  - `separator` (`Widget?`): Pembatas sela item (default: teks `/`).
  - `maxItems` (`int?`): Batas jumlah item yang dirender. Jika total item melampaui batas ini, item tengah otomatis dikompresi menjadi tombol tiga titik (`...`).
  - `collapsed` (`Widget?`): Kustomisasi indikator ciut.
- **Contoh Kode**:
  ```dart
  JustBreadcrumb(
    items: [
      JustBreadcrumbItem(label: 'Home', onTap: () => _goHome(), icon: const Icon(Icons.home)),
      JustBreadcrumbItem(label: 'Kategori', onTap: () => _goCategory()),
      JustBreadcrumbItem(label: 'Elektronik', onTap: () => _goElectronics()),
      JustBreadcrumbItem(label: 'Detail Produk'), // Item aktif (onTap null)
    ],
    maxItems: 3,
  )
  ```
- **Dropdown Overlay**:
  Ketika tombol ciut tiga titik (`...`) diketuk, sistem memunculkan menu mengambang berisi seluruh daftar halaman tersembunyi menggunakan `OverlayPortal`. Lokasi portal diproyeksikan secara presisi mengikuti koordinat global tombol pengetuk melalui konversi matriks transformasi.

### 3.13 `JustTabs`
Pengatur tab konten navigasi dengan indikator geser presisi dan pemuatan malas (*lazy loading*).
- **Properties**:
  - `tabs` (`List<JustTab>`, required): Pasangan judul tab, ikon, dan widget konten.
  - `variant` (`JustTabVariant`, default: `.line`): Jenis visual: `line` (garis bawah aktif), `enclosed` (kontainer kartu bersudut), `pill` (pil solid transparan), `vertical` (panel tab di kiri halaman).
  - `controller` (`JustTabController?`): Pengontrol eksternal penyelarasan tab.
  - `isScrollable` (`bool`, default: `false`): Judul tab dapat digeser horizontal (jika muatan teks sangat panjang).
- **Contoh Kode**:
  ```dart
  JustTabs.pill(
    tabs: [
      JustTab(label: 'Profil', icon: const Icon(Icons.person), content: ProfilePage()),
      JustTab(label: 'Keamanan', content: SecurityPage(), badge: const JustBadge.dot()),
      JustTab(label: 'Riwayat', content: HistoryPage(), enabled: false), // Disabled
    ],
  )
  ```
- **Optimasi Tab & Lazy Loading**:
  - **Pemuatan Malas & Caching**: Mengingat isi halaman tab seringkali berat, tab JustUI menggunakan `Set<int> _visitedIndices`. Konten tab yang belum pernah dikunjungi oleh user sama sekali tidak akan diinisialisasi dalam widget tree (mengembalikan `SizedBox.shrink()`). Saat user pertama kali membuka tab tersebut, ia baru dimuat dan disimpan di memori (`AutomaticKeepAliveClientMixin`) sehingga perpindahan tab berikutnya berjalan instan tanpa memicu pembuatan ulang status halaman (*no loss of state*).
  - **Perhitungan Geometri Indikator**: Posisi garis indikator aktif dihitung secara dinamis menggunakan kunci global (`GlobalKey`). Rentang pergeseran indikator diinterpolasi secara linear berdasarkan data margin global target untuk menciptakan efek transisi meluncur yang mulus.

### 3.14 `JustBottomNav`
Bilah navigasi bawah dengan pilihan tata letak tetap, dinamis berpindah, dan mengambang kustom.
- **Properties**:
  - `items` (`List<JustBottomNavItem>`, required): Daftar destinasi utama (diwajibkan berisi minimal 3 dan maksimal 5 item).
  - `selectedIndex` (`int`, default: `0`): Indeks aktif.
  - `onItemSelected` (`ValueChanged<int>?`): Callback perpindahan.
  - `variant` (`JustBottomNavVariant`, default: `.fixed`): Pilihan gaya `fixed`, `shifting` (hanya tab terpilih yang menampilkan label teks, dengan peningkatan area lebar tab secara dinamis), `floating` (mengambang bebas berbayangan lembut di atas layar).
  - `showLabels` (`bool`, default: `true`).
- **Contoh Kode**:
  ```dart
  JustBottomNav(
    selectedIndex: _currentIndex,
    variant: JustBottomNavVariant.floating,
    items: const [
      JustBottomNavItem(label: 'Beranda', icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home)),
      JustBottomNavItem(label: 'Pencarian', icon: Icon(Icons.search)),
      JustBottomNavItem(label: 'Pengaturan', icon: Icon(Icons.settings)),
    ],
    onItemSelected: (idx) => setState(() => _currentIndex = idx),
  )
  ```

### 3.15 `JustSidebar`
Panel laci navigasi samping responsif untuk sistem aplikasi berskala besar atau dashboard.
- **Properties**:
  - `items` (`List<JustSidebarItem>`, required): Daftar item navigasi utama yang dapat bercabang secara bertingkat (*recursive folders*).
  - `header` / `footer` (`Widget?`): Komposisi atas/bawah sidebar.
  - `width` / `collapsedWidth` (`double`, default: `260.0` / `68.0`): Lebar panel saat terbuka/ciut.
  - `isCollapsed` (`bool`, default: `false`): Status kempis aktif.
  - `variant` (`JustSidebarVariant`, default: `.default_`): Gaya penempatan: `default_`, `floating` (kartu mengambang bersisi), `inset` (laci terisolasi di dalam bingkai).
- **Contoh Kode**:
  ```dart
  JustSidebar(
    isCollapsed: _isCollapsed,
    header: const Image(image: AssetImage('logo.png')),
    selectedIndex: _activeIndex,
    items: [
      const JustSidebarItem(label: 'Dashboard', icon: Icon(Icons.dashboard)),
      JustSidebarItem(
        label: 'Manajemen Pengguna',
        icon: const Icon(Icons.people),
        children: [
          JustSidebarItem(label: 'Daftar Klien', icon: const Icon(Icons.list), onTap: () => _showClients()),
          JustSidebarItem(label: 'Hak Akses', icon: const Icon(Icons.security), onTap: () => _showRoles()),
        ],
      ),
    ],
    onItemSelected: (idx) => setState(() => _activeIndex = idx),
  )
  ```
- **Kondisi Khusus & Aksesibilitas**:
  - **Auto-Collapse Responsif**: Jika lebar layar perangkat terpantau $\le$ `JustBreakpoints.md` (768px), sidebar secara otomatis menciutkan diri menjadi lebar minimal 68px tanpa memedulikan status `isCollapsed` dari pengembang.
  - **Dukungan Tooltip & Folder**: Jika laci navigasi ciut, nama item yang tersembunyi ditampilkan kembali sebagai balon petunjuk layang (`JustTooltipOverlay`) saat cursor menyentuh ikon. Folder anak bercabang ditata secara rekursif dengan penambahan margin spasi `depth * 16.0 px` di setiap tingkatan folder dengan animasi pelipatan vertikal menggunakan `SizeTransition`.

### 3.16 `JustSkeleton`
Pemuat kerangka struktural otomatis (*structure-aware skeleton loader*) untuk merepresentasikan status loading aplikasi secara natural.
- **Properties**:
  - `child` (`Widget`, required): Struktur pohon widget asli aplikasi.
  - `loading` (`bool`, required): Status aktif pemuatan skeleton.
  - `style` (`JustSkeletonStyle?`): Kustomisasi warna dasar dan pendaran shimmer.
- **Contoh Kode**:
  ```dart
  // Pemuat Struktural Otomatis
  JustSkeleton(
    loading: _isLoading,
    child: CardProfileWidget(data: _profileData),
  )

  // Tempat Penampung Manual
  JustSkeleton.circle(size: 40.0)
  ```
- **Mekanisme Shimmer & Pelarian Khusus (Escape Hatches)**:
  - **Pelarian `JustSkeletonIgnore`**: Memungkinkan sub-widget di dalam pohon widget tetap interaktif dan terlihat normal (misalnya tombol back atau header statis) meskipun dibungkus skeleton global.
  - **Pelarian `JustSkeletonAtomic`**: Memaksa sub-tree yang kompleks untuk melebur menjadi satu blok kotak abu-abu tunggal (misalnya menyederhanakan sekumpulan ikon rating rumit menjadi satu persegi panjang).
  - **Sinkronisasi Gelombang Shimmer Seluruh Layar**: Untuk mencegah arah pendaran shimmer antar widget bergerak berantakan, JustUI meluncurkan satu pengontrol `_JustSkeletonScope` di tingkat teratas. Koordinat posisi absolut widget di atas layar diperoleh menggunakan `RenderBox.localToGlobal(Offset.zero).dx`. Gradien linier diterjemahkan secara khusus berdasarkan letak relatif masing-masing elemen terhadap sumbu global layar, menghasilkan efek gelombang kilauan cahaya (*shimmer wave*) yang selaras meluncur dari kiri ke kanan melintasi seluruh area aplikasi secara harmonis.
  - **Mode Neobrutalism**: Di bawah preset neobrutalism, gelombang kilauan gradien ditiadakan sama sekali dan digantikan oleh animasi denyut transparansi (*opacity pulsing*) warna latar belakang padat abu-abu antara `0.3` dan `0.6` secara linear.

---

## 4. Analisis Package `just_ui_cli`

Package `just_ui_cli` adalah alat bantu baris perintah (*command-line interface*) untuk mendukung copy-paste kode sumber komponen ke proyek pengguna secara lokal.

### 4.1 Struktur File & Cara Kerja Copy-Paste Scaffolding

#### Struktur Folder Proyek CLI
```
packages/just_ui_cli/
├── bin/
│   └── just_ui_cli.dart         # Entry point eksekusi baris perintah
├── lib/
│   ├── just_ui_cli.dart         # Ekspor modul CLI utama
│   └── src/
│       ├── commands/            # Direktori implementasi perintah CLI
│       ├── config/              # Modul parser konfigurasi justui.config.yaml
│       ├── registry/            # Klien pengunduh indeks dan kode sumber dari repositori
│       └── utils/               # Modul pembanding berkas, pembaca pubspec, & pemformat teks
```

#### Cara Kerja Scaffolding
1. **Pemeriksaan Pubspec**: Sistem memastikan perintah dipanggil dari folder root proyek Flutter yang memiliki berkas `pubspec.yaml`.
2. **Koneksi Registry**: Membaca berkas `justui.config.yaml` untuk mengunduh daftar indeks komponen resmi (`index.json`) dari repositori GitHub utama (atau server kustom jika dikonfigurasi).
3. **Penyalinan & Verifikasi Keamanan**: Mengunduh berkas komponen secara individual. CLI melakukan verifikasi integritas berkas menggunakan kode hash **SHA-256** untuk menjamin kode sumber yang diunduh tidak rusak atau disabotase di tengah jalan.
4. **Import Rewriting**:
   Agar file yang disalin langsung berfungsi tanpa error jalur berkas (*broken paths*), kelas `ImportRewriter` secara otomatis mendeteksi jalur impor dalam file, lalu:
   - Mengalihkan referensi file bertema core (seperti `theme_provider.dart` atau `theme_data.dart`) menjadi paket global `package:just_ui_core/just_ui_core.dart`.
   - Mengubah referensi antar komponen lokal menjadi penulisan jalur relatif dinamis sesuai lokasi direktori target yang dikonfigurasi pengguna (`components_dir` dan `tokens_dir`).
5. **Injeksi Metadata Kontrol**: Menuliskan baris komentar pelacak di bagian paling atas setiap file:
   ```dart
   // justui-meta: registry=<sha_original_remote> local=<sha_local_rewritten>
   ```
6. **Resolusi Konflik**: Jika file yang diunduh sudah ada di proyek lokal dan telah dimodifikasi oleh user, CLI mendeteksi perbedaan hash, mengidentifikasi konflik, memunculkan prompt aksi untuk memilih apakah berkas harus ditimpa (*overwrite*), dilewati (*skip*), atau menampilkan perbedaan garis berkas (*show diff*).
7. **Injeksi Pub dependencies**: Secara otomatis mendaftarkan dependensi pihak ketiga pub.dev yang dibutuhkan komponen (jika ada) ke dalam `pubspec.yaml` target menggunakan pustaka pembuat YAML `PubspecEditor`.

---

### 4.2 Daftar Perintah CLI beserta Parameter dan Kegunaannya

*Catatan Investigasi Penting: Berdasarkan audit kode sumber riil pada direktori `lib/src/commands/`, perintah `remove` dan `doctor` yang ditanyakan **tidak ditemukan / belum diimplementasikan** di dalam sistem CLI saat ini. Namun, sistem menyediakan perintah `list` dan `create` yang krusial untuk melengkapi fungsionalitas scaffolding.*

#### 1. Perintah `init`
Menginisialisasi konfigurasi dasar JustUI di dalam proyek Flutter.
- **Parameter/Opsi**:
  - `--preset`: Menentukan gaya desain visual awal yang akan digunakan. Pilihan yang didukung: `default` atau `neobrutalism` (default: `default`).
- **Kegunaan**:
  - Memverifikasi keberadaan proyek Flutter.
  - Meminta input interaktif dari pengguna untuk menentukan direktori komponen (default: `lib/ui`), direktori token (default: `lib/tokens`), serta kode warna seed merek (HEX).
  - Menghasilkan berkas konfigurasi `justui.config.yaml` dan berkas inisialisasi tema `lib/theme/just_theme.dart`.

#### 2. Perintah `add`
Mengunduh komponen dan menyalin kode sumbernya langsung ke dalam folder proyek lokal.
- **Parameter/Argumen**:
  - `[component_names]`: Daftar nama komponen yang ingin dipasang (dapat dipisahkan dengan spasi, contoh: `justui add button input`). Jika nama komponen dilewatkan kosong, CLI memunculkan antarmuka daftar centang interaktif (*multi-select prompt*) agar pengguna dapat memilih komponen secara visual.
- **Kegunaan**:
  - Menyalin file komponen terpilih secara rekursif termasuk mengunduh komponen dependensinya (*registry dependencies*).
  - Melakukan import rewriting, pemeriksaan keamanan SHA-256, dan menambahkan dependensi eksternal di `pubspec.yaml`.

#### 3. Perintah `list`
Menampilkan seluruh daftar komponen yang tersedia di server registry.
- **Kegunaan**:
  - Menghubungi server registry untuk membaca isi berkas indeks.
  - Mengelompokkan komponen berdasarkan kategorinya secara rapi, lengkap dengan informasi versi rilis dan deskripsi singkat kegunaannya.

#### 4. Perintah `diff`
Membandingkan perbedaan kode sumber komponen lokal dengan versi resmi yang ada di server registry.
- **Parameter/Argumen**:
  - `[component_name]` (Required): Nama komponen spesifik yang ingin dibandingkan.
  - `--verbose` / `-v` (Flag): Menampilkan perbandingan baris per baris kode yang ditambahkan atau dikurangi secara mendetail di terminal (menggunakan pewarnaan terminal merah/hijau).
- **Kegunaan**:
  - Membandingkan hash internal file lokal untuk mendeteksi apakah file tersebut dalam kondisi mutakhir, dimodifikasi oleh user, memiliki pembaruan baru dari pusat, atau mengalami status konflik.
  - Membuka menu interaktif untuk mengaplikasikan pembaruan registry secara massal (`Apply all`), memilih file tertentu saja (`Select changes`), atau menampilkan perbedaan penuh (`View full diff`).

#### 5. Perintah `update`
Memindai seluruh komponen yang terpasang di proyek lokal dan memperbarui komponen yang usang ke versi terbaru.
- **Kegunaan**:
  - Memindai folder `components_dir` secara lokal untuk mendata komponen apa saja yang sudah terpasang.
  - Membandingkan meta-hash setiap file terpasang dengan versi registry terbaru untuk menyaring komponen yang usang (*outdated*).
  - Menampilkan daftar komponen yang usang dan meminta konfirmasi pengguna untuk melakukan penarikan pembaruan secara otomatis.

#### 6. Perintah `create`
Membuat templat struktur 4 berkas komponen kustom lokal baru yang mematuhi pedoman sistem desain JustUI.
- **Parameter/Argumen**:
  - `[custom_component_name]`: Nama komponen kustom baru yang ingin dibuat (otomatis dikonversi menjadi format Snake Case untuk berkas dan Pascal Case untuk nama Class).
- **Kegunaan**:
  - Menghasilkan bundel struktur berkas standar di folder komponen proyek pengguna:
    1. `<component_name>.dart`: Widget utama yang sudah terhubung dengan extension context pembaca aspek tema (`justColors`, `justSpacing`, `justRadius`).
    2. `<component_name>_style.dart`: Parameter kustomisasi visual individual.
    3. `<component_name>_variants.dart`: Definisienum varian visual dan ukuran.
    4. `<component_name>_theme.dart`: Pendaftaran jembatan kelas ke sistem `ThemeExtension` milik Flutter.
