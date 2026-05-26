import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../utils/session_manager.dart';

// ─── MODEL BERKAS ───

class _BerkasItem {
  final String id;
  final String nama;
  final String format;
  final bool wajib;
  final bool opsional;
  final String? keterangan;
  String? filePath;
  String? fileName;

  _BerkasItem({
    required this.id,
    required this.nama,
    required this.format,
    required this.wajib,
    this.opsional = false,
    this.keterangan,
  });
}

// ─── BERKAS WAJIB PER LAYANAN ───

class _BerkasLayanan {
  static List<_BerkasItem> getBerkasWajib(
      String kodeLayanan, String namaLayanan) {
    final nama = namaLayanan.toLowerCase();

    // KTP
    if (nama.contains('ktp') && nama.contains('baru')) {
      return [
        _BerkasItem(
            id: 'pengantar_rtrw',
            nama: 'Surat Pengantar RT/RW',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'fotokopi_kk',
            nama: 'Fotokopi Kartu Keluarga',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'pas_foto',
            nama: 'Pas Foto 3x4',
            format: 'JPG, PNG (Maks. 2MB)',
            wajib: true),
      ];
    }
    if (nama.contains('ktp') && nama.contains('hilang')) {
      return [
        _BerkasItem(
            id: 'surat_kehilangan',
            nama: 'Surat Kehilangan dari Polisi',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'fotokopi_kk',
            nama: 'Fotokopi Kartu Keluarga',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
      ];
    }
    if (nama.contains('ktp') && nama.contains('rusak')) {
      return [
        _BerkasItem(
            id: 'ktp_lama',
            nama: 'KTP-el Lama yang Rusak',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'fotokopi_kk',
            nama: 'Fotokopi Kartu Keluarga',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
      ];
    }
    if (nama.contains('ktp') && nama.contains('perubahan')) {
      return [
        _BerkasItem(
            id: 'ktp_lama',
            nama: 'KTP-el Lama',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'dokumen_perubahan',
            nama: 'Dokumen Pendukung Perubahan',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'fotokopi_kk',
            nama: 'Fotokopi Kartu Keluarga',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
      ];
    }

    // Kartu Keluarga
    if (nama.contains('kartu keluarga') ||
        nama.contains(' kk ') ||
        nama.contains('penerbitan kk')) {
      return [
        _BerkasItem(
            id: 'kk_lama',
            nama: 'Kartu Keluarga Lama',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'akta_kelahiran',
            nama: 'Akta Kelahiran',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'sk_pindah',
            nama: 'SK Pindah',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'surat_nikah',
            nama: 'Surat Nikah/Cerai',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: false,
            opsional: true,
            keterangan: 'Opsional jika berstatus kawin/cerai'),
      ];
    }
    if (nama.contains('kk') &&
        (nama.contains('hilang') || nama.contains('rusak'))) {
      return [
        _BerkasItem(
            id: 'surat_kehilangan',
            nama: 'Surat Kehilangan dari Polisi',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'ktp_kepala',
            nama: 'KTP Kepala Keluarga',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
      ];
    }

    // Akta Kelahiran
    if (nama.contains('akta kelahiran') && nama.contains('baru')) {
      return [
        _BerkasItem(
            id: 'surat_lahir',
            nama: 'Surat Keterangan Lahir',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'kk',
            nama: 'Kartu Keluarga',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'ktp_ortu',
            nama: 'KTP Orang Tua',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'buku_nikah',
            nama: 'Buku Nikah',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
      ];
    }
    if (nama.contains('akta kelahiran') && nama.contains('hilang')) {
      return [
        _BerkasItem(
            id: 'surat_kehilangan',
            nama: 'Surat Kehilangan dari Polisi',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'akta_lama',
            nama: 'Fotokopi Akta Lama',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
      ];
    }
    if (nama.contains('akta perkawinan')) {
      return [
        _BerkasItem(
            id: 'surat_nikah',
            nama: 'Surat Nikah dari KUA/Gereja',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'ktp',
            nama: 'KTP Kedua Mempelai',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'kk',
            nama: 'Kartu Keluarga',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
      ];
    }
    if (nama.contains('akta kematian')) {
      return [
        _BerkasItem(
            id: 'surat_kematian',
            nama: 'Surat Keterangan Kematian',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'kk',
            nama: 'Kartu Keluarga',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'ktp_almarhum',
            nama: 'KTP Almarhum/Almarhumah',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
      ];
    }

    // KIA
    if (nama.contains('kartu identitas anak') || nama.contains('kia')) {
      return [
        _BerkasItem(
            id: 'akta_kelahiran',
            nama: 'Akta Kelahiran',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'kk',
            nama: 'Kartu Keluarga',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'ktp_ortu',
            nama: 'KTP Orang Tua',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
      ];
    }

    // Pindah
    if (nama.contains('pindah')) {
      return [
        _BerkasItem(
            id: 'kk',
            nama: 'Kartu Keluarga',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'ktp',
            nama: 'KTP',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'pengantar_rtrw',
            nama: 'Surat Pengantar RT/RW',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
      ];
    }

    // Domisili
    if (nama.contains('domisili')) {
      return [
        _BerkasItem(
            id: 'ktp',
            nama: 'KTP',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'kk',
            nama: 'Kartu Keluarga',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
        _BerkasItem(
            id: 'pengantar_rtrw',
            nama: 'Surat Pengantar RT/RW',
            format: 'JPG, PNG, PDF (Maks. 2MB)',
            wajib: true),
      ];
    }

    // Default
    return [
      _BerkasItem(
          id: 'ktp',
          nama: 'Kartu Tanda Penduduk (KTP)',
          format: 'JPG, PNG, PDF (Maks. 2MB)',
          wajib: true),
      _BerkasItem(
          id: 'kk',
          nama: 'Kartu Keluarga',
          format: 'JPG, PNG, PDF (Maks. 2MB)',
          wajib: true),
    ];
  }
}

// ─── SCREEN ───

class UploadBerkasScreen extends StatefulWidget {
  final int permohonanId;
  final Map<String, dynamic> permohonanData;
  final Map<String, dynamic>? layananData;

  const UploadBerkasScreen({
    super.key,
    required this.permohonanId,
    required this.permohonanData,
    this.layananData,
  });

  @override
  State<UploadBerkasScreen> createState() => _UploadBerkasScreenState();
}

class _UploadBerkasScreenState extends State<UploadBerkasScreen> {
  late List<_BerkasItem> _berkasWajib;
  final List<_BerkasItem> _berkasPendukung = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final namaLayanan = widget.permohonanData['nama_layanan']?.toString() ?? '';
    final kodeLayanan = widget.layananData?['kode']?.toString() ?? '';
    _berkasWajib = _BerkasLayanan.getBerkasWajib(kodeLayanan, namaLayanan);
  }

  int get _jumlahBerkasWajib => _berkasWajib.where((b) => b.wajib).length;

  bool get _canSubmit =>
      _berkasWajib.where((b) => b.wajib).every((b) => b.filePath != null);

  Future<void> _pickFile(int index, {bool isPendukung = false}) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        final fileName = picked.path.split('/').last;
        setState(() {
          if (isPendukung) {
            _berkasPendukung[index].filePath = picked.path;
            _berkasPendukung[index].fileName = fileName;
          } else {
            _berkasWajib[index].filePath = picked.path;
            _berkasWajib[index].fileName = fileName;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memilih berkas: $e', Colors.red);
      }
    }
  }

  void _removeFile(int index, {bool isPendukung = false}) {
    setState(() {
      if (isPendukung) {
        _berkasPendukung[index].filePath = null;
        _berkasPendukung[index].fileName = null;
      } else {
        _berkasWajib[index].filePath = null;
        _berkasWajib[index].fileName = null;
      }
    });
  }

  void _tambahBerkasPendukung() {
    setState(() {
      _berkasPendukung.add(_BerkasItem(
        id: 'pendukung_${_berkasPendukung.length}',
        nama: 'Berkas Pendukung ${_berkasPendukung.length + 1}',
        format: 'JPG, PNG, PDF (Maks. 2MB)',
        wajib: false,
      ));
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.plusJakartaSans(fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _simpanDraft() async {
    _showSnackBar('Berkas disimpan sebagai draft', AppColors.dilapakTeal);
  }

  Future<void> _kirimPermohonan() async {
    if (!_canSubmit) {
      _showSnackBar(
          'Lengkapi semua berkas wajib terlebih dahulu', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = await SessionManager.instance.getUserId();
      if (userId == null) {
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }

      final allBerkas = [..._berkasWajib, ..._berkasPendukung];
      for (final berkas in allBerkas) {
        if (berkas.filePath != null) {
          await DatabaseHelper.instance.insertBerkas({
            'user_id': userId,
            'permohonan_id': widget.permohonanId,
            'nama_berkas': berkas.nama,
            'tipe_berkas': berkas.wajib ? 'wajib' : 'pendukung',
            'path_file': berkas.filePath,
            'status': 'menunggu',
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }

      await DatabaseHelper.instance.updatePermohonan(
        widget.permohonanId,
        {'status': 'menunggu'},
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _SelesaiScreen(
            nomorResi: widget.permohonanData['nomor_resi']?.toString() ?? '-',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnackBar('Gagal mengirim: $e', Colors.red);
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
        backgroundColor: AppColors.dilapakBackground,
        body: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 20),
                    _buildBerkasWajibSection(),
                    const SizedBox(height: 16),
                    _buildBerkasPendukungSection(),
                    const SizedBox(height: 16),
                    _buildInfoNote(),
                    const SizedBox(height: 24),
                    _buildScrolledActions(context),
                    const SizedBox(height: 32),
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
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.textPrimary, size: 22),
          ),
          Expanded(
            child: Text(
              'Upload Berkas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: _showBantuanDialog,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Icon(Icons.help_outline_rounded,
                  size: 18, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showBantuanDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Bantuan Upload',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Pastikan semua berkas wajib sudah diunggah sebelum mengirim permohonan.\n\n'
          'Format yang diterima: JPG, PNG, PDF dengan ukuran maksimal 2MB per file.\n\n'
          'Petugas akan memverifikasi berkas dalam 1x24 jam kerja.',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: AppColors.textSecondary, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Mengerti',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700, color: AppColors.dilapakTeal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final p = widget.permohonanData;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor Resi + Badge DRAFT
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOMOR RESI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      p['nomor_resi']?.toString() ?? '-',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dilapakTeal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'DRAFT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF59E0B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.borderColor),
          ),

          // NIK + Layanan (sejajar)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoChip(
                  'NIK Pemohon',
                  p['nik_pemohon']?.toString() ?? '-',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  'Layanan',
                  p['nama_layanan']?.toString() ?? '-',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Nama Lengkap (full width)
          _buildInfoChip(
            'Nama Lengkap',
            (p['nama_pemohon']?.toString() ?? '-').toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildBerkasWajibSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Berkas Wajib',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dilapakTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_jumlahBerkasWajib Dokumen',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dilapakTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _berkasWajib.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BerkasCard(
                berkas: _berkasWajib[i],
                onPick: () => _pickFile(i),
                onRemove: () => _removeFile(i),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBerkasPendukungSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Berkas Pendukung',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: _tambahBerkasPendukung,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Tambah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_berkasPendukung.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.dilapakBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.folder_open_outlined,
                        size: 24, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Belum ada berkas pendukung\nditambahkan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(
              _berkasPendukung.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BerkasCard(
                  berkas: _berkasPendukung[i],
                  onPick: () => _pickFile(i, isPendukung: true),
                  onRemove: () => _removeFile(i, isPendukung: true),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 16, color: AppColors.dilapakTeal),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(
                        text:
                            'Pastikan semua dokumen terbaca dengan jelas dan tidak buram sebelum menekan tombol '),
                    TextSpan(
                      text: 'Kirim Permohonan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrolledActions(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _kirimPermohonan,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                'Kirim Permohonan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSubmit
                    ? AppColors.dilapakTeal
                    : AppColors.dilapakTeal.withOpacity(0.35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _simpanDraft,
              icon: const Icon(Icons.bookmark_outline_rounded, size: 18),
              label: Text(
                'Simpan sebagai Draft',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.dilapakTeal,
                side: const BorderSide(color: AppColors.dilapakTeal),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BERKAS CARD WIDGET ───

class _BerkasCard extends StatelessWidget {
  final _BerkasItem berkas;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _BerkasCard({
    required this.berkas,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isUploaded = berkas.filePath != null;

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon dokumen
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isUploaded
                  ? const Color(0xFF22C55E).withOpacity(0.1)
                  : AppColors.dilapakBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUploaded
                  ? Icons.description_rounded
                  : Icons.upload_file_outlined,
              size: 20,
              color: isUploaded ? const Color(0xFF22C55E) : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),

          // Konten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama + badge opsional
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        berkas.nama,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (berkas.opsional) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.dilapakBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'OPSIONAL',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Keterangan / format
                const SizedBox(height: 3),
                Text(
                  berkas.keterangan != null
                      ? berkas.keterangan!
                      : 'Format: ${berkas.format}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontStyle: berkas.keterangan != null
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),

                const SizedBox(height: 10),

                // Status upload
                if (isUploaded) ...[
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 13, color: Color(0xFF22C55E)),
                      const SizedBox(width: 4),
                      Text(
                        'Berhasil diunggah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.dilapakBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            berkas.fileName ?? 'berkas.pdf',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onRemove,
                          child: const Icon(Icons.delete_outline_rounded,
                              size: 16, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  _PickFileButton(onTap: onPick),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PICK FILE BUTTON (menggantikan DashedBorderPainterWidget) ───

class _PickFileButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PickFileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.dilapakTeal.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded,
                size: 16, color: AppColors.dilapakTeal),
            const SizedBox(width: 6),
            Text(
              'Pilih Berkas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.dilapakTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SELESAI SCREEN ───

class _SelesaiScreen extends StatelessWidget {
  final String nomorResi;
  const _SelesaiScreen({required this.nomorResi});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.dilapakBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 40, 24, bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Ikon sukses ──
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.dilapakTeal.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 40,
                  color: AppColors.dilapakTeal,
                ),
              ),
              const SizedBox(height: 20),

              // ── Judul ──
              Text(
                'Permohonan Berhasil\nTerkirim!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),

              // ── Deskripsi ──
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Berkas Anda sedang diverifikasi oleh petugas. '
                          'Kami akan memberikan kabar dalam waktu ',
                    ),
                    TextSpan(
                      text: '1x24\njam kerja',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Card Nomor Resi ──
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOMOR RESI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nomorResi,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dilapakTeal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: nomorResi));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Nomor resi disalin',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13)),
                                backgroundColor: AppColors.dilapakTeal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.dilapakBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.copy_rounded,
                                size: 16, color: AppColors.dilapakTeal),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Tahapan Selanjutnya ──
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'TAHAPAN SELANJUTNYA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildTahapanItem(
                icon: Icons.fact_check_outlined,
                judul: 'Verifikasi Berkas',
                deskripsi:
                    'Tim administrasi sedang memeriksa kelengkapan dokumen Anda.',
              ),
              const SizedBox(height: 10),
              _buildTahapanItem(
                icon: Icons.notifications_outlined,
                judul: 'Terima Notifikasi',
                deskripsi:
                    'Update status akan dikirimkan melalui aplikasi dan email.',
              ),
              const SizedBox(height: 32),

              // ── Tombol Lihat Status ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dilapakTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Lihat Status Permohonan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── Tombol Kembali ──
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dilapakTeal,
                    side: const BorderSide(color: AppColors.dilapakTeal),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
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

  Widget _buildTahapanItem({
    required IconData icon,
    required String judul,
    required String deskripsi,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.dilapakTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.dilapakTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  deskripsi,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
