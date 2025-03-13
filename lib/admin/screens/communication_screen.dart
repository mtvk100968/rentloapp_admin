import 'package:flutter/material.dart';

class CommunicationScreen extends StatelessWidget {
  const CommunicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Communication')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Send Notification'),
            subtitle: const Text('Notify selected agents'),
            trailing: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                // Code to send notification
              },
            ),
          ),
          ListTile(
            title: const Text('Messaging'),
            subtitle: const Text('Chat with agents'),
            trailing: IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                // Code to open chat screen
              },
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}