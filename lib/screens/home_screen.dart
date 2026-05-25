import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../utils/session_manager.dart';
import '../screens/daftar_permohonan_screen.dart';
import '../screens/notifikasi_screen.dart';
import 'verifikasi_whatsapp_screen.dart';
import 'tambah_permohonan_screen.dart';
import 'tiga1_form_screen.dart';
import 'edit_profil_screen.dart';
import 'ubah_kata_sandi_screen.dart';
import 'pilih_layanan_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isVerifiedWa = false;
  bool _isVerifiedBerkas = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final userId = await SessionManager.instance.getUserId();
    if (userId == null) return;
    final user = await DatabaseHelper.instance.getUserById(userId);
    if (mounted && user != null) {
      setState(() {
        _isVerifiedWa = user['is_verified_wa'] == 1;
        _isVerifiedBerkas = user['is_verified_berkas'] == 1;
        _isLoading = false;
      });
    }
  }

  Future<void> _onVerified() async {
    await _loadStatus();
  }

  static const List<String> _pageTitles = [
    'Beranda',
    'Permohonan',
    'Notifikasi',
    'Profil',
  ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F6FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isVerified = _isVerifiedWa && _isVerifiedBerkas;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: _currentIndex == 0 ? null : _buildAppBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          isVerified
              ? _VerifiedDashboard(
                  onSwitchTab: (i) => setState(() => _currentIndex = i))
              : _UnverifiedDashboard(
                  isVerifiedWa: _isVerifiedWa, onVerified: _onVerified),
          const DaftarPermohonanScreen(),
          const NotifikasiScreen(),
          _ProfilPlaceholder(onRefresh: _loadStatus),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF4F6FA),
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      title: Text(
        _pageTitles[_currentIndex],
        style: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.dilapakTeal,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded,
                color: AppColors.white, size: 20),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// UNVERIFIED DASHBOARD
// ─────────────────────────────────────────────
class _UnverifiedDashboard extends StatelessWidget {
  final bool isVerifiedWa;
  final Future<void> Function() onVerified;

  const _UnverifiedDashboard({
    required this.isVerifiedWa,
    required this.onVerified,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Column(
        children: [
          const _TealAppBar(onNotifTap: null),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const _UnverifiedBannerCard(),
                  const SizedBox(height: 24),
                  _ProgressSection(
                    isVerifiedWa: isVerifiedWa,
                    onVerified: onVerified,
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Layanan Utama'),
                  const SizedBox(height: 12),
                  const _LayananUtamaRow(isVerified: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROGRESS SECTION
// ─────────────────────────────────────────────
class _ProgressSection extends StatelessWidget {
  final bool isVerifiedWa;
  final Future<void> Function() onVerified;

  const _ProgressSection({
    required this.isVerifiedWa,
    required this.onVerified,
  });

  int get _doneCount {
    int count = 1;
    if (isVerifiedWa) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progres Pendaftaran',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '$_doneCount/3 Selesai',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.dilapakTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
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
            children: [
              _ProgressItem(
                number: 1,
                title: 'Lengkapi Profil',
                state: _ProgressState.done,
                onVerified: onVerified,
              ),
              const Divider(height: 1, color: AppColors.borderColor),
              _ProgressItem(
                number: 2,
                title: 'Verifikasi WhatsApp',
                subtitle: isVerifiedWa
                    ? 'WhatsApp telah terverifikasi'
                    : 'Kirim kode verifikasi ke nomor WhatsApp Anda.',
                state:
                    isVerifiedWa ? _ProgressState.done : _ProgressState.active,
                onVerified: onVerified,
              ),
              const Divider(height: 1, color: AppColors.borderColor),
              _ProgressItem(
                number: 3,
                title: 'Unggah KTP & Swafoto',
                subtitle: isVerifiedWa
                    ? 'Unggah KTP dan swafoto untuk verifikasi identitas.'
                    : 'Terbuka setelah WhatsApp terverifikasi.',
                state: isVerifiedWa
                    ? _ProgressState.active
                    : _ProgressState.locked,
                onVerified: onVerified,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _ProgressState { done, active, locked }

class _ProgressItem extends StatelessWidget {
  final int number;
  final String title;
  final String? subtitle;
  final _ProgressState state;
  final Future<void> Function() onVerified;

  const _ProgressItem({
    required this.number,
    required this.title,
    this.subtitle,
    required this.state,
    required this.onVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StepIndicator(number: number, state: state),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: state == _ProgressState.locked
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        decoration: state == _ProgressState.done
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.textMuted,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (state == _ProgressState.active) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.45,
                minHeight: 6,
                backgroundColor: AppColors.borderColor,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.dilapakTeal),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const VerifikasiWhatsappScreen(),
                  ),
                );
                await onVerified();
              },
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.dilapakTeal,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dilapakTeal.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    number == 2 ? 'Verifikasi WhatsApp' : 'Unggah Berkas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int number;
  final _ProgressState state;
  const _StepIndicator({required this.number, required this.state});
  @override
  Widget build(BuildContext context) {
    if (state == _ProgressState.done) {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
            color: AppColors.greenPrimary, shape: BoxShape.circle),
        child:
            const Icon(Icons.check_rounded, color: AppColors.white, size: 18),
      );
    } else if (state == _ProgressState.active) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.dilapakTeal, width: 2)),
        child: Center(
          child: Text('$number',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.dilapakTeal)),
        ),
      );
    } else {
      return Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
            color: AppColors.borderColor, shape: BoxShape.circle),
        child: const Icon(Icons.lock_outline_rounded,
            color: AppColors.textMuted, size: 16),
      );
    }
  }
}

