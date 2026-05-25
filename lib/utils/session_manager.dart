import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static final SessionManager instance = SessionManager._();
  SessionManager._();

  static const _kUserId = 'user_id';
  static const _kNama = 'nama';
  static const _kNoWa = 'no_wa';
  static const _kIsLoggedIn = 'is_logged_in';
  static const _kIsVerifiedWa = 'is_verified_wa';
  static const _kIsVerifiedBerkas = 'is_verified_berkas';
  static const _kIsProfilLengkap = 'is_profil_lengkap';

  Future<void> saveSession({
    required int userId,
    required String noWa,
    String? nama,
    bool isVerifiedWa = false,
    bool isVerifiedBerkas = false,
    bool isProfilLengkap = false,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kUserId, userId);
    await p.setString(_kNoWa, noWa);
    await p.setString(_kNama, nama ?? '');
    await p.setBool(_kIsLoggedIn, true);
    await p.setBool(_kIsVerifiedWa, isVerifiedWa);
    await p.setBool(_kIsVerifiedBerkas, isVerifiedBerkas);
    await p.setBool(_kIsProfilLengkap, isProfilLengkap);
  }

  Future<void> updateSession({
    String? nama,
    bool? isVerifiedWa,
    bool? isVerifiedBerkas,
    bool? isProfilLengkap,
  }) async {
    final p = await SharedPreferences.getInstance();
    if (nama != null) await p.setString(_kNama, nama);
    if (isVerifiedWa != null) await p.setBool(_kIsVerifiedWa, isVerifiedWa);
    if (isVerifiedBerkas != null) {
      await p.setBool(_kIsVerifiedBerkas, isVerifiedBerkas);
    }
    if (isProfilLengkap != null) {
      await p.setBool(_kIsProfilLengkap, isProfilLengkap);
    }
  }

  Future<bool> isLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kIsLoggedIn) ?? false;
  }

  Future<int?> getUserId() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_kUserId);
  }

  Future<String?> getNoWa() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kNoWa);
  }

  Future<String?> getNama() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_kNama);
  }

  Future<bool> isVerifiedWa() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kIsVerifiedWa) ?? false;
  }

  Future<bool> isVerifiedBerkas() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kIsVerifiedBerkas) ?? false;
  }

  Future<bool> isProfilLengkap() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_kIsProfilLengkap) ?? false;
  }

  Future<void> clearSession() async {
    final p = await SharedPreferences.getInstance();
    await p.clear();
  }
}
