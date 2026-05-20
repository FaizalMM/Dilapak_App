import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/permohonan_model.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

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
    'Des'
  ];
  final jam = dt.hour.toString().padLeft(2, '0');
  final menit = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} ${bulan[dt.month]} ${dt.year}, $jam:$menit';
}

class TrackingScreen extends StatelessWidget {
  final Permohonan permohonan;

  const TrackingScreen({super.key, required this.permohonan});

  Color get _accentColor {
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
        title: Text(
          'Detail Permohonan',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 20),
            Text(
              'Tracking Status',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildTrackingCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(status: permohonan.status),
          const SizedBox(height: 10),
          Text(
            permohonan.jenisLayanan,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            permohonan.namaPemohon,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderColor),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoItem(
                  label: 'NO. RESI',
                  value: permohonan.nomorResi,
                ),
              ),
              Expanded(
                child: _InfoItem(
                  label: 'TANGGAL PENGAJUAN',
                  value: _formatDateTime(permohonan.tanggalPengajuan),
                ),
              ),
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(
          permohonan.trackingSteps.length,
          (index) => _TrackingStepTile(
            step: permohonan.trackingSteps[index],
            isLast: index == permohonan.trackingSteps.length - 1,
            accentColor: _accentColor,
          ),
        ),
      ),
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
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _TrackingStepTile extends StatelessWidget {
  final TrackingStep step;
  final bool isLast;
  final Color accentColor;

  const _TrackingStepTile({
    required this.step,
    required this.isLast,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDone = step.status == TrackingStepStatus.selesai;
    final bool isActive = step.status == TrackingStepStatus.aktif;
    final bool isWaiting = step.status == TrackingStepStatus.menunggu;

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
                                color: accentColor,
                              ),
                            ),
                          )
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
                  Text(
                    step.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isWaiting
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (step.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.description!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isWaiting
                            ? AppColors.textMuted
                            : AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(step.timestamp!),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDone ? const Color(0xFF10B981) : accentColor,
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
}
