import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../common/services_admin/property_service.dart';

class AssignAgentScreen extends StatefulWidget {
  final String propertyId;
  final List<Map<String, dynamic>> assignedAgents;

  const AssignAgentScreen({
    Key? key,
    required this.propertyId,
    required this.assignedAgents,
  }) : super(key: key);

  @override
  _AssignAgentScreenState createState() => _AssignAgentScreenState();
}

class _AssignAgentScreenState extends State<AssignAgentScreen> {
  final PropertyService propertyService = PropertyService();
  List<Map<String, dynamic>> agents = [];
  List<Map<String, dynamic>> filteredAgents = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAgents();
  }

  // Future<void> _fetchAgents() async {
  //   agents = await propertyService.fetchAgents(); // Calls the existing fetchAgents function
  //   print("Fetched agents: $agents"); // Debugging output
  //   setState(() {
  //     filteredAgents = agents; // Display all agents initially
  //   });
  // }

  Future<void> _fetchAgents() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('agents').get();

      setState(() {
        agents = snapshot.docs.map((doc) => doc.data()).toList();
        filteredAgents = agents;
      });
    } catch (e) {
      print("Error fetching agents: $e");
    }
  }

  void _filterAgents(String query) {
    setState(() {
      filteredAgents = agents.where((agent) {
        final name = agent['name']?.toLowerCase() ?? '';
        final area = agent['area']?.toLowerCase() ?? ''; // Assuming `area` is a field in the agent document
        final pincode = agent['pincode']?.toString() ?? ''; // Assuming `pincode` is a field
        final code = agent['id']?.toString() ?? ''; // Assuming `id` is the agent code

        return name.contains(query.toLowerCase()) ||
            area.contains(query.toLowerCase()) ||
            pincode.contains(query) ||
            code.contains(query);
      }).toList();
    });
  }

  // Future<void> _assignAgent(String agentId, String agentName) async {
  //   // Check if the agent is already assigned to the property
  //   bool isAgentAlreadyAssigned = widget.assignedAgents.any((agent) => agent['id'] == agentId);
  //
  //   if (isAgentAlreadyAssigned) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("$agentName is already added to Property ID: ${widget.propertyId}")),
  //     );
  //     return;
  //   }
  //
  //   // Proceed to assign agent if not already assigned
  //   await propertyService.assignAgentToProperty(widget.propertyId, agentId, agentName);
  //   Navigator.pop(context, {'id': agentId, 'name': agentName});
  // }

  Future<void> _assignAgent(String agentId, String agentName) async {
    final isAgentAlreadyAssigned = widget.assignedAgents.any((agent) {
      return agent['id'] == agentId;
    });

    if (isAgentAlreadyAssigned) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$agentName is already added to Property ID: ${widget.propertyId}")),
      );
      return;
    }

    try {
      await propertyService.assignAgentToProperty(widget.propertyId, agentId, agentName);
      Navigator.pop(context, {'id': agentId, 'name': agentName});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to assign agent: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Agent List")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: _filterAgents,
              decoration: const InputDecoration(
                labelText: 'Search by name, area, pincode, or code',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredAgents.length,
                itemBuilder: (context, index) {
                  final agent = filteredAgents[index];
                  return ListTile(
                    title: Text(agent['name'] ?? 'Unknown Agent'),
                    subtitle: Text(
                      "Area: ${agent['area'] ?? 'N/A'}, Pincode: ${agent['pincode'] ?? 'N/A'}",
                    ),
                    onTap: () => _assignAgent(agent['id'], agent['name']),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}