// ─────────────────────────────────────────────
// VERIFIED DASHBOARD
// ─────────────────────────────────────────────
class _VerifiedDashboard extends StatelessWidget {
  final ValueChanged<int> onSwitchTab;
  const _VerifiedDashboard({required this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Column(
        children: [
          _TealAppBar(onNotifTap: () => onSwitchTab(2)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const _VerifiedBannerCard(),
                  const SizedBox(height: 24),
                  const _LayananUtamaTappableTitle(),
                  const SizedBox(height: 12),
                  const _LayananUtamaRow(isVerified: true),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Kategori Layanan'),
                  const SizedBox(height: 12),
                  const _KategoriLayanan(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _SectionTitle(title: 'Permohonan Terbaru'),
                      GestureDetector(
                        onTap: () => onSwitchTab(1),
                        child: Text('Lihat Semua',
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.dilapakTeal)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const _PermohonanRecentList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TealAppBar extends StatelessWidget {
  final VoidCallback? onNotifTap;
  const _TealAppBar({this.onNotifTap});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return FutureBuilder<String?>(
      future: SessionManager.instance.getNama(),
      builder: (context, snap) {
        final nama = snap.data ?? 'Pengguna';
        return Container(
          color: AppColors.greenPrimary,
          padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 20),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.3), width: 1.5),
                ),
                child: Icon(Icons.person_rounded,
                    color: Colors.white.withOpacity(0.8), size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KOTA MADIUN',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.75),
                            letterSpacing: 0.8)),
                    const SizedBox(height: 2),
                    Text('Halo, $nama!',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white)),
                    const SizedBox(height: 2),
                    Text(
                        'Selamat datang kembali di layanan publik Kota Madiun.',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.75))),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onNotifTap,
                child: Stack(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.notifications_outlined,
                          color: AppColors.white, size: 22),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFF4444),
                              shape: BoxShape.circle)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UnverifiedBannerCard extends StatelessWidget {
  const _UnverifiedBannerCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
                color: Color(0xFFFFE4E4), shape: BoxShape.circle),
            child: const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFEF4444), size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Akun Belum Terverifikasi',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(
                    'Verifikasi identitas Anda untuk membuka akses penuh ke semua layanan publik digital.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifiedBannerCard extends StatelessWidget {
  const _VerifiedBannerCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE6F7F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.dilapakTeal.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: AppColors.dilapakTeal.withOpacity(0.15),
                shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.dilapakTeal, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Akun telah diverifikasi',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greenPrimary)),
                const SizedBox(height: 4),
                Text(
                    'Semua layanan kini dapat diakses. Anda bisa melakukan permohonan sekarang.',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                        height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LayananUtamaRow extends StatelessWidget {
  final bool isVerified;
  const _LayananUtamaRow({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    if (!isVerified) {
      return const Row(
        children: [
          _ServiceIconCard(icon: Icons.description_outlined),
          SizedBox(width: 10),
          _ServiceIconCard(icon: Icons.account_balance_outlined),
          SizedBox(width: 10),
          _ServiceIconCard(icon: Icons.lock_outline_rounded),
          SizedBox(width: 10),
          _ServiceIconCard(icon: Icons.school_outlined),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: _LayananBigCard(
            icon: Icons.add_rounded,
            label: 'Tambah\nPermohonan',
            color: AppColors.greenPrimary,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const TambahPermohonanScreen())),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _LayananBigCard(
            icon: Icons.layers_outlined,
            label: 'Layanan\n3 in 1',
            color: AppColors.bluePrimary,
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const Tiga1FormScreen())),
          ),
        ),
      ],
    );
  }
}

