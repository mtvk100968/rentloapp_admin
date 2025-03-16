// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// import 'agent_dashboard_screen.dart';
//
// class AgentLoginScreen extends StatefulWidget {
//   @override
//   _AgentLoginScreenState createState() => _AgentLoginScreenState();
// }
//
// class _AgentLoginScreenState extends State<AgentLoginScreen> {
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _otpController = TextEditingController();
//   String? _verificationId;
//
//   // Method to verify phone number
//   Future<void> _verifyPhoneNumber() async {
//     try {
//       await FirebaseAuth.instance.verifyPhoneNumber(
//         phoneNumber: _phoneController.text,
//         verificationCompleted: (PhoneAuthCredential credential) async {
//           await FirebaseAuth.instance.signInWithCredential(credential);
//           Navigator.pushReplacementNamed(context, '/agent_dashboard');
//         },
//         verificationFailed: (FirebaseAuthException e) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text("Verification failed: ${e.message}")),
//           );
//         },
//         codeSent: (String verificationId, int? resendToken) {
//           setState(() {
//             _verificationId = verificationId;
//           });
//         },
//         codeAutoRetrievalTimeout: (String verificationId) {
//           _verificationId = verificationId;
//         },
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error verifying phone number: $e")),
//       );
//     }
//   }
//
//   // Method to sign in with OTP
//   Future<void> _signInWithOTP() async {
//     try {
//       PhoneAuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId!,
//         smsCode: _otpController.text,
//       );
//       await FirebaseAuth.instance.signInWithCredential(credential);
//       Navigator.pushReplacementNamed(context, '/agent_dashboard');
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("OTP verification failed: $e")),
//       );
//     }
//   }
//
//   // Method to sign in with Google
//   Future<void> _signInWithGoogle(BuildContext context) async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//       if (googleUser == null) return; // User aborted sign-in
//
//       final GoogleSignInAuthentication googleAuth =
//       await googleUser.authentication;
//
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       await FirebaseAuth.instance.signInWithCredential(credential);
//       Navigator.pushReplacementNamed(context, '/agent_dashboard');
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Google sign-in failed: $e")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Agent Login"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             // Phone Login Section
//             Text(
//               "Phone Login",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             TextField(
//               controller: _phoneController,
//               decoration: InputDecoration(labelText: "Phone Number"),
//               keyboardType: TextInputType.phone,
//             ),
//             SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: _verifyPhoneNumber,
//               child: Text("Send OTP"),
//             ),
//             if (_verificationId != null) ...[
//               TextField(
//                 controller: _otpController,
//                 decoration: InputDecoration(labelText: "Enter OTP"),
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: 8),
//               ElevatedButton(
//                 onPressed: _signInWithOTP,
//                 child: Text("Verify OTP"),
//               ),
//             ],
//             Divider(thickness: 2, height: 32),
//
//             // Google Login Section
//             Text(
//               "Google Login",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton.icon(
//               icon: Image.asset(
//                 'assets/images/google_icon.png', // Ensure this icon exists
//                 height: 24,
//                 width: 24,
//               ),
//               label: Text("Sign in with Google"),
//               onPressed: () => _signInWithGoogle(context),
//             ),
//             Divider(thickness: 2, height: 32),
//
//             // Normal Agent Login Section
//             Text(
//               "Normal Agent Login",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (_) => AgentDashboardScreen()),
//                 );
//               },
//               child: Text("Normal Agent Login"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }