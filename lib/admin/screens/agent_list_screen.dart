import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgentListScreen extends StatelessWidget {
  const AgentListScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> fetchAgents() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('agents').get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching agents: $e");
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agents List"),
      ),
      body: Column(
        children: [
          // Heading
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Agents List",
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchAgents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No agents found"));
                }

                final agents = snapshot.data!;

                return ListView.builder(
                  itemCount: agents.length,
                  itemBuilder: (context, index) {
                    final agent = agents[index];
                    return ListTile(
                      title: Text(agent['name'] ?? 'Unknown'),
                      subtitle: Text('ID: ${agent['id'] ?? 'N/A'}'),
                      trailing: Text('Assigned: ${agent['assignedProperties'] ?? 0}'),
                      onTap: () {
                        // Navigate to Agent Details or Interaction Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AgentDetailsScreen(
                              agentId: agent['id'],
                              agentName: agent['name'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy Screen for Agent Details
class AgentDetailsScreen extends StatelessWidget {
  final String agentId;
  final String agentName;

  const AgentDetailsScreen({
    required this.agentId,
    required this.agentName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Details for $agentName"),
      ),
      body: Center(
        child: Text("Details for Agent ID: $agentId"),
      ),
    );
  }
}
