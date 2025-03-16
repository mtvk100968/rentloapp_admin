import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rentloapp_admin/user/screens/rent_property_screen.dart';

import '../../admin/screens/admin_page.dart';
import '../../admin/screens/agent_dashboard_screen.dart';

class UnifiedLoginScreen extends StatefulWidget {
  @override
  _UnifiedLoginScreenState createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Check Firestore for user role and navigate accordingly
  Future<void> _handleLogin(User user) async {
    setState(() => _isLoading = true);

    final FirebaseFirestore userFirestore = FirebaseFirestore.instanceFor(
      app: Firebase.app('rentloapp'),
    );

    final FirebaseFirestore adminFirestore = FirebaseFirestore.instanceFor(
      app: Firebase.app('rentloapp-admin'),
    );

    DocumentSnapshot userDoc = await userFirestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists) {
      // If user does not exist, create an entry with default role 'user'
      await userFirestore.collection('users').doc(user.uid).set({
        "userId": user.uid,
        "name": user.displayName ?? "User",
        "email": user.email ?? "",
        "phoneNumber": user.phoneNumber ?? "",
        "role": "user"
      });

      // ✅ Fetch the updated document **after** adding the user to Firestore
      userDoc = await userFirestore.collection('users').doc(user.uid).get();
    }

    // 🔹 Log Firestore data to debug issues
    print("User document data: ${userDoc.data()}");

    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('role')) {
        String role = userData['role']; // Safe access
      } else {
        print("Role field does not exist");
      }
    }

    String role = userDoc['role'];

    // 🔹 Navigate based on role
    if (role == "admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
      );
    } else if (role == "agent") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AgentDashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RentPropertyScreen(properties: [], center: null),
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  // 🔹 Google Sign-In
  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // User canceled login

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      await _handleLogin(userCredential.user!);
    } catch (e) {
      _showErrorSnackBar("Google Sign-In failed: $e");
    }
  }

  // 🔹 Phone Number Authentication
  Future<void> _verifyPhoneNumber() async {
    if (_phoneController.text.isEmpty) {
      _showErrorSnackBar("Enter a valid phone number");
      return;
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        await _handleLogin(_auth.currentUser!);
      },
      verificationFailed: (FirebaseAuthException e) {
        _showErrorSnackBar("Phone verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() => _verificationId = verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> _signInWithOTP() async {
    if (_verificationId == null || _otpController.text.isEmpty) {
      _showErrorSnackBar("Please enter a valid OTP");
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      await _handleLogin(userCredential.user!);
    } catch (e) {
      _showErrorSnackBar("OTP verification failed: $e");
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Unified Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Sign in to continue",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 🔹 Google Login Button
            ElevatedButton.icon(
              icon: Image.asset('assets/images/google_icon.png', width: 24, height: 24),
              label: Text("Sign in with Google"),
              onPressed: _signInWithGoogle,
            ),

            Divider(height: 40, thickness: 2),

            // 🔹 Phone Number Input
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "Enter Phone Number"),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _verifyPhoneNumber,
              child: Text("Send OTP"),
            ),

            if (_verificationId != null) ...[
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: "Enter OTP"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _signInWithOTP,
                child: Text("Verify OTP"),
              ),
            ],

            if (_isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
