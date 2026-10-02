import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/pengguna.dart';
import '../../models/presensi.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  bool _userLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_userLoaded) {
      // ignore: unused_local_variable
      final _ = ModalRoute.of(context)!.settings.arguments as Pengguna;
      _userLoaded = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboard(),
      _AdminMahasantriTab(),
      _AdminMusyrifTab(),
      _AdminJadwalTab(),
      _buildPengaturan(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), activeIcon: Icon(Icons.school), label: 'Mahasantri'),
          BottomNavigationBarItem(icon: Icon(Icons.supervisor_account_outlined), activeIcon: Icon(Icons.supervisor_account), label: 'Musyrif'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule_outlined), activeIcon: Icon(Icons.schedule), label: 'Jadwal'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Pengaturan'),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final totalMhs = MockData.mahasantri.length;
    final totalMusyrif = MockData.musyrif.length;
    final totalPresensi = MockData.presensi.length;
    final totalIzin = MockData.izin.length;
    final hadirPersen = totalPresensi == 0
        ? 0.0
        : MockData.presensi.where((p) => p.statusPresensi == StatusPresensi.hadir).length /
            totalPresensi *
            100;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: const Color(0xFF7B1FA2),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
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
                    const Text('Administrator',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('GEO-JAMAAH Admin Panel',
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
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      StatCard(label: 'Total Mahasantri', value: '$totalMhs', color: AppTheme.primary, icon: Icons.school),
                      StatCard(label: 'Total Musyrif', value: '$totalMusyrif', color: const Color(0xFF1976D2), icon: Icons.supervisor_account),
                      StatCard(label: 'Total Presensi', value: '$totalPresensi', color: AppTheme.statusHadir, icon: Icons.check_circle),
                      StatCard(label: 'Total Izin', value: '$totalIzin', color: AppTheme.statusIzin, icon: Icons.info),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Kehadiran Global',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                              Text('${hadirPersen.toStringAsFixed(1)}%',
                                  style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: hadirPersen / 100,
                              minHeight: 10,
                              backgroundColor: Colors.grey[200],
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const SectionTitle(title: 'Menu Admin'),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _AdminMenuCard(icon: Icons.school, label: 'Data Mahasantri', color: AppTheme.primary, onTap: () => setState(() => _currentIndex = 1)),
                      _AdminMenuCard(icon: Icons.supervisor_account, label: 'Data Musyrif', color: const Color(0xFF1976D2), onTap: () => setState(() => _currentIndex = 2)),
                      _AdminMenuCard(icon: Icons.schedule, label: 'Jadwal Sholat', color: AppTheme.statusBelum, onTap: () => setState(() => _currentIndex = 3)),
                      _AdminMenuCard(icon: Icons.mosque, label: 'Data Masjid', color: AppTheme.statusHadir, onTap: () => _showMasjidDialog()),
                      _AdminMenuCard(icon: Icons.bar_chart, label: 'Rekap Global', color: const Color(0xFF7B1FA2), onTap: () => _showRekapDialog()),
                      _AdminMenuCard(icon: Icons.description, label: 'Laporan', color: AppTheme.statusTidakHadir, onTap: () => _showLaporanDialog()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMasjidDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Data Masjid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow('Nama', MockData.masjid.namaMasjid),
            _InfoRow('Latitude', MockData.masjid.latitude.toString()),
            _InfoRow('Longitude', MockData.masjid.longitude.toString()),
            _InfoRow('Radius', '${MockData.masjid.radiusToleransi.toInt()} meter'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
      ),
    );
  }

  void _showRekapDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rekap Global'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow('Total Mahasantri', '${MockData.mahasantri.length}'),
            _InfoRow('Total Presensi', '${MockData.presensi.length}'),
            _InfoRow('Hadir', '${MockData.presensi.where((p) => p.statusPresensi == StatusPresensi.hadir).length}'),
            _InfoRow('Izin', '${MockData.presensi.where((p) => p.statusPresensi == StatusPresensi.izin).length}'),
            _InfoRow('Tidak Hadir', '${MockData.presensi.where((p) => p.statusPresensi == StatusPresensi.tidakHadir).length}'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup'))],
      ),
    );
  }

  void _showLaporanDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fitur ekspor laporan tidak tersedia pada prototype')));
  }

  Widget _buildPengaturan() {
    return Scaffold(
      appBar: const GeoAppBar(title: 'Pengaturan', showBack: false),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF7B1FA2),
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Administrator', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    Text('admin', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text('Admin Panel', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _SettingTile(icon: Icons.mosque, title: 'Data Masjid', onTap: _showMasjidDialog),
          _SettingTile(icon: Icons.bar_chart, title: 'Rekap Global', onTap: _showRekapDialog),
          _SettingTile(icon: Icons.description, title: 'Ekspor Laporan', onTap: _showLaporanDialog),
          const Divider(height: 24),
          _SettingTile(
            icon: Icons.logout,
            title: 'Keluar',
            color: Colors.red,
            onTap: () => Navigator.pushReplacementNamed(context, '/'),
          ),
        ],
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AdminMenuCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
          Text(': ', style: const TextStyle(color: AppTheme.textSecondary)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  const _SettingTile({required this.icon, required this.title, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? const Color(0xFF7B1FA2)),
      title: Text(title, style: TextStyle(color: color ?? AppTheme.textPrimary, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textLight),
      onTap: onTap,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ADMIN MAHASANTRI TAB
// ══════════════════════════════════════════════════════════════════════════════
class _AdminMahasantriTab extends StatelessWidget {
  const _AdminMahasantriTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeoAppBar(
        title: 'Data Mahasantri',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tambah mahasantri tidak tersedia pada prototype'))),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.mahasantri.length,
        itemBuilder: (context, i) {
          final m = MockData.mahasantri[i];
          final musyrif = MockData.getMusyrifById(m.idMusyrif);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primary.withOpacity(0.1),
                child: Text(m.nama.substring(0, 1),
                    style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
              ),
              title: Text(m.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${m.nim} · Kamar ${m.kamar}\nMusyrif: ${musyrif?.nama ?? '-'}',
                  style: const TextStyle(fontSize: 12)),
              isThreeLine: true,
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: m.statusAktif ? AppTheme.statusHadir.withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(m.statusAktif ? 'Aktif' : 'Nonaktif',
                    style: TextStyle(fontSize: 11, color: m.statusAktif ? AppTheme.statusHadir : Colors.grey, fontWeight: FontWeight.w600)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ADMIN MUSYRIF TAB
// ══════════════════════════════════════════════════════════════════════════════
class _AdminMusyrifTab extends StatelessWidget {
  const _AdminMusyrifTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GeoAppBar(
        title: 'Data Musyrif',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tambah musyrif tidak tersedia pada prototype'))),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.musyrif.length,
        itemBuilder: (context, i) {
          final m = MockData.musyrif[i];
          final jumlahMhs = MockData.getMahasantriByMusyrif(m.idMusyrif).length;
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1976D2).withOpacity(0.1),
                child: Text(m.nama.substring(4, 5),
                    style: const TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.w700)),
              ),
              title: Text(m.nama, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${m.noTelepon}\n$jumlahMhs mahasantri',
                  style: const TextStyle(fontSize: 12)),
              isThreeLine: true,
              trailing: const Icon(Icons.chevron_right, color: AppTheme.textLight),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ADMIN JADWAL TAB
// ══════════════════════════════════════════════════════════════════════════════
class _AdminJadwalTab extends StatelessWidget {
  const _AdminJadwalTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GeoAppBar(title: 'Jadwal Sholat', showBack: false),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: MockData.jadwalSholat.length,
        itemBuilder: (context, i) {
          final j = MockData.jadwalSholat[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.mosque, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(j.namaSholat,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _JadwalBadge(label: 'Azan', value: j.waktuAzan),
                            const SizedBox(width: 8),
                            _JadwalBadge(label: 'Iqamah', value: j.waktuIqamah),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Presensi: ${j.waktuMulaiPresensi} – ${j.waktuAkhirPresensi}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppTheme.textSecondary),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit jadwal tidak tersedia pada prototype'))),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _JadwalBadge extends StatelessWidget {
  final String label;
  final String value;
  const _JadwalBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text('$label $value',
          style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
    );
  }
}
