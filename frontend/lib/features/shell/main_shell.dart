import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/screens/login_screen.dart';
import '../home/screens/home_screen.dart';
import '../station/screens/station_screen.dart';
import '../scan/screens/scan_screen.dart';
import '../history/screens/history_screen.dart';
import '../profile/screens/profile_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'EVOLTSOFT',
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 20),
            ),
            onPressed: () {
              // TODO: search
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary, size: 20),
            ),
            onPressed: () {
              // TODO: notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary, size: 20),
            onPressed: () {
              ref.read(authProvider.notifier).reset();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: PersistentTabView(
        tabs: [
          PersistentTabConfig(
            screen: const HomeScreen(),
            item: ItemConfig(
              icon: const Icon(Icons.home_rounded),
              title: 'Home',
              activeForegroundColor: AppColors.primary,
              inactiveForegroundColor: AppColors.textTertiary,
            ),
          ),
          PersistentTabConfig(
            screen: const StationScreen(),
            item: ItemConfig(
              icon: const Icon(Icons.ev_station_rounded),
              title: 'Station',
              activeForegroundColor: AppColors.primary,
              inactiveForegroundColor: AppColors.textTertiary,
            ),
          ),
          PersistentTabConfig(
            screen: const ScanScreen(),
            item: ItemConfig(
              icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
              title: 'Scan',
              activeForegroundColor: AppColors.primary,
              inactiveForegroundColor: AppColors.textTertiary,
            ),
          ),
          PersistentTabConfig(
            screen: const HistoryScreen(),
            item: ItemConfig(
              icon: const Icon(Icons.history_rounded),
              title: 'History',
              activeForegroundColor: AppColors.primary,
              inactiveForegroundColor: AppColors.textTertiary,
            ),
          ),
          PersistentTabConfig(
            screen: const ProfileScreen(),
            item: ItemConfig(
              icon: const Icon(Icons.person_rounded),
              title: 'Profile',
              activeForegroundColor: AppColors.primary,
              inactiveForegroundColor: AppColors.textTertiary,
            ),
          ),
        ],
        navBarBuilder: (navBarConfig) => Style13BottomNavBar(
          navBarConfig: navBarConfig,
          navBarDecoration: NavBarDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
