import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../utils/session_manager.dart';
import '../data/wilayah_data.dart';
import '../widgets/layanan_picker_sheet.dart';
import '../widgets/layanan_slot.dart';

class Tiga1FormScreen extends StatefulWidget {
  const Tiga1FormScreen({super.key});

  @override
  State<Tiga1FormScreen> createState() => _Tiga1FormScreenState();
}

class _Tiga1FormScreenState extends State<Tiga1FormScreen> {
  final _noHpController = TextEditingController();
  final _emailController = TextEditingController();
  final _namaPelapController = TextEditingController();
  final _nikController = TextEditingController();
  final _kkController = TextEditingController();
  final _namaPemohonController = TextEditingController();
  final _alamatController = TextEditingController();
  final _rtController = TextEditingController();
  final _rwController = TextEditingController();

  String? _statusPemohon;
  String? _kecamatan;
  String? _kelurahan;

  final List<String> _statusPemohonOptions = [
    'Diri Sendiri',
    'Suami/Istri',
    'Orang Tua',
    'Anak',
    'Saudara',
  ];
  final List<String> _kecamatanOptions = WilayahMadiun.kecamatan;

  String? _statusPengajuan = 'ONLINE';
  Map<String, dynamic>? _layanan1;
  Map<String, dynamic>? _layanan2;
  Map<String, dynamic>? _layanan3;
  final _keteranganController = TextEditingController();
  final List<String> _statusPengajuanOptions = ['ONLINE', 'OFFLINE'];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _prefillAkun();
  }

  Future<void> _prefillAkun() async {
    final userId = await SessionManager.instance.getUserId();
    if (userId == null) return;
    final user = await DatabaseHelper.instance.getUserById(userId);
    if (user != null && mounted) {
      setState(() {
        _noHpController.text = user['no_whatsapp']?.toString() ?? '';
        _emailController.text = user['email']?.toString() ?? '';
        _namaPelapController.text = user['nama_lengkap']?.toString() ?? '';
        _nikController.text = user['nik']?.toString() ?? '';
        _kkController.text = user['no_kk']?.toString() ?? '';
        _namaPemohonController.text = user['nama_lengkap']?.toString() ?? '';
        _alamatController.text = user['alamat']?.toString() ?? '';
        _rtController.text = user['rt']?.toString() ?? '';
        _rwController.text = user['rw']?.toString() ?? '';
        final kec = user['kecamatan']?.toString() ?? '';
        _kecamatan = WilayahMadiun.kecamatan.contains(kec) ? kec : null;
        if (_kecamatan != null) {
          final kels = WilayahMadiun.getKelurahan(_kecamatan!);
          final kel = user['kelurahan']?.toString() ?? '';
          _kelurahan = kels.contains(kel) ? kel : null;
        }
      });
    }
  }

  @override
  void dispose() {
    _noHpController.dispose();
    _emailController.dispose();
    _namaPelapController.dispose();
    _nikController.dispose();
    _kkController.dispose();
    _namaPemohonController.dispose();
    _alamatController.dispose();
    _rtController.dispose();
    _rwController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _pickLayanan(int slot) async {
    final allLayanan = await DatabaseHelper.instance.getAllLayanan();
    if (!mounted) return;
    String? current;

    if (slot == 1 && _layanan1 != null) {
      current = _layanan1!['nama'];
    } else if (slot == 2 && _layanan2 != null) {
      current = _layanan2!['nama'];
    } else if (slot == 3 && _layanan3 != null) {
      current = _layanan3!['nama'];
    }
    final result = await LayananPickerSheet.showFromDb(context, allLayanan,
        selectedLayanan: current);
    if (result != null) {
      setState(() {
        if (slot == 1) _layanan1 = result;
        if (slot == 2) _layanan2 = result;
        if (slot == 3) _layanan3 = result;
      });
    }
  }

  Future<void> _submit() async {
    final pilihanLayanan = [_layanan1, _layanan2, _layanan3]
        .whereType<Map<String, dynamic>>()
        .toList();
    if (pilihanLayanan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Pilih minimal satu layanan',
            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final userId = await SessionManager.instance.getUserId();
      if (userId == null) return;

      final resiList = <String>[];
      for (final layanan in pilihanLayanan) {
        final resi =
            'RESI-${DateTime.now().millisecondsSinceEpoch}-${layanan['id']}';
        resiList.add(resi);
        await DatabaseHelper.instance.insertPermohonan({
          'user_id': userId,
          'nomor_resi': resi,
          'layanan_id': layanan['id'],
          'jenis_layanan': layanan['nama'],
          'nama_pemohon': _namaPemohonController.text.trim(),
          'nik_pemohon': _nikController.text.trim(),
          'kecamatan': _kecamatan,
          'kelurahan': _kelurahan,
          'alamat': _alamatController.text.trim(),
          'rt': _rtController.text.trim(),
          'rw': _rwController.text.trim(),
          'status': 'baru',
          'catatan': _keteranganController.text.trim(),
          'tanggal_pengajuan': DateTime.now().toIso8601String(),
        });
      }

      await DatabaseHelper.instance.insertNotifikasi({
        'user_id': userId,
        'judul': 'Permohonan 3-in-1 Diterima',
        'isi':
            '${pilihanLayanan.length} permohonan layanan berhasil dikirim dan sedang diproses.',
        'tipe': 'permohonan',
        'is_read': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${pilihanLayanan.length} permohonan berhasil dikirim!',
            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        backgroundColor: AppColors.dilapakTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Gagal: $e', style: GoogleFonts.plusJakartaSans(fontSize: 13)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.offWhite,
        body: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  children: [
                    _buildSection(
                      icon: Icons.person_outline_rounded,
                      label: 'DATA PEMILIK AKUN',
                      children: [
                        _field('Nomor Handphone', _noHpController,
                            keyboardType: TextInputType.phone),
                        _gap(),
                        _field('Email', _emailController,
                            keyboardType: TextInputType.emailAddress),
                        _gap(),
                        _field('Nama Pelapor', _namaPelapController),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      icon: Icons.badge_outlined,
                      label: 'DATA PEMOHON',
                      children: [
                        Row(children: [
                          Expanded(
                              child: _field('NIK', _nikController,
                                  keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _field('No KK', _kkController,
                                  keyboardType: TextInputType.number)),
                        ]),
                        _gap(),
                        _field('Nama Pemohon', _namaPemohonController),
                        _gap(),
                        _dropdown(
                            label: 'Status Pemohon',
                            value: _statusPemohon,
                            hint: 'Pilih status',
                            items: _statusPemohonOptions,
                            onChanged: (v) =>
                                setState(() => _statusPemohon = v)),
                        _gap(),
                        _field('Alamat Pemohon', _alamatController,
                            hint: 'Alamat Pemohon'),
                        _gap(),
                        _dropdown(
                            label: 'Kecamatan',
                            value: _kecamatan,
                            hint: 'Pilih Kecamatan',
                            items: _kecamatanOptions,
                            onChanged: (v) => setState(() {
                                  _kecamatan = v;
                                  _kelurahan = null;
                                })),
                        _gap(),
                        _dropdown(
                          label: 'Kelurahan',
                          value: _kelurahan,
                          hint: _kecamatan == null
                              ? 'Pilih Kecamatan dulu'
                              : 'Pilih Kelurahan',
                          items: _kecamatan != null
                              ? WilayahMadiun.getKelurahan(_kecamatan!)
                              : [],
                          enabled: _kecamatan != null,
                          onChanged: _kecamatan != null
                              ? (v) => setState(() => _kelurahan = v)
                              : null,
                        ),
                        _gap(),
                        Row(children: [
                          Expanded(
                              child: _field('RT', _rtController,
                                  hint: 'RT',
                                  keyboardType: TextInputType.number)),
                          const SizedBox(width: 12),
                          Expanded(
                              child: _field('RW', _rwController,
                                  hint: 'RW',
                                  keyboardType: TextInputType.number)),
                        ]),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      icon: Icons.description_outlined,
                      label: 'DATA PERMOHONAN',
                      children: [
                        _dropdown(
                            label: 'Status Pengajuan',
                            value: _statusPengajuan,
                            hint: 'Pilih status',
                            items: _statusPengajuanOptions,
                            onChanged: (v) =>
                                setState(() => _statusPengajuan = v)),
                        _gap(),
                        LayananSlot(
                            label: 'Layanan 1',
                            selectedLayanan: _layanan1?['nama'],
                            onTap: () => _pickLayanan(1)),
                        _gap(),
                        LayananSlot(
                            label: 'Layanan 2',
                            selectedLayanan: _layanan2?['nama'],
                            onTap: () => _pickLayanan(2)),
                        _gap(),
                        LayananSlot(
                            label: 'Layanan 3',
                            selectedLayanan: _layanan3?['nama'],
                            onTap: () => _pickLayanan(3)),
                        _gap(),
                        _field(
                            'Data dan Informasi Lainnya', _keteranganController,
                            hint: 'Masukkan keterangan tambahan jika ada...',
                            maxLines: 4),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5))
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text('Kirim Permohonan',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 15, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dilapakTeal,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(4, top + 4, 16, 12),
      child: Row(children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary, size: 22),
        ),
        const SizedBox(width: 4),
        Text('Layanan 3 in 1',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ]),
    );
  }

  Widget _buildSection(
      {required IconData icon,
      required String label,
      required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              height: 2.5,
              decoration: BoxDecoration(
                  color: AppColors.dilapakTeal,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Row(children: [
            Icon(icon, size: 16, color: AppColors.dilapakTeal),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dilapakTeal,
                    letterSpacing: 0.8)),
          ]),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  SizedBox _gap() => const SizedBox(height: 14);

  Widget _field(String label, TextEditingController controller,
      {String? hint,
      TextInputType keyboardType = TextInputType.text,
      int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint ?? label,
            hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13.5, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.inputBackground,
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

  Widget _dropdown(
      {required String label,
      required String? value,
      required String hint,
      required List<String> items,
      bool enabled = true,
      void Function(String?)? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: items.contains(value) ? value : null,
          hint: Text(hint,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5, color: AppColors.textMuted)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor:
                enabled ? AppColors.inputBackground : const Color(0xFFF0F0F0),
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
          items: items.isEmpty
              ? null
              : items
                  .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: GoogleFonts.plusJakartaSans(fontSize: 13.5))))
                  .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
