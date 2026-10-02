import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/presensi.dart';
import '../../theme/app_theme.dart';
import '../../utils/presensi_validator.dart';
import '../../widgets/common_widgets.dart';

/// Mode pengambilan lokasi untuk prototipe
enum ModeLokasi { simulasiDalam, simulasiLuar }

class PresensiScreen extends StatefulWidget {
  final String nim;
  final VoidCallback? onPresensiSuccess;

  const PresensiScreen({
    super.key,
    required this.nim,
    this.onPresensiSuccess,
  });

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  String _phase = 'idle'; // idle | loading | result
  bool _lokasiValid = false;
  bool _waktuValid = false;
  double _jarakMeter = 0;
  String? _selectedSholat;
  String _resultMsg = '';

  // ── Toggle Mode Simulasi ──────────────────────────────────────────────────
  /// Mode lokasi simulasi: [simulasiDalam] = dalam radius, [simulasiLuar] = luar radius
  ModeLokasi _modeLokasi = ModeLokasi.simulasiDalam;

  /// Jika true, validasi waktu dilewati (memudahkan demo di luar jam shalat)
  bool _bypassWaktu = true;

  // Koordinat aktif berdasarkan mode simulasi
  double get _currentLat => _modeLokasi == ModeLokasi.simulasiDalam
      ? PresensiValidator.simDalamRadiusLat
      : PresensiValidator.simLuarRadiusLat;

  double get _currentLon => _modeLokasi == ModeLokasi.simulasiDalam
      ? PresensiValidator.simDalamRadiusLon
      : PresensiValidator.simLuarRadiusLon;

