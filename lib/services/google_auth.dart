import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Reference the Singleton instance
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<bool> signInWithGoogle() async {
    try {
      // 2. IMPORTANT: You MUST call initialize once before anything else.
      // You can do this in main() or here with a "check if initialized" logic.
      await _googleSignIn.initialize(
        clientId: dotenv.env['GOOGLE_CLIENT_ID'],
      );

      // 🌐 WEB implementation
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await _auth.signInWithPopup(googleProvider);
        return true;
      }

      // 📱 ANDROID / IOS
      // 3. The method is now .authenticate() instead of .signIn()
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      return true;
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return false;
    }
  }

  Future<void> googleSignOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}