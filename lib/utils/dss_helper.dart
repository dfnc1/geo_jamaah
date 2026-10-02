import '../data/mock_data.dart';
import '../models/mahasantri.dart';
import '../models/presensi.dart';

/// Threshold dan konfigurasi Decision Support System (DSS).
class DssKonfig {
  /// Persentase kehadiran minimum sebelum dianggap kritis (default: 75%)
  static const double ambangKehadiranPersen = 75.0;

  /// Jumlah mangkir (tidakHadir) berturut-turut yang memicu peringatan
  static const int ambangMangkirBerturut = 3;
}

/// Hasil analisis risiko seorang mahasantri oleh DSS.
class HasilDss {
  /// Data mahasantri yang dianalisis
  final Mahasantri mahasantri;

  /// Persentase kehadiran (0-100)
  final double persenKehadiran;

  /// Total presensi yang ada di sistem
  final int totalPresensi;

  /// Jumlah status hadir
  final int jumlahHadir;

  /// Jumlah mangkir (tidakHadir)
  final int jumlahMangkir;

  /// Jumlah mangkir berturut-turut (dihitung dari presensi terbaru ke belakang)
  final int mangkirBerturut;

  /// [true] jika kehadiran di bawah [DssKonfig.ambangKehadiranPersen]
  final bool risikoKehadiran;

  /// [true] jika mangkir berturut-turut >= [DssKonfig.ambangMangkirBerturut]
  final bool risikoMangkirBerturut;

  const HasilDss({
    required this.mahasantri,
    required this.persenKehadiran,
    required this.totalPresensi,
    required this.jumlahHadir,
    required this.jumlahMangkir,
    required this.mangkirBerturut,
    required this.risikoKehadiran,
    required this.risikoMangkirBerturut,
  });

  /// [true] jika salah satu atau lebih faktor risiko terpenuhi
  bool get berisiko => risikoKehadiran || risikoMangkirBerturut;

  /// Deskripsi singkat faktor risiko yang aktif untuk ditampilkan di UI
  String get deskripsiRisiko {
    final List<String> alasan = [];
    if (risikoKehadiran) {
      alasan.add('Kehadiran ${persenKehadiran.toStringAsFixed(0)}% < ${DssKonfig.ambangKehadiranPersen.toInt()}%');
    }
    if (risikoMangkirBerturut) {
      alasan.add('Mangkir $mangkirBerturut× berturut-turut');
    }
    return alasan.isEmpty ? 'Normal' : alasan.join(' · ');
  }

  /// Label tingkat risiko untuk badge UI
  String get labelRisiko {
    if (risikoKehadiran && risikoMangkirBerturut) return 'KRITIS';
    if (risikoKehadiran || risikoMangkirBerturut) return 'PERLU PERHATIAN';
    return 'NORMAL';
  }
}

/// Helper DSS / Early Warning System (EWS) untuk memantau risiko kehadiran.
///
/// Semua metode bersifat `static` sehingga dapat dipanggil tanpa instansiasi.
class DssHelper {
  // Cegah instansiasi
  DssHelper._();

  // ── ANALISIS PER MAHASANTRI ───────────────────────────────────────────────

  /// Menghitung [HasilDss] untuk satu mahasantri berdasarkan data presensi
  /// yang ada di [MockData.presensi].
  static HasilDss analisisMahasantri(Mahasantri mhs) {
    final presensiList = MockData.getPresensiByNim(mhs.nim);

    final total = presensiList.length;
    final hadir = presensiList
        .where((p) => p.statusPresensi == StatusPresensi.hadir)
        .length;
    final mangkir = presensiList
        .where((p) => p.statusPresensi == StatusPresensi.tidakHadir)
        .length;

    // Hitung persentase kehadiran; jika belum ada data, anggap 100%
    final persen = total == 0 ? 100.0 : (hadir / total * 100);

    // Hitung mangkir berturut-turut dari presensi terbaru ke terlama
    final sorted = List<Presensi>.from(presensiList)
      ..sort((a, b) => b.waktuPresensi.compareTo(a.waktuPresensi));

    int berturut = 0;
    for (final p in sorted) {
      if (p.statusPresensi == StatusPresensi.tidakHadir) {
        berturut++;
      } else {
        break; // urutan berturut putus
      }
    }

    return HasilDss(
      mahasantri: mhs,
      persenKehadiran: persen,
      totalPresensi: total,
      jumlahHadir: hadir,
      jumlahMangkir: mangkir,
      mangkirBerturut: berturut,
      risikoKehadiran: persen < DssKonfig.ambangKehadiranPersen,
      risikoMangkirBerturut: berturut >= DssKonfig.ambangMangkirBerturut,
    );
  }

  // ── ANALISIS PER MUSYRIF ──────────────────────────────────────────────────

  /// Mengembalikan list [HasilDss] untuk **semua** mahasantri yang diampu
  /// oleh musyrif dengan [idMusyrif].
  static List<HasilDss> analisisPerMusyrif(String idMusyrif) {
    final listMhs = MockData.getMahasantriByMusyrif(idMusyrif);
    return listMhs.map(analisisMahasantri).toList();
  }

  /// Mengembalikan hanya mahasantri yang **berisiko** (EWS aktif)
  /// dari musyrif tertentu, diurutkan dari risiko tertinggi ke terendah.
  static List<HasilDss> filterBerisiko(String idMusyrif) {
    return analisisPerMusyrif(idMusyrif)
        .where((h) => h.berisiko)
        .toList()
      ..sort((a, b) {
        // Kritis (keduanya) → hanya kehadiran → hanya mangkir → normal
        final scoreA = (a.risikoKehadiran ? 2 : 0) + (a.risikoMangkirBerturut ? 1 : 0);
        final scoreB = (b.risikoKehadiran ? 2 : 0) + (b.risikoMangkirBerturut ? 1 : 0);
        if (scoreB != scoreA) return scoreB.compareTo(scoreA);
        return a.persenKehadiran.compareTo(b.persenKehadiran); // kehadiran terendah duluan
      });
  }

  // ── RINGKASAN ─────────────────────────────────────────────────────────────

  /// Jumlah total mahasantri berisiko di bawah pengampuan [idMusyrif].
  static int jumlahBerisiko(String idMusyrif) =>
      filterBerisiko(idMusyrif).length;
}
