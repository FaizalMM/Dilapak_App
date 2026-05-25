import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../utils/session_manager.dart';
import '../services/notification_service.dart';
import 'verifikasi_berkas_screen.dart';

class VerifikasiWhatsappScreen extends StatefulWidget {
  const VerifikasiWhatsappScreen({super.key});

  @override
  State<VerifikasiWhatsappScreen> createState() =>
      _VerifikasiWhatsappScreenState();
}

class _VerifikasiWhatsappScreenState extends State<VerifikasiWhatsappScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _kodeDikirim = false;
  int _countdown = 59;
  bool _isLoading = false;
  bool _isSendingCode = false;

  String? _noWaTampil;
  String? _kodeVerifikasi;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _initNotifikasi();
  }

  Future<void> _initNotifikasi() async {
    await NotificationService.instance.init();
    await NotificationService.instance.requestPermission();
  }

  Future<void> _loadUser() async {
    final userId = await SessionManager.instance.getUserId();
    if (userId == null) return;
    final user = await DatabaseHelper.instance.getUserById(userId);
    if (mounted && user != null) {
      setState(() {
        _noWaTampil = user['no_whatsapp']?.toString() ?? '-';
        _kodeVerifikasi = user['kode_verifikasi']?.toString();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _otpControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // ── Kirim kode via NOTIFIKASI LOKAL ──
  Future<void> _kirimKode() async {
    if (_kodeVerifikasi == null || _noWaTampil == null) return;
    if (_isSendingCode) return;

    setState(() => _isSendingCode = true);

    try {
      // Kirim notifikasi lokal ke status bar HP
      await NotificationService.instance.kirimNotifikasiOTP(
        noWa: _noWaTampil!,
        kode: _kodeVerifikasi!,
      );

      if (mounted) {
        setState(() {
          _kodeDikirim = true;
          _countdown = 59;
          _isSendingCode = false;
        });
        _startCountdown();

        // Tampilkan snackbar konfirmasi bahwa notifikasi sudah dikirim
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.notifications_active_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Kode verifikasi telah dikirim ke notifikasi HP Anda.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.dilapakTeal,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSendingCode = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal mengirim notifikasi. Pastikan izin notifikasi diaktifkan.',
              style: GoogleFonts.plusJakartaSans(fontSize: 13),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() => _countdown--);
        _startCountdown();
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  bool get _otpLengkap => _otpControllers.every((c) => c.text.isNotEmpty);
  String get _kodeInput => _otpControllers.map((c) => c.text).join();

  Future<void> _verifikasi() async {
    setState(() => _isLoading = true);

    final userId = await SessionManager.instance.getUserId();
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final user = await DatabaseHelper.instance.getUserById(userId);
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final kodeBenar = user['kode_verifikasi']?.toString();

    if (_kodeInput == kodeBenar) {
      // Update status verifikasi WA di SQLite
      await DatabaseHelper.instance.updateUser(userId, {'is_verified_wa': 1});
      await SessionManager.instance.updateSession(isVerifiedWa: true);

      // Hapus notifikasi OTP dari status bar setelah berhasil
      await NotificationService.instance.hapusNotifikasiOTP();

      // Simpan notifikasi ke tabel SQLite
      await DatabaseHelper.instance.insertNotifikasi({
        'user_id': userId,
        'judul': 'Nomor HP Terverifikasi',
        'isi': 'Nomor HP Anda telah berhasil diverifikasi. '
            'Lanjutkan upload berkas identitas untuk aktivasi penuh.',
        'tipe': 'sukses',
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const VerifikasiBerkasScreen()),
        );
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
        // Goyangkan kotak OTP (feedback visual)
        _clearOtp();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kode verifikasi salah. Coba lagi.',
                style: GoogleFonts.plusJakartaSans(fontSize: 13)),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _clearOtp() {
    for (final c in _otpControllers) c.clear();
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  // ─── BUILD — DESAIN ASLI TIDAK DIUBAH SAMA SEKALI ───
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Langkah Terakhir',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Keamanan akun Anda adalah prioritas kami. Silakan verifikasi nomor HP Anda untuk melanjutkan.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            _VerifCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.dilapakTeal.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notifications_outlined,
                            color: AppColors.dilapakTeal, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Verifikasi Nomor HP',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                          Text('Kode dikirim via notifikasi HP',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'NOMOR TERDAFTAR',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_outlined,
                            color: AppColors.textSecondary, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          _noWaTampil ?? '...',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Petunjuk notifikasi
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dilapakTeal.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.dilapakTeal.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.dilapakTeal, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kode OTP akan muncul di notifikasi HP Anda. '
                            'Turunkan status bar untuk melihatnya.',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: AppColors.dilapakTeal,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tombol kirim kode
                  GestureDetector(
                    onTap: _isSendingCode ? null : _kirimKode,
                    child: AnimatedOpacity(
                      opacity: _isSendingCode ? 0.6 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.dilapakTeal,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.dilapakTeal.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isSendingCode
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.notifications_active_rounded,
                                    color: AppColors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _isSendingCode
                                  ? 'Mengirim...'
                                  : 'Kirim kode verifikasi',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'KODE VERIFIKASI (6 DIGIT)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _OtpInput(
                    controllers: _otpControllers,
                    focusNodes: _focusNodes,
                    onChanged: _onOtpChanged,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Belum terima notifikasi?',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 12, color: AppColors.textSecondary)),
                      GestureDetector(
                        onTap: (_countdown == 0 && !_isSendingCode)
                            ? _kirimKode
                            : null,
                        child: Text(
                          _countdown > 0
                              ? 'Kirim ulang (0:${_countdown.toString().padLeft(2, '0')})'
                              : 'Kirim ulang',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _countdown > 0
                                ? AppColors.textMuted
                                : AppColors.dilapakTeal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Tombol verifikasi utama
            GestureDetector(
              onTap: (_otpLengkap && _kodeDikirim && !_isLoading)
                  ? _verifikasi
                  : null,
              child: AnimatedOpacity(
                opacity: (_otpLengkap && _kodeDikirim) ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.dilapakTeal,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dilapakTeal.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: AppColors.white, strokeWidth: 2.5))
                        : Text('Verifikasi Sekarang',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        color: AppColors.white,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.textPrimary, size: 22),
                ),
                Text('Verifikasi Akun',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── WIDGET DESAIN ASLI SAMA PERSIS ───

class _OtpInput extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(String value, int index) onChanged;

  const _OtpInput({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (i) {
        final filled = controllers[i].text.isNotEmpty;
        return Container(
          width: 44,
          height: 52,
          decoration: BoxDecoration(
            color: filled
                ? AppColors.dilapakTeal.withOpacity(0.08)
                : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: filled ? AppColors.dilapakTeal : AppColors.borderColor,
              width: filled ? 1.5 : 1,
            ),
          ),
          child: Center(
            child: TextField(
              controller: controllers[i],
              focusNode: focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              obscureText: true,
              obscuringCharacter: '●',
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dilapakTeal),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) => onChanged(val, i),
            ),
          ),
        );
      }),
    );
  }
}

class _VerifCard extends StatelessWidget {
  final Widget child;
  const _VerifCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}
