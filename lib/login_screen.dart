import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<String?> determineUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Check if the document exists and contains the "role" field.
    if (doc.exists && doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey('role')) {
      return (doc.data() as Map<String, dynamic>)['role'] as String?;
    } else {
      print("User document does not contain a 'role' field.");
      return null;
    }
  }

  Future<void> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // aborted sign-in
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
    String? role = await determineUserRole();
    _navigateBasedOnRole(role);
  }

  void _navigateBasedOnRole(String? role) {
    if (role == 'admin') {
      Navigator.pushReplacementNamed(context, '/admin_dashboard');
    } else if (role == 'agent') {
      Navigator.pushReplacementNamed(context, '/agent_dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/user_home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _signInWithGoogle,
              child: Text('Sign in with Google'),
            ),
            // Add other sign-in methods here...
            ElevatedButton(
              onPressed: () async {
                // Optionally, implement "Continue as Guest"
                _navigateBasedOnRole('user');
              },
              child: Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
