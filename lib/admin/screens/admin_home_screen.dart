// home_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/services_admin/property_service.dart';
import 'activity_log_screen.dart';
import 'admin_page.dart';
import '../widgets/agent_management_screen.dart';
import 'communication_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  // Define an instance of PropertyService
  final PropertyService propertyService = PropertyService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Property Management')),
      body: ListView(
        padding: const EdgeInsets.all(16.0), // Adds padding around the list
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: () async {
                await navigateToAdminPage(context);
              },
              child: const Text('Go to Admin Page'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AgentManagementScreen()),
                );
              },
              child: const Text('Go to Agent Management'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: () async {
                await propertyService.syncPropertiesToAdmin();
                print("Triggered property sync manually.");
              },
              child: const Text('Sync Properties Manually'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CommunicationScreen()),
                );
              },
              child: const Text('Go to Communication'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ActivityLogScreen()),
                );
              },
              child: const Text('Go to Activity Log'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instanceFor(app: Firebase.app('rentloapp-admin')).signInAnonymously();
                print("Signed in anonymously for testing");
              },
              child: const Text('Sign in Anonymously'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> navigateToAdminPage(BuildContext context) async {
    final user = FirebaseAuth.instanceFor(app: Firebase.app('rentloapp-admin')).currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to access the admin page.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
    );
  }
}
