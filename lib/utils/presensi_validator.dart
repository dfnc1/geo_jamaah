import 'dart:math';

/// Utility untuk validasi geofencing dan rentang waktu presensi jamaah.
///
/// Menyediakan:
/// - Kalkulasi jarak menggunakan formula Haversine (output: meter)
/// - Validasi apakah waktu saat ini berada dalam window presensi shalat
/// - Koordinat simulasi GPS untuk mode pengujian prototipe
class PresensiValidator {
  /// Radius rata-rata bumi dalam meter
  static const double earthRadiusMeters = 6371000.0;

  // ── KOORDINAT SIMULASI ─────────────────────────────────────────────────────

  /// Koordinat masjid default (sama dengan MockData.masjid)
  static const double defaultLatMasjid = -6.914744;
  static const double defaultLonMasjid = 107.609811;

  /// Koordinat simulasi DALAM radius — berjarak ~10 meter dari masjid
  static const double simDalamRadiusLat = -6.914740;
  static const double simDalamRadiusLon = 107.609820;

  /// Koordinat simulasi LUAR radius — berjarak ~800 meter dari masjid
  static const double simLuarRadiusLat = -6.920000;
  static const double simLuarRadiusLon = 107.615000;

  // ── HAVERSINE FORMULA ─────────────────────────────────────────────────────

  /// Menghitung jarak presisi antara dua titik koordinat menggunakan
  /// formula **Haversine**, dalam satuan **meter**.
  ///
  /// Formula:
  ///   a = sin²(Δlat/2) + cos(lat1)·cos(lat2)·sin²(Δlon/2)
  ///   c = 2·atan2(√a, √(1−a))
  ///   d = R · c
  ///
  /// Parameter:
  /// - [lat1], [lon1] : Koordinat titik pertama (pengguna)
  /// - [lat2], [lon2] : Koordinat titik kedua (masjid)
  ///
  /// Return: jarak dalam meter (double)
  static double hitungJarakHaversine(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final rLat1 = _toRadians(lat1);
    final rLat2 = _toRadians(lat2);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(rLat1) * cos(rLat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  static double _toRadians(double degree) => degree * (pi / 180.0);

  // ── VALIDASI WINDOW WAKTU SHALAT ──────────────────────────────────────────

  /// Memeriksa apakah waktu saat ini (atau [targetTime]) berada dalam
  /// window presensi shalat, yaitu antara [waktuMulaiPresensi] dan
  /// [waktuAkhirPresensi].
  ///
  /// Format waktu: `"HH:mm"` — contoh: `"04:30"` s/d `"05:00"`.
  ///
  /// Mendukung rentang yang melintas tengah malam (contoh: `"23:45"` - `"00:15"`).
  static bool isWaktuValid({
    required String waktuMulaiPresensi,
    required String waktuAkhirPresensi,
    DateTime? targetTime,
  }) {
    final now = targetTime ?? DateTime.now();

    final partsMulai = waktuMulaiPresensi.split(':');
    final partsAkhir  = waktuAkhirPresensi.split(':');
    if (partsMulai.length < 2 || partsAkhir.length < 2) return false;

    final jamMulai   = int.tryParse(partsMulai[0]) ?? 0;
    final menitMulai = int.tryParse(partsMulai[1]) ?? 0;
    final jamAkhir   = int.tryParse(partsAkhir[0]) ?? 0;
    final menitAkhir = int.tryParse(partsAkhir[1]) ?? 0;

    final start = DateTime(now.year, now.month, now.day, jamMulai, menitMulai);
    final end   = DateTime(now.year, now.month, now.day, jamAkhir, menitAkhir);

    // Tangani rentang lintas tengah malam (misal 23:45 – 00:15)
    if (end.isBefore(start)) {
      final endNextDay = end.add(const Duration(days: 1));
      return !now.isBefore(start) && !now.isAfter(endNextDay);
    }

    return !now.isBefore(start) && !now.isAfter(end);
  }

  // ── VALIDASI LOKASI ───────────────────────────────────────────────────────

  /// Memeriksa apakah lokasi pengguna berada dalam [radiusToleransi] meter
  /// dari koordinat masjid.
  static bool isLokasiValid({
    required double latUser,
    required double lonUser,
    required double latMasjid,
    required double lonMasjid,
    required double radiusToleransi,
  }) {
    final jarak = hitungJarakHaversine(latUser, lonUser, latMasjid, lonMasjid);
    return jarak <= radiusToleransi;
  }

  // ── FORMAT HELPER ─────────────────────────────────────────────────────────

  /// Format jarak (meter) ke string ramah pengguna.
  /// Contoh: 45.3 → `"45.3 meter"`, 1250.0 → `"1.25 km"`
  static String formatJarak(double meter) {
    if (meter >= 1000) {
      return '${(meter / 1000).toStringAsFixed(2)} km';
    }
    return '${meter.toStringAsFixed(1)} meter';
  }
}
