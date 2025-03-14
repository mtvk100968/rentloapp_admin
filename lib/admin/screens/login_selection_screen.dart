//
import 'package:flutter/material.dart';

class LoginSelectionScreen extends StatelessWidget {
  const LoginSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Login Role'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Admin Login
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/admin_login');
              },
              child: Text('Admin Login'),
            ),
            SizedBox(height: 20),

            // Agent Login
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/agent_login');
              },
              child: Text('Agent Login'),
            ),
            SizedBox(height: 20),

            // Continue as Guest -> open map
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/property_map');
              },
              child: Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
