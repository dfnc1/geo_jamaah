import '../models/pengguna.dart';
import '../models/mahasantri.dart';
import '../models/musyrif.dart';
import '../models/jadwal_sholat.dart';
import '../models/masjid.dart';
import '../models/presensi.dart';
import '../models/izin.dart';

class MockData {
  // ── PENGGUNA ──────────────────────────────────────────────────────────────
  static final List<Pengguna> pengguna = [
    const Pengguna(idPengguna: 'P001', username: 'ahmad', password: '1234', role: RolePengguna.mahasantri),
    const Pengguna(idPengguna: 'P002', username: 'rizki', password: '1234', role: RolePengguna.mahasantri),
    const Pengguna(idPengguna: 'P003', username: 'fajar', password: '1234', role: RolePengguna.mahasantri),
    const Pengguna(idPengguna: 'P004', username: 'hasan', password: '1234', role: RolePengguna.mahasantri),
    const Pengguna(idPengguna: 'P005', username: 'yusuf', password: '1234', role: RolePengguna.mahasantri),
    const Pengguna(idPengguna: 'P006', username: 'ilham', password: '1234', role: RolePengguna.mahasantri),
    const Pengguna(idPengguna: 'P007', username: 'bagas', password: '1234', role: RolePengguna.mahasantri),
    const Pengguna(idPengguna: 'P008', username: 'dimas', password: '1234', role: RolePengguna.mahasantri),
    const Pengguna(idPengguna: 'P009', username: 'rafi', password: '1234', role: RolePengguna.mahasantri),
    const Pengguna(idPengguna: 'P010', username: 'aldi', password: '1234', role: RolePengguna.mahasantri),
    const Pengguna(idPengguna: 'M001', username: 'musyrif1', password: '1234', role: RolePengguna.musyrif),
    const Pengguna(idPengguna: 'M002', username: 'musyrif2', password: '1234', role: RolePengguna.musyrif),
    const Pengguna(idPengguna: 'M003', username: 'musyrif3', password: '1234', role: RolePengguna.musyrif),
    const Pengguna(idPengguna: 'A001', username: 'admin', password: 'admin', role: RolePengguna.admin),
  ];

  // ── MUSYRIF ───────────────────────────────────────────────────────────────
  static final List<Musyrif> musyrif = [
    const Musyrif(idMusyrif: 'M001', idPengguna: 'M001', nama: 'Ust. Abdullah Fauzi', noTelepon: '0812-3456-7890'),
    const Musyrif(idMusyrif: 'M002', idPengguna: 'M002', nama: 'Ust. Rahmat Hidayat', noTelepon: '0813-2345-6789'),
    const Musyrif(idMusyrif: 'M003', idPengguna: 'M003', nama: 'Ust. Zainul Arifin', noTelepon: '0814-3456-7890'),
  ];

  // ── MAHASANTRI ────────────────────────────────────────────────────────────
  static final List<Mahasantri> mahasantri = [
    const Mahasantri(nim: '220101001', idPengguna: 'P001', idMusyrif: 'M001', nama: 'Ahmad Fauzan', kamar: 'A-101'),
    const Mahasantri(nim: '220101002', idPengguna: 'P002', idMusyrif: 'M001', nama: 'Rizki Ramadhan', kamar: 'A-102'),
    const Mahasantri(nim: '220101003', idPengguna: 'P003', idMusyrif: 'M001', nama: 'Fajar Maulana', kamar: 'A-103'),
    const Mahasantri(nim: '220101004', idPengguna: 'P004', idMusyrif: 'M002', nama: 'Hasan Al-Bana', kamar: 'B-201'),
    const Mahasantri(nim: '220101005', idPengguna: 'P005', idMusyrif: 'M002', nama: 'Yusuf Abdillah', kamar: 'B-202'),
    const Mahasantri(nim: '220101006', idPengguna: 'P006', idMusyrif: 'M002', nama: 'Ilham Nugroho', kamar: 'B-203'),
    const Mahasantri(nim: '220101007', idPengguna: 'P007', idMusyrif: 'M003', nama: 'Bagas Prasetyo', kamar: 'C-301'),
    const Mahasantri(nim: '220101008', idPengguna: 'P008', idMusyrif: 'M003', nama: 'Dimas Kurniawan', kamar: 'C-302'),
    const Mahasantri(nim: '220101009', idPengguna: 'P009', idMusyrif: 'M003', nama: 'Rafi Saputra', kamar: 'C-303'),
    const Mahasantri(nim: '220101010', idPengguna: 'P010', idMusyrif: 'M001', nama: 'Aldi Firmansyah', kamar: 'A-104'),
  ];

