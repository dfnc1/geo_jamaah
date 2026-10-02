class Mahasantri {
  final String nim;
  final String idPengguna;
  final String idMusyrif;
  final String nama;
  final String kamar;
  final bool statusAktif;

  const Mahasantri({
    required this.nim,
    required this.idPengguna,
    required this.idMusyrif,
    required this.nama,
    required this.kamar,
    this.statusAktif = true,
  });
}
