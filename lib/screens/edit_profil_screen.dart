import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../utils/session_manager.dart';
import '../data/wilayah_data.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  // NIK & No KK kini bisa diedit
  final _nikController = TextEditingController();
  final _noKkController = TextEditingController();
  final _namaController = TextEditingController();
  final _waController = TextEditingController();
  final _alamatController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();

  String? _selectedJenisKelamin;
  String? _selectedProvinsi;
  String? _selectedKabupaten;
  String? _selectedKecamatan;
  String? _selectedKelurahan;

  int? _userId;
  bool _isSaving = false;

  final List<String> _jenisKelaminOptions = ['LAKI-LAKI', 'PEREMPUAN'];

  List<String> get _provinsiOptions =>
      WilayahIndonesia.provinsi.map((e) => e.toUpperCase()).toList();

  List<String> get _kabupatenOptions {
    if (_selectedProvinsi == null) return [];
    final key = WilayahIndonesia.provinsi.firstWhere(
      (e) => e.toUpperCase() == _selectedProvinsi,
      orElse: () => '',
    );
    return WilayahIndonesia.getKabupatenKota(key)
        .map((e) => e.toUpperCase())
        .toList();
  }

  List<String> get _kecamatanOptions {
    if (_selectedKabupaten == null) return [];
    // Cari key asli (mixed case) dari kabupatenKota
    String keyKab = '';
    for (final entry in WilayahIndonesia.kabupatenKota.entries) {
      for (final kab in entry.value) {
        if (kab.toUpperCase() == _selectedKabupaten) {
          keyKab = kab;
          break;
        }
      }
      if (keyKab.isNotEmpty) break;
    }
    return WilayahIndonesia.getKecamatan(keyKab)
        .map((e) => e.toUpperCase())
        .toList();
  }

  List<String> get _kelurahanOptions {
    if (_selectedKabupaten != 'KOTA MADIUN' || _selectedKecamatan == null) {
      return [];
    }
    // Convert uppercase kecamatan ke title case untuk lookup WilayahMadiun
    final kecTitleCase = _selectedKecamatan!
        .split(' ')
        .map((w) =>
            w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
    return WilayahMadiun.getKelurahan(kecTitleCase)
        .map((e) => e.toUpperCase())
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nikController.dispose();
    _noKkController.dispose();
    _namaController.dispose();
    _waController.dispose();
    _alamatController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _userId = await SessionManager.instance.getUserId();
    if (_userId == null) return;
    final user = await DatabaseHelper.instance.getUserById(_userId!);
    if (user != null && mounted) {
      setState(() {
        _nikController.text = user['nik']?.toString() ?? '';
        _noKkController.text = user['no_kk']?.toString() ?? '';
        _namaController.text = user['nama_lengkap']?.toString() ?? '';
        _waController.text = user['no_whatsapp']?.toString() ?? '';

        final jk = user['jenis_kelamin']?.toString().toUpperCase();
        _selectedJenisKelamin = _jenisKelaminOptions.contains(jk) ? jk : null;

        final prov = user['provinsi']?.toString().toUpperCase();
        _selectedProvinsi = _provinsiOptions.contains(prov) ? prov : null;

        _selectedKabupaten = user['kabupaten']?.toString().toUpperCase();
        _selectedKecamatan = user['kecamatan']?.toString().toUpperCase();
        _selectedKelurahan = user['kelurahan']?.toString().toUpperCase();

        _alamatController.text = user['alamat']?.toString() ?? '';
        _rtController.text = user['rt']?.toString() ?? '';
        _rwController.text = user['rw']?.toString() ?? '';
      });
    }
  }

  Future<void> _simpan() async {
    if (_userId == null) return;
    setState(() => _isSaving = true);

    final isLengkap = _namaController.text.trim().isNotEmpty &&
        _nikController.text.trim().isNotEmpty &&
        _selectedJenisKelamin != null &&
        _selectedProvinsi != null &&
        _selectedKabupaten != null &&
        _selectedKecamatan != null &&
        _alamatController.text.trim().isNotEmpty;

    await DatabaseHelper.instance.updateUser(_userId!, {
      'nik': _nikController.text.trim(),
      'no_kk': _noKkController.text.trim(),
      'nama_lengkap': _namaController.text.trim(),
      'no_whatsapp': _waController.text.trim(),
      'jenis_kelamin': _selectedJenisKelamin,
      'provinsi': _selectedProvinsi,
      'kabupaten': _selectedKabupaten,
      'kecamatan': _selectedKecamatan,
      'kelurahan': _selectedKelurahan,
      'alamat': _alamatController.text.trim(),
      'rt': _rtController.text.trim(),
      'rw': _rwController.text.trim(),
      'is_profil_lengkap': isLengkap ? 1 : 0,
    });

    await SessionManager.instance.updateSession(
      nama: _namaController.text.trim(),
      isProfilLengkap: isLengkap,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil berhasil diperbarui',
              style: GoogleFonts.plusJakartaSans(fontSize: 13)),
          backgroundColor: AppColors.dilapakTeal,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  // ─── BUILD — DESAIN ASLI TIDAK DIUBAH SAMA SEKALI ───
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // DATA IDENTITAS — NIK & No KK kini _EditableField bukan _LockedField
            _buildSection(
              title: 'Data Identitas',
              children: [
                _EditableField(
                  label: 'NIK',
                  controller: _nikController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                _EditableField(
                  label: 'NO KK',
                  controller: _noKkController,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSection(
              title: 'Informasi Pribadi',
              children: [
                _EditableField(
                    label: 'Nama Lengkap', controller: _namaController),
                const SizedBox(height: 14),
                _DropdownField(
                  label: 'Jenis Kelamin',
                  value: _selectedJenisKelamin,
                  options: _jenisKelaminOptions,
                  hint: 'Pilih Jenis Kelamin',
                  onChanged: (val) =>
                      setState(() => _selectedJenisKelamin = val),
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
                  hint: 'Pilih Provinsi',
                  onChanged: (val) => setState(() {
                    _selectedProvinsi = val;
                    _selectedKabupaten = null;
                    _selectedKecamatan = null;
                    _selectedKelurahan = null;
                  }),
                ),
                const SizedBox(height: 14),
                _DropdownField(
                  label: 'Kabupaten/Kota',
                  value: _kabupatenOptions.contains(_selectedKabupaten)
                      ? _selectedKabupaten
                      : null,
                  options: _kabupatenOptions,
                  hint: _selectedProvinsi == null
                      ? 'Pilih Provinsi dulu'
                      : 'Pilih Kabupaten/Kota',
                  enabled: _selectedProvinsi != null,
                  onChanged: _selectedProvinsi != null
                      ? (val) => setState(() {
                            _selectedKabupaten = val;
                            _selectedKecamatan = null;
                            _selectedKelurahan = null;
                          })
                      : null,
                ),
                const SizedBox(height: 14),
                _DropdownField(
                  label: 'Kecamatan',
                  value: _kecamatanOptions.contains(_selectedKecamatan)
                      ? _selectedKecamatan
                      : null,
                  options: _kecamatanOptions,
                  hint: _selectedKabupaten == null
                      ? 'Pilih Kab/Kota dulu'
                      : _kecamatanOptions.isEmpty
                          ? 'Ketik di bawah'
                          : 'Pilih Kecamatan',
                  enabled: _selectedKabupaten != null &&
                      _kecamatanOptions.isNotEmpty,
                  onChanged: (_selectedKabupaten != null &&
                          _kecamatanOptions.isNotEmpty)
                      ? (val) => setState(() {
                            _selectedKecamatan = val;
                            _selectedKelurahan = null;
                          })
                      : null,
                ),
                const SizedBox(height: 14),
                // Kelurahan dropdown (hanya Kota Madiun), lainnya field bebas
                if (_kelurahanOptions.isNotEmpty)
                  _DropdownField(
                    label: 'Kelurahan/Desa',
                    value: _kelurahanOptions.contains(_selectedKelurahan)
                        ? _selectedKelurahan
                        : null,
                    options: _kelurahanOptions,
                    hint: _selectedKecamatan == null
                        ? 'Pilih Kecamatan dulu'
                        : 'Pilih Kelurahan',
                    enabled: _selectedKecamatan != null,
                    onChanged: _selectedKecamatan != null
                        ? (val) => setState(() => _selectedKelurahan = val)
                        : null,
                  )
                else
                  _EditableFieldSimple(
                    label: 'Kelurahan/Desa',
                    value: _selectedKelurahan ?? '',
                    onChanged: (v) =>
                        setState(() => _selectedKelurahan = v.toUpperCase()),
                  ),
                const SizedBox(height: 14),
                _EditableFieldSimple(
                  label: 'Alamat Lengkap',
                  value: _alamatController.text,
                  hint: 'Jl. Contoh No. 10',
                  onChanged: (v) => setState(() => _alamatController.text = v),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _EditableFieldSimple(
                        label: 'RT',
                        value: _rtController.text,
                        hint: '001',
                        onChanged: (v) =>
                            setState(() => _rtController.text = v),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _EditableFieldSimple(
                        label: 'RW',
                        value: _rwController.text,
                        hint: '001',
                        onChanged: (v) =>
                            setState(() => _rwController.text = v),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
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

  Widget _buildSection(
      {required String title, required List<Widget> children}) {
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
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dilapakTeal)),
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
              offset: const Offset(0, -3)),
        ],
      ),
      child: GestureDetector(
        onTap: _isSaving ? null : _simpan,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.dilapakTeal,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2.5))
                  : const Icon(Icons.save_rounded,
                      color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Text('Update Profil',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── WIDGET DESAIN ASLI SAMA PERSIS ───

class _EditableField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  const _EditableField(
      {required this.label,
      required this.controller,
      this.keyboardType = TextInputType.text});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.dilapakTeal, width: 1.5)),
          ),
        ),
      ],
    );
  }
}

class _EditableFieldSimple extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final TextInputType? keyboardType;
  const _EditableFieldSimple({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.keyboardType,
  });

  @override
  State<_EditableFieldSimple> createState() => _EditableFieldSimpleState();
}

class _EditableFieldSimpleState extends State<_EditableFieldSimple> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    // Taruh cursor di akhir teks
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  @override
  void didUpdateWidget(_EditableFieldSimple oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Hanya update jika value berubah dari luar (bukan dari user mengetik)
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          keyboardType: widget.keyboardType,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13.5, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.dilapakTeal, width: 1.5)),
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
  const _DropdownField(
      {required this.label,
      required this.value,
      required this.options,
      this.onChanged,
      this.hint,
      this.enabled = true});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: options.contains(value) ? value : null,
          onChanged: onChanged,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500),
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
                borderSide: const BorderSide(color: AppColors.borderColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.borderColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.dilapakTeal, width: 1.5)),
          ),
          items: options.isEmpty
              ? null
              : options
                  .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o,
                          style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
                          overflow: TextOverflow.ellipsis)))
                  .toList(),
        ),
      ],
    );
  }
}
