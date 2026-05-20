import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/permohonan_model.dart';

class StatusBadge extends StatelessWidget {
  final StatusPermohonan status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12, color: _foregroundColor),
          const SizedBox(width: 4),
          Text(
            _label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: _foregroundColor,
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    switch (status) {
      case StatusPermohonan.baru:
        return 'BARU';
      case StatusPermohonan.diproses:
        return 'DIPROSES';
      case StatusPermohonan.selesai:
        return 'SELESAI';
      case StatusPermohonan.ditolak:
        return 'DITOLAK';
    }
  }

  Color get _backgroundColor {
    switch (status) {
      case StatusPermohonan.baru:
        return const Color(0xFFEFF6FF);
      case StatusPermohonan.diproses:
        return const Color(0xFFFFFBEB);
      case StatusPermohonan.selesai:
        return const Color(0xFFECFDF5);
      case StatusPermohonan.ditolak:
        return const Color(0xFFFEF2F2);
    }
  }

  Color get _foregroundColor {
    switch (status) {
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

  IconData get _icon {
    switch (status) {
      case StatusPermohonan.baru:
        return Icons.inbox_rounded;
      case StatusPermohonan.diproses:
        return Icons.hourglass_top_rounded;
      case StatusPermohonan.selesai:
        return Icons.check_circle_outline_rounded;
      case StatusPermohonan.ditolak:
        return Icons.cancel_outlined;
    }
  }
}
