class Masjid {
  final String idMasjid;
  final String namaMasjid;
  final double latitude;
  final double longitude;
  final double radiusToleransi; // in meters

  const Masjid({
    required this.idMasjid,
    required this.namaMasjid,
    required this.latitude,
    required this.longitude,
    required this.radiusToleransi,
  });
}
