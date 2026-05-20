import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/permohonan_model.dart';
import '../theme/app_theme.dart';
import 'status_badge.dart';

String _formatDateTime(DateTime dt) {
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
  return '${dt.day} ${bulan[dt.month]} ${dt.year}, $jam:$menit';
}

class PermohonanCard extends StatelessWidget {
  final Permohonan permohonan;
  final VoidCallback? onTap;

  const PermohonanCard({
    super.key,
    required this.permohonan,
    this.onTap,
  });

  Color get _borderColor {
    switch (permohonan.status) {
      case StatusPermohonan.baru:
        return const Color(0xFF3B82F6);
      case StatusPermohonan.diproses:
        return const Color(0xFFF59E0B);
      case StatusPermohonan.selesai:
        return const Color(0xFF10B981);
      case StatusPermohonan.ditolak:
        return const Color(0xFFEF4444);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: _borderColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatusBadge(status: permohonan.status),
                        const SizedBox(height: 8),
                        Text(
                          permohonan.jenisLayanan,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          permohonan.namaPemohon,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppColors.borderColor),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _MetaItem(
                                label: 'NO. RESI',
                                value: permohonan.nomorResi,
                              ),
                            ),
                            Expanded(
                              child: _MetaItem(
                                label: 'TANGGAL PENGAJUAN',
                                value: _formatDateTime(
                                    permohonan.tanggalPengajuan),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _MetaItem extends StatelessWidget {
  final String label;
  final String value;

  const _MetaItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
