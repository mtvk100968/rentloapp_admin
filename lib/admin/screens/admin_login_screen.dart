import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'admin_page.dart';

class AdminLoginScreen extends StatelessWidget {
  Future<void> _loginAsAdmin(BuildContext context) async {
    try {
      // Trigger Google sign-in
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // If the user cancels the sign-in process
        return;
      }

      // Authenticate with Firebase using Google credentials
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Check if the authenticated user’s email matches the allowed admin email
      if (userCredential.user?.email != 'tirupathim@gmail.com') {
        // Sign out the user and show an error if the email does not match
        await FirebaseAuth.instance.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Only the specified admin email is allowed for login.")),
        );
        return;
      }

      // Navigate to Admin Dashboard if email matches
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Admin login failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Login")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            icon: Image.asset(
              'assets/images/google_icon.png',
              width: 24,
              height: 24,
            ),
            label: Text("Sign in with Google"),
            onPressed: () => _loginAsAdmin(context),
          ),
        ),
      ),
    );
  }
}