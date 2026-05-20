import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class VerifikasiBerkasScreen extends StatefulWidget {
  const VerifikasiBerkasScreen({super.key});

  @override
  State<VerifikasiBerkasScreen> createState() => _VerifikasiBerkasScreenState();
}

class _VerifikasiBerkasScreenState extends State<VerifikasiBerkasScreen> {
  bool _ktpDipilih = false;
  bool _swafotoDiambil = false;
  bool _isLoading = false;

  void _pilihKTP() {
    setState(() => _ktpDipilih = true);
  }

  void _ambilSwafoto() {
    setState(() => _swafotoDiambil = true);
  }

  void _kirimVerifikasi() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccessDialog();
      }
    });
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
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.dilapakTeal,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Berkas Dikirim',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Berkas verifikasi Anda sedang ditinjau. Proses ini memakan waktu 1x24 jam.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.dilapakTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Kembali ke Beranda',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
            Text(
              '1. Foto KTP',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _UploadBox(
              state: _ktpDipilih ? _UploadState.selected : _UploadState.empty,
              icon: Icons.badge_outlined,
              label: 'Pilih File KTP',
              sublabel: 'Maksimal 5MB (JPG/PNG)',
              borderColor: AppColors.borderColor,
              accentColor: AppColors.dilapakTeal,
              onTap: _pilihKTP,
            ),
            const SizedBox(height: 24),
            Text(
              '2. Swafoto (Selfie) dengan KTP',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const _WarningBanner(
              text:
                  'Pastikan wajah Anda dan seluruh informasi KTP terlihat jelas',
            ),
            const SizedBox(height: 10),
            _UploadBox(
              state: _swafotoDiambil
                  ? _UploadState.selected
                  : _UploadState.warning,
              icon: Icons.photo_camera_outlined,
              label: 'Ambil Swafoto',
              sublabel: 'Pencahayaan harus terang',
              borderColor: _swafotoDiambil
                  ? AppColors.borderColor
                  : const Color(0xFFE87B2E),
              accentColor: _swafotoDiambil
                  ? AppColors.dilapakTeal
                  : const Color(0xFFE87B2E),
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
                              color: AppColors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            'Kirim untuk Verifikasi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
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
                Text(
                  'Verifikasi Berkas',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INFO BANNER
// ─────────────────────────────────────────────
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
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF2D7DD2),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Silakan unggah dokumen berikut untuk keperluan verifikasi pendaftaran layanan. Pastikan gambar jelas dan tidak terpotong.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF1A5080),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// WARNING BANNER
// ─────────────────────────────────────────────
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
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFE87B2E),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFB85D1A),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// UPLOAD BOX
// ─────────────────────────────────────────────
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
              offset: const Offset(0, 3),
            ),
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
                color:
                    state == _UploadState.selected ? accentColor : accentColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state == _UploadState.selected ? 'File dipilih' : label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              state == _UploadState.selected
                  ? 'Ketuk untuk mengganti'
                  : sublabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
