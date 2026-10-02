enum RolePengguna { mahasantri, musyrif, admin }

class Pengguna {
  final String idPengguna;
  final String username;
  final String password;
  final RolePengguna role;
  final String? deviceId;

  const Pengguna({
    required this.idPengguna,
    required this.username,
    required this.password,
    required this.role,
    this.deviceId,
  });
}