  // ── JADWAL SHOLAT ─────────────────────────────────────────────────────────
  static final List<JadwalSholat> jadwalSholat = [
    const JadwalSholat(idJadwal: 'JS001', namaSholat: 'Subuh',   waktuAzan: '04:30', waktuIqamah: '04:45', waktuMulaiPresensi: '04:30', waktuAkhirPresensi: '05:00'),
    const JadwalSholat(idJadwal: 'JS002', namaSholat: 'Dzuhur',  waktuAzan: '12:00', waktuIqamah: '12:15', waktuMulaiPresensi: '12:00', waktuAkhirPresensi: '12:30'),
    const JadwalSholat(idJadwal: 'JS003', namaSholat: 'Ashar',   waktuAzan: '15:15', waktuIqamah: '15:30', waktuMulaiPresensi: '15:15', waktuAkhirPresensi: '15:45'),
    const JadwalSholat(idJadwal: 'JS004', namaSholat: 'Maghrib', waktuAzan: '17:55', waktuIqamah: '18:05', waktuMulaiPresensi: '17:55', waktuAkhirPresensi: '18:20'),
    const JadwalSholat(idJadwal: 'JS005', namaSholat: 'Isya',    waktuAzan: '19:15', waktuIqamah: '19:30', waktuMulaiPresensi: '19:15', waktuAkhirPresensi: '19:45'),
  ];

  // ── MASJID ────────────────────────────────────────────────────────────────
  static const Masjid masjid = Masjid(
    idMasjid: 'MSJ001',
    namaMasjid: 'Masjid Al-Hikmah Pesantren',
    latitude: -6.914744,
    longitude: 107.609811,
    radiusToleransi: 100,
  );

