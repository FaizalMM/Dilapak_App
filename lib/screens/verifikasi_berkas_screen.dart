import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../utils/session_manager.dart';
import 'home_screen.dart';

class VerifikasiBerkasScreen extends StatefulWidget {
  const VerifikasiBerkasScreen({super.key});

  @override
  State<VerifikasiBerkasScreen> createState() => _VerifikasiBerkasScreenState();
}

class _VerifikasiBerkasScreenState extends State<VerifikasiBerkasScreen> {
  File? _fileKTP;
  File? _fileSwafoto;
  bool _isLoading = false;

  final _picker = ImagePicker();

  bool get _ktpDipilih => _fileKTP != null;
  bool get _swafotoDiambil => _fileSwafoto != null;

  Future<void> _pilihKTP() async {
    final source = await _showSourceDialog('Foto KTP');
    if (source == null) return;
    final picked = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1920);
    if (picked != null && mounted) {
      setState(() => _fileKTP = File(picked.path));
    }
  }

  Future<void> _ambilSwafoto() async {
    final source = await _showSourceDialog('Swafoto dengan KTP');
    if (source == null) return;
    final picked = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1920);
    if (picked != null && mounted) {
      setState(() => _fileSwafoto = File(picked.path));
    }
  }

  Future<ImageSource?> _showSourceDialog(String judul) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(judul,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(context, ImageSource.camera),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                    color: AppColors.dilapakTeal,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Text('Buka Kamera',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.pop(context, ImageSource.gallery),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderColor)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_library_outlined,
                        color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 10),
                    Text('Pilih dari Galeri',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _kirimVerifikasi() async {
    setState(() => _isLoading = true);
    try {
      final userId = await SessionManager.instance.getUserId();
      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Update status utama ke SQLite (must await)
      await DatabaseHelper.instance.updateUser(userId, {
        'foto_ktp': _fileKTP!.path,
        'foto_swafoto': _fileSwafoto!.path,
        'is_verified_berkas': 1,
        'status_berkas': 'menunggu_review',
      });
      await SessionManager.instance.updateSession(isVerifiedBerkas: true);

      if (mounted) {
        setState(() => _isLoading = false);

        // Simpan entry berkas dan notifikasi di background (tidak perlu menunggu)
        unawaited(Future.microtask(() async {
          await DatabaseHelper.instance.insertBerkas({
            'user_id': userId,
            'nama_berkas': 'Foto KTP',
            'tipe_berkas': 'ktp',
            'path_file': _fileKTP!.path,
            'status': 'menunggu',
            'created_at': DateTime.now().toIso8601String(),
          });
          await DatabaseHelper.instance.insertBerkas({
            'user_id': userId,
            'nama_berkas': 'Swafoto dengan KTP',
            'tipe_berkas': 'swafoto',
            'path_file': _fileSwafoto!.path,
            'status': 'menunggu',
            'created_at': DateTime.now().toIso8601String(),
          });
          await DatabaseHelper.instance.insertNotifikasi({
            'user_id': userId,
            'judul': 'Berkas Dikirim untuk Verifikasi',
            'isi': 'KTP dan swafoto Anda sedang ditinjau. '
                'Lengkapi data profil untuk aktivasi penuh.',
            'tipe': 'info',
            'is_read': 0,
            'created_at': DateTime.now().toIso8601String(),
          });
        }));

        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal mengunggah berkas: $e',
              style: GoogleFonts.plusJakartaSans(fontSize: 13)),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    color: AppColors.dilapakTeal.withOpacity(0.12),
                    shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.dilapakTeal, size: 36),
              ),
              const SizedBox(height: 16),
              Text('Berkas Dikirim',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'Berkas verifikasi Anda sedang ditinjau. Proses ini memakan waktu 1x24 jam.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.6),
              ),
              const SizedBox(height: 24),
              // FIX: pakai pushAndRemoveUntil ke HomeScreen, bukan popUntil isFirst
              // agar tidak kembali ke login screen
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => const HomeScreen(),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                    (route) => false,
                  );
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                      color: AppColors.dilapakTeal,
                      borderRadius: BorderRadius.circular(12)),
                  child: Center(
                    child: Text('Kembali ke Beranda',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── BUILD — DESAIN ASLI TIDAK DIUBAH SAMA SEKALI ───
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoBanner(),
            const SizedBox(height: 24),
            Text('1. Foto KTP',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            if (_fileKTP != null) ...[
              _ImagePreview(file: _fileKTP!, onGanti: _pilihKTP),
              const SizedBox(height: 12),
            ] else
              _UploadBox(
                state: _UploadState.empty,
                icon: Icons.badge_outlined,
                label: 'Pilih File KTP',
                sublabel: 'Maksimal 5MB (JPG/PNG)',
                borderColor: AppColors.borderColor,
                accentColor: AppColors.dilapakTeal,
                onTap: _pilihKTP,
              ),
            const SizedBox(height: 24),
            Text('2. Swafoto (Selfie) dengan KTP',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            const _WarningBanner(
                text:
                    'Pastikan wajah Anda dan seluruh informasi KTP terlihat jelas'),
            const SizedBox(height: 10),
            if (_fileSwafoto != null) ...[
              _ImagePreview(file: _fileSwafoto!, onGanti: _ambilSwafoto),
              const SizedBox(height: 12),
            ] else
              _UploadBox(
                state: _UploadState.warning,
                icon: Icons.photo_camera_outlined,
                label: 'Ambil Swafoto',
                sublabel: 'Pencahayaan harus terang',
                borderColor: const Color(0xFFE87B2E),
                accentColor: const Color(0xFFE87B2E),
                onTap: _ambilSwafoto,
              ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: (_ktpDipilih && _swafotoDiambil) ? _kirimVerifikasi : null,
              child: AnimatedOpacity(
                opacity: (_ktpDipilih && _swafotoDiambil) ? 1.0 : 0.5,
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
                          offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: AppColors.white, strokeWidth: 2.5))
                        : Text('Kirim untuk Verifikasi',
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
                Text('Verifikasi Berkas',
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

// Widget preview gambar nyata
class _ImagePreview extends StatelessWidget {
  final File file;
  final VoidCallback onGanti;
  const _ImagePreview({required this.file, required this.onGanti});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(file,
              width: double.infinity, height: 200, fit: BoxFit.cover),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onGanti,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text('Ganti',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── WIDGET DESAIN ASLI SAMA PERSIS ───

class _InfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB3D9F7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFF2D7DD2), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Silakan unggah dokumen berikut untuk keperluan verifikasi pendaftaran layanan. Pastikan gambar jelas dan tidak terpotong.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: const Color(0xFF1A5080), height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String text;
  const _WarningBanner({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE87B2E).withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFE87B2E), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFB85D1A),
                    height: 1.5)),
          ),
        ],
      ),
    );
  }
}

enum _UploadState { empty, warning, selected }

class _UploadBox extends StatelessWidget {
  final _UploadState state;
  final IconData icon;
  final String label;
  final String sublabel;
  final Color borderColor;
  final Color accentColor;
  final VoidCallback onTap;

  const _UploadBox({
    required this.state,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.borderColor,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: state == _UploadState.selected
              ? accentColor.withOpacity(0.05)
              : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: state == _UploadState.warning
                ? borderColor
                : state == _UploadState.selected
                    ? accentColor.withOpacity(0.5)
                    : borderColor,
            width: state == _UploadState.warning ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: state == _UploadState.selected
                    ? accentColor.withOpacity(0.12)
                    : AppColors.borderColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                state == _UploadState.selected
                    ? Icons.check_circle_outline_rounded
                    : icon,
                color: accentColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state == _UploadState.selected ? 'File dipilih' : label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accentColor),
            ),
            const SizedBox(height: 4),
            Text(
              state == _UploadState.selected
                  ? 'Ketuk untuk mengganti'
                  : sublabel,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
