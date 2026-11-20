import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/riwayat_provider.dart';

import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/pengajuan_screen.dart';
import 'screens/riwayat_screen.dart';
import 'screens/saldo_screen.dart';
import 'screens/rekapan_screen.dart';
import 'screens/laporan_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RiwayatProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/pengajuan': (context) => const PengajuanScreen(),
        '/riwayat': (context) => const RiwayatScreen(),
        '/saldo': (context) => const SaldoScreen(),
        '/rekapan': (context) => const RekapanScreen(),
        '/laporan': (context) => const LaporanScreen(),
      },
    );
  }
}