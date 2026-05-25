import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';

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

class TrackingScreen extends StatefulWidget {
  final int permohonanId;
  const TrackingScreen({super.key, required this.permohonanId});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Map<String, dynamic>? _permohonan;
  List<Map<String, dynamic>> _tracking = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final p =
        await DatabaseHelper.instance.getPermohonanById(widget.permohonanId);
    final t = await DatabaseHelper.instance
        .getTrackingByPermohonan(widget.permohonanId);
    if (mounted)
      setState(() {
        _permohonan = p;
        _tracking = t;
        _isLoading = false;
      });
  }

  Color get _accentColor {
    final status = _permohonan?['status']?.toString() ?? 'menunggu';
    switch (status) {
      case 'baru':
        return const Color(0xFF3B82F6);
      case 'diproses':
        return const Color(0xFFF59E0B);
      case 'selesai':
        return const Color(0xFF10B981);
      case 'ditolak':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F6FA),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Detail Permohonan',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _permohonan == null
              ? const Center(child: Text('Data tidak ditemukan'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(),
                      const SizedBox(height: 20),
                      Text('Tracking Status',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 12),
                      _buildTrackingCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoCard() {
    final status = _permohonan!['status']?.toString() ?? 'menunggu';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBadge(status: status),
          const SizedBox(height: 10),
          Text(_permohonan!['nama_layanan']?.toString() ?? '-',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(_permohonan!['nama_pemohon']?.toString() ?? '-',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _InfoItem(
                      label: 'NO. RESI',
                      value: _permohonan!['nomor_resi']?.toString() ?? '-')),
              Expanded(
                  child: _InfoItem(
                      label: 'TANGGAL PENGAJUAN',
                      value: _formatDateTime(
                          _permohonan!['tanggal_pengajuan']?.toString()))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: List.generate(
          _tracking.length,
          (index) => _TrackingStepTile(
            step: _tracking[index],
            isLast: index == _tracking.length - 1,
            accentColor: _accentColor,
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color {
    switch (status) {
      case 'selesai':
        return const Color(0xFF10B981);
      case 'diproses':
        return const Color(0xFFF59E0B);
      case 'ditolak':
        return const Color(0xFFEF4444);
      case 'baru':
        return const Color(0xFF3B82F6);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String get _label {
    switch (status) {
      case 'selesai':
        return 'Selesai';
      case 'diproses':
        return 'Sedang Diproses';
      case 'ditolak':
        return 'Ditolak';
      case 'baru':
        return 'Baru Diterima';
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(_label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 11, fontWeight: FontWeight.w700, color: _color)),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
                letterSpacing: 0.3)),
        const SizedBox(height: 2),
        Text(value,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

class _TrackingStepTile extends StatelessWidget {
  final Map<String, dynamic> step;
  final bool isLast;
  final Color accentColor;

  const _TrackingStepTile(
      {required this.step, required this.isLast, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final isDone = step['is_done'] == 1;
    // Step aktif = step pertama yang belum selesai
    final isActive = !isDone && !isLast;
    final isWaiting = !isDone && isLast;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? const Color(0xFF10B981)
                      : isActive
                          ? accentColor.withOpacity(0.15)
                          : AppColors.borderColor,
                  border: isActive
                      ? Border.all(color: accentColor, width: 2)
                      : null,
                ),
                child: isDone
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : isActive
                        ? Center(
                            child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentColor)))
                        : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isDone
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : AppColors.borderColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 2),
                  Text(step['judul']?.toString() ?? '-',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isWaiting
                              ? AppColors.textMuted
                              : AppColors.textPrimary)),
                  if (step['deskripsi'] != null) ...[
                    const SizedBox(height: 2),
                    Text(step['deskripsi'].toString(),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: isWaiting
                                ? AppColors.textMuted
                                : AppColors.textSecondary,
                            height: 1.5)),
                  ],
                  if (step['waktu'] != null &&
                      step['waktu'].toString().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(_formatDateTime(step['waktu'].toString()),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDone
                                ? const Color(0xFF10B981)
                                : accentColor)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
