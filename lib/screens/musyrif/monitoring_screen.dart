import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/presensi.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class MonitoringScreen extends StatefulWidget {
  final String idMusyrif;

  const MonitoringScreen({
    super.key,
    required this.idMusyrif,
  });

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  String _filterStatus = 'Semua';
  String _filterSholat = 'Semua';
  final _statusOptions = ['Semua', 'Hadir', 'Izin', 'Tidak Hadir'];
  final _sholatOptions = ['Semua', 'Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];

  List<Presensi> get _filtered {
    final myMhs = MockData.getMahasantriByMusyrif(widget.idMusyrif);
    var list = MockData.presensi.where((p) => myMhs.any((m) => m.nim == p.nim)).toList();

    if (_filterStatus != 'Semua') {
      final st = switch (_filterStatus) {
        'Hadir' => StatusPresensi.hadir,
        'Izin' => StatusPresensi.izin,
        _ => StatusPresensi.tidakHadir,
      };
      list = list.where((p) => p.statusPresensi == st).toList();
    }
    if (_filterSholat != 'Semua') {
      final jadwal = MockData.jadwalSholat.firstWhere((j) => j.namaSholat == _filterSholat);
      list = list.where((p) => p.idJadwal == jadwal.idJadwal).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeoAppBar(title: 'Monitoring Presensi', showBack: false),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Status: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      ..._statusOptions.map((s) {
                        final sel = _filterStatus == s;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _filterStatus = s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: sel ? AppTheme.primary : Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: sel ? AppTheme.primary : Colors.grey[300]!),
                              ),
                              child: Text(s, style: TextStyle(fontSize: 12, color: sel ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('Shalat: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                      ..._sholatOptions.map((s) {
                        final sel = _filterSholat == s;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => setState(() => _filterSholat = s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: sel ? const Color(0xFF1976D2) : Colors.grey[100],
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: sel ? const Color(0xFF1976D2) : Colors.grey[300]!),
                              ),
                              child: Text(s, style: TextStyle(fontSize: 12, color: sel ? Colors.white : AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text('${_filtered.length} data ditemukan',
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('Tidak ada data', style: TextStyle(color: AppTheme.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final p = _filtered[i];
                      final mhs = MockData.getMahasantriByNim(p.nim);
                      final jadwal = MockData.getJadwalById(p.idJadwal);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                                child: Text(mhs?.nama.substring(0, 1) ?? '?',
                                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(mhs?.nama ?? '-',
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                    Text('${mhs?.nim ?? '-'} · Kamar ${mhs?.kamar ?? '-'}',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                    Text('${jadwal?.namaSholat ?? '-'} · ${p.waktuPresensi.hour.toString().padLeft(2, '0')}:${p.waktuPresensi.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                              StatusBadgePresensi(status: p.statusPresensi, small: true),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