class _ServiceIconCard extends StatelessWidget {
  final IconData icon;
  const _ServiceIconCard({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Center(child: Icon(icon, color: AppColors.textMuted, size: 24)),
      ),
    );
  }
}

class _LayananBigCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _LayananBigCard(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle),
                  child: Icon(icon, color: AppColors.white, size: 20),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: Colors.white.withOpacity(0.85), size: 22),
              ],
            ),
            Text(label,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                    height: 1.3)),
          ],
        ),
      ),
    );
  }
}

class _KategoriLayanan extends StatelessWidget {
  static const List<Map<String, dynamic>> _items = [
    {'icon': Icons.badge_outlined, 'label': 'Kependudukan'},
    {'icon': Icons.description_outlined, 'label': 'Perizinan'},
    {'icon': Icons.health_and_safety_outlined, 'label': 'Kesehatan'},
    {'icon': Icons.school_outlined, 'label': 'Pendidikan'},
  ];
  const _KategoriLayanan();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _items
          .map((item) => _KategoriCard(
              icon: item['icon'] as IconData, label: item['label'] as String))
          .toList(),
    );
  }
}

class _KategoriCard extends StatelessWidget {
  final IconData icon;
  final String label;
  const _KategoriCard({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => PilihLayananScreen(kategori: label))),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
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
            child: Icon(icon, color: AppColors.textSecondary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _PermohonanRecentList extends StatefulWidget {
  const _PermohonanRecentList();
  @override
  State<_PermohonanRecentList> createState() => _PermohonanRecentListState();
}

class _PermohonanRecentListState extends State<_PermohonanRecentList> {
  List<Map<String, dynamic>> _list = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = await SessionManager.instance.getUserId();
    if (userId == null) return;
    final list = await DatabaseHelper.instance.getPermohonanByUser(userId);
    if (mounted) setState(() => _list = list.take(2).toList());
  }

  @override
  Widget build(BuildContext context) {
    if (_list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 3))
          ],
        ),
        child: Center(
            child: Text('Belum ada permohonan',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13, color: AppColors.textMuted))),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < _list.length; i++) ...[
            _PermohonanRow(item: _list[i]),
            if (i < _list.length - 1)
              const Divider(
                  height: 1,
                  color: AppColors.borderColor,
                  indent: 16,
                  endIndent: 16),
          ],
        ],
      ),
    );
  }
}

class _PermohonanRow extends StatelessWidget {
  final Map<String, dynamic> item;
  const _PermohonanRow({required this.item});

  Color _statusColor(String s) {
    switch (s) {
      case 'selesai':
        return const Color(0xFF22C55E);
      case 'diproses':
        return const Color(0xFF2D7DD2);
      case 'ditolak':
        return const Color(0xFFEF4444);
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
      default:
        return 'Menunggu';
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = item['status']?.toString() ?? 'menunggu';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.borderColor,
                borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.description_outlined,
                color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['nama_layanan']?.toString() ?? '-',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text(item['nomor_resi']?.toString() ?? '-',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: _statusColor(status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            child: Text(_statusLabel(status),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _statusColor(status))),
          ),
        ],
      ),
    );
  }
}

class _LayananUtamaTappableTitle extends StatelessWidget {
  const _LayananUtamaTappableTitle();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLayananUtamaSheet(context),
      child: Row(
        children: [
          Text('Layanan Utama',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const SizedBox(width: 6),
          const Icon(Icons.info_outline_rounded,
              size: 16, color: AppColors.dilapakTeal),
        ],
      ),
    );
  }

  void _showLayananUtamaSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LayananUtamaSheet(),
    );
  }
}

