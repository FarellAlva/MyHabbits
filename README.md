# MaHabits - Pelacak Kebiasaan Sederhana

MaHabits adalah aplikasi pelacak kebiasaan (habit tracker) minimalis yang dibangun dengan Flutter. Aplikasi ini dirancang untuk membantu Anda membangun rutinitas harian secara konsisten dengan antarmuka yang bersih dan fokus.

Selain melacak kebiasaan pribadi, MaHabits juga memiliki fitur unik "Pesan Global" di mana Anda dapat berbagi pemikiran atau pesan motivasi secara anonim dengan pengguna lain.

## 🖼️ Tampilan Aplikasi

| Halaman Utama (Progress) | Halaman Utama (Selesai) | Halaman Tambah/Edit | Halaman Pesan Global |
| :---: | :---: | :---: | :---: |
| ![Halaman Utama (Progress)](https://github.com/FarellAlva/Image-Hosting/blob/main/Screenshot%202025-10-31%20132132.png) | ![Halaman Utama (Selesai)](https://github.com/

## ✨ Fitur Utama

* **Manajemen Kebiasaan:** Buat, Edit, dan Hapus kebiasaan harian dengan mudah.
* **Pelacakan Progress:** Tandai kebiasaan sebagai selesai dan lihat progress harian Anda melalui *progress bar* visual.
* **Penyimpanan Persisten:** Semua data kebiasaan Anda disimpan secara lokal di perangkat menggunakan **SQLite**, sehingga data aman dan tersedia offline.
* **Pesan Global (Online):**
    * Bagikan pemikiran/pesan unik Anda hari ini ke papan pesan global.
    * Lihat riwayat pesan dari semua pengguna, diurutkan dari yang terbaru.


## 🚀 Teknologi yang Digunakan

* **Framework:** Flutter
* **State Management:** Riverpod
* **Database Lokal:** SQLite (via `sqflite`)
* **Penyimpanan Sederhana:** SharedPreferences
* **Backend (Fitur Online):** Supabase (untuk API "Pesan Global")
* **Networking:** `http`
* **Konfigurasi:** `flutter_dotenv` (untuk mengelola kunci API)

## ⚙️ Cara Menjalankan Proyek

Untuk menjalankan proyek ini di lokal, ikuti langkah-langkah berikut:

**1. Clone Repositori**
```bash
git clone [URL_REPOSITORI_ANDA]
cd [NAMA_FOLDER_PROYEK]
```

**2. Dapatkan Dependensi Flutter**
```bash
flutter pub get
```

**3. Konfigurasi Backend (Supabase)**

Fitur "Pesan Global" memerlukan koneksi ke Supabase.

* Buat proyek baru di [Supabase](https://supabase.com/).
* Di dalam proyek Anda, buat tabel baru (misalnya, `thought_entries`) dengan skema berikut:
    * `id` (uuid, primary key)
    * `created_at` (timestampz, default: `now()`)
    * `thought` (text)
* Atur RLS (Row Level Security) agar tabel bisa dibaca (`SELECT`) oleh semua orang dan ditulis (`INSERT`) oleh pengguna anonim.

**4. Buat File `.env`**

Di *root* proyek Anda, buat file bernama `.env` dan tambahkan kunci Supabase Anda:

```
SUPABASE_URL=URL_PROYEK_SUPABASE_ANDA
SUPABASE_ANON_KEY=KUNCI_ANON_PUBLIK_SUPABASE_ANDA
```

**5. Jalankan Aplikasi**
```bash
flutter run
```

## 📂 Struktur Proyek

Proyek ini mengikuti struktur yang bersih untuk memisahkan logika:

```
lib/
├── model/
│   └── model.dart         # Model data (Habit, ThoughtEntry)
├── page/
│   ├── add_edit_habit_page.dart # Halaman form tambah/edit habit
│   ├── home_page.dart           # Halaman utama (daftar habit, progress)
│   └── thought_page.dart        # Halaman riwayat pesan global
├── provider/
│   └── provider.dart      # Semua provider Riverpod (state management)
├── service/
│   ├── database_service.dart    # Helper untuk database SQLite (CRUD Habit)
│   └── thought_api_service.dart # Service untuk API Supabase (CRUD Thought)
├── app.dart               # Konfigurasi MaterialApp dan Rute
└── main.dart              # Titik masuk aplikasi
```