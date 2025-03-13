import 'package:flutter/material.dart';

class AgentManagementScreen extends StatelessWidget {
  const AgentManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agent Management')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Agent John Doe'),
            subtitle: const Text('Assigned Properties: 3\nDeals Closed: 5'),
            trailing: ElevatedButton(
              onPressed: () {
                // Code to assign property to agent
              },
              child: const Text('Assign Property'),
            ),
          ),
          const Divider(),
          // Repeat for other agents
        ],
      ),
    );
  }
}