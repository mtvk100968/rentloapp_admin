import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../common/services_admin/property_service.dart';
import 'assign_agent_list.dart';
import 'customer_interaction_screen.dart';

class PropertyWithAgentsScreen extends StatefulWidget {
  final String propertyId;
  final String address;
  final List<dynamic> agents;

  const PropertyWithAgentsScreen({
    Key? key,
    required this.propertyId,
    required this.address,
    required this.agents,
  }) : super(key: key);

  @override
  _PropertyWithAgentsScreenState createState() => _PropertyWithAgentsScreenState();
}

class _PropertyWithAgentsScreenState extends State<PropertyWithAgentsScreen> {
  final PropertyService propertyService = PropertyService();
  List<Map<String, dynamic>> assignedAgents = [];
  List<Map<String, dynamic>> removedAgents = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignedAgents();
    removedAgents = [];
  }

  Future<void> _fetchAssignedAgents() async {
    try {
      DocumentSnapshot propertySnapshot = await FirebaseFirestore.instance
          .collection('properties')
          .doc(widget.propertyId)
          .get();

      if (propertySnapshot.exists) {
        List<dynamic> agents = propertySnapshot['agents'] ?? [];
        setState(() {
          assignedAgents =
              agents.map((agent) => Map<String, dynamic>.from(agent)).toList();
          removedAgents = [];
        });
      }
    } catch (e) {
      print("Error fetching agents: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load agents: $e")),
      );
    }
  }

  // Future<void> assignAgentToProperty(String agentId, String agentName) async {
  //   await ensureAuthenticated();
  //   await propertyService.assignAgentToProperty(
  //       widget.propertyId, agentId, agentName);
  //   await _fetchAssignedAgents();
  // }

  Future<void> _assignAgentToProperty(String agentId, String agentName) async {
    try {
      // Ensure the user is authenticated
      await ensureAuthenticated();

      // Add the agent back to Firestore
      await propertyService.assignAgentToProperty(widget.propertyId, agentId, agentName);

      // Update the UI
      setState(() {
        // Remove the agent from removedAgents and add to assignedAgents
        removedAgents.removeWhere((agent) => agent['id'] == agentId);
        if (!assignedAgents.any((agent) => agent['id'] == agentId)) {
          assignedAgents.add({'id': agentId, 'name': agentName});
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Agent $agentName assigned to property")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to assign agent: $e")),
      );
    }
  }

  Future<void> ensureAuthenticated() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  Future<void> _removeAgent(String agentId, String agentName) async {
    try {
      await propertyService.removeAgentFromProperty(
          widget.propertyId, agentId, agentName);
      await _fetchAssignedAgents();
      setState(() {
        assignedAgents.removeWhere((agent) => agent['id'] == agentId);
        removedAgents.add({'id': agentId, 'name': agentName});
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Agent removed from property")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to remove agent: $e")),
      );
    }
  }

  Future<void> _assignAgent() async {
    final selectedAgent = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssignAgentScreen(
          propertyId: widget.propertyId,
          assignedAgents: assignedAgents,
        ),
      ),
    );

    if (selectedAgent != null) {
      setState(() {
        assignedAgents.add(selectedAgent);
        removedAgents.removeWhere((agent) => agent['id'] == selectedAgent['id']);
      });
      await _assignAgentToProperty(selectedAgent['id'], selectedAgent['name']);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Agent ${selectedAgent['name']} assigned to property!")),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCustomerInteractions(
      String agentId) async {
    QuerySnapshot interactionsSnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .doc(widget.propertyId)
        .collection('customer_interactions')
        .where('agentId', isEqualTo: agentId)
        .get();

    return interactionsSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Property With Agents",
              style: TextStyle(fontSize: 24), // Adjust font size as needed
            ),
            Text(
              "Property: ${widget.propertyId}",
              style: const TextStyle(fontSize: 14), // Adjust font size as needed
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Assign Agents and Customers",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text("Assigned Agents:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...assignedAgents.map((agent) =>
                ListTile(
                  title: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CustomerInteractionScreen(
                                propertyId: widget.propertyId,
                                agentId: agent['id'],
                                agentName: agent['name'],
                              ),
                        ),
                      );
                    },
                    child: Text(agent['name'] ?? 'Unknown Agent'),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeAgent(agent['id'], agent['name']),
                  ),
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _assignAgent,
              child: const Text('Assign Agent'),
            ),
            const SizedBox(height: 20),
            const Text("Removed Agents:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...removedAgents.map((agent) =>
                ListTile(
                  title: Text(agent['name'] ?? 'Unknown Agent'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () =>
                        _assignAgentToProperty(agent['id'], agent['name']),
                  ),
                )),
            const SizedBox(height: 20),
            const Text("Customers Visited Property:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            // List all customer interactions for each assigned agent
            ...assignedAgents.map((agent) =>
                ExpansionTile(
                  title: Text(agent['name'] ?? 'Unknown Agent'),
                  children: [
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: _fetchCustomerInteractions(agent['id']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text(
                              "Error: ${snapshot.error}"));
                        }
                        final interactions = snapshot.data ?? [];
                        if (interactions.isEmpty) {
                          return const Center(child: Text(
                              "No customers visited this property for this agent."));
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: interactions.length,
                          itemBuilder: (context, index) {
                            final interaction = interactions[index];
                            return ListTile(
                              title: Text(interaction['customerName'] ?? 'Unknown Customer'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Phone: ${interaction['phoneNo'] ?? 'N/A'}"),
                                  Text("Offer Price: ${interaction['priceOffered'] ?? 'N/A'}"),
                                  Text("Opinion: ${interaction['opinion'] ?? 'N/A'}"),
                                  Text("Visit Count: ${interaction['visitCount'] ?? 1}"),
                                  if (interaction['visitTimestamps'] != null)
                                    ...List.from(interaction['visitTimestamps']).map((timestamp) {
                                      final date = (timestamp as Timestamp).toDate();
                                      return Text("Visited on: ${date.toLocal()}");
                                    }),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
