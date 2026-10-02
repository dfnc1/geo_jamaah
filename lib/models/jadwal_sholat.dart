class JadwalSholat {
  final String idJadwal;
  final String namaSholat;
  final String waktuAzan;
  final String waktuIqamah;
  final String waktuMulaiPresensi;
  final String waktuAkhirPresensi;

  const JadwalSholat({
    required this.idJadwal,
    required this.namaSholat,
    required this.waktuAzan,
    required this.waktuIqamah,
    required this.waktuMulaiPresensi,
    required this.waktuAkhirPresensi,
  });
}
