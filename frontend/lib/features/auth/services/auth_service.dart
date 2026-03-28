import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // trigger Firebase phone verification
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onError,
    required void Function() onAutoVerified,
    int? resendToken,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // auto sign-in on Android
        await _auth.signInWithCredential(credential);
        onAutoVerified();
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('Verification failed: ${e.message}');
        onError(e.message ?? 'Verification failed. Please try again.');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId, resendToken);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // auto-retrieval timed out, user types manually
      },
    );
  }

  // verify OTP and sign in
  Future<UserCredential> verifyOTP({
    required String verificationId,
    required String otp,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    return await _auth.signInWithCredential(credential);
  }

  // sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
