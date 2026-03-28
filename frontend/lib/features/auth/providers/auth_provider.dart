import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

// auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// possible auth states
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

// manages login/OTP state transitions
class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    return const AuthState();
  }

  // send OTP to the given phone number
  Future<void> sendOTP(String phoneNumber) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      phoneNumber: phoneNumber,
      errorMessage: null,
    );

    try {
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
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to send OTP. Please check your connection and try again.',
      );
    }
  }

  // verify the OTP the user typed
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

  // resend OTP to the same number
  Future<void> resendOTP() async {
    if (state.phoneNumber == null) return;
    await sendOTP(state.phoneNumber!);
  }

  // reset back to initial (used on logout or back navigation)
  void reset() {
    state = const AuthState();
  }
}

// the global auth provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
