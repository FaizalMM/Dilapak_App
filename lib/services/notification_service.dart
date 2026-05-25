import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    // Pengaturan Android
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Pengaturan iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  /// Minta izin notifikasi (Android 13+)
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    return true; // iOS sudah diminta saat init
  }

  /// Kirim notifikasi OTP ke status bar HP
  Future<void> kirimNotifikasiOTP({
    required String noWa,
    required String kode,
  }) async {
    await init();

    // Sembunyikan sebagian nomor: 0812****5678
    final nomorSensor = _sensorNomor(noWa);

    const androidDetails = AndroidNotificationDetails(
      'otp_channel', // channel id
      'Verifikasi OTP', // channel name
      channelDescription: 'Notifikasi kode verifikasi akun Dilapak',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Kode Verifikasi Dilapak',
      styleInformation: BigTextStyleInformation(''),
      playSound: true,
      enableVibration: true,
      autoCancel: false, // tidak hilang saat disentuh agar user bisa catat
      ongoing: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      1001, // notification id
      'Kode Verifikasi Dilapak', // judul
      'Kode OTP untuk $nomorSensor adalah: $kode\n'
          'Berlaku 5 menit. Jangan berikan kode ini kepada siapapun.',
      details,
    );
  }

  /// Hapus notifikasi OTP setelah berhasil diverifikasi
  Future<void> hapusNotifikasiOTP() async {
    await _plugin.cancel(1001);
  }

  String _sensorNomor(String nomor) {
    if (nomor.length < 8) return nomor;
    final awal = nomor.substring(0, 4);
    final akhir = nomor.substring(nomor.length - 4);
    final bintang = '*' * (nomor.length - 8);
    return '$awal$bintang$akhir';
  }
}
