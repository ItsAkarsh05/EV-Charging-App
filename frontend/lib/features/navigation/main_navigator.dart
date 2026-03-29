import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class MainNavigator extends ConsumerWidget {
  const MainNavigator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        shadowColor: AppColors.textTertiary.withValues(alpha: 0.6),
        elevation: 0.5,
        scrolledUnderElevation: 0,
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
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.textTertiary, width: 0.5),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            onPressed: () {
              // TODO: open search
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.textTertiary, width: 0.5),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
            onPressed: () {
              // TODO: open notifications
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () async {
              // sign out and clear local state
              await FirebaseAuth.instance.signOut();
              ref.read(authProvider.notifier).reset();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
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
              inactiveForegroundColor: AppColors.textSecondary,
            ),
          ),
          PersistentTabConfig(
            screen: const StationScreen(),
            item: ItemConfig(
              icon: const Icon(Icons.ev_station_rounded),
              title: 'Station',
              activeForegroundColor: AppColors.primary,
              inactiveForegroundColor: AppColors.textSecondary,
            ),
          ),
          PersistentTabConfig(
            screen: const ScanScreen(),
            item: ItemConfig(
              icon: const Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.white,
              ),
              title: 'Scan',
              activeForegroundColor: AppColors.primary,
              inactiveForegroundColor: AppColors.textSecondary,
            ),
          ),
          PersistentTabConfig(
            screen: const HistoryScreen(),
            item: ItemConfig(
              icon: const Icon(Icons.history_rounded),
              title: 'History',
              activeForegroundColor: AppColors.primary,
              inactiveForegroundColor: AppColors.textSecondary,
            ),
          ),
          PersistentTabConfig(
            screen: const ProfileScreen(),
            item: ItemConfig(
              icon: const Icon(Icons.person_rounded),
              title: 'Profile',
              activeForegroundColor: AppColors.primary,
              inactiveForegroundColor: AppColors.textSecondary,
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
