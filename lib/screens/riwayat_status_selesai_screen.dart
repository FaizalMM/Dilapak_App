import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';

class RiwayatStatusSelesaiScreen extends StatefulWidget {
  final int permohonanId;

  const RiwayatStatusSelesaiScreen({
    super.key,
    required this.permohonanId,
  });

  @override
  State<RiwayatStatusSelesaiScreen> createState() =>
      _RiwayatStatusSelesaiScreenState();
}

class _RiwayatStatusSelesaiScreenState
    extends State<RiwayatStatusSelesaiScreen> {
  Map<String, dynamic>? _permohonan;
  List<Map<String, dynamic>> _tracking = [];
  List<Map<String, dynamic>> _berkas = [];
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

  String _formatTanggalWaktu(String? iso) {
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
        'Des',
      ];
      final jam = dt.hour.toString().padLeft(2, '0');
      final menit = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} ${bulan[dt.month]}, $jam:$menit';
    } catch (_) {
      return iso;
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
                child: CircularProgressIndicator(color: AppColors.dilapakTeal),
              )
            : _permohonan == null
                ? const Center(child: Text('Data tidak ditemukan'))
                : Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeaderCard(),
                              const SizedBox(height: 16),
                              _buildSelamatCard(),
                              const SizedBox(height: 20),
                              _buildRiwayatProses(),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
        bottomNavigationBar: _permohonan == null ? null : _buildUnduhButton(),
      ),
    );
  }

  Widget _buildAppBar() {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(4, top + 4, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
              size: 22,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Riwayat Status',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    final p = _permohonan!;
    final nomorResi = p['nomor_resi']?.toString() ?? '-';
    final namaLayanan = p['nama_layanan']?.toString() ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOMOR REGISTRASI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#$nomorResi',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.dilapakTeal,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Selesai',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.borderColor),
          ),
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.dilapakTealLight,
                  borderRadius: BorderRadius.circular(10),
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
                      'Jenis Layanan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      namaLayanan,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelamatCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dilapakTealLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dilapakTeal.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.dilapakTeal.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.celebration_outlined,
              size: 22,
              color: AppColors.dilapakTeal,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.dilapakTeal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Dokumen Anda telah berhasil diterbitkan dan siap untuk diunduh. Silakan gunakan tombol di bawah untuk mendapatkan file digital.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.dilapakTeal.withOpacity(0.85),
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatProses() {
    final items = _buildRiwayatItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Riwayat Proses',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          items.length,
          (i) => _RiwayatTile(
            item: items[i],
            isLast: i == items.length - 1,
            berkasList: i == 0 ? _berkas : [],
          ),
        ),
      ],
    );
  }

  List<_RiwayatItem> _buildRiwayatItems() {
    final items = <_RiwayatItem>[];

    items.add(_RiwayatItem(
      judul: 'Dokumen Terbit',
      deskripsi:
          'Sertifikat digital telah ditandatangani secara elektronik dan tersedia di sistem.',
      waktu: _tracking.length > 2
          ? _formatTanggalWaktu(_tracking[2]['waktu']?.toString())
          : _formatTanggalWaktu(_permohonan?['updated_at']?.toString()),
      hasBerkas: true,
    ));

    items.add(_RiwayatItem(
      judul: 'Sedang Diproses',
      deskripsi:
          'Permohonan Anda sedang ditinjau oleh tim teknis dinas terkait.',
      waktu: _tracking.length > 1
          ? _formatTanggalWaktu(_tracking[1]['waktu']?.toString())
          : '',
      hasBerkas: false,
    ));

    items.add(_RiwayatItem(
      judul: 'Verifikasi Berkas',
      deskripsi:
          'Berkas administrasi telah diverifikasi dan dinyatakan lengkap.',
      waktu: _tracking.isNotEmpty
          ? _formatTanggalWaktu(_tracking[0]['waktu']?.toString())
          : '',
      hasBerkas: false,
    ));

    items.add(_RiwayatItem(
      judul: 'Pengajuan Terkirim',
      deskripsi: 'Data permohonan telah masuk ke dalam antrean sistem kami.',
      waktu: _formatTanggalWaktu(_permohonan?['tanggal_pengajuan']?.toString()),
      hasBerkas: false,
    ));

    return items;
  }

  Widget _buildUnduhButton() {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottom + 12),
      color: AppColors.white,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Mengunduh dokumen digital...',
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                ),
                backgroundColor: AppColors.dilapakTeal,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          icon: const Icon(Icons.download_rounded, size: 20),
          label: Text(
            'Unduh Dokumen Digital',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.dilapakTeal,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

class _RiwayatItem {
  final String judul;
  final String deskripsi;
  final String waktu;
  final bool hasBerkas;

  const _RiwayatItem({
    required this.judul,
    required this.deskripsi,
    required this.waktu,
    required this.hasBerkas,
  });
}

class _RiwayatTile extends StatelessWidget {
  final _RiwayatItem item;
  final bool isLast;
  final List<Map<String, dynamic>> berkasList;

  const _RiwayatTile({
    required this.item,
    required this.isLast,
    required this.berkasList,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.dilapakTeal,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.dilapakTeal.withOpacity(0.25),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.judul,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: item.hasBerkas
                                ? AppColors.dilapakTeal
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (item.waktu.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          item.waktu,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.deskripsi,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  if (item.hasBerkas && berkasList.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildBerkasPreview(context, berkasList.first),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBerkasPreview(
      BuildContext context, Map<String, dynamic> berkas) {
    final path = berkas['path_file']?.toString() ?? '';
    final nama = berkas['nama_berkas']?.toString() ?? 'Dokumen';
    final isImage = ['jpg', 'jpeg', 'png', 'webp']
        .contains(path.split('.').last.toLowerCase());

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderColor),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isImage && path.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.file(
                File(path),
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildBerkasPlaceholder(),
              ),
            )
          else
            _buildBerkasPlaceholder(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: AppColors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nama,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.remove_red_eye_outlined,
                  size: 18,
                  color: AppColors.dilapakTeal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBerkasPlaceholder() {
    return Container(
      width: double.infinity,
      height: 140,
      color: AppColors.dilapakBackground,
      child: const Center(
        child: Icon(
          Icons.description_outlined,
          size: 48,
          color: AppColors.dilapakTeal,
        ),
      ),
    );
  }
}
