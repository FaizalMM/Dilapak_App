import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' as io;
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

void _initializeDatabase() {
  // Inisialisasi SQLite untuk Windows/Linux/Mac menggunakan FFI
  if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
    // FFI initialization dilakukan di sini jika diperlukan
    // Note: sqflite sudah handle platform-specific initialization
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database
  _initializeDatabase();

  // Inisialisasi notifikasi lokal saat app pertama dibuka
  await NotificationService.instance.init();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const DilapakApp());
}

class DilapakApp extends StatelessWidget {
  const DilapakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dilapak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
