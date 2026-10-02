import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/izin.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class IzinScreen extends StatefulWidget {
  final String nim;
  final String idMusyrif;

  const IzinScreen({
    super.key,
    required this.nim,
    required this.idMusyrif,
  });

  @override
  State<IzinScreen> createState() => _IzinScreenState();
}

class _IzinScreenState extends State<IzinScreen> {
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

    setState(() {
      MockData.izin.insert(0, Izin(
        idIzin: 'IZ${DateTime.now().millisecondsSinceEpoch}',
        nim: widget.nim,
        idMusyrif: widget.idMusyrif,
        jenisIzin: jenis,
        tanggalIzin: _selectedDate,
        alasan: _alasanController.text.trim(),
      ));
      _alasanController.clear();
    });

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
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
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
