import 'package:flutter/material.dart';
import '../models/presensi.dart';
import '../models/izin.dart';
import '../theme/app_theme.dart';

class StatusBadgePresensi extends StatelessWidget {
  final StatusPresensi status;
  final bool small;

  const StatusBadgePresensi({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      StatusPresensi.hadir      => ('Hadir',          AppTheme.statusHadir,      Icons.check_circle),
      StatusPresensi.tidakHadir => ('Tidak Hadir',    AppTheme.statusTidakHadir, Icons.cancel),
      StatusPresensi.izin       => ('Izin',           AppTheme.statusIzin,       Icons.info),
      StatusPresensi.belum      => ('Belum Presensi', AppTheme.statusBelum,      Icons.access_time),
      StatusPresensi.manual     => ('Manual',         AppTheme.statusManual,     Icons.edit),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: small ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 11 : 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: small ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusBadgeIzin extends StatelessWidget {
  final StatusPersetujuan status;
  final bool small;

  const StatusBadgeIzin({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      StatusPersetujuan.pending    => ('Pending',    AppTheme.statusPending,    Icons.schedule),
      StatusPersetujuan.disetujui  => ('Disetujui',  AppTheme.statusDisetujui,  Icons.check_circle),
      StatusPersetujuan.ditolak    => ('Ditolak',    AppTheme.statusDitolak,    Icons.cancel),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 8 : 10, vertical: small ? 3 : 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 11 : 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: small ? 10 : 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionTitle({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel!, style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const StatCard({super.key, required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class GeoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const GeoAppBar({super.key, required this.title, this.actions, this.showBack = true});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: showBack,
      actions: actions,
    );
  }
}
