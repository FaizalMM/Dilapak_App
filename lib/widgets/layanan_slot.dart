import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LayananSlot extends StatelessWidget {
  final String label;
  final String? selectedLayanan;
  final VoidCallback onTap;

  const LayananSlot({
    super.key,
    required this.label,
    this.selectedLayanan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedLayanan != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasValue
                    ? AppColors.dilapakTeal.withValues(alpha: 0.5)
                    : AppColors.borderColor,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? selectedLayanan! : 'Pilih jenis layanan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      color: hasValue
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: hasValue ? AppColors.dilapakTeal : AppColors.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
