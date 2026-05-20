import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/layanan_data.dart';
import '../theme/app_theme.dart';

class LayananPickerSheet extends StatefulWidget {
  final String? selectedLayanan;
  final void Function(String layanan) onSelected;

  const LayananPickerSheet({
    super.key,
    this.selectedLayanan,
    required this.onSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    String? selectedLayanan,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LayananPickerSheet(
        selectedLayanan: selectedLayanan,
        onSelected: (v) => Navigator.pop(context, v),
      ),
    );
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

  List<LayananCategory> get _filtered {
    if (_query.isEmpty) return allLayanan;
    return allLayanan
        .map((cat) => LayananCategory(
              name: cat.name,
              items: cat.items
                  .where((item) =>
                      item.toLowerCase().contains(_query.toLowerCase()))
                  .toList(),
            ))
        .where((cat) => cat.items.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
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
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Layanan tidak ditemukan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 16),
                      itemCount: _buildItems(filtered).length,
                      itemBuilder: (_, index) => _buildItems(filtered)[index],
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
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Pilih Jenis Layanan',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
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
            color: AppColors.textMuted,
            fontSize: 13.5,
          ),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textMuted, size: 20),
          filled: true,
          fillColor: AppColors.offWhite,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildItems(List<LayananCategory> categories) {
    final widgets = <Widget>[];
    for (int i = 0; i < categories.length; i++) {
      if (i > 0) {
        widgets.add(
            const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)));
      }
      widgets.add(_buildCategoryHeader(categories[i].name));
      for (final item in categories[i].items) {
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
      child: Text(
        name,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.dilapakTeal,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildServiceItem(String item) {
    final isSelected = item == widget.selectedLayanan;
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
              child: Text(
                item,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_rounded, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
