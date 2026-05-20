import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/app_data.dart';
import '../models/permohonan_model.dart';
import '../theme/app_theme.dart';
import '../widgets/permohonan_card.dart';
import 'tracking_screen.dart';

class DaftarPermohonanScreen extends StatefulWidget {
  const DaftarPermohonanScreen({super.key});

  @override
  State<DaftarPermohonanScreen> createState() => _DaftarPermohonanScreenState();
}

class _DaftarPermohonanScreenState extends State<DaftarPermohonanScreen> {
  StatusPermohonan? _selectedFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Permohonan> get _filtered {
    var list = AppData.daftarPermohonan;
    if (_selectedFilter != null) {
      list = list.where((p) => p.status == _selectedFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.nomorResi.toLowerCase().contains(q) ||
              p.namaPemohon.toLowerCase().contains(q) ||
              p.jenisLayanan.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  int _countByStatus(StatusPermohonan? status) {
    if (status == null) return AppData.daftarPermohonan.length;
    return AppData.daftarPermohonan.where((p) => p.status == status).length;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(child: _buildList()),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
            hintText: 'Cari nomor resi atau nama...',
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

  Widget _buildFilterChips() {
    final filters = [
      _FilterOption(label: 'Semua', count: _countByStatus(null), value: null),
      _FilterOption(
          label: 'Baru',
          count: _countByStatus(StatusPermohonan.baru),
          value: StatusPermohonan.baru),
      _FilterOption(
          label: 'Diproses',
          count: _countByStatus(StatusPermohonan.diproses),
          value: StatusPermohonan.diproses),
      _FilterOption(
          label: 'Selesai',
          count: _countByStatus(StatusPermohonan.selesai),
          value: StatusPermohonan.selesai),
      _FilterOption(
          label: 'Ditolak',
          count: _countByStatus(StatusPermohonan.ditolak),
          value: StatusPermohonan.ditolak),
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = filters[index];
          final isSelected = _selectedFilter == f.value;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.dilapakTeal : Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isSelected
                      ? AppColors.dilapakTeal
                      : AppColors.borderColor,
                  width: 1.5,
                ),
              ),
              child: Text(
                '${f.label} (${f.count})',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
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
            Icon(Icons.inbox_outlined,
                size: 48, color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'Tidak ada permohonan',
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return PermohonanCard(
          permohonan: items[index],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TrackingScreen(permohonan: items[index]),
            ),
          ),
        );
      },
    );
  }
}

class _FilterOption {
  final String label;
  final int count;
  final StatusPermohonan? value;

  const _FilterOption({
    required this.label,
    required this.count,
    required this.value,
  });
}
