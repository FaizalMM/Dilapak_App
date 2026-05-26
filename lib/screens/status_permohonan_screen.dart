import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';

// ─── HELPERS ────────────────────────────────────────────────────────────────

String _formatTanggal(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  try {
    final dt = DateTime.parse(iso);
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  } catch (_) {
    return iso;
  }
}

String _formatDateTime(String? iso) {
  if (iso == null || iso.isEmpty) return '';
  try {
    final dt = DateTime.parse(iso);
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final jam = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${bulan[dt.month]} ${dt.year}, $jam:$menit';
  } catch (_) {
    return iso;
  }
}

// ─── SCREEN ─────────────────────────────────────────────────────────────────

class StatusPermohonanScreen extends StatefulWidget {
  final int permohonanId;

  const StatusPermohonanScreen({super.key, required this.permohonanId});

  @override
  State<StatusPermohonanScreen> createState() => _StatusPermohonanScreenState();
}

class _StatusPermohonanScreenState extends State<StatusPermohonanScreen> {
  Timer? _timer;
  Map<String, dynamic>? _permohonan;
  List<Map<String, dynamic>> _tracking = [];
  List<Map<String, dynamic>> _berkas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final p =
        await DatabaseHelper.instance.getPermohonanById(widget.permohonanId);
    final t = await DatabaseHelper.instance
        .getTrackingByPermohonan(widget.permohonanId);
    final b = await DatabaseHelper.instance
        .getBerkasByPermohonan(widget.permohonanId);
    if (mounted) {
      setState(() {
        _permohonan = p;
        _tracking = t;
        _berkas = b;
        _isLoading = false;
      });
    }
  }

  // Step upload berkas: setelah insert, update tracking step-2 sebagai done
  List<_StepData> get _stepData {
    // Map tracking DB ke model tampilan
    final steps = <_StepData>[];

    // Step 1: Upload Berkas Selesai
    final step1Tracking = _tracking.isNotEmpty ? _tracking[0] : null;
    final step1Done = step1Tracking?['is_done'] == 1;
    steps.add(_StepData(
      judul: 'Upload Berkas Selesai',
      deskripsi: step1Done
          ? _formatDateTime(step1Tracking?['waktu']?.toString())
          : null,
      isDone: step1Done,
      isActive: false,
    ));

    // Step 2: Verifikasi Petugas
    final step2Tracking = _tracking.length > 1 ? _tracking[1] : null;
    final step2Done = step2Tracking?['is_done'] == 1;
    final berkasUploaded = _berkas.isNotEmpty;
    final step2Active = berkasUploaded && !step2Done;
    steps.add(_StepData(
      judul: 'Verifikasi Petugas',
      deskripsi: step2Done
          ? _formatDateTime(step2Tracking?['waktu']?.toString())
          : step2Active
              ? 'Estimasi selesai dalam 1–2 hari kerja.'
              : null,
      isDone: step2Done,
      isActive: step2Active,
    ));

    // Step 3: Pengambilan Dokumen
    final step3Tracking = _tracking.length > 2 ? _tracking[2] : null;
    final step3Done = step3Tracking?['is_done'] == 1;
    steps.add(_StepData(
      judul: 'Pengambilan Dokumen',
      deskripsi: step3Done
          ? _formatDateTime(step3Tracking?['waktu']?.toString())
          : 'Menunggu hasil verifikasi.',
      isDone: step3Done,
      isActive: false,
      isWaiting: !step2Done && !step3Done,
    ));

    return steps;
  }

  String get _statusLabel {
    final status = _permohonan?['status']?.toString() ?? 'menunggu';
    switch (status) {
      case 'menunggu':
        return 'Sedang Diverifikasi';
      case 'diproses':
        return 'Sedang Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Sedang Diverifikasi';
    }
  }

  Color get _statusColor {
    final status = _permohonan?['status']?.toString() ?? 'menunggu';
    switch (status) {
      case 'selesai':
        return const Color(0xFF10B981);
      case 'diproses':
        return const Color(0xFFF59E0B);
      case 'ditolak':
        return const Color(0xFFEF4444);
      default:
        return AppColors.dilapakTeal;
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.dilapakTeal))
            : _permohonan == null
                ? const Center(child: Text('Data tidak ditemukan'))
                : Column(
                    children: [
                      _AppBarCustom(onBack: () => Navigator.pop(context)),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadData,
                          color: AppColors.dilapakTeal,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _StatusCard(
                                  statusLabel: _statusLabel,
                                  statusColor: _statusColor,
                                  nomorResi:
                                      _permohonan!['nomor_resi']?.toString() ??
                                          '-',
                                  tanggal: _formatTanggal(
                                      _permohonan!['tanggal_pengajuan']
                                          ?.toString()),
                                  namaLayanan: _permohonan!['nama_layanan']
                                          ?.toString() ??
                                      '-',
                                ),
                                const SizedBox(height: 20),
                                _LangkahProsesCard(steps: _stepData),
                                const SizedBox(height: 20),
                                _BerkasTerlampirCard(berkasList: _berkas),
                                const SizedBox(height: 20),
                                _HubungiButton(onTap: () {}),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

// ─── APP BAR CUSTOM (tanpa AppBar bawaan Flutter) ────────────────────────────

class _AppBarCustom extends StatelessWidget {
  final VoidCallback onBack;
  const _AppBarCustom({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(4, top + 4, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: AppColors.textPrimary, size: 18),
          ),
          Text(
            'Status Permohonan',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── STATUS CARD ─────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  final String statusLabel;
  final Color statusColor;
  final String nomorResi;
  final String tanggal;
  final String namaLayanan;

  const _StatusCard({
    required this.statusLabel,
    required this.statusColor,
    required this.nomorResi,
    required this.tanggal,
    required this.namaLayanan,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon centang di lingkaran teal muda
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_outlined,
              size: 34,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 12),

          // Badge status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Deskripsi
          Text(
            'Berkas Anda telah diterima dan sedang dalam\ntahap peninjauan oleh petugas.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),

          // Nomor Resi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.dilapakBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
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
                      Text(
                        nomorResi,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: nomorResi));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Nomor resi disalin',
                            style: GoogleFonts.plusJakartaSans(fontSize: 13)),
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
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: const Icon(Icons.copy_rounded,
                        size: 18, color: AppColors.dilapakTeal),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Tanggal & Layanan
          Row(
            children: [
              Expanded(
                child: _InfoBox(label: 'TANGGAL', value: tanggal),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoBox(label: 'LAYANAN', value: namaLayanan),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dilapakBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}

// ─── LANGKAH PROSES CARD ─────────────────────────────────────────────────────

class _StepData {
  final String judul;
  final String? deskripsi;
  final bool isDone;
  final bool isActive;
  final bool isWaiting;

  const _StepData({
    required this.judul,
    this.deskripsi,
    required this.isDone,
    required this.isActive,
    this.isWaiting = false,
  });
}

class _LangkahProsesCard extends StatelessWidget {
  final List<_StepData> steps;
  const _LangkahProsesCard({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Langkah Proses',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            steps.length,
            (i) => _StepTile(
              step: steps[i],
              isLast: i == steps.length - 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final _StepData step;
  final bool isLast;
  const _StepTile({required this.step, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indikator + garis
          SizedBox(
            width: 24,
            child: Column(
              children: [
                _buildCircle(),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: step.isDone
                          ? const Color(0xFF10B981).withOpacity(0.35)
                          : AppColors.borderColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Konten
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    step.judul,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: step.isWaiting
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (step.deskripsi != null && step.deskripsi!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      step.deskripsi!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: step.isWaiting
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircle() {
    if (step.isDone) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF10B981),
        ),
        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
      );
    }
    if (step.isActive) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.dilapakTeal.withOpacity(0.12),
          border: Border.all(color: AppColors.dilapakTeal, width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.dilapakTeal,
            ),
          ),
        ),
      );
    }
    // Waiting
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.borderColor.withOpacity(0.5),
        border: Border.all(color: AppColors.borderColor),
      ),
    );
  }
}

// ─── BERKAS TERLAMPIR CARD ───────────────────────────────────────────────────

class _BerkasTerlampirCard extends StatelessWidget {
  final List<Map<String, dynamic>> berkasList;
  const _BerkasTerlampirCard({required this.berkasList});

  @override
  Widget build(BuildContext context) {
    if (berkasList.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Berkas Terlampir',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${berkasList.length} Berkas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...berkasList.map(
            (b) => _BerkasItem(berkas: b),
          ),
        ],
      ),
    );
  }
}

class _BerkasItem extends StatelessWidget {
  final Map<String, dynamic> berkas;
  const _BerkasItem({required this.berkas});

  String get _ext {
    final path = berkas['path_file']?.toString() ?? '';
    final parts = path.split('.');
    if (parts.length > 1) return parts.last.toUpperCase();
    return 'FILE';
  }

  String get _size {
    final path = berkas['path_file']?.toString() ?? '';
    if (path.isEmpty) return '-';
    try {
      final file = File(path);
      if (file.existsSync()) {
        final bytes = file.lengthSync();
        if (bytes < 1024 * 1024) {
          return '${(bytes / 1024).toStringAsFixed(0)} KB';
        }
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (_) {}
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dilapakBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 18,
              color: AppColors.dilapakTeal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  berkas['nama_berkas']?.toString() ?? 'Berkas',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$_ext • $_size',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _lihatBerkas(context),
            child: Container(
              padding: const EdgeInsets.all(6),
              child: const Icon(
                Icons.remove_red_eye_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _lihatBerkas(BuildContext context) {
    final path = berkas['path_file']?.toString() ?? '';
    final nama = berkas['nama_berkas']?.toString() ?? 'Berkas';

    if (path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File tidak tersedia',
              style: GoogleFonts.plusJakartaSans(fontSize: 13)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _BerkasPreviewScreen(filePath: path, namaBerkas: nama),
      ),
    );
  }
}

// ─── BERKAS PREVIEW SCREEN ───────────────────────────────────────────────────

class _BerkasPreviewScreen extends StatelessWidget {
  final String filePath;
  final String namaBerkas;

  const _BerkasPreviewScreen({
    required this.filePath,
    required this.namaBerkas,
  });

  bool get _isImage {
    final ext = filePath.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          namaBerkas,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _isImage
            ? InteractiveViewer(
                child: Image.file(
                  File(filePath),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => _Placeholder(),
                ),
              )
            : _Placeholder(),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.description_outlined, size: 64, color: Colors.white54),
        const SizedBox(height: 12),
        Text(
          'Preview tidak tersedia untuk tipe file ini.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: Colors.white54,
          ),
        ),
      ],
    );
  }
}

// ─── HUBUNGI PETUGAS BUTTON ──────────────────────────────────────────────────

class _HubungiButton extends StatelessWidget {
  final VoidCallback onTap;
  const _HubungiButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.support_agent_rounded, size: 18),
        label: Text(
          'Hubungi Petugas Bantuan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dilapakTeal,
          side: const BorderSide(color: AppColors.dilapakTeal, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
