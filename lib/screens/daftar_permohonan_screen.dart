import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../utils/session_manager.dart';
import 'detail_permohonan_screen.dart';

class DaftarPermohonanScreen extends StatefulWidget {
  const DaftarPermohonanScreen({super.key});

  @override
  State<DaftarPermohonanScreen> createState() => _DaftarPermohonanScreenState();
}

class _DaftarPermohonanScreenState extends State<DaftarPermohonanScreen>
    with AutomaticKeepAliveClientMixin {
  // AutomaticKeepAliveClientMixin agar state tidak direset saat pindah tab
  @override
  bool get wantKeepAlive => false; // false = selalu reload saat kembali ke tab

  Timer? _timer;
  String? _selectedFilter;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allPermohonan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    // Auto refresh setiap 30 detik
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await SessionManager.instance.getUserId();
    if (userId == null) return;
    final list = await DatabaseHelper.instance.getPermohonanByUser(userId);
    if (mounted) {
      setState(() {
        _allPermohonan = list;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    var list = _allPermohonan;
    if (_selectedFilter != null) {
      list = list.where((p) => p['status'] == _selectedFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p['nomor_resi'].toString().toLowerCase().contains(q) ||
              p['nama_pemohon'].toString().toLowerCase().contains(q) ||
              p['nama_layanan'].toString().toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  int _countByStatus(String? status) {
    if (status == null) return _allPermohonan.length;
    return _allPermohonan.where((p) => p['status'] == status).length;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // ─── BUILD — DESAIN ASLI TIDAK DIUBAH ───
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSearchBar(),
        _buildFilterChips(),
        Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildList()),
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
                offset: const Offset(0, 2)),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Cari nomor resi atau nama...',
            hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13.5, color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textMuted, size: 20),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      _FilterOption(label: 'Semua', count: _countByStatus(null), value: null),
      _FilterOption(
          label: 'Baru', count: _countByStatus('baru'), value: 'baru'),
      _FilterOption(
          label: 'Menunggu',
          count: _countByStatus('menunggu'),
          value: 'menunggu'),
      _FilterOption(
          label: 'Diproses',
          count: _countByStatus('diproses'),
          value: 'diproses'),
      _FilterOption(
          label: 'Selesai', count: _countByStatus('selesai'), value: 'selesai'),
      _FilterOption(
          label: 'Ditolak', count: _countByStatus('ditolak'), value: 'ditolak'),
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
      return RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.dilapakTeal,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 48, color: AppColors.textMuted.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Text('Tidak ada permohonan',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, color: AppColors.textMuted)),
                    const SizedBox(height: 8),
                    Text('Tarik ke bawah untuk memperbarui',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12, color: AppColors.textMuted)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.dilapakTeal,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _PermohonanCard(
            data: items[index],
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DetailPermohonanScreen(permohonanId: items[index]['id']),
                ),
              );
              _loadData();
            },
          );
        },
      ),
    );
  }
}

class _FilterOption {
  final String label;
  final int count;
  final String? value;
  const _FilterOption(
      {required this.label, required this.count, required this.value});
}

// ─── PERMOHONAN CARD — DESAIN ASLI SAMA PERSIS ───

class _PermohonanCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _PermohonanCard({
    required this.data,
    required this.onTap,
  });

  Color _statusColor(String s) {
    switch (s) {
      case 'selesai':
        return const Color(0xFF22C55E);
      case 'diproses':
        return const Color(0xFF2D7DD2);
      case 'ditolak':
        return const Color(0xFFEF4444);
      case 'baru':
        return AppColors.dilapakTeal;
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'selesai':
        return 'Selesai';
      case 'diproses':
        return 'Diproses';
      case 'ditolak':
        return 'Ditolak';
      case 'baru':
        return 'Baru';
      default:
        return 'Menunggu';
    }
  }

  String _formatTanggal(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso);
      const b = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Ags',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      return '${dt.day} ${b[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = data['status']?.toString() ?? 'menunggu';
    final statusColor = _statusColor(status);

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
                offset: const Offset(0, 3))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.description_outlined,
                        color: statusColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['nama_layanan']?.toString() ?? '-',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(data['kategori']?.toString() ?? '-',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(_statusLabel(status),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.borderColor),
              const SizedBox(height: 10),
              Row(
                children: [
                  _InfoChip(
                      icon: Icons.confirmation_number_outlined,
                      text: data['nomor_resi']?.toString() ?? '-'),
                  const SizedBox(width: 16),
                  _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      text: _formatTanggal(
                          data['tanggal_pengajuan']?.toString())),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Lihat detail ',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dilapakTeal)),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 14, color: AppColors.dilapakTeal),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoChip({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(text,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
