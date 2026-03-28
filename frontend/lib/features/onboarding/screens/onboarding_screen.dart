import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../auth/screens/login_screen.dart';

// data for each onboarding page
class _OnboardingPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<_FloatingIcon> floatingIcons;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.floatingIcons,
  });
}

class _FloatingIcon {
  final IconData icon;
  final double top;
  final double left;
  final double size;

  const _FloatingIcon({
    required this.icon,
    required this.top,
    required this.left,
    this.size = 24,
  });
}

// onboarding page data
final _pages = [
  _OnboardingPage(
    title: 'Find Charging\nStations Nearby',
    subtitle:
        'Locate the nearest EV charging stations on an interactive map with real-time availability updates.',
    icon: Icons.location_on_rounded,
    floatingIcons: const [
      _FloatingIcon(icon: Icons.ev_station_rounded, top: 0.10, left: 0.08, size: 28),
      _FloatingIcon(icon: Icons.map_rounded, top: 0.06, left: 0.75, size: 22),
      _FloatingIcon(icon: Icons.near_me_rounded, top: 0.30, left: 0.85, size: 20),
      _FloatingIcon(icon: Icons.place_rounded, top: 0.28, left: 0.05, size: 18),
    ],
  ),
  _OnboardingPage(
    title: 'Check Connector\nAvailability',
    subtitle:
        'View live charger status, connector types, and power output before you even arrive at the station.',
    icon: Icons.electrical_services_rounded,
    floatingIcons: const [
      _FloatingIcon(icon: Icons.bolt_rounded, top: 0.08, left: 0.12, size: 26),
      _FloatingIcon(icon: Icons.power_rounded, top: 0.05, left: 0.78, size: 24),
      _FloatingIcon(icon: Icons.speed_rounded, top: 0.29, left: 0.88, size: 20),
      _FloatingIcon(icon: Icons.battery_charging_full_rounded, top: 0.30, left: 0.04, size: 22),
    ],
  ),
  _OnboardingPage(
    title: 'Start Charging\nSeamlessly',
    subtitle:
        'Scan the QR code, plug in, and start your charging session — all from the palm of your hand.',
    icon: Icons.qr_code_scanner_rounded,
    floatingIcons: const [
      _FloatingIcon(icon: Icons.flash_on_rounded, top: 0.09, left: 0.10, size: 24),
      _FloatingIcon(icon: Icons.timer_rounded, top: 0.06, left: 0.80, size: 22),
      _FloatingIcon(icon: Icons.electric_car_rounded, top: 0.28, left: 0.86, size: 26),
      _FloatingIcon(icon: Icons.check_circle_rounded, top: 0.30, left: 0.06, size: 20),
    ],
  ),
];

// onboarding screen
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late final AnimationController _heroController;
  late final Animation<double> _heroScale;
  late final Animation<double> _heroFade;

  @override
  void initState() {
    super.initState();
    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _heroScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.elasticOut),
    );
    _heroFade = CurvedAnimation(parent: _heroController, curve: Curves.easeIn);
    _heroController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(opacity: anim, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    _heroController.reset();
    _heroController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 20, top: 12),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            // pages (swipeable)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingPageView(
                    page: page,
                    heroScale: _heroScale,
                    heroFade: _heroFade,
                    screenSize: size,
                  );
                },
              ),
            ),

            // dot indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (i) {
                  final isActive = i == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: isActive ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textTertiary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),

            // next / get started button
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    if (isLastPage) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLastPage ? 'Get Started' : 'Next',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!isLastPage) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// single onboarding page
class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  final Animation<double> heroScale;
  final Animation<double> heroFade;
  final Size screenSize;

  const _OnboardingPageView({
    required this.page,
    required this.heroScale,
    required this.heroFade,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 1),

          // hero illustration
          FadeTransition(
            opacity: heroFade,
            child: ScaleTransition(
              scale: heroScale,
              child: SizedBox(
                height: screenSize.height * 0.38,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // background glow
                    Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.12),
                            AppColors.primary.withOpacity(0.04),
                            Colors.transparent,
                          ],
                          stops: const [0.3, 0.7, 1.0],
                        ),
                      ),
                    ),

                    // icon circle
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primarySurface,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        page.icon,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),

                    // ring dots
                    ...List.generate(12, (i) {
                      final angle = (i * 30) * (pi / 180);
                      const radius = 120.0;
                      return Positioned(
                        left: (screenSize.width - 56) / 2 -
                            28 +
                            radius * cos(angle) +
                            radius,
                        top: screenSize.height * 0.38 / 2 -
                            4 +
                            radius * sin(angle),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary.withOpacity(
                              i % 3 == 0 ? 0.4 : 0.15,
                            ),
                          ),
                        ),
                      );
                    }),

                    // floating accent icons
                    ...page.floatingIcons.map((fi) {
                      return Positioned(
                        top: screenSize.height * 0.38 * fi.top,
                        left: (screenSize.width - 56) * fi.left,
                        child: _FloatingIconWidget(data: fi),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

          const Spacer(flex: 1),

          // title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.displayLarge.copyWith(
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),

          // subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),

          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

// floating icon with pulse animation
class _FloatingIconWidget extends StatefulWidget {
  final _FloatingIcon data;
  const _FloatingIconWidget({required this.data});

  @override
  State<_FloatingIconWidget> createState() => _FloatingIconWidgetState();
}

class _FloatingIconWidgetState extends State<_FloatingIconWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800 + (widget.data.size * 30).toInt()),
    )..repeat(reverse: true);

    _float = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          widget.data.icon,
          size: widget.data.size,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
