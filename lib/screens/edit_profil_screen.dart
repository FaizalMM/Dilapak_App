import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../data/wilayah_madiun.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _namaController = TextEditingController(text: 'Tes programmer kominfo');
  final _waController = TextEditingController(text: '085748630511');

  String _selectedJenisKelamin = 'LAKI-LAKI';
  String _selectedProvinsi = 'JAWA TIMUR';
  String _selectedKabupaten = 'KOTA MADIUN';
  String? _selectedKecamatan;
  String? _selectedKelurahan;

  final List<String> _jenisKelaminOptions = ['LAKI-LAKI', 'PEREMPUAN'];
  final List<String> _provinsiOptions = [
    'JAWA TIMUR',
    'JAWA TENGAH',
    'JAWA BARAT'
  ];
  final List<String> _kabupatenOptions = [
    'KOTA MADIUN',
    'KABUPATEN MADIUN',
    'MAGETAN',
    'NGAWI',
    'PONOROGO',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _waController.dispose();
    super.dispose();
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
            _buildSection(
              title: 'Data Identitas',
              children: [
                const _LockedField(label: 'NIK', value: '3520050050050055'),
                const SizedBox(height: 14),
                const _LockedField(label: 'NO KK', value: '3520060060060066'),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Informasi Pribadi',
              children: [
                _EditableField(
                  label: 'Nama Lengkap',
                  controller: _namaController,
                ),
                const SizedBox(height: 14),
                _DropdownField(
                  label: 'Jenis Kelamin',
                  value: _selectedJenisKelamin,
                  options: _jenisKelaminOptions,
                  onChanged: (val) =>
                      setState(() => _selectedJenisKelamin = val!),
                ),
                const SizedBox(height: 14),
                _EditableField(
                  label: 'Whatsapp',
                  controller: _waController,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Alamat',
              children: [
                _DropdownField(
                  label: 'Provinsi',
                  value: _selectedProvinsi,
                  options: _provinsiOptions,
                  onChanged: (val) => setState(() => _selectedProvinsi = val!),
                ),
                const SizedBox(height: 14),
                _DropdownField(
                  label: 'Kabupaten/Kota',
                  value: _selectedKabupaten,
                  options: _kabupatenOptions,
                  onChanged: (val) => setState(() => _selectedKabupaten = val!),
                ),
                const SizedBox(height: 14),
                _DropdownField(
                  label: 'Kecamatan',
                  value: _selectedKecamatan,
                  options: WilayahMadiun.kecamatan,
                  hint: 'Pilih Kecamatan',
                  onChanged: (val) => setState(() {
                    _selectedKecamatan = val;
                    _selectedKelurahan = null;
                  }),
                ),
                const SizedBox(height: 14),
                _DropdownField(
                  label: 'Kelurahan/Desa',
                  value: _selectedKelurahan,
                  options: _selectedKecamatan != null
                      ? WilayahMadiun.getKelurahan(_selectedKecamatan!)
                      : [],
                  hint: _selectedKecamatan == null
                      ? 'Pilih Kecamatan dulu'
                      : 'Pilih Kelurahan',
                  enabled: _selectedKecamatan != null,
                  onChanged: _selectedKecamatan != null
                      ? (val) => setState(() => _selectedKelurahan = val)
                      : null,
                ),
              ],
            ),
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
        'Edit Profil',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.dilapakTeal,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: AppColors.borderColor),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
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
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.dilapakTeal,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
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
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Profil berhasil diperbarui',
                style: GoogleFonts.plusJakartaSans(fontSize: 13),
              ),
              backgroundColor: AppColors.dilapakTeal,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        },
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
                'Update Profil',
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

class _LockedField extends StatelessWidget {
  final String label;
  final String value;

  const _LockedField({required this.label, required this.value});

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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const Icon(Icons.lock_outline_rounded,
                  size: 18, color: AppColors.textMuted),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  const _EditableField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
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
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?>? onChanged;
  final String? hint;
  final bool enabled;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    this.onChanged,
    this.hint,
    this.enabled = true,
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
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          hint: hint != null
              ? Text(hint!,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5, color: AppColors.textMuted))
              : null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? AppColors.white : const Color(0xFFF0F0F0),
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.dilapakTeal, width: 1.5),
            ),
          ),
          items: options.isEmpty
              ? null
              : options
                  .map((o) => DropdownMenuItem(
                        value: o,
                        child: Text(o,
                            style: GoogleFonts.plusJakartaSans(fontSize: 13.5)),
                      ))
                  .toList(),
        ),
      ],
    );
  }
}
