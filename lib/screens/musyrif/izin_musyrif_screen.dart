import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/izin.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class IzinMusyrifScreen extends StatefulWidget {
  final String idMusyrif;

  const IzinMusyrifScreen({
    super.key,
    required this.idMusyrif,
  });

  @override
  State<IzinMusyrifScreen> createState() => _IzinMusyrifScreenState();
}

class _IzinMusyrifScreenState extends State<IzinMusyrifScreen> {
  String _filterStatus = 'Semua';

  List<Izin> get _filtered {
    final all = MockData.getIzinByMusyrif(widget.idMusyrif);
    if (_filterStatus == 'Semua') return all;
    final st = switch (_filterStatus) {
      'Pending' => StatusPersetujuan.pending,
      'Disetujui' => StatusPersetujuan.disetujui,
      _ => StatusPersetujuan.ditolak,
    };
    return all.where((i) => i.statusPersetujuan == st).toList();
  }

  void _updateIzin(Izin izin, StatusPersetujuan status) {
    setState(() => izin.statusPersetujuan = status);
    final label = status == StatusPersetujuan.disetujui ? 'disetujui' : 'ditolak';
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Izin $label'), backgroundColor: AppTheme.primary));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeoAppBar(title: 'Verifikasi Izin', showBack: false),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Pending', 'Disetujui', 'Ditolak'].map((s) {
                  final sel = _filterStatus == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterStatus = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.primary : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sel ? AppTheme.primary : Colors.grey[300]!),
                        ),
                        child: Text(s,
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
                    child: Text('Tidak ada pengajuan izin',
                        style: TextStyle(color: AppTheme.textSecondary)))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final izin = _filtered[i];
                      final mhs = MockData.getMahasantriByNim(izin.nim);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
                                    child: Text(mhs?.nama.substring(0, 1) ?? '?',
                                        style: const TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(mhs?.nama ?? '-',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w700, fontSize: 14)),
                                        Text('${mhs?.nim ?? '-'} · Kamar ${mhs?.kamar ?? '-'}',
                                            style: const TextStyle(
                                                fontSize: 12, color: AppTheme.textSecondary)),
                                      ],
                                    ),
                                  ),
                                  StatusBadgeIzin(status: izin.statusPersetujuan),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                children: [
                                  _IzinInfoChip(label: izin.jenisIzinLabel, icon: Icons.category),
                                  const SizedBox(width: 8),
                                  _IzinInfoChip(
                                      label: '${izin.tanggalIzin.day}/${izin.tanggalIzin.month}/${izin.tanggalIzin.year}',
                                      icon: Icons.calendar_today),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(izin.alasan,
                                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary)),
                              if (izin.statusPersetujuan == StatusPersetujuan.pending) ...[
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _updateIzin(izin, StatusPersetujuan.ditolak),
                                        icon: const Icon(Icons.close, size: 16),
                                        label: const Text('Tolak'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppTheme.statusTidakHadir,
                                          side: const BorderSide(color: AppTheme.statusTidakHadir),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _updateIzin(izin, StatusPersetujuan.disetujui),
                                        icon: const Icon(Icons.check, size: 16),
                                        label: const Text('Setujui'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.statusHadir,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

class _IzinInfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _IzinInfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
