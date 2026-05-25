import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      type: OnboardingType.illustration,
      title: 'Layanan Publik dalam\nGenggaman',
      description:
          'Urus berbagai dokumen kependudukan dan layanan publik lainnya dengan mudah, cepat, dan aman langsung dari perangkat Anda.',
      primaryColor: AppColors.dilapakTeal,
      backgroundColor: AppColors.white,
    ),
    OnboardingData(
      type: OnboardingType.serviceCards,
      title: 'Semua Layanan di Satu\nTempat',
      description:
          'Mulai dari urusan kependudukan hingga perizinan, semua bisa diakses dari satu aplikasi.',
      primaryColor: AppColors.bluePrimary,
      backgroundColor: AppColors.blueLight,
    ),
    OnboardingData(
      type: OnboardingType.featureIcons,
      title: 'Cepat, Aman, dan\nTransparan',
      description:
          'Pantau status permohonan Anda secara real-time kapan saja dan di mana saja.',
      primaryColor: AppColors.bluePrimary,
      backgroundColor: AppColors.dilapakBackground,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return _OnboardingPage(data: _pages[index]);
              },
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, right: 20),
                  child: TextButton(
                    onPressed: _goToLogin,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bluePrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomBar(
                currentPage: _currentPage,
                totalPages: _pages.length,
                pageController: _pageController,
                isLastPage: isLastPage,
                primaryColor: _pages[_currentPage].primaryColor,
                onNext: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PageController pageController;
  final bool isLastPage;
  final Color primaryColor;
  final VoidCallback onNext;

  const _BottomBar({
    required this.currentPage,
    required this.totalPages,
    required this.pageController,
    required this.isLastPage,
    required this.primaryColor,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentPage == 0) ...[
            // Page 1: dot indicator bottom-left, next button bottom-right as FAB
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SmoothPageIndicator(
                  controller: pageController,
                  count: totalPages,
                  effect: ExpandingDotsEffect(
                    activeDotColor: primaryColor,
                    dotColor: Colors.grey.shade300,
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 3.5,
                    spacing: 6,
                  ),
                ),
                GestureDetector(
                  onTap: onNext,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: AppColors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (currentPage == 1) ...[
            // Page 2: indicator centered, Next button full-width
            SmoothPageIndicator(
              controller: pageController,
              count: totalPages,
              effect: ExpandingDotsEffect(
                activeDotColor: primaryColor,
                dotColor: Colors.grey.shade300,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3.5,
                spacing: 6,
              ),
            ),
            const SizedBox(height: 20),
            _PrimaryButton(
              label: 'Next',
              icon: Icons.arrow_forward,
              color: primaryColor,
              onTap: onNext,
            ),
          ] else ...[
            // Page 3: indicator centered, Mulai Sekarang button full-width
            SmoothPageIndicator(
              controller: pageController,
              count: totalPages,
              effect: ExpandingDotsEffect(
                activeDotColor: primaryColor,
                dotColor: Colors.grey.shade300,
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3.5,
                spacing: 6,
              ),
            ),
            const SizedBox(height: 20),
            _PrimaryButton(
              label: 'Mulai Sekarang',
              icon: Icons.arrow_forward,
              color: primaryColor,
              onTap: onNext,
            ),
          ],
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: AppColors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

enum OnboardingType { illustration, serviceCards, featureIcons }

class OnboardingData {
  final OnboardingType type;
  final String title;
  final String description;
  final Color primaryColor;
  final Color backgroundColor;

  OnboardingData({
    required this.type,
    required this.title,
    required this.description,
    required this.primaryColor,
    required this.backgroundColor,
  });
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: data.backgroundColor,
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
              child: _buildVisual(),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 120),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                      height: 1.65,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisual() {
    switch (data.type) {
      case OnboardingType.illustration:
        return _IllustrationWidget();
      case OnboardingType.serviceCards:
        return _ServiceCardsWidget();
      case OnboardingType.featureIcons:
        return _FeatureIconsWidget();
    }
  }
}

// Page 1 visual: woman with phone illustration (teal style)
class _IllustrationWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 1.1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE8F8F7), Color(0xFFF5FFFE)],
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.dilapakTeal.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone_android_rounded,
                          size: 40,
                          color: AppColors.dilapakTeal,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.dilapakTeal,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Layanan Digital',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Page 2 visual: service category cards (Kependudukan, Kesehatan, Pendidikan)
class _ServiceCardsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ServiceCard(
            label: 'Kependudukan',
            icon: Icons.people_alt_rounded,
            iconColor: AppColors.bluePrimary,
            iconBackground: AppColors.blueLight,
            width: 260,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ServiceCard(
                label: 'Kesehatan',
                icon: Icons.health_and_safety_rounded,
                iconColor: AppColors.bluePrimary,
                iconBackground: AppColors.blueLight,
                width: 124,
              ),
              SizedBox(width: 12),
              _ServiceCard(
                label: 'Pendidikan',
                icon: Icons.school_rounded,
                iconColor: AppColors.textSecondary,
                iconBackground: Color(0xFFEEEEEE),
                width: 124,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final double width;

  const _ServiceCard({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Page 3 visual: Shield, Speed, Checkmark icons card
class _FeatureIconsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 260,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 16,
                  top: 20,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8EDF5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 20,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEEEEE),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 44,
                            color: AppColors.bluePrimary,
                          ),
                          SizedBox(width: 20),
                          Icon(
                            Icons.speed_rounded,
                            size: 44,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 44,
                        color: Color(0xFF22C55E),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Lock badge top-right
          Positioned(
            top: -12,
            right: -12,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 18,
                color: AppColors.bluePrimary,
              ),
            ),
          ),
          // Clock badge bottom-left
          Positioned(
            bottom: -12,
            left: -12,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.history_rounded,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
