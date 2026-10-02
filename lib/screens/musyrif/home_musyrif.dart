import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/pengguna.dart';
import '../../models/presensi.dart';
import '../../models/izin.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class MusyrifHomeScreen extends StatefulWidget {
  const MusyrifHomeScreen({super.key});

  @override
  State<MusyrifHomeScreen> createState() => _MusyrifHomeScreenState();
}

class _MusyrifHomeScreenState extends State<MusyrifHomeScreen> {
  int _currentIndex = 0;
  late Pengguna _user;
  bool _userLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_userLoaded) {
      _user = ModalRoute.of(context)!.settings.arguments as Pengguna;
      _userLoaded = true;
    }
  }

  String get _idMusyrif => _user.idPengguna;

  String get _namaMusyrif {
    final m = MockData.getMusyrifById(_idMusyrif);
    return m?.nama ?? _user.username;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      _MonitoringTab(idMusyrif: _idMusyrif),
      _IzinMusyrifTab(idMusyrif: _idMusyrif),
      _RekapTab(idMusyrif: _idMusyrif),
      _buildProfil(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.monitor_outlined), activeIcon: Icon(Icons.monitor), label: 'Monitoring'),
          BottomNavigationBarItem(icon: Icon(Icons.approval_outlined), activeIcon: Icon(Icons.approval), label: 'Izin'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), activeIcon: Icon(Icons.bar_chart), label: 'Rekap'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final myMhs = MockData.getMahasantriByMusyrif(_idMusyrif);
    final allPresensiToday = MockData.presensi.where((p) {
      final today = DateTime.now();
      return p.waktuPresensi.year == today.year &&
          p.waktuPresensi.month == today.month &&
          p.waktuPresensi.day == today.day &&
          myMhs.any((m) => m.nim == p.nim);
    }).toList();

    final hadirCount = allPresensiToday.where((p) => p.statusPresensi == StatusPresensi.hadir).length;
    final izinCount = allPresensiToday.where((p) => p.statusPresensi == StatusPresensi.izin).length;
    final belumCount = myMhs.length -
        allPresensiToday.where((p) => p.statusPresensi != StatusPresensi.belum).toSet().length;
    final persen = myMhs.isEmpty ? 0.0 : (hadirCount / myMhs.length * 100);

    final recentPresensi = allPresensiToday.take(8).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF1976D2),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Assalamu'alaikum,",
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
                    Text(_namaMusyrif,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('Musyrif · ${myMhs.length} Mahasantri',
                        style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      StatCard(label: 'Total Mahasantri', value: '${myMhs.length}', color: const Color(0xFF1976D2), icon: Icons.group),
                      StatCard(label: 'Hadir Hari Ini', value: '$hadirCount', color: AppTheme.statusHadir, icon: Icons.check_circle),
                      StatCard(label: 'Izin Hari Ini', value: '$izinCount', color: AppTheme.statusIzin, icon: Icons.info),
                      StatCard(label: 'Belum Presensi', value: '$belumCount', color: AppTheme.statusBelum, icon: Icons.schedule),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Persentase
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Persentase Kehadiran',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              Text('${persen.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: persen / 100,
                              minHeight: 10,
                              backgroundColor: Colors.grey[200],
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SectionTitle(
                    title: 'Presensi Terbaru',
                    actionLabel: 'Lihat Semua',
                    onAction: () => setState(() => _currentIndex = 1),
                  ),
                  ...recentPresensi.map((p) {
                    final mhs = MockData.getMahasantriByNim(p.nim);
                    final jadwal = MockData.getJadwalById(p.idJadwal);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primary.withOpacity(0.1),
                          child: Text(mhs?.nama.substring(0, 1) ?? '?',
                              style: const TextStyle(
                                  color: AppTheme.primary, fontWeight: FontWeight.w700)),
                        ),
                        title: Text(mhs?.nama ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text('${mhs?.kamar ?? '-'} · ${jadwal?.namaSholat ?? '-'}',
                            style: const TextStyle(fontSize: 12)),
                        trailing: StatusBadgePresensi(status: p.statusPresensi, small: true),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfil() {
    final musyrif = MockData.getMusyrifById(_idMusyrif);
    return Scaffold(
      appBar: const GeoAppBar(title: 'Profil', showBack: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF1976D2),
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.supervisor_account, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(musyrif?.nama ?? '-',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(_user.username,
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                      Text('Musyrif',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.phone_outlined, color: Color(0xFF1976D2)),
              title: const Text('No. Telepon', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              subtitle: Text(musyrif?.noTelepon ?? '-',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            ListTile(
              leading: const Icon(Icons.group, color: Color(0xFF1976D2)),
              title: const Text('Jumlah Mahasantri', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              subtitle: Text('${MockData.getMahasantriByMusyrif(_idMusyrif).length} mahasantri',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Keluar', style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pushReplacementNamed(context, '/'),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MONITORING TAB
// ══════════════════════════════════════════════════════════════════════════════
class _MonitoringTab extends StatefulWidget {
  final String idMusyrif;
  const _MonitoringTab({required this.idMusyrif});

  @override
  State<_MonitoringTab> createState() => _MonitoringTabState();
}

class _MonitoringTabState extends State<_MonitoringTab> {
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
                                backgroundColor: AppTheme.primary.withOpacity(0.1),
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

// ══════════════════════════════════════════════════════════════════════════════
// IZIN MUSYRIF TAB
// ══════════════════════════════════════════════════════════════════════════════
class _IzinMusyrifTab extends StatefulWidget {
  final String idMusyrif;
  const _IzinMusyrifTab({required this.idMusyrif});

  @override
  State<_IzinMusyrifTab> createState() => _IzinMusyrifTabState();
}

class _IzinMusyrifTabState extends State<_IzinMusyrifTab> {
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
                                    backgroundColor: AppTheme.primary.withOpacity(0.1),
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

// ══════════════════════════════════════════════════════════════════════════════
// REKAP TAB
// ══════════════════════════════════════════════════════════════════════════════
class _RekapTab extends StatefulWidget {
  final String idMusyrif;
  const _RekapTab({required this.idMusyrif});

  @override
  State<_RekapTab> createState() => _RekapTabState();
}

class _RekapTabState extends State<_RekapTab> {
  String _filterSholat = 'Semua';

  @override
  Widget build(BuildContext context) {
    final myMhs = MockData.getMahasantriByMusyrif(widget.idMusyrif);

    Map<String, Map<String, int>> rekapPerMhs = {};
    for (final m in myMhs) {
      var presensiMhs = MockData.getPresensiByNim(m.nim);
      if (_filterSholat != 'Semua') {
        final jadwal = MockData.jadwalSholat.firstWhere((j) => j.namaSholat == _filterSholat);
        presensiMhs = presensiMhs.where((p) => p.idJadwal == jadwal.idJadwal).toList();
      }
      rekapPerMhs[m.nim] = {
        'hadir': presensiMhs.where((p) => p.statusPresensi == StatusPresensi.hadir).length,
        'izin': presensiMhs.where((p) => p.statusPresensi == StatusPresensi.izin).length,
        'tidakHadir': presensiMhs.where((p) => p.statusPresensi == StatusPresensi.tidakHadir).length,
        'total': presensiMhs.length,
      };
    }

    final totalHadir = rekapPerMhs.values.fold(0, (s, m) => s + (m['hadir'] ?? 0));
    final totalIzin = rekapPerMhs.values.fold(0, (s, m) => s + (m['izin'] ?? 0));
    final totalTidakHadir = rekapPerMhs.values.fold(0, (s, m) => s + (m['tidakHadir'] ?? 0));
    final totalSemua = totalHadir + totalIzin + totalTidakHadir;
    final persen = totalSemua == 0 ? 0.0 : (totalHadir / totalSemua * 100);

    return Scaffold(
      appBar: const GeoAppBar(title: 'Rekap Presensi', showBack: false),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Semua', 'Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'].map((s) {
                  final sel = _filterSholat == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterSholat = s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.primary : Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: sel ? AppTheme.primary : Colors.grey[300]!),
                        ),
                        child: Text(s,
                            style: TextStyle(
                                fontSize: 12,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Summary Stats
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      StatCard(label: 'Total Presensi', value: '$totalSemua', color: const Color(0xFF1976D2), icon: Icons.list_alt),
                      StatCard(label: 'Hadir', value: '$totalHadir', color: AppTheme.statusHadir, icon: Icons.check_circle),
                      StatCard(label: 'Izin', value: '$totalIzin', color: AppTheme.statusIzin, icon: Icons.info),
                      StatCard(label: 'Tidak Hadir', value: '$totalTidakHadir', color: AppTheme.statusTidakHadir, icon: Icons.cancel),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress bar overall
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Persentase Kehadiran',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              Text('${persen.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: persen / 100,
                              minHeight: 10,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _LegendDot(color: AppTheme.statusHadir, label: 'Hadir'),
                              _LegendDot(color: AppTheme.statusIzin, label: 'Izin'),
                              _LegendDot(color: AppTheme.statusTidakHadir, label: 'Tidak Hadir'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Per-mahasantri table
                  const SectionTitle(title: 'Rekap Per Mahasantri'),
                  Card(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.05),
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                          ),
                          child: const Row(
                            children: [
                              Expanded(flex: 3, child: Text('Nama', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary))),
                              Expanded(child: Text('H', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.statusHadir))),
                              Expanded(child: Text('I', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.statusIzin))),
                              Expanded(child: Text('TH', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.statusTidakHadir))),
                              Expanded(child: Text('%', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary))),
                            ],
                          ),
                        ),
                        ...myMhs.map((m) {
                          final rek = rekapPerMhs[m.nim]!;
                          final total = rek['total']!;
                          final persenMhs = total == 0 ? 0.0 : (rek['hadir']! / total * 100);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: Colors.grey[200]!)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(m.nama, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                      Text(m.kamar, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                                    ],
                                  ),
                                ),
                                Expanded(child: Text('${rek['hadir']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.statusHadir))),
                                Expanded(child: Text('${rek['izin']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.statusIzin))),
                                Expanded(child: Text('${rek['tidakHadir']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.statusTidakHadir))),
                                Expanded(
                                  child: Text('${persenMhs.toStringAsFixed(0)}%',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: persenMhs >= 80 ? AppTheme.statusHadir : AppTheme.statusTidakHadir)),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
