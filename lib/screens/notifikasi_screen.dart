import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/app_data.dart';
import '../models/notifikasi_model.dart';
import '../theme/app_theme.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Notifikasi> get _filtered {
    final list = AppData.daftarNotifikasi;
    if (_searchQuery.isEmpty) return list;
    final q = _searchQuery.toLowerCase();
    return list
        .where((n) =>
            n.judul.toLowerCase().contains(q) ||
            n.isi.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Cari notifikasi...',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    final items = _filtered;
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 48, color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'Tidak ada notifikasi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) =>
          _NotifikasiTile(notifikasi: items[index]),
    );
  }
}

class _NotifikasiTile extends StatelessWidget {
  final Notifikasi notifikasi;

  const _NotifikasiTile({required this.notifikasi});

  Color get _iconBgColor {
    switch (notifikasi.type) {
      case NotifikasiType.statusUpdate:
        return AppColors.dilapakTeal;
      case NotifikasiType.infoLayanan:
        return const Color(0xFF3B82F6);
      case NotifikasiType.dokumenTidakLengkap:
        return AppColors.borderColor;
      case NotifikasiType.permohonanDiterima:
        return AppColors.borderColor;
    }
  }

  Color get _iconColor {
    switch (notifikasi.type) {
      case NotifikasiType.statusUpdate:
      case NotifikasiType.infoLayanan:
        return AppColors.white;
      case NotifikasiType.dokumenTidakLengkap:
      case NotifikasiType.permohonanDiterima:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (notifikasi.type) {
      case NotifikasiType.statusUpdate:
        return Icons.check_circle_rounded;
      case NotifikasiType.infoLayanan:
        return Icons.info_rounded;
      case NotifikasiType.dokumenTidakLengkap:
        return Icons.error_outline_rounded;
      case NotifikasiType.permohonanDiterima:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: notifikasi.isNew
            ? const Border(
                left: BorderSide(
                  color: AppColors.dilapakTeal,
                  width: 4,
                ),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notifikasi.judul,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        notifikasi.waktu,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: notifikasi.isNew
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: notifikasi.isNew
                              ? AppColors.dilapakTeal
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notifikasi.isi,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
