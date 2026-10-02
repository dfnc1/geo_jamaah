import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

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

  void _startPresensi() async {
    if (_selectedSholat == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Pilih shalat terlebih dahulu')));
      return;
    }
    setState(() => _phase = 'loading');
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final jarak = (DateTime.now().millisecond % 150).toDouble();
    final lokasiOk = jarak <= MockData.masjid.radiusToleransi;
    const waktuOk = true;

    setState(() {
      _phase = 'result';
      _jarakMeter = jarak;
      _lokasiValid = lokasiOk;
      _waktuValid = waktuOk;
      _resultMsg = lokasiOk
          ? 'Presensi berhasil! Status Hadir tercatat.'
          : 'Anda berada di luar radius masjid. Presensi ditolak.';
    });
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
            // Info Masjid
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
                          Text('Radius: ${MockData.masjid.radiusToleransi.toInt()} meter',
                              style:
                                  const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Pilih Sholat
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

            if (_phase == 'loading')
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppTheme.primary),
                      SizedBox(height: 16),
                      Text('Mengambil data lokasi...',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('Mohon tunggu sebentar',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ),

            if (_phase == 'result') ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hasil Validasi',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 12),
                      _ValidationRow(
                          label: 'Status Lokasi',
                          ok: _lokasiValid,
                          value: _lokasiValid ? 'Lokasi valid' : 'Di luar radius'),
                      const Divider(height: 16),
                      _ValidationRow(
                          label: 'Jarak dari Masjid',
                          ok: _lokasiValid,
                          value: '${_jarakMeter.toInt()} meter'),
                      const Divider(height: 16),
                      _ValidationRow(
                          label: 'Waktu Presensi',
                          ok: _waktuValid,
                          value: _waktuValid
                              ? 'Dalam waktu presensi'
                              : 'Waktu sudah berakhir'),
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
