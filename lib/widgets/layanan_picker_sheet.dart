import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class LayananPickerSheet extends StatefulWidget {
  final String? selectedLayanan;
  final void Function(Map<String, dynamic> layanan) onSelected;
  final List<Map<String, dynamic>> layananList;

  const LayananPickerSheet({
    super.key,
    this.selectedLayanan,
    required this.onSelected,
    required this.layananList,
  });

  /// Dipakai oleh TambahPermohonanScreen dan Tiga1FormScreen
  /// Mengembalikan Map<String,dynamic> layanan yang dipilih (dari SQLite)
  static Future<Map<String, dynamic>?> showFromDb(
    BuildContext context,
    List<Map<String, dynamic>> layananList, {
    String? selectedLayanan,
  }) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LayananPickerSheet(
        selectedLayanan: selectedLayanan,
        layananList: layananList,
        onSelected: (v) => Navigator.pop(context, v),
      ),
    );
  }

  /// Backward-compat: dipakai kode lama yang hanya butuh String nama layanan
  static Future<String?> show(
    BuildContext context, {
    String? selectedLayanan,
    List<Map<String, dynamic>>? layananList,
  }) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LayananPickerSheet(
        selectedLayanan: selectedLayanan,
        layananList: layananList ?? [],
        onSelected: (v) => Navigator.pop(context, v),
      ),
    );
    return result?['nama']?.toString();
  }

  @override
  State<LayananPickerSheet> createState() => _LayananPickerSheetState();
}

class _LayananPickerSheetState extends State<LayananPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Group layanan by kategori
  Map<String, List<Map<String, dynamic>>> get _grouped {
    final map = <String, List<Map<String, dynamic>>>{};
    for (final l in widget.layananList) {
      if (_query.isNotEmpty &&
          !l['nama'].toString().toLowerCase().contains(_query.toLowerCase())) {
        continue;
      }
      final kat = l['kategori']?.toString() ?? 'Lainnya';
      map.putIfAbsent(kat, () => []).add(l);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.93,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            _buildDragHandle(),
            _buildHeader(context),
            _buildSearchBar(),
            const Divider(height: 1),
            Expanded(
              child: grouped.isEmpty
                  ? Center(
                      child: Text('Layanan tidak ditemukan',
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 13, color: AppColors.textMuted)))
                  : ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 16),
                      children: _buildItems(grouped),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDragHandle() {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
            color: AppColors.borderColor,
            borderRadius: BorderRadius.circular(2)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text('Pilih Jenis Layanan',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
        decoration: InputDecoration(
          hintText: 'Cari layanan...',
          hintStyle: GoogleFonts.plusJakartaSans(
              color: AppColors.textMuted, fontSize: 13.5),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textMuted, size: 20),
          filled: true,
          fillColor: AppColors.offWhite,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  List<Widget> _buildItems(Map<String, List<Map<String, dynamic>>> grouped) {
    final widgets = <Widget>[];
    final entries = grouped.entries.toList();
    for (int i = 0; i < entries.length; i++) {
      if (i > 0) {
        widgets.add(
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)));
      }
      widgets.add(_buildCategoryHeader(entries[i].key));
      for (final item in entries[i].value) {
        widgets.add(_buildServiceItem(item));
      }
      widgets.add(const SizedBox(height: 6));
    }
    return widgets;
  }

  Widget _buildCategoryHeader(String name) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF0F9F8),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Text(name.toUpperCase(),
          style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.dilapakTeal,
              letterSpacing: 1.0)),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> item) {
    final isSelected = item['nama']?.toString() == widget.selectedLayanan;
    return InkWell(
      onTap: () => widget.onSelected(item),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.dilapakTeal : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.dilapakTeal : AppColors.borderColor,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(item['nama']?.toString() ?? '-',
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400)),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