  // ── Logic Presensi ────────────────────────────────────────────────────────
  void _startPresensi() async {
    if (_selectedSholat == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih shalat terlebih dahulu')));
      return;
    }

    final jadwal = MockData.jadwalSholat.firstWhere((j) => j.idJadwal == _selectedSholat);

    setState(() => _phase = 'loading');
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // 1. Kalkulasi jarak menggunakan formula Haversine
    final jarak = PresensiValidator.hitungJarakHaversine(
      _currentLat,
      _currentLon,
      MockData.masjid.latitude,
      MockData.masjid.longitude,
    );

    // 2. Validasi geofencing
    final lokasiOk = PresensiValidator.isLokasiValid(
      latUser: _currentLat,
      lonUser: _currentLon,
      latMasjid: MockData.masjid.latitude,
      lonMasjid: MockData.masjid.longitude,
      radiusToleransi: MockData.masjid.radiusToleransi,
    );

    // 3. Validasi window waktu shalat
    final waktuOk = _bypassWaktu
        ? true
        : PresensiValidator.isWaktuValid(
            waktuMulaiPresensi: jadwal.waktuMulaiPresensi,
            waktuAkhirPresensi: jadwal.waktuAkhirPresensi,
          );

    final berhasil = lokasiOk && waktuOk;

    // 4. Mutasi data real-time ke MockData.presensi
    MockData.simpanPresensi(
      nim: widget.nim,
      idJadwal: _selectedSholat!,
      idMasjid: MockData.masjid.idMasjid,
      waktuPresensi: DateTime.now(),
      latitudeUser: _currentLat,
      longitudeUser: _currentLon,
      statusPresensi: berhasil ? StatusPresensi.hadir : StatusPresensi.tidakHadir,
    );

    setState(() {
      _phase = 'result';
      _jarakMeter = jarak;
      _lokasiValid = lokasiOk;
      _waktuValid = waktuOk;
      _resultMsg = berhasil
          ? 'Presensi berhasil! Status Hadir tercatat.'
          : !lokasiOk
              ? 'Di luar radius masjid (${PresensiValidator.formatJarak(jarak)}). Presensi ditolak.'
              : 'Di luar window waktu shalat. Presensi ditolak.';
    });

    // Notify parent agar beranda di-refresh
    widget.onPresensiSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeoAppBar(title: 'Presensi Shalat', showBack: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Info Masjid ─────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.mosque, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(MockData.masjid.namaMasjid,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          Text('Radius toleransi: ${MockData.masjid.radiusToleransi.toInt()} meter',
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Toggle Mode Simulasi ────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.science_outlined, color: AppTheme.primary, size: 18),
                        const SizedBox(width: 8),
                        const Text('Mode Simulasi GPS',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _ModeButton(
                            label: '📍 Dalam Radius',
                            subtitle: '~10 meter',
                            selected: _modeLokasi == ModeLokasi.simulasiDalam,
                            color: AppTheme.statusHadir,
                            onTap: () => setState(() {
                              _modeLokasi = ModeLokasi.simulasiDalam;
                              _phase = 'idle';
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ModeButton(
                            label: '🚫 Luar Radius',
                            subtitle: '~800 meter',
                            selected: _modeLokasi == ModeLokasi.simulasiLuar,
                            color: AppTheme.statusTidakHadir,
                            onTap: () => setState(() {
                              _modeLokasi = ModeLokasi.simulasiLuar;
                              _phase = 'idle';
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Bypass Window Waktu Shalat',
                            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                        Switch(
                          value: _bypassWaktu,
                          activeColor: AppTheme.primary,
                          onChanged: (v) => setState(() {
                            _bypassWaktu = v;
                            _phase = 'idle';
                          }),
                        ),
                      ],
                    ),
                    if (!_bypassWaktu)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.statusIzin.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '⚠️ Presensi hanya diterima dalam window waktu shalat yang aktif.',
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Pilih Sholat ────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih Shalat',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: MockData.jadwalSholat.map((j) {
                        final sel = _selectedSholat == j.idJadwal;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedSholat = j.idJadwal;
                            _phase = 'idle';
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? AppTheme.primary : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: sel ? AppTheme.primary : Colors.grey[300]!),
                            ),
                            child: Column(
                              children: [
                                Text(j.namaSholat,
                                    style: TextStyle(
                                        color: sel ? Colors.white : AppTheme.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13)),
                                Text(j.waktuAzan,
                                    style: TextStyle(
                                        color: sel ? Colors.white70 : AppTheme.textSecondary,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Loading ─────────────────────────────────────────────────────
            if (_phase == 'loading')
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppTheme.primary),
                      SizedBox(height: 16),
                      Text('Memvalidasi lokasi & waktu...',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Kalkulasi Haversine berjalan...',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ),

            // ── Hasil Validasi ──────────────────────────────────────────────
            if (_phase == 'result') ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hasil Validasi Haversine',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 12),
                      _ValidationRow(
                          label: 'Status Lokasi',
                          ok: _lokasiValid,
                          value: _lokasiValid ? 'Dalam radius ✓' : 'Luar radius ✗'),
                      const Divider(height: 16),
                      _ValidationRow(
                          label: 'Jarak dari Masjid',
                          ok: _lokasiValid,
                          value: PresensiValidator.formatJarak(_jarakMeter)),
                      const Divider(height: 16),
                      _ValidationRow(
                          label: 'Waktu Presensi',
                          ok: _waktuValid,
                          value: _bypassWaktu
                              ? 'Dilewati (bypass aktif)'
                              : (_waktuValid ? 'Dalam window ✓' : 'Luar window ✗')),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (_lokasiValid && _waktuValid)
                              ? AppTheme.statusHadir.withValues(alpha: 0.08)
                              : AppTheme.statusTidakHadir.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: (_lokasiValid && _waktuValid)
                                  ? AppTheme.statusHadir
                                  : AppTheme.statusTidakHadir),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              (_lokasiValid && _waktuValid)
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: (_lokasiValid && _waktuValid)
                                  ? AppTheme.statusHadir
                                  : AppTheme.statusTidakHadir,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Text(_resultMsg,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: (_lokasiValid && _waktuValid)
                                            ? AppTheme.statusHadir
                                            : AppTheme.statusTidakHadir))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => setState(() {
                  _phase = 'idle';
                  _selectedSholat = null;
                }),
                icon: const Icon(Icons.refresh),
                label: const Text('Presensi Baru'),
              ),
            ],

            const SizedBox(height: 16),
            if (_phase != 'loading')
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _startPresensi,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Presensi Sekarang'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? color : Colors.grey[300]!,
              width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? color : AppTheme.textPrimary)),
            Text(subtitle,
                style: TextStyle(
                    fontSize: 10,
                    color: selected ? color : AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ValidationRow extends StatelessWidget {
  final String label;
  final bool ok;
  final String value;
  const _ValidationRow({required this.label, required this.ok, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.cancel,
            color: ok ? AppTheme.statusHadir : AppTheme.statusTidakHadir, size: 16),
        const SizedBox(width: 8),
        Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: ok ? AppTheme.statusHadir : AppTheme.statusTidakHadir)),
      ],
    );
  }
}
