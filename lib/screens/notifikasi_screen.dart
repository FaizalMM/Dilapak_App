import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../utils/session_manager.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allNotif = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = await SessionManager.instance.getUserId();
    if (userId == null) return;
    final list = await DatabaseHelper.instance.getNotifikasiByUser(userId);
    if (mounted)
      setState(() {
        _allNotif = list;
        _isLoading = false;
      });
  }

  List<Map<String, dynamic>> get _filtered {
    if (_searchQuery.isEmpty) return _allNotif;
    final q = _searchQuery.toLowerCase();
    return _allNotif
        .where((n) =>
            n['judul'].toString().toLowerCase().contains(q) ||
            n['isi'].toString().toLowerCase().contains(q))
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
        Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildList()),
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
                offset: const Offset(0, 2))
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) => setState(() => _searchQuery = val),
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Cari notifikasi...',
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
            Text('Tidak ada notifikasi',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14, color: AppColors.textMuted)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.dilapakTeal,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        itemCount: items.length,
        itemBuilder: (context, index) => _NotifikasiTile(
          notif: items[index],
          onTap: () async {
            await DatabaseHelper.instance.markRead(items[index]['id']);
            _loadData();
          },
        ),
      ),
    );
  }
}

class _NotifikasiTile extends StatelessWidget {
  final Map<String, dynamic> notif;
  final VoidCallback onTap;

  const _NotifikasiTile({required this.notif, required this.onTap});

  Color get _iconBgColor {
    switch (notif['tipe']?.toString()) {
      case 'sukses':
        return AppColors.dilapakTeal;
      case 'permohonan':
        return const Color(0xFF3B82F6);
      case 'peringatan':
        return AppColors.borderColor;
      default:
        return AppColors.borderColor;
    }
  }

  Color get _iconColor {
    switch (notif['tipe']?.toString()) {
      case 'sukses':
      case 'permohonan':
        return AppColors.white;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _icon {
    switch (notif['tipe']?.toString()) {
      case 'sukses':
        return Icons.check_circle_rounded;
      case 'permohonan':
        return Icons.description_outlined;
      case 'peringatan':
        return Icons.error_outline_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  bool get _isNew => notif['is_read'] == 0;

  String _formatWaktu(String? iso) {
    if (iso == null) return '-';
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
      if (diff.inHours < 24) return '${diff.inHours}j lalu';
      if (diff.inDays < 7) return '${diff.inDays}h lalu';
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
      return '${dt.day} ${b[dt.month - 1]}';
    } catch (_) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: _isNew
              ? const Border(
                  left: BorderSide(color: AppColors.dilapakTeal, width: 4))
              : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
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
                decoration:
                    BoxDecoration(color: _iconBgColor, shape: BoxShape.circle),
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
                          child: Text(notif['judul']?.toString() ?? '-',
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatWaktu(notif['created_at']?.toString()),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight:
                                _isNew ? FontWeight.w600 : FontWeight.w400,
                            color: _isNew
                                ? AppColors.dilapakTeal
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(notif['isi']?.toString() ?? '-',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