class _LayananUtamaSheet extends StatelessWidget {
  const _LayananUtamaSheet();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 16),
            child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2))),
          )),
          Text('Pilih Layanan',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(
              'Silakan pilih jenis layanan dokumen kependudukan yang Anda butuhkan.',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 13, color: AppColors.textSecondary, height: 1.55)),
          const SizedBox(height: 20),
          _SheetLayananCard(
            icon: Icons.document_scanner_outlined,
            iconColor: AppColors.dilapakTeal,
            iconBackground: const Color(0xFFE6F7F5),
            title: 'Tambah Permohonan',
            description:
                'Permohonan pembuatan/penerbitan 1 jenis layanan dokumen kependudukan.',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const TambahPermohonanScreen()));
            },
          ),
          const SizedBox(height: 14),
          _SheetLayananCard(
            icon: Icons.copy_all_rounded,
            iconColor: AppColors.bluePrimary,
            iconBackground: const Color(0xFFEBF3FF),
            title: 'Layanan Three In One',
            description:
                'Layanan pembuatan 3 dokumen kependudukan sekaligus dalam satu kali permohonan.',
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const Tiga1FormScreen()));
            },
          ),
        ],
      ),
    );
  }
}

class _SheetLayananCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String description;
  final VoidCallback onTap;
  const _SheetLayananCard(
      {required this.icon,
      required this.iconColor,
      required this.iconBackground,
      required this.title,
      required this.description,
      required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: iconColor, size: 24)),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Text(description,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.6)),
                ])),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary));
  }
}

// ─────────────────────────────────────────────
// PROFIL
// ─────────────────────────────────────────────
class _ProfilPlaceholder extends StatefulWidget {
  final Future<void> Function() onRefresh;
  const _ProfilPlaceholder({required this.onRefresh});
  @override
  State<_ProfilPlaceholder> createState() => _ProfilPlaceholderState();
}

class _ProfilPlaceholderState extends State<_ProfilPlaceholder> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userId = await SessionManager.instance.getUserId();
    if (userId == null) return;
    final user = await DatabaseHelper.instance.getUserById(userId);
    if (mounted) setState(() => _user = user);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Keluar Akun',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
        content: Text('Apakah Anda yakin ingin keluar dari akun Dilapak?',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SessionManager.instance.clearSession();
              if (!mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => const LoginScreen(),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 400),
                ),
                (route) => false,
              );
            },
            child: Text('Keluar',
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nama = _user?['nama_lengkap']?.toString() ?? 'Pengguna';
    final email =
        _user?['email']?.toString() ?? _user?['no_whatsapp']?.toString() ?? '-';

    return Column(
      children: [
        const SizedBox(height: 32),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                    color: AppColors.dilapakTeal, shape: BoxShape.circle),
                child: const Icon(Icons.person_rounded,
                    color: AppColors.white, size: 44),
              ),
              const SizedBox(height: 16),
              Text(nama,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(email,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 32),
              _ProfileTile(
                icon: Icons.person_outline_rounded,
                label: 'Data Diri',
                onTap: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProfilScreen()));
                  await _loadUser();
                  await widget.onRefresh();
                },
              ),
              _ProfileTile(
                icon: Icons.lock_outline_rounded,
                label: 'Ubah Kata Sandi',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UbahKataSandiScreen())),
              ),
              const _ProfileTile(
                  icon: Icons.notifications_outlined,
                  label: 'Pengaturan Notifikasi'),
              const _ProfileTile(
                  icon: Icons.help_outline_rounded, label: 'Bantuan & FAQ'),
              _ProfileTile(
                  icon: Icons.logout_rounded,
                  label: 'Keluar',
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;
  const _ProfileTile(
      {required this.icon,
      required this.label,
      this.isDestructive = false,
      this.onTap});
  @override
  Widget build(BuildContext context) {
    final color =
        isDestructive ? const Color(0xFFEF4444) : AppColors.textPrimary;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
          color: AppColors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 22),
        title: Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14, fontWeight: FontWeight.w500, color: color)),
        trailing: isDestructive
            ? null
            : const Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
        onTap: onTap,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BOTTOM NAV — Pill / Bubble style
// Tab aktif: icon + label di dalam pill berwarna
// Tab inaktif: icon + label tanpa background
// ─────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}

const List<_NavItem> _navItems = [
  _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Beranda'),
  _NavItem(
      icon: Icons.description_outlined,
      activeIcon: Icons.description_rounded,
      label: 'Permohonan'),
  _NavItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications_rounded,
      label: 'Notifikasi'),
  _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil'),
];

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_navItems.length, (i) {
              final isActive = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.dilapakTeal.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                isActive
                                    ? _navItems[i].activeIcon
                                    : _navItems[i].icon,
                                size: 22,
                                color: isActive
                                    ? AppColors.dilapakTeal
                                    : AppColors.textMuted,
                              ),
                              if (i == 2)
                                Positioned(
                                  top: 0,
                                  right: -2,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _navItems[i].label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? AppColors.dilapakTeal
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
