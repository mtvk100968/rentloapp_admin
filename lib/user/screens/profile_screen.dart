import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../common/models_user/property_model.dart';
import '../../common/models_user/user_model.dart';
import '../../common/services_user/auth_service.dart';
import '../../common/services_user/user_service.dart';
import '../components/simple_property_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './property_details_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  String _verificationId = '';
  User? _currentUser;

  // State variables to hold user info
  String? _userName;
  String? _userPhone;
  String? _userEmail;

  // List of properties posted by this user
  List<Property> _userPostedProperties = [];
  bool _isLoadingProperties = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadUserData();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      setState(() => _isLoadingProperties = true);

      // Fetch user details from Firestore
      AppUser? appUser = await UserService().getUserById(_currentUser!.uid);

      if (appUser != null) {
        setState(() {
          _userName = appUser.name;
          _userPhone = appUser.phoneNumber;
          _userEmail = appUser.email;
        });

        // Fetch user properties
        if (appUser.postedPropertyIds.isNotEmpty) {
          try {
            final QuerySnapshot<Map<String, dynamic>> propertySnapshots =
                await FirebaseFirestore.instance
                    .collection('properties')
                    .where(
                      FieldPath.documentId,
                      whereIn: appUser.postedPropertyIds,
                    )
                    .get();

            setState(() {
              _userPostedProperties =
                  propertySnapshots.docs
                      .map((doc) => Property.fromDocument(doc))
                      .toList();
            });
          } catch (e) {
            print('Error fetching properties: $e');
          }
        }
      }

      setState(() => _isLoadingProperties = false);
    }
  }

  void _checkLoginStatus() {
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> _refreshProfile() async {
    await _loadUserData();
  }

  // The method that starts phone verification
  Future<void> _verifyPhoneNumber() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      _showErrorSnackBar("Please enter a valid phone number.");
      return;
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // auto-resolve scenario
        try {
          await FirebaseAuth.instance.signInWithCredential(credential);
          _showSuccessSnackBar("Phone auto-verified!");
          _loadUserData();
          Navigator.pop(context); // close the dialog
        } catch (e) {
          _showErrorSnackBar("Auto-verification failed: $e");
        }
      },
      verificationFailed: (FirebaseAuthException e) {
        _showErrorSnackBar("Verification failed: ${e.message}");
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        _showSuccessSnackBar("Verification code sent to $phoneNumber");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  // The method that uses the code typed by the user
  Future<void> _signInWithSmsCode() async {
    final smsCode = _codeController.text.trim();
    if (_verificationId.isEmpty || smsCode.isEmpty) {
      _showErrorSnackBar("Need verification ID and code!");
      return;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codeController.text.trim(),
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _showSuccessSnackBar("Phone verified & user signed in!");
      Navigator.pop(context); // close the dialog
      _loadUserData();
    } catch (e) {
      _showErrorSnackBar('Failed to sign in with phone: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.blue, // Set text color to blue
            fontSize: 22, // Increased font size
            fontWeight: FontWeight.bold, // Bold text
          ),
        ),
        actions: [
          if (_currentUser != null)
            TextButton.icon(
              onPressed: _signOut,
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18, // Increased font size
                  fontWeight: FontWeight.w900, // Extra bold
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProfile,
        child: _currentUser == null ? _buildSignInUI() : _buildProfilePage(),
      ),
    );
  }

  Widget _buildSignInUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Sign-In/Sign-Up',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _signInWithGoogle(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FaIcon(FontAwesomeIcons.google, size: 20),
                      SizedBox(width: 10),
                      Text('With Google'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showPhoneNumberDialog(),
                  icon: const Icon(Icons.phone),
                  label: const Text('With Number'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePage() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Information Card
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Divider(),
                  if (_userName != null) Text('Name: $_userName'),
                  if (_userPhone != null) Text('Phone: $_userPhone'),
                  if (_userEmail != null) Text('Email: $_userEmail'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // In your ProfileScreen's _buildProfilePage() method
          // Posted Properties Section
          _isLoadingProperties
              ? const Center(child: CircularProgressIndicator())
              : _userPostedProperties.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Your Posted Properties',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No properties posted yet.',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Posted Properties',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _userPostedProperties.length,
                    itemBuilder: (context, index) {
                      final property = _userPostedProperties[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to full property details if needed
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) =>
                                      PropertyDetailsScreen(property: property),
                            ),
                          );
                        },
                        child: SimplePropertyCard(property: property),
                      );
                    },
                  ),
                ],
              ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _currentUser = null;
      _userName = null;
      _userPhone = null;
      _userEmail = null;
      _userPostedProperties.clear();
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      User? user = await signInWithGoogle();
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
        });
        _loadUserData();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to sign in with Google');
    }
  }

  Future<void> _sendCode() async {
    final phoneNumber = _phoneController.text.trim();
    if (phoneNumber.isEmpty) {
      print("Phone number is empty!");
      _showErrorSnackBar("Please enter a valid phone number.");
      return;
    }

    try {
      // signInWithPhoneNumber is a helper that starts phone verification.
      // It should call FirebaseAuth.instance.verifyPhoneNumber under the hood.
      await signInWithPhoneNumber(
        phoneNumber,
            (String verId) {
          if (mounted) {
            setState(() {
              _verificationId = verId;
            });
          }
        },
            (FirebaseAuthException e) {
          _showErrorSnackBar('Failed to verify phone number: ${e.message}');
        },
      );
      _showSuccessSnackBar('Verification code sent.');
    } catch (e) {
      _showErrorSnackBar('Failed to send verification code');
    }
  }

  Future<void> _signInWithPhone() async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codeController.text.trim(),
      );
      // signInWithPhoneAuthCredential should use the credential to sign in.
      User? user = await signInWithPhoneAuthCredential(credential);
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
        });
        await _loadUserData();
        Navigator.pop(context); // close the dialog
        _showSuccessSnackBar("Phone verified & user signed in!");
      }
    } catch (e) {
      _showErrorSnackBar('Failed to sign in with phone number: $e');
    }
  }

  void _showPhoneNumberDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Phone Number'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: 'Verification Code',
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _verifyPhoneNumber,
              child: const Text('Send Code'),
            ),
            TextButton(
              onPressed: _signInWithSmsCode,
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }
}
