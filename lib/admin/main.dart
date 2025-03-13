// main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rentloapp_admin/admin/screens/admin_login_screen.dart';
import 'package:rentloapp_admin/admin/screens/admin_page.dart';
import 'package:rentloapp_admin/admin/screens/agent_dashboard_screen.dart';
import 'package:rentloapp_admin/admin/screens/agent_list_screen.dart';
import 'package:rentloapp_admin/admin/screens/agent_login_screen.dart';
import 'package:rentloapp_admin/admin/screens/login_selection_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  // Initialize Firebase for the main project (rentloapp-admin)
  try {
    if (Firebase.apps.where((app) => app.name == 'rentloapp-admin').isEmpty) {
      await Firebase.initializeApp(
        name: 'rentloapp-admin',
        options: const FirebaseOptions(
          apiKey: "AIzaSyAguaCAv3YP07yjejqpwm7vEfO5EZNaveU",
          appId: "1:945841099979:android:bfe0058313471f3705374e",
          messagingSenderId: "945841099979",
          projectId: "rentloapp-admin",
        ),
      );
      print("Firebase initialized for rentloapp-admin.");
    } else {
      print("Firebase already initialized for rentloapp-admin.");
    }
  } catch (e) {
    print("Error initializing Firebase for 'rentloapp-admin': $e");
  }

  // Initialize Firebase for the second project (rentloapp)
  try {
    if (Firebase.apps.where((app) => app.name == 'rentloapp').isEmpty) {
      await Firebase.initializeApp(
        name: 'rentloapp',
        options: const FirebaseOptions(
          apiKey: "AIzaSyD88PR_DjOJuRPLdzXW2My-m37wnZd_2nU",
          appId: "1:945841099979:ios:d788fcac2f4e513d05374e",
          messagingSenderId: "945841099979",
          projectId: "rentloapp",
        ),
      );
      print("Firebase initialized for rentloapp.");
    } else {
      print("Firebase already initialized for rentloapp.");
    }
  } catch (e) {
    print("Error initializing Firebase for 'rentloapp': $e");
  }

  runApp(MyApp());
}

Future<void> syncData() async {
  final rentloapp =
  FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp'));
  final rentloappAdmin =
  FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp-admin'));

  final adminAuth =
  FirebaseAuth.instanceFor(app: Firebase.app('rentloapp-admin'));
  final user = adminAuth.currentUser;

  if (user == null || user.email != "tirupathim@gmail.com") {
    print("Unauthorized access: Only 'tirupathim@gmail.com' can sync data.");
    return;
  }

  try {
    print("Fetching properties from 'rentloapp'...");
    QuerySnapshot<Map<String, dynamic>> v2Properties =
    await rentloapp.collection('properties').get();

    if (v2Properties.docs.isEmpty) {
      print("No properties found in 'rentloapp'.");
      return;
    }

    print(
        "Found ${v2Properties.docs.length} properties. Syncing to 'rentloapp-admin'...");
    for (var doc in v2Properties.docs) {
      await rentloappAdmin
          .collection('properties')
          .doc(doc.id)
          .set(doc.data());
      print("Synced property: ${doc.id}");
    }

    print('Data synced successfully!');
  } on FirebaseException catch (e) {
    print('Firebase error during sync: ${e.code} - ${e.message}');
  } catch (e) {
    print('Unknown error during sync: $e');
  }
}

Future<void> transferProperties() async {
  // Initialize Firebase for both projects
  final rentloapp =
  FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp'));
  final rentloappAdmin =
  FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp-admin'));

  try {
    // Fetch properties from rentloapp
    QuerySnapshot<Map<String, dynamic>> snapshot =
    await rentloapp.collection('properties').get();

    // Transfer properties to rentloapp-admin
    for (var doc in snapshot.docs) {
      final propertyData = doc.data();
      await rentloappAdmin
          .collection('properties')
          .doc(doc.id)
          .set(propertyData, SetOptions(merge: true));
    }

    print('Properties transferred successfully!');
  } catch (e) {
    print('Error transferring properties: $e');
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes the debug banner
      initialRoute: '/login_selection', // Set initial route to LoginSelectionScreen
      routes: {
        '/login_selection': (context) => LoginSelectionScreen(), // Login selection screen
        '/': (context) => RoleBasedHome(), // Role-based home logic
        '/admin_login': (context) => AdminLoginScreen(),
        '/agent_login': (context) => AgentLoginScreen(),
        '/agent_dashboard': (context) => AgentDashboardScreen(),
        '/admin_dashboard': (context) => AdminDashboardScreen(),
        '/agents': (context) => AgentListScreen(),
      },
    );
  }
}

class RoleBasedHome extends StatelessWidget {
  Future<String?> _getUserRole() async {
    try {
      print("Checking user role...");
      // Get FirebaseAuth and Firestore instances for the 'rentloapp-admin' app
      final adminAuth =
      FirebaseAuth.instanceFor(app: Firebase.app('rentloapp-admin'));
      final adminFirestore =
      FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp-admin'));
      final user = adminAuth.currentUser;

      // Debug: Print user details
      if (user != null) {
        print("Logged in user email: ${user.email}");
        print("User UID: ${user.uid}");
      } else {
        print("No user signed in.");
        return null; // If no user is signed in, return null
      }

      print("User signed in: ${user.email}");

      // Fetch user details from Firestore
      final userDoc =
      await adminFirestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final role = userDoc.data()?['role'];
        print("User role: $role");
        return role ?? 'unknown'; // Return the role if it exists
      } else {
        print("No Firestore document found for user: ${user.uid}");
      }
    } catch (e) {
      print("Error fetching user role: $e");
    }
    return null; // Default to null if no role found
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Loading user role...");
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print("Error in FutureBuilder: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        // If no user is authenticated, redirect to LoginScreen
        if (snapshot.data == null) {
          print("Redirecting to AdminLoginScreen...");
          return AdminLoginScreen(); // Replace with your actual login screen
        }

        // Route based on user role
        final role = snapshot.data;
        if (role == 'admin') {
          print("Redirecting to AdminDashboardScreen...");
          return AdminDashboardScreen(); // Admin dashboard
        } else if (role == 'agent') {
          print("Redirecting to AgentDashboardScreen...");
          return AgentDashboardScreen(); // Agent dashboard
        } else {
          print("Unauthorized role detected: $role");
          return Center(
            child: Text(
              "Unauthorized access. Please contact support.",
              style: TextStyle(fontSize: 16),
            ),
          ); // Handle unknown role
        }
      },
    );
  }
}

// Optional Sync Button for Testing
class SyncButtonTestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sync Data Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await syncData(); // Trigger syncData function
          },
          child: Text('Sync Data'),
        ),
      ),
    );
  }
}
