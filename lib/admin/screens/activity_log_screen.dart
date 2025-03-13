import 'package:flutter/material.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity Log')),
      body: const Column(
        children: [
          ListTile(
            title: Text('Property #123 assigned to Agent John'),
            subtitle: Text('Time: 10:00 AM, 11/06/2024'),
          ),
          Divider(),
          // Repeat similar ListTiles for other activities...
        ],
      ),
    );
  }
}