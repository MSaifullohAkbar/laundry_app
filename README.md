<div align="center">

# 🧺 LaundryKu Kasir

**Aplikasi Point of Sale (POS) Modern untuk Bisnis Laundry**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Material Design 3](https://img.shields.io/badge/Material%20Design-3-757575?style=for-the-badge&logo=material-design&logoColor=white)](https://m3.material.io)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

*Kelola transaksi, pelanggan, layanan, dan laporan bisnis laundry Anda dalam satu aplikasi yang elegan.*

</div>

---

## 📱 Tentang Aplikasi

**LaundryKu Kasir** adalah aplikasi mobile POS (Point of Sale) yang dirancang khusus untuk bisnis laundry. Dibangun dengan Flutter dan mengikuti prinsip **Material Design 3 (Material You)**, aplikasi ini memberikan pengalaman kasir yang modern, cepat, dan intuitif.

### ✨ Desain Sistem
- 🎨 **Color Scheme**: Biru Azure (Material Design 3 Custom ColorScheme)
- 🔤 **Typography**: Plus Jakarta Sans (Google Fonts)
- 🌟 **Visual**: Glassmorphism, Gradient, Micro-animations
- 📐 **Border Radius**: Pill, Card (16dp), Large Card (32dp)

---

## 🚀 Fitur Utama

### 🏠 Dashboard
- Ringkasan pendapatan hari ini dengan badge pertumbuhan
- Informasi toko (nama cabang & jam operasional)
- Grid statistik: Masuk, Harus Selesai, Terlambat
- Menu utama 6 item dengan ikon berwarna
- **FAB besar** "TRANSAKSI BARU" dengan efek gradien dan _glow shadow_
- Bottom navigation bar 4 tab

### 💰 Transaksi Baru
- Pilih pelanggan dengan search realtime
- Tambah layanan dengan stepper quantity (− / n / +)
- Preview cart dengan subtotal per item
- Tombol Checkout (aktif hanya jika data lengkap)
- Otomatis buat nomor invoice (INV-YYYYMMDD-XXX)

### 👥 Manajemen Pelanggan
- **Daftar Pelanggan** — Search realtime, badge VIP 🟠, ikon bintang
- **Tambah Pelanggan** — Form lengkap: nama, telepon, email, toggle gender animasi, alamat
- Penanda VIP dengan warna `tertiaryContainer`
- Avatar inisial otomatis dari nama pelanggan

### 🧼 Manajemen Layanan
- Tampilan **Grid 2 kolom** per kategori
- **Kategori Kiloan Reguler**: Cuci Komplit, Express, Cuci Saja, Setrika
- **Kategori Satuan Premium**: Jas, Gaun, Sepatu, Selimut — badge "Premium"
- **Tambah Layanan**: Toggle proses (Cuci/Kering/Setrika) animasi pill
- Form jenis layanan dengan empty state ilustrasi

### 📊 Laporan
- **Menu Laporan** — Grid 6 item: Transaksi, Pengeluaran, Pelanggan, Export Excel, Kasir, Metode Bayar
- **Laporan Transaksi** — Filter periode (Hari Ini/Minggu/Bulan), KPI Bento Grid, Bar Chart (`fl_chart`), daftar transaksi terbaru
- **Riwayat Transaksi** — Filter chip horizontal: Semua, Selesai, Proses, Antrian, Terlambat, Batal

### 🌸 Kelola Parfum
- Grid 2 kolom kartu parfum
- Indikator stok: **Penuh** (hijau) / **Hampir Habis** (merah) / **Habis** (abu, opasitas 75%)
- Search nama parfum realtime
- FAB tambah parfum baru

### ⚙️ Pengaturan Toko
- Hero section gradien dengan dekorasi lingkaran blur
- Card form overlap (efek -mt overlap dari hero)
- Upload logo toko (avatar besar 112px)
- Input: Nama Toko, Alamat, Catatan Struk, Pesan Bawah Struk
- Tombol "Simpan Perubahan" dengan gradient dan shadow

---

## 🗂️ Struktur Proyek

```
lib/
├── main.dart                     # Entry point + MultiProvider
├── app.dart                      # GoRouter (14 routes) + MaterialApp.router
├── config/
│   └── app_theme.dart            # Material Design 3 ColorScheme, Typography, Shadows
├── models/
│   ├── customer.dart             # Model Customer + dummy data
│   ├── service.dart              # Model ServiceType + dummy data
│   ├── transaction.dart          # Model Transaction + TransactionItem + dummy data
│   └── parfum.dart               # Model Parfum + dummy data
├── providers/
│   ├── customer_provider.dart    # State: daftar & pencarian pelanggan
│   ├── service_provider.dart     # State: daftar layanan per kategori
│   ├── transaction_provider.dart # State: cart, checkout, riwayat
│   └── report_provider.dart      # State: parfum stok & data laporan
├── screens/
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── transaction/
│   │   ├── new_transaction_screen.dart
│   │   ├── pick_customer_screen.dart
│   │   ├── pick_service_screen.dart
│   │   └── transaction_detail_screen.dart
│   ├── customer/
│   │   ├── customer_list_screen.dart
│   │   └── add_customer_screen.dart
│   ├── service/
│   │   ├── service_list_screen.dart
│   │   └── add_service_screen.dart
│   ├── report/
│   │   ├── report_menu_screen.dart
│   │   ├── transaction_report_screen.dart
│   │   └── transaction_history_screen.dart
│   ├── parfum/
│   │   └── parfum_screen.dart
│   └── settings/
│       └── store_settings_screen.dart
└── widgets/
    ├── common/
    │   ├── gradient_app_bar.dart   # GradientAppBar + GlassAppBar
    │   ├── floating_search_bar.dart
    │   └── bottom_action_bar.dart  # BottomActionBar + GradientButton + StatusChip
    └── cards/
        ├── customer_card.dart      # CustomerCard + SimpleCustomerCard + TransactionCard
        └── service_card.dart       # ServiceCard (list & grid mode) + stepper
```

---

## 📦 Dependencies

| Package | Versi | Fungsi |
|---|---|---|
| `google_fonts` | ^6.1.0 | Font Plus Jakarta Sans |
| `go_router` | ^13.0.0 | Navigasi declarative (14 routes) |
| `provider` | ^6.1.1 | State management |
| `intl` | ^0.19.0 | Format Rupiah & tanggal Bahasa Indonesia |
| `fl_chart` | ^0.68.0 | Bar chart laporan pendapatan |

---

## 🖥️ Cara Menjalankan di Laptop

### Prasyarat

Pastikan perangkat Anda sudah terinstal:

| Perangkat Lunak | Versi Minimum | Link |
|---|---|---|
| Flutter SDK | 3.10.0+ | [flutter.dev/docs/get-started/install](https://docs.flutter.dev/get-started/install) |
| Dart SDK | 3.0.0+ | (sudah termasuk dalam Flutter) |
| Android Studio / VS Code | Terbaru | [developer.android.com/studio](https://developer.android.com/studio) |
| Git | Terbaru | [git-scm.com](https://git-scm.com) |

> **💡 Tip:** Jalankan `flutter doctor` untuk memastikan semua kebutuhan sudah terpenuhi.

---

### Langkah Instalasi

#### 1. Clone Repository

```bash
git clone https://github.com/username/laundry_app.git
cd laundry_app
```

#### 2. Install Dependencies

```bash
flutter pub get
```

#### 3. Verifikasi Setup (opsional)

```bash
flutter doctor
flutter analyze
```

Output `flutter analyze` harusnya:
```
No issues found!
```

#### 4. Jalankan Aplikasi

**Emulator Android / iOS Simulator:**
```bash
flutter run
```

**Di browser (Chrome) — Web mode:**
```bash
flutter run -d chrome
```

**Di Windows Desktop:**
```bash
flutter run -d windows
```

**Pilih device secara interaktif:**
```bash
flutter run --list-devices
# lalu pilih device yang diinginkan
```

---

### 🏗️ Build APK (Android)

```bash
# Debug APK (untuk testing)
flutter build apk --debug

# Release APK (untuk distribusi)
flutter build apk --release
```

File APK tersimpan di:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

### 🪟 Build Windows Desktop

```bash
flutter build windows --release
```

File `.exe` tersimpan di:
```
build/windows/x64/runner/Release/
```

---

## 🗺️ Navigasi (Routes)

| Route | Screen |
|---|---|
| `/` | Dashboard |
| `/transaction/new` | Transaksi Baru |
| `/transaction/pick-customer` | Pilih Pelanggan |
| `/transaction/pick-service` | Pilih Layanan |
| `/transaction/:id` | Detail Transaksi |
| `/customers` | Daftar Pelanggan |
| `/customers/add` | Tambah Pelanggan |
| `/services` | Daftar Layanan |
| `/services/add` | Tambah Layanan |
| `/reports` | Menu Laporan |
| `/reports/transactions` | Laporan Transaksi |
| `/reports/history` | Riwayat Transaksi |
| `/parfum` | Kelola Parfum |
| `/settings` | Pengaturan Toko |

---

## 🎨 Color Palette

| Token | Warna | Hex |
|---|---|---|
| `primary` | 🔵 Biru Azure | `#006590` |
| `primaryContainer` | 🩵 Biru Muda | `#00B5FF` |
| `secondary` | 🔷 Biru Steel | `#38637F` |
| `tertiary` | 🟠 Oranye | `#8A5100` |
| `tertiaryContainer` | 🟡 Kuning Emas | `#F39413` |
| `error` | 🔴 Merah | `#BA1A1A` |
| `surface` | ⬜ Putih Kebiruan | `#F6FAFF` |

---

## 🤝 Kontribusi

Kontribusi sangat diterima! Silakan:

1. Fork repository ini
2. Buat branch fitur: `git checkout -b feature/fitur-baru`
3. Commit perubahan: `git commit -m 'Tambah fitur baru'`
4. Push ke branch: `git push origin feature/fitur-baru`
5. Buka Pull Request

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE).

---

<div align="center">

Dibuat dengan ❤️ menggunakan Flutter & Material Design 3

**LaundryKu Kasir** — *Bersih, Rapi, Tepat Waktu*

</div>
