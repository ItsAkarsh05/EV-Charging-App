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
import 'features/navigation/main_navigator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // load env vars
  await dotenv.load(fileName: ".env");

  // portrait only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // init Firebase
  bool firebaseReady = false;
  try {
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e) {
    debugPrint('⚠️ Firebase init failed: $e');
  }

  // check first-launch flag and login state
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
    // pick the right starting screen
    Widget home;
    if (!onboardingComplete) {
      home = const OnboardingScreen();
    } else if (isLoggedIn) {
      home = const MainNavigator();
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