  // ── PRESENSI (mutable list) ───────────────────────────────────────────────
  static List<Presensi> presensi = [
    Presensi(idPresensi: 'PR001', nim: '220101001', idJadwal: 'JS001', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(days: 0, hours: 14, minutes: 10)), latitudeUser: -6.914744, longitudeUser: 107.609811, statusPresensi: StatusPresensi.hadir),
    Presensi(idPresensi: 'PR002', nim: '220101001', idJadwal: 'JS002', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(days: 0, hours: 6, minutes: 5)),  latitudeUser: -6.914744, longitudeUser: 107.609811, statusPresensi: StatusPresensi.hadir),
    Presensi(idPresensi: 'PR003', nim: '220101001', idJadwal: 'JS003', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(days: 0, hours: 3)),              latitudeUser: -6.914744, longitudeUser: 107.609811, statusPresensi: StatusPresensi.hadir),
    Presensi(idPresensi: 'PR004', nim: '220101001', idJadwal: 'JS001', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(days: 1, hours: 14)),             latitudeUser: -6.914744, longitudeUser: 107.609811, statusPresensi: StatusPresensi.hadir),
    Presensi(idPresensi: 'PR005', nim: '220101001', idJadwal: 'JS002', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(days: 1, hours: 6)),              latitudeUser: -6.914744, longitudeUser: 107.609811, statusPresensi: StatusPresensi.izin),
    Presensi(idPresensi: 'PR006', nim: '220101001', idJadwal: 'JS004', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(days: 2, hours: 0, minutes: 30)), latitudeUser: -6.914744, longitudeUser: 107.609811, statusPresensi: StatusPresensi.tidakHadir),
    Presensi(idPresensi: 'PR007', nim: '220101001', idJadwal: 'JS005', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(days: 2, hours: 3)),              latitudeUser: -6.914744, longitudeUser: 107.609811, statusPresensi: StatusPresensi.hadir),
    // Other mahasantri
    Presensi(idPresensi: 'PR008', nim: '220101002', idJadwal: 'JS001', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(hours: 14)), latitudeUser: -6.914800, longitudeUser: 107.609900, statusPresensi: StatusPresensi.hadir),
    Presensi(idPresensi: 'PR009', nim: '220101002', idJadwal: 'JS002', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(hours: 6)),  latitudeUser: -6.914800, longitudeUser: 107.609900, statusPresensi: StatusPresensi.tidakHadir),
    Presensi(idPresensi: 'PR010', nim: '220101003', idJadwal: 'JS001', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(hours: 14)), latitudeUser: -6.914700, longitudeUser: 107.609700, statusPresensi: StatusPresensi.hadir),
    Presensi(idPresensi: 'PR011', nim: '220101004', idJadwal: 'JS001', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(hours: 14)), latitudeUser: -6.914700, longitudeUser: 107.609700, statusPresensi: StatusPresensi.izin),
    Presensi(idPresensi: 'PR012', nim: '220101005', idJadwal: 'JS001', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(hours: 14)), latitudeUser: -6.914700, longitudeUser: 107.609700, statusPresensi: StatusPresensi.hadir),
    Presensi(idPresensi: 'PR013', nim: '220101006', idJadwal: 'JS001', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(hours: 14)), latitudeUser: -6.914700, longitudeUser: 107.609700, statusPresensi: StatusPresensi.hadir),
    Presensi(idPresensi: 'PR014', nim: '220101007', idJadwal: 'JS001', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(hours: 14)), latitudeUser: -6.914700, longitudeUser: 107.609700, statusPresensi: StatusPresensi.tidakHadir),
    Presensi(idPresensi: 'PR015', nim: '220101008', idJadwal: 'JS001', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(hours: 14)), latitudeUser: -6.914700, longitudeUser: 107.609700, statusPresensi: StatusPresensi.hadir),
    Presensi(idPresensi: 'PR016', nim: '220101009', idJadwal: 'JS001', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(hours: 14)), latitudeUser: -6.920000, longitudeUser: 107.615000, statusPresensi: StatusPresensi.tidakHadir),
    Presensi(idPresensi: 'PR017', nim: '220101010', idJadwal: 'JS001', idMasjid: 'MSJ001', waktuPresensi: DateTime.now().subtract(const Duration(hours: 14)), latitudeUser: -6.914744, longitudeUser: 107.609811, statusPresensi: StatusPresensi.hadir),
  ];

  // ── IZIN (mutable list) ───────────────────────────────────────────────────
  static List<Izin> izin = [
    Izin(idIzin: 'IZ001', nim: '220101001', idMusyrif: 'M001', jenisIzin: JenisIzin.sakit,       tanggalIzin: DateTime.now().subtract(const Duration(days: 1)), alasan: 'Sakit demam dan flu, tidak sanggup ke masjid', statusPersetujuan: StatusPersetujuan.disetujui),
    Izin(idIzin: 'IZ002', nim: '220101001', idMusyrif: 'M001', jenisIzin: JenisIzin.tugasKampus, tanggalIzin: DateTime.now().subtract(const Duration(days: 3)), alasan: 'Mengikuti seminar nasional di kampus hingga malam', statusPersetujuan: StatusPersetujuan.disetujui),
    Izin(idIzin: 'IZ003', nim: '220101002', idMusyrif: 'M001', jenisIzin: JenisIzin.pulang,      tanggalIzin: DateTime.now().subtract(const Duration(days: 2)), alasan: 'Ada acara keluarga yang tidak bisa ditinggal', statusPersetujuan: StatusPersetujuan.pending),
    Izin(idIzin: 'IZ004', nim: '220101003', idMusyrif: 'M001', jenisIzin: JenisIzin.sakit,       tanggalIzin: DateTime.now(),                                   alasan: 'Sakit perut mendadak', statusPersetujuan: StatusPersetujuan.pending),
    Izin(idIzin: 'IZ005', nim: '220101004', idMusyrif: 'M002', jenisIzin: JenisIzin.tugasKampus, tanggalIzin: DateTime.now().subtract(const Duration(days: 1)), alasan: 'Praktikum laboratorium wajib', statusPersetujuan: StatusPersetujuan.ditolak),
    Izin(idIzin: 'IZ006', nim: '220101005', idMusyrif: 'M002', jenisIzin: JenisIzin.pulang,      tanggalIzin: DateTime.now(),                                   alasan: 'Orang tua datang menjenguk dari luar kota', statusPersetujuan: StatusPersetujuan.pending),
    Izin(idIzin: 'IZ007', nim: '220101007', idMusyrif: 'M003', jenisIzin: JenisIzin.sakit,       tanggalIzin: DateTime.now(),                                   alasan: 'Demam tinggi, sudah ke klinik pesantren', statusPersetujuan: StatusPersetujuan.pending),
  ];

  // ── MUTASI DATA REAL-TIME ─────────────────────────────────────────────────

  /// Menambahkan atau memperbarui data presensi.
  /// Jika record dengan [nim] + [idJadwal] pada hari yang sama sudah ada,
  /// data lama diganti (update). Jika belum ada, ditambahkan ke awal list.
  /// Mengembalikan objek [Presensi] yang disimpan.
  static Presensi simpanPresensi({
    required String nim,
    required String idJadwal,
    required String idMasjid,
    required DateTime waktuPresensi,
    required double latitudeUser,
    required double longitudeUser,
    required StatusPresensi statusPresensi,
    String? idPresensiOverride,
  }) {
    // Cari apakah sudah ada record untuk NIM + jadwal + hari yang sama
    final existingIndex = presensi.indexWhere((p) =>
        p.nim == nim &&
        p.idJadwal == idJadwal &&
        p.waktuPresensi.year == waktuPresensi.year &&
        p.waktuPresensi.month == waktuPresensi.month &&
        p.waktuPresensi.day == waktuPresensi.day);

    final id = idPresensiOverride ??
        (existingIndex != -1
            ? presensi[existingIndex].idPresensi
            : 'PR${DateTime.now().millisecondsSinceEpoch}');

    final newPresensi = Presensi(
      idPresensi: id,
      nim: nim,
      idJadwal: idJadwal,
      idMasjid: idMasjid,
      waktuPresensi: waktuPresensi,
      latitudeUser: latitudeUser,
      longitudeUser: longitudeUser,
      statusPresensi: statusPresensi,
    );

    if (existingIndex != -1) {
      presensi[existingIndex] = newPresensi; // update in-place
    } else {
      presensi.insert(0, newPresensi); // tambah ke awal agar tampil terbaru
    }
    return newPresensi;
  }

  /// Mengubah status persetujuan izin berdasarkan [idIzin].
  /// Mengembalikan `true` jika berhasil, `false` jika id tidak ditemukan.
  static bool updateStatusIzin(String idIzin, StatusPersetujuan status) {
    final index = izin.indexWhere((i) => i.idIzin == idIzin);
    if (index != -1) {
      izin[index].statusPersetujuan = status;
      return true;
    }
    return false;
  }

  /// Menambahkan pengajuan izin baru ke awal list.
  static void tambahIzin(Izin newIzin) {
    izin.insert(0, newIzin);
  }

  // ── HELPERS ───────────────────────────────────────────────────────────────
  static Mahasantri? getMahasantriByNim(String nim) {
    try {
      return mahasantri.firstWhere((m) => m.nim == nim);
    } catch (_) {
      return null;
    }
  }

  static Mahasantri? getMahasantriByPenggunaId(String idPengguna) {
    try {
      return mahasantri.firstWhere((m) => m.idPengguna == idPengguna);
    } catch (_) {
      return null;
    }
  }

  static Musyrif? getMusyrifById(String id) {
    try {
      return musyrif.firstWhere((m) => m.idMusyrif == id);
    } catch (_) {
      return null;
    }
  }

  static JadwalSholat? getJadwalById(String id) {
    try {
      return jadwalSholat.firstWhere((j) => j.idJadwal == id);
    } catch (_) {
      return null;
    }
  }

  static List<Presensi> getPresensiByNim(String nim) {
    return presensi.where((p) => p.nim == nim).toList();
  }

  static List<Izin> getIzinByNim(String nim) {
    return izin.where((i) => i.nim == nim).toList();
  }

  static List<Izin> getIzinByMusyrif(String idMusyrif) {
    return izin.where((i) => i.idMusyrif == idMusyrif).toList();
  }

  static List<Mahasantri> getMahasantriByMusyrif(String idMusyrif) {
    return mahasantri.where((m) => m.idMusyrif == idMusyrif).toList();
  }

  static Pengguna? authenticate(String username, String password) {
    try {
      return pengguna.firstWhere((p) => p.username == username && p.password == password);
    } catch (_) {
      return null;
    }
  }
}
