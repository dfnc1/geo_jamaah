import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/presensi.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class RiwayatScreen extends StatefulWidget {
  final String nim;

  const RiwayatScreen({
    super.key,
    required this.nim,
  });

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _filter = 'Semua';
  final _filters = ['Semua', 'Hadir', 'Izin', 'Tidak Hadir'];

  List<Presensi> get _filtered {
    final all = MockData.getPresensiByNim(widget.nim);
    if (_filter == 'Semua') return all;
    final st = switch (_filter) {
      'Hadir' => StatusPresensi.hadir,
      'Izin' => StatusPresensi.izin,
      _ => StatusPresensi.tidakHadir,
    };
    return all.where((p) => p.statusPresensi == st).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeoAppBar(title: 'Riwayat Presensi', showBack: false),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final sel = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.primary : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel ? AppTheme.primary : Colors.grey[300]!),
                        ),
                        child: Text(f,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : AppTheme.textPrimary)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text('Tidak ada data presensi',
                        style: TextStyle(color: AppTheme.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final p = _filtered[i];
                      final jadwal = MockData.getJadwalById(p.idJadwal);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppTheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.mosque,
                                    color: AppTheme.primary, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(jadwal?.namaSholat ?? '-',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700, fontSize: 14)),
                                    Text(
                                        '${p.waktuPresensi.day}/${p.waktuPresensi.month}/${p.waktuPresensi.year}'
                                        ' · ${p.waktuPresensi.hour.toString().padLeft(2, '0')}:${p.waktuPresensi.minute.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary)),
                                  ],
                                ),
                              ),
                              StatusBadgePresensi(
                                  status: p.statusPresensi, small: true),
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
