import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models_user/user_model.dart';
import 'user_service.dart'; // Import the user service

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      print("Google sign-in was canceled");
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      // ✅ Convert Firebase User to AppUser
      AppUser appUser = AppUser(
        uid: user.uid,
        name: user.displayName,
        email: user.email,
        phoneNumber: user.phoneNumber,
      );

      // ✅ Save AppUser to Firestore
      await UserService().saveUser(appUser);
    }

    return user;
  } catch (e) {
    print("Google Sign-In Error: $e");
    return null;
  }
}

Future<void> signInWithPhoneNumber(String phoneNumber, Function(String) codeSent, Function(FirebaseAuthException) verificationFailed) async {
  await _auth.verifyPhoneNumber(
    phoneNumber: phoneNumber,
    verificationCompleted: (PhoneAuthCredential credential) async {
      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User? user = authResult.user;

      if (user != null) {
        // Create an AppUser instance
        AppUser appUser = AppUser(
          uid: user.uid,
          name: user.displayName,
          email: user.email,
          phoneNumber: user.phoneNumber,
        );

        // Save or update the user in Firestore
        await UserService().saveUser(appUser);
      }
    },
    verificationFailed: verificationFailed,
    codeSent: (String verificationId, int? resendToken) {
      codeSent(verificationId);
    },
    codeAutoRetrievalTimeout: (String verificationId) {},
  );
}

Future<User?> signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential) async {
  final UserCredential authResult = await _auth.signInWithCredential(phoneAuthCredential);
  final User? user = authResult.user;

  if (user != null) {
    // Create an AppUser instance
    AppUser appUser = AppUser(
      uid: user.uid,
      name: user.displayName,
      email: user.email,
      phoneNumber: user.phoneNumber,
    );

    // Save or update the user in Firestore
    await UserService().saveUser(appUser);
  }

  return user;
}