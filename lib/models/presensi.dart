enum StatusPresensi { hadir, tidakHadir, izin, belum, manual }

class Presensi {
  final String idPresensi;
  final String nim;
  final String idJadwal;
  final String idMasjid;
  final DateTime waktuPresensi;
  final double latitudeUser;
  final double longitudeUser;
  StatusPresensi statusPresensi;
  final bool isManual;
  final String? alasanKendala;

  Presensi({
    required this.idPresensi,
    required this.nim,
    required this.idJadwal,
    required this.idMasjid,
    required this.waktuPresensi,
    required this.latitudeUser,
    required this.longitudeUser,
    required this.statusPresensi,
    this.isManual = false,
    this.alasanKendala,
  });

  Presensi copyWith({StatusPresensi? statusPresensi}) {
    return Presensi(
      idPresensi: idPresensi,
      nim: nim,
      idJadwal: idJadwal,
      idMasjid: idMasjid,
      waktuPresensi: waktuPresensi,
      latitudeUser: latitudeUser,
      longitudeUser: longitudeUser,
      statusPresensi: statusPresensi ?? this.statusPresensi,
      isManual: isManual,
      alasanKendala: alasanKendala,
    );
  }
}
