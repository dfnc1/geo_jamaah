import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/mahasiswa/home_screen.dart';
import 'screens/musyrif/home_musyrif.dart';
import 'screens/admin/home_admin.dart';

void main() {
  runApp(const GeoJamaahApp());
}

class GeoJamaahApp extends StatelessWidget {
  const GeoJamaahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GEO-JAMAAH',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/mahasantri/home': (context) => const MahasantriHomeScreen(),
        '/musyrif/home': (context) => const MusyrifHomeScreen(),
        '/admin/home': (context) => const AdminHomeScreen(),
      },
    );
  }
}
