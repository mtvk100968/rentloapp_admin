// agent
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'agent_property_details_page.dart';
import 'customer_interaction_screen.dart';

class AgentDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? agentId = FirebaseAuth.instance.currentUser?.uid;

    if (agentId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Agent Dashboard")),
        body: const Center(child: Text("User is not authenticated")),
      );
    }

    Future<DocumentSnapshot<Map<String, dynamic>>> fetchAgentData() async {
      try {
        final snapshot = await FirebaseFirestore.instance.collection('agents').doc(agentId).get();
        if (!snapshot.exists) {
          print("No data found for agentId: $agentId");
        } else {
          print("Agent data: ${snapshot.data()}");
        }
        return snapshot;
      } catch (e) {
        print("Error fetching agent data: $e");
        rethrow;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Agent Dashboard")),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: fetchAgentData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No agent data found"));
          }

          final agentData = snapshot.data!.data();
          final assignedProperties = List<String>.from(agentData?['assignedProperties'] ?? []);
          final agentName = agentData?['name'] ?? 'Agent';

          if (assignedProperties.isEmpty) {
            return const Center(child: Text("No properties assigned to you."));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          title: const Text("Select a Property"),
                          children: assignedProperties.map((propertyId) {
                            return SimpleDialogOption(
                              child: Text(propertyId),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerInteractionScreen(
                                      propertyId: propertyId,
                                      agentId: agentId,
                                      agentName: agentName,
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                  child: const Text("Add Customer Interaction"),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "My Assigned Properties",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: assignedProperties.length,
                  itemBuilder: (context, index) {
                    final propertyId = assignedProperties[index];
                    return ListTile(
                      title: Text("Property ID: $propertyId"),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AgentPropertyDetailsPage(
                                propertyId: propertyId,
                                agentId: agentId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
