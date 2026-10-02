import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/pengguna.dart';
import '../../models/presensi.dart';
import '../../theme/app_theme.dart';
import '../../utils/dss_helper.dart';
import '../../widgets/common_widgets.dart';
import 'izin_musyrif_screen.dart';
import 'monitoring_screen.dart';

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
      MonitoringScreen(idMusyrif: _idMusyrif),
      IzinMusyrifScreen(idMusyrif: _idMusyrif),
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
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                    Text(_namaMusyrif,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('Musyrif · ${myMhs.length} Mahasantri',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
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

                  // ── EWS Card ───────────────────────────────────────────
                  _EwsCard(idMusyrif: _idMusyrif),
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
                          backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
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
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
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
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                      Text('Musyrif',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
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
// REKAP TAB (tetap di home_musyrif karena bergantung pada _currentIndex)
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
                            color: AppTheme.primary.withValues(alpha: 0.05),
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

// ══════════════════════════════════════════════════════════════════════════════
// EWS CARD — Early Warning System
// ══════════════════════════════════════════════════════════════════════════════

/// Kartu EWS yang menampilkan daftar mahasantri berisiko.
/// Mendeteksi: kehadiran < 75% atau mangkir berturut-turut ≥ 3×.
class _EwsCard extends StatelessWidget {
  final String idMusyrif;

  const _EwsCard({required this.idMusyrif});

  static const Color _colorKritis = Color(0xFFB71C1C);
  static const Color _colorPerhatian = Color(0xFFE65100);

  Color _badgeColor(HasilDss h) {
    if (h.risikoKehadiran && h.risikoMangkirBerturut) return _colorKritis;
    return _colorPerhatian;
  }

  void _showPanggilDialog(BuildContext context, HasilDss h) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.campaign_outlined, color: AppTheme.primary),
            SizedBox(width: 8),
            Text('Panggil Pembinaan', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(h.mahasantri.nama,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 4),
            Text('Kamar ${h.mahasantri.kamar}',
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            const SizedBox(height: 12),
            _DialogInfoRow(
              icon: Icons.bar_chart,
              label: 'Kehadiran',
              value: '${h.persenKehadiran.toStringAsFixed(0)}%',
              valueColor:
                  h.risikoKehadiran ? _colorKritis : AppTheme.statusHadir,
            ),
            const SizedBox(height: 6),
            _DialogInfoRow(
              icon: Icons.warning_amber_rounded,
              label: 'Mangkir berturut',
              value: '${h.mangkirBerturut}×',
              valueColor:
                  h.risikoMangkirBerturut ? _colorKritis : AppTheme.statusHadir,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _colorPerhatian.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⚠️ ${h.deskripsiRisiko}',
                style: const TextStyle(fontSize: 12, color: _colorPerhatian),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '✅ Panggilan pembinaan untuk ${h.mahasantri.nama} tercatat.'),
                  backgroundColor: AppTheme.statusHadir,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Konfirmasi Panggil'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final berisiko = DssHelper.filterBerisiko(idMusyrif);

    if (berisiko.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.statusHadir.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield_outlined,
                    color: AppTheme.statusHadir, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Early Warning System',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    SizedBox(height: 2),
                    Text('Semua mahasantri dalam kondisi baik ✓',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header EWS ────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _colorKritis.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: _colorKritis, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⚠️ Early Warning System (EWS)',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      Text('${berisiko.length} mahasantri perlu perhatian',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),

            // ── List mahasantri berisiko ───────────────────────────────────
            ...berisiko.map(
              (h) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    // Avatar inisial
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          _badgeColor(h).withValues(alpha: 0.12),
                      child: Text(
                        h.mahasantri.nama.substring(0, 1),
                        style: TextStyle(
                            color: _badgeColor(h),
                            fontWeight: FontWeight.w700,
                            fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Nama + keterangan risiko
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.mahasantri.nama,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(h.deskripsiRisiko,
                              style: TextStyle(
                                  fontSize: 11, color: _badgeColor(h))),
                        ],
                      ),
                    ),
                    // Badge label risiko
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _badgeColor(h).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: _badgeColor(h).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        h.labelRisiko,
                        style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _badgeColor(h)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Tombol Panggil Pembinaan
                    SizedBox(
                      height: 30,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primary),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _showPanggilDialog(context, h),
                        child: const Text(
                          'Panggil',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _DialogInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
        ),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: valueColor)),
      ],
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
