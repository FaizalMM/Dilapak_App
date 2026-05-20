import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class UbahKataSandiScreen extends StatefulWidget {
  const UbahKataSandiScreen({super.key});

  @override
  State<UbahKataSandiScreen> createState() => _UbahKataSandiScreenState();
}

class _UbahKataSandiScreenState extends State<UbahKataSandiScreen> {
  final _passwordLamaController = TextEditingController();
  final _passwordBaruController = TextEditingController();
  final _konfirmasiController = TextEditingController();

  bool _showPasswordLama = false;
  bool _showPasswordBaru = false;
  bool _showKonfirmasi = false;

  @override
  void dispose() {
    _passwordLamaController.dispose();
    _passwordBaruController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  void _simpanPerubahan() {
    final lama = _passwordLamaController.text.trim();
    final baru = _passwordBaruController.text.trim();
    final konfirmasi = _konfirmasiController.text.trim();

    if (lama.isEmpty || baru.isEmpty || konfirmasi.isEmpty) {
      _showSnackBar('Semua kolom wajib diisi', isError: true);
      return;
    }
    if (baru.length < 8) {
      _showSnackBar('Password baru minimal 8 karakter', isError: true);
      return;
    }
    if (baru != konfirmasi) {
      _showSnackBar('Konfirmasi password tidak cocok', isError: true);
      return;
    }
    _showSnackBar('Kata sandi berhasil diperbarui');
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        backgroundColor:
            isError ? const Color(0xFFEF4444) : AppColors.dilapakTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildInfoAkunSection(),
            const SizedBox(height: 16),
            _buildUbahPasswordSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded,
            color: AppColors.textPrimary, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Ubah Kata Sandi',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.borderColor),
      ),
    );
  }

  Widget _buildInfoAkunSection() {
    return const _SectionCard(
      icon: Icons.person_outline_rounded,
      title: 'Informasi Akun',
      child: Column(
        children: [
          _ReadOnlyField(
            label: 'Nama Pengguna',
            value: 'Tes programmer kominfo',
          ),
          SizedBox(height: 14),
          _ReadOnlyField(
            label: 'Username / Email',
            value: 'tesprogramerkmf@gmail.com',
          ),
        ],
      ),
    );
  }

  Widget _buildUbahPasswordSection() {
    return _SectionCard(
      icon: Icons.lock_outline_rounded,
      title: 'Ubah Password',
      child: Column(
        children: [
          _PasswordField(
            label: 'Password Lama',
            hint: 'Masukkan password lama',
            controller: _passwordLamaController,
            showPassword: _showPasswordLama,
            onToggle: () =>
                setState(() => _showPasswordLama = !_showPasswordLama),
          ),
          const SizedBox(height: 14),
          _PasswordField(
            label: 'Password Baru',
            hint: 'Masukkan password baru',
            controller: _passwordBaruController,
            showPassword: _showPasswordBaru,
            onToggle: () =>
                setState(() => _showPasswordBaru = !_showPasswordBaru),
            helperText: 'Minimal 8 karakter, kombinasi huruf dan angka.',
          ),
          const SizedBox(height: 14),
          _PasswordField(
            label: 'Konfirmasi Password Baru',
            hint: 'Ketik ulang password baru',
            controller: _konfirmasiController,
            showPassword: _showKonfirmasi,
            onToggle: () => setState(() => _showKonfirmasi = !_showKonfirmasi),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: _simpanPerubahan,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.dilapakTeal,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.save_rounded, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Simpan Perubahan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.dilapakTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool showPassword;
  final VoidCallback onToggle;
  final String? helperText;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.showPassword,
    required this.onToggle,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !showPassword,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: AppColors.textMuted,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.dilapakTeal, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                showPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 5),
          Text(
            helperText!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
