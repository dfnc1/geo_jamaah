enum JenisIzin { sakit, pulang, tugasKampus }
enum StatusPersetujuan { pending, disetujui, ditolak }

class Izin {
  final String idIzin;
  final String nim;
  final String idMusyrif;
  JenisIzin jenisIzin;
  DateTime tanggalIzin;
  String alasan;
  String? buktiLampiran;
  StatusPersetujuan statusPersetujuan;

  Izin({
    required this.idIzin,
    required this.nim,
    required this.idMusyrif,
    required this.jenisIzin,
    required this.tanggalIzin,
    required this.alasan,
    this.buktiLampiran,
    this.statusPersetujuan = StatusPersetujuan.pending,
  });

  String get jenisIzinLabel {
    switch (jenisIzin) {
      case JenisIzin.sakit:
        return 'Sakit';
      case JenisIzin.pulang:
        return 'Pulang';
      case JenisIzin.tugasKampus:
        return 'Tugas Kampus';
    }
  }

  String get statusLabel {
    switch (statusPersetujuan) {
      case StatusPersetujuan.pending:
        return 'Pending';
      case StatusPersetujuan.disetujui:
        return 'Disetujui';
      case StatusPersetujuan.ditolak:
        return 'Ditolak';
    }
  }
}
