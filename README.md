#  GEO-JAMAAH — Sistem Informasi Presensi Shalat Berjamaah Berbasis Geofencing & DSS

> **Tugas Mata Kuliah:** Sistem Informasi Manajemen / Praktikum SIM  
> **Platform:** Flutter / Dart (Mobile Application)  
> **Metode Validasi:** Geofencing (Haversine Formula) & Window Time

---

## 📌 Deskripsi Sistem

**GEO-JAMAAH** adalah sistem informasi manajemen presensi shalat berjamaah yang dirancang untuk lingkungan pesantren mahasiswa (mahasantri). Sistem ini memvalidasi kehadiran secara digital berdasarkan lokasi fisik perangkat (geofencing) dan rentang waktu shalat guna mengurangi potensi titip presensi, penggunaan *fake GPS*, serta mempermudah musyrif dalam melakukan evaluasi kedisiplinan.

---

## 👥 Peran Pengguna & Fitur Utama

### 1. Mahasantri (Mobile Role)
- **Presensi Digital:** Melakukan presensi shalat 5 waktu dengan verifikasi jarak GPS ke masjid dan batas waktu shalat.
- **Pengajuan Izin:** Mengajukan izin (Sakit, Pulang, Tugas Kampus) dilengkapi unggahan bukti lampiran.
- **Riwayat & Profil:** Meninjau histori kehadiran dan data pembimbing musyrif.

### 2. Musyrif (Operational & DSS Role)
- **Dashboard Operasional:** Memantau kehadiran harian santri binaan secara *real-time*.
- **Early Warning System (EWS / DSS):** Mendeteksi mahasantri dengan status kehadiran kritis (< 75%) untuk intervensi dan pembinaan langsung.
- **Verifikasi Izin:** Menyetujui atau menolak pengajuan izin mahasantri.
- **Rekapitulasi Kehadiran:** Meninjau rekapitulasi individu dan kelompok per kamar.

### 3. Admin / Pengasuh (Strategic Role)
- **Master Data Management:** Pengelolaan data Mahasantri, Musyrif, Jadwal Shalat, dan Koordinat Masjid.
- **Evaluasi Kebijakan:** Penyesuaian variabel `radius_toleransi` masjid dan rentang *window time* presensi.

---

## 🏗️ Arsitektur Data (7 Entitas Utama)

1. `Pengguna` (Role, Authentication, Device ID)
2. `Mahasantri` (NIM, Kamar, Pembina)
3. `Musyrif` (ID Musyrif, Kontak)
4. `Jadwal_Sholat` (Waktu Azan, Iqamah, Window Presensi)
5. `Masjid` (Koordinat Latitude/Longitude, Radius Toleransi Meter)
6. `Presensi` (Kordinat User, Status Hadir/Izin/Alpha, Timestamp)
7. `Izin` (Jenis Izin, Bukti, Status Approval)

---

## 🛠️ Teknologi & Cara Menjalankan Project

- **Framework:** Flutter (Material 3 Design)
- **State/Storage:** In-Memory Mock Repository
- **Kalkulasi Jarak:** Haversine Formula

### Langkah Menjalankan:
```bash
# 1. Clone repository ini
git clone [https://github.com/username_anda/geo-jamaah.git](https://github.com/username_anda/geo-jamaah.git)

# 2. Masuk ke folder project
cd geo-jamaah

# 3. Install dependensi
flutter pub get

# 4. Jalankan aplikasi
flutter run
```

---

## 🤖 Catatan Pengembangan

> Sebagian besar kode dalam proyek ini dikembangkan dengan bantuan **AI (Artificial Intelligence)** sebagai asisten *coding* (*pair programmer*). Proyek ini berada dalam tahap pengembangan aktif (*work in progress*) dan akan terus dilanjutkan serta disempurnakan.