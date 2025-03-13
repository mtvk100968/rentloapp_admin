import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:rentloapp_admin/admin/screens/add_agent_screen.dart';
import 'package:rentloapp_admin/admin/screens/agent_properties_screen.dart';
import 'package:rentloapp_admin/admin/screens/property_detail_screen.dart';
import 'package:rentloapp_admin/admin/screens/property_with_agents_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> properties = [];
  List<Map<String, dynamic>> allProperties = [];
  List<Map<String, dynamic>> assignedProperties = [];
  List<Map<String, dynamic>> agents = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchProperties();
    fetchAgents(); // Fetch agents' data on initialization
    fetchAssignedProperties(); // Fetch assigned properties on screen load
    fetchAllPropertiesForAdmin(); // Fetch all properties for admin on screen load
  }

  /// Fetch properties from `rentloapp-admin`
  Future<void> fetchProperties() async {
    try {
      FirebaseFirestore v2Firestore =
      FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp'));
      QuerySnapshot querySnapshot =
      await v2Firestore.collection('properties').get();

      setState(() {
        properties = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching properties: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching properties: ${e.toString()}")),
      );
    }
  }

  /// Fetch agents' data
  Future<void> fetchAgents() async {
    try {
      final agentsSnapshot =
      await FirebaseFirestore.instance.collection('agents').get();

      setState(() {
        agents = agentsSnapshot.docs.map((doc) {
          return {
            ...doc.data(),
            'id': doc.id,
          };
        }).toList();
      });

      print('Fetched ${agents.length} agents.');
    } catch (e) {
      print('Error fetching agents: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch agents: $e")),
      );
    }
  }

  /// Fetch assigned properties for the current user
  Future<void> fetchAssignedProperties() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated.');
    }

    try {
      FirebaseFirestore adminFirestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await adminFirestore
          .collection('properties')
          .where('agents',
          arrayContains: user.uid) // Check if user is an assigned agent
          .get();

      setState(() {
        properties = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching assigned properties: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
            Text("Error fetching assigned properties: ${e.toString()}")),
      );
    }
  }

  Future<void> fetchAllPropertiesForAdmin() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.email != "tirupathim@gmail.com") {
      print("Not an admin user.");
      return;
    }

    try {
      FirebaseFirestore adminFirestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot =
      await adminFirestore.collection('properties').get();

      setState(() {
        properties = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching properties for admin: $e');
    }
  }

  /// Sync properties from `rentloapp` to `rentloappAdmin`
  Future<void> syncProperties() async {
    try {
      final v2Firestore =
      FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp'));
      final adminFirestore =
      FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp-admin'));

      final querySnapshot = await v2Firestore.collection('properties').get();

      if (querySnapshot.docs.isEmpty) {
        print("No properties found in 'rentloapp'.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No properties to sync.")),
        );
        return;
      }

      for (var doc in querySnapshot.docs) {
        try {
          final propertyData = doc.data();
          print('Syncing document ID: ${doc.id}');
          await adminFirestore
              .collection('properties')
              .doc(doc.id)
              .set(propertyData, SetOptions(merge: true));
        } catch (e) {
          print('Error syncing document ID ${doc.id}: $e');
        }
      }

      print("All properties synced successfully.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Properties synced successfully!")),
      );

      // Refresh properties after syncing
      fetchProperties();
    } catch (e) {
      print("Error during property sync: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to sync properties: $e")),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDashboard() {
    return properties.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: properties.length,
      itemBuilder: (context, index) {
        final property = properties[index];
        final propertyId = property[
        'id']; // Replace with the actual field for property ID
        final address = property['address'] ?? 'Unknown Address';
        final assignedAgents = property['agents'] ??
            []; // Assuming 'agents' field holds assigned agents

        return Card(
          margin:
          const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text("Property ID: ${propertyId ?? 'N/A'}"),
            subtitle: Text("Address: ${address ?? 'N/A'}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Assign Agents Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PropertyWithAgentsScreen(
                          propertyId: propertyId ?? '',
                          address: address,
                          agents: assignedAgents,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                  ),
                  child: const Text('Assign Agents'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Property Details Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PropertyDetailScreen(
                          propertyId: propertyId ?? '',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgentsListScreen() {
    return agents.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      itemCount: agents.length,
      itemBuilder: (context, index) {
        final agentData = agents[index];
        return ListTile(
          title: Text(agentData['name'] ?? 'Unknown'),
          subtitle: Text("ID: ${agentData['id']}"),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgentPropertiesScreen(
                agentId: agentData['id'] ?? 'N/A',
                agentName: agentData['name'] ?? 'Unknown',
              ),
            ),
          ),
        );
      },
    );
  }

  // void _filterProperties(String query) {
  //   setState(() {
  //     // If the query is empty, reset to the full list
  //     if (query.isEmpty) {
  //       fetchProperties(); // Reload all properties if no query
  //     } else {
  //       properties = properties.where((property) {
  //         final propertyId = property['id']?.toLowerCase() ?? '';
  //         return propertyId.contains(query.toLowerCase());
  //       }).toList();
  //     }
  //   });
  // }

  void _filterItems(String query) {
    setState(() {
      if (_selectedIndex == 0) {
        // If on Properties tab
        if (query.isEmpty) {
          fetchProperties(); // Reload all properties if no query
        } else {
          properties = properties.where((property) {
            final propertyId = property['id']?.toLowerCase() ?? '';
            final address = property['address']?.toLowerCase() ?? '';
            return propertyId.contains(query.toLowerCase()) ||
                address.contains(query.toLowerCase());
          }).toList();
        }
      } else if (_selectedIndex == 1) {
        // If on Agents tab
        if (query.isEmpty) {
          fetchAgents(); // Reload all agents if no query
        } else {
          agents = agents.where((agent) {
            final agentName = agent['name']?.toLowerCase() ?? '';
            final agentId = agent['id']?.toLowerCase() ?? '';
            return agentName.contains(query.toLowerCase()) ||
                agentId.contains(query.toLowerCase());
          }).toList();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildDashboard(),
      _buildAgentsListScreen(),
      const Center(child: Text("Settings")), // Placeholder for Settings
    ];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rentloapp Admin Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: fetchAssignedProperties,
            ),
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: syncProperties,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddAgentScreen()),
                ).then((_) =>
                    fetchAgents()); // Refresh the agent list after adding
              },
              tooltip: 'Add Agent',
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterItems, // Call the unified filter method
                decoration: const InputDecoration(
                  hintText: 'Search properties or agents...',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Properties',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Agents',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
