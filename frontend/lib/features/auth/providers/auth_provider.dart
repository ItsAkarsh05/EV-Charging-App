import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// ─── Auth Service Provider ─────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ─── Auth State ────────────────────────────────────────────────
enum AuthStatus { idle, loading, codeSent, authenticated, error }

class AuthState {
  final AuthStatus status;
  final String? verificationId;
  final int? resendToken;
  final String? phoneNumber;
  final String? errorMessage;
  final User? user;

  const AuthState({
    this.status = AuthStatus.idle,
    this.verificationId,
    this.resendToken,
    this.phoneNumber,
    this.errorMessage,
    this.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? verificationId,
    int? resendToken,
    String? phoneNumber,
    String? errorMessage,
    User? user,
  }) {
    return AuthState(
      status: status ?? this.status,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

// ─── Auth Notifier ─────────────────────────────────────────────
class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    return const AuthState();
  }

  /// Send OTP to the provided phone number.
  Future<void> sendOTP(String phoneNumber) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      phoneNumber: phoneNumber,
      errorMessage: null,
    );

    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      resendToken: state.resendToken,
      onCodeSent: (verificationId, resendToken) {
        state = state.copyWith(
          status: AuthStatus.codeSent,
          verificationId: verificationId,
          resendToken: resendToken,
        );
      },
      onError: (error) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: error,
        );
      },
      onAutoVerified: () {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: _authService.currentUser,
        );
      },
    );
  }

  /// Verify OTP code.
  Future<void> verifyOTP(String otp) async {
    if (state.verificationId == null) return;

    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
    );

    try {
      final userCredential = await _authService.verifyOTP(
        verificationId: state.verificationId!,
        otp: otp,
      );
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: userCredential.user,
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message ?? 'Invalid OTP. Please try again.',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      );
    }
  }

  /// Resend OTP to the same phone number.
  Future<void> resendOTP() async {
    if (state.phoneNumber == null) return;
    await sendOTP(state.phoneNumber!);
  }

  /// Reset state (used on sign-out or going back).
  void reset() {
    state = const AuthState();
  }
}

// ─── Auth Notifier Provider ────────────────────────────────────
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
