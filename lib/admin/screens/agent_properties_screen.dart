import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rentloapp_admin/admin/screens/property_with_agents_screen.dart';

class AgentPropertiesScreen extends StatefulWidget {
  final String agentId;
  final String agentName;

  const AgentPropertiesScreen({
    Key? key,
    required this.agentId,
    required this.agentName,
  }) : super(key: key);

  @override
  _AgentPropertiesScreenState createState() => _AgentPropertiesScreenState();
}

class _AgentPropertiesScreenState extends State<AgentPropertiesScreen> {
  String? agentImageUrl;
  String? agentGender;

  @override
  void initState() {
    super.initState();
    _fetchAgentDetails(); // Fetch agent details on screen load
  }

  Future<Map<String, dynamic>> fetchAgentStats() async {
    try {
      // Fetch agent's properties count, sold count, and available properties
      QuerySnapshot<Map<String, dynamic>> propertiesSnapshot =
      await FirebaseFirestore.instance
          .collection('properties')
          .where('agents', arrayContains: widget.agentId)
          .get();

      int totalProperties = propertiesSnapshot.docs.length;
      int soldCount = propertiesSnapshot.docs
          .where((doc) => doc.data()['status'] == 'sold')
          .length;
      int availableProperties = totalProperties - soldCount;

      return {
        'totalProperties': totalProperties,
        'soldCount': soldCount,
        'availableProperties': availableProperties,
      };
    } catch (e) {
      print('Error fetching agent stats: $e');
      return {
        'totalProperties': 0,
        'soldCount': 0,
        'availableProperties': 0,
      };
    }
  }

  Future<void> _fetchAgentDetails() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> agentSnapshot =
      await FirebaseFirestore.instance.collection('agents').doc(widget.agentId).get();

      if (agentSnapshot.exists) {
        setState(() {
          agentImageUrl = agentSnapshot.data()?['imageUrl'];
          agentGender = agentSnapshot.data()?['gender'];
        });
      }
    } catch (e) {
      print("Error fetching agent details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.agentName}'s Properties"),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchAgentStats(),
        builder: (context, statsSnapshot) {
          if (statsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (statsSnapshot.hasError) {
            return Center(child: Text('Error: ${statsSnapshot.error}'));
          }

          final stats = statsSnapshot.data!;
          final int totalProperties = stats['totalProperties'];
          final int soldCount = stats['soldCount'];
          final int availableProperties = stats['availableProperties'];

          return Column(
            children: [
              // Agent Profile Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: agentImageUrl != null && agentImageUrl!.isNotEmpty
                          ? NetworkImage(agentImageUrl!)
                          : AssetImage(
                        agentGender == 'Male'
                            ? 'assets/images/businessman.png'
                            : 'assets/images/businesswoman.png',
                      ) as ImageProvider,
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.agentName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Agent ID: ${widget.agentId}",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          "$totalProperties",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Total Properties"),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "$soldCount",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Sold"),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          "$availableProperties",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Available"),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Properties List Section
              Expanded(
                child: totalProperties == 0
                    ? const Center(
                  child: Text(
                    "No properties assigned to this agent.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('properties')
                      .where('agents', arrayContains: widget.agentId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData ||
                        snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No properties found.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    final properties = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: properties.length,
                      itemBuilder: (context, index) {
                        final property = properties[index].data();
                        final propertyId = properties[index].id;
                        final address =
                            property['address'] ?? 'Unknown Address';
                        final status = property['status'] ?? 'N/A';

                        return ListTile(
                          title: Text("Property ID: $propertyId"),
                          subtitle: Text("Address: $address"),
                          trailing: Text(
                            status,
                            style: TextStyle(
                              color: status == 'sold'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            // Navigate to property details
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertyWithAgentsScreen(
                                  propertyId: propertyId,
                                  address: address,
                                  agents: property['agents'] ?? [],
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
          );
        },
      ),
    );
  }
}
