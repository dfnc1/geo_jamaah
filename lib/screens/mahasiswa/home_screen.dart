import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/pengguna.dart';
import '../../models/presensi.dart';
import '../../models/izin.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

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
      _buildPresensiPage(),
      _buildIzinPage(),
      _buildRiwayatPage(),
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
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13)),
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
                            color: AppTheme.primary.withOpacity(0.3),
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
                                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
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
                                    color: AppTheme.primary.withOpacity(0.08),
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

  Widget _buildPresensiPage() => const _PresensiTab();

  Widget _buildIzinPage() {
    final mhs = MockData.getMahasantriByPenggunaId(_user.idPengguna);
    return _IzinTab(nim: _nim, idMusyrif: mhs?.idMusyrif ?? 'M001');
  }

  Widget _buildRiwayatPage() => _RiwayatTab(nim: _nim);

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
                    backgroundColor: Colors.white.withOpacity(0.2),
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
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                      Text('Mahasantri',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
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

// ══════════════════════════════════════════════════════════════════════════════
// PRESENSI TAB
// ══════════════════════════════════════════════════════════════════════════════
class _PresensiTab extends StatefulWidget {
  const _PresensiTab();

  @override
  State<_PresensiTab> createState() => _PresensiTabState();
}

class _PresensiTabState extends State<_PresensiTab> {
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
                          color: AppTheme.primary.withOpacity(0.1),
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
                              ? AppTheme.statusHadir.withOpacity(0.08)
                              : AppTheme.statusTidakHadir.withOpacity(0.08),
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

// ══════════════════════════════════════════════════════════════════════════════
// IZIN TAB
// ══════════════════════════════════════════════════════════════════════════════
class _IzinTab extends StatefulWidget {
  final String nim;
  final String idMusyrif;
  const _IzinTab({required this.nim, required this.idMusyrif});

  @override
  State<_IzinTab> createState() => _IzinTabState();
}

class _IzinTabState extends State<_IzinTab> {
  final _alasanController = TextEditingController();
  String _jenisIzin = 'Sakit';
  DateTime _selectedDate = DateTime.now();
  final _jenisOptions = ['Sakit', 'Pulang', 'Tugas Kampus'];

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  void _submitIzin() {
    if (_alasanController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Alasan tidak boleh kosong')));
      return;
    }
    final jenis = switch (_jenisIzin) {
      'Sakit' => JenisIzin.sakit,
      'Pulang' => JenisIzin.pulang,
      _ => JenisIzin.tugasKampus,
    };

    MockData.izin.add(Izin(
      idIzin: 'IZ${DateTime.now().millisecondsSinceEpoch}',
      nim: widget.nim,
      idMusyrif: widget.idMusyrif,
      jenisIzin: jenis,
      tanggalIzin: _selectedDate,
      alasan: _alasanController.text.trim(),
    ));

    setState(() => _alasanController.clear());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Izin berhasil diajukan!'),
        backgroundColor: AppTheme.statusHadir));
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (d != null) setState(() => _selectedDate = d);
  }

  @override
  Widget build(BuildContext context) {
    final myIzin = MockData.getIzinByNim(widget.nim);

    return Scaffold(
      appBar: const GeoAppBar(title: 'Pengajuan Izin', showBack: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Form Pengajuan Izin',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 16),

                    const Text('Jenis Izin',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: _jenisOptions.map((opt) {
                        final sel = _jenisIzin == opt;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _jenisIzin = opt),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: sel ? AppTheme.primary : Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: sel ? AppTheme.primary : Colors.grey[300]!),
                              ),
                              child: Text(opt,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: sel ? Colors.white : AppTheme.textPrimary)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    const Text('Tanggal Izin',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: AppTheme.primary),
                            const SizedBox(width: 10),
                            Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text('Alasan',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _alasanController,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(hintText: 'Tuliskan alasan izin...'),
                    ),
                    const SizedBox(height: 14),

                    GestureDetector(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Fitur upload tidak tersedia pada prototype'))),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_file, color: AppTheme.textSecondary),
                            SizedBox(width: 8),
                            Text('Upload Bukti Lampiran',
                                style: TextStyle(
                                    color: AppTheme.textSecondary, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _submitIzin,
                        icon: const Icon(Icons.send),
                        label: const Text('Ajukan Izin'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const SectionTitle(title: 'Riwayat Pengajuan Izin'),

            ...myIzin.map((izin) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: [
                              const Icon(Icons.event_note,
                                  color: AppTheme.primary, size: 16),
                              const SizedBox(width: 6),
                              Text(izin.jenisIzinLabel,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 14)),
                            ]),
                            StatusBadgeIzin(
                                status: izin.statusPersetujuan, small: true),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                            '${izin.tanggalIzin.day}/${izin.tanggalIzin.month}/${izin.tanggalIzin.year}',
                            style: const TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(height: 4),
                        Text(izin.alasan,
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// RIWAYAT TAB
// ══════════════════════════════════════════════════════════════════════════════
class _RiwayatTab extends StatefulWidget {
  final String nim;
  const _RiwayatTab({required this.nim});

  @override
  State<_RiwayatTab> createState() => _RiwayatTabState();
}

class _RiwayatTabState extends State<_RiwayatTab> {
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
                                  color: AppTheme.primary.withOpacity(0.1),
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
