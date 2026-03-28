import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env
  await dotenv.load(fileName: ".env");

  // Lock portrait orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase (gracefully handle misconfiguration)
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    debugPrint('⚠️ Firebase init failed: $e');
  }

  // Check onboarding and auth state
  bool onboardingComplete = false;
  bool isLoggedIn = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
    if (firebaseReady) {
      isLoggedIn = FirebaseAuth.instance.currentUser != null;
    }
  } catch (e) {
    debugPrint('⚠️ SharedPreferences error: $e');
  }

  runApp(ProviderScope(
    child: EvoltSoftApp(
      onboardingComplete: onboardingComplete,
      isLoggedIn: isLoggedIn,
    ),
  ));
}

class EvoltSoftApp extends StatelessWidget {
  final bool onboardingComplete;
  final bool isLoggedIn;

  const EvoltSoftApp({
    super.key,
    required this.onboardingComplete,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    // Decide initial screen:
    // 1. First launch → Onboarding
    // 2. Not logged in → Login
    // 3. Logged in → MainShell (home)
    Widget home;
    if (!onboardingComplete) {
      home = const OnboardingScreen();
    } else if (isLoggedIn) {
      home = const MainShell();
    } else {
      home = const LoginScreen();
    }

    return MaterialApp(
      title: 'EVOLTSOFT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: home,
    );
  }
}
