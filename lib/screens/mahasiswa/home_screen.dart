import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/pengguna.dart';
import '../../models/presensi.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'izin_screen.dart';
import 'presensi_screen.dart';
import 'riwayat_screen.dart';

class MahasantriHomeScreen extends StatefulWidget {
  const MahasantriHomeScreen({super.key});

  @override
  State<MahasantriHomeScreen> createState() => _MahasantriHomeScreenState();
}

class _MahasantriHomeScreenState extends State<MahasantriHomeScreen> {
  int _currentIndex = 0;
  late Pengguna _user;
  bool _userLoaded = false;

  final List<String> _sholatOrder = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_userLoaded) {
      _user = ModalRoute.of(context)!.settings.arguments as Pengguna;
      _userLoaded = true;
    }
  }

  String get _nim {
    final m = MockData.getMahasantriByPenggunaId(_user.idPengguna);
    return m?.nim ?? '';
  }

  String get _namaUser {
    final m = MockData.getMahasantriByPenggunaId(_user.idPengguna);
    return m?.nama ?? _user.username;
  }

  StatusPresensi _getStatusToday(String namaSholat) {
    final jadwal = MockData.jadwalSholat.firstWhere((j) => j.namaSholat == namaSholat);
    final today = DateTime.now();
    try {
      final p = MockData.presensi.firstWhere(
        (p) =>
            p.nim == _nim &&
            p.idJadwal == jadwal.idJadwal &&
            p.waktuPresensi.year == today.year &&
            p.waktuPresensi.month == today.month &&
            p.waktuPresensi.day == today.day,
      );
      return p.statusPresensi;
    } catch (_) {
      return StatusPresensi.belum;
    }
  }

  String _nextSholat() {
    final now = TimeOfDay.now();
    for (final j in MockData.jadwalSholat) {
      final parts = j.waktuAzan.split(':');
      final t = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      if (t.hour > now.hour || (t.hour == now.hour && t.minute > now.minute)) {
        return j.namaSholat;
      }
    }
    return 'Subuh';
  }

  String _nextSholatTime() {
    final name = _nextSholat();
    return MockData.jadwalSholat.firstWhere((j) => j.namaSholat == name).waktuAzan;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      PresensiScreen(nim: _nim, onPresensiSuccess: () => setState(() {})),
      IzinScreen(
          nim: _nim,
          idMusyrif: MockData.getMahasantriByPenggunaId(_user.idPengguna)?.idMusyrif ?? 'M001'),
      RiwayatScreen(nim: _nim),
      _buildProfilPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.fingerprint), label: 'Presensi'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), activeIcon: Icon(Icons.event_note), label: 'Izin'),
          BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.primary,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryDark, AppTheme.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Assalamu'alaikum,",
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(_namaUser,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
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
                  // Next Sholat Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Shalat Berikutnya',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                              const SizedBox(height: 4),
                              Text(_nextSholat(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, color: Colors.white70, size: 14),
                                  const SizedBox(width: 4),
                                  Text(_nextSholatTime(),
                                      style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              GestureDetector(
                                onTap: () => setState(() => _currentIndex = 1),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text('Presensi Sekarang',
                                      style: TextStyle(
                                          color: AppTheme.primary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.mosque, color: Colors.white24, size: 70),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Presensi Hari Ini
                  const SectionTitle(title: 'Presensi Hari Ini'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: _sholatOrder.map((nama) {
                          final status = _getStatusToday(nama);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.mosque, color: AppTheme.primary, size: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                    child: Text(nama,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: 14))),
                                StatusBadgePresensi(status: status, small: true),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Jadwal Sholat
                  const SectionTitle(title: 'Jadwal Sholat Hari Ini'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: MockData.jadwalSholat
                            .map((j) => Column(
                                  children: [
                                    Text(j.namaSholat,
                                        style: const TextStyle(
                                            fontSize: 11, color: AppTheme.textSecondary)),
                                    const SizedBox(height: 4),
                                    Text(j.waktuAzan,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primary)),
                                  ],
                                ))
                            .toList(),
                      ),
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

  Widget _buildProfilPage() {
    final mhs = MockData.getMahasantriByPenggunaId(_user.idPengguna);
    final musyrif = mhs != null ? MockData.getMusyrifById(mhs.idMusyrif) : null;
    return Scaffold(
      appBar: const GeoAppBar(title: 'Profil', showBack: false),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppTheme.primary,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(Icons.person, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mhs?.nama ?? '-',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                      Text(mhs?.nim ?? '-',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                      Text('Mahasantri',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _ProfileTile(icon: Icons.bed_outlined, label: 'Kamar', value: mhs?.kamar ?? '-'),
            _ProfileTile(
                icon: Icons.supervisor_account_outlined,
                label: 'Musyrif',
                value: musyrif?.nama ?? '-'),
            _ProfileTile(
                icon: Icons.phone_outlined,
                label: 'No. Musyrif',
                value: musyrif?.noTelepon ?? '-'),
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

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProfileTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(label,
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      subtitle: Text(value,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
    );
  }
}
