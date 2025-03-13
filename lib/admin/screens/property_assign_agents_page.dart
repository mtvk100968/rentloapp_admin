import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/property_service.dart';

class PropertyAssignAgentsPage extends StatefulWidget {
  @override
  _PropertyAssignAgentsPageState createState() => _PropertyAssignAgentsPageState();
}

class _PropertyAssignAgentsPageState extends State<PropertyAssignAgentsPage> {
  final PropertyService propertyService = PropertyService();
  List<Map<String, dynamic>> properties = []; // Update the type
  List<Map<String, dynamic>> agents = []; // Update type to match fetchAgents result

  @override
  void initState() {
    super.initState();
    fetchProperties();
    fetchAgents();
  }

  Future<void> fetchProperties() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('properties').get();
    setState(() {
      properties = snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'propertyType': doc['propertyType'],
          'propertyPrice': doc['propertyPrice'],
          'assignedAgents': List<Map<String, dynamic>>.from(doc['assignedAgents'] ?? []),
        };
      }).toList();
    });
  }

  Future<void> fetchAgents() async {
    List<Map<String, dynamic>> fetchedAgents = await propertyService.fetchAgents();
    setState(() {
      agents = fetchedAgents;
    });
  }

  // void assignAgent(String propertyId, String agentId) async {
  //   await FirebaseFirestore.instance.collection('properties').doc(propertyId).update({
  //     'assignedAgents': FieldValue.arrayUnion([agentId]),
  //   });
  //   fetchProperties(); // Refresh properties after updating Firestore
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Agent assigned to property!')));
  // }

  void assignAgent(String propertyId, Map<String, dynamic> agent) async {
    try {
      await FirebaseFirestore.instance.collection('properties').doc(propertyId).update({
        'assignedAgents': FieldValue.arrayUnion([
          {
            'id': agent['id'],
            'name': agent['name'],
          }
        ]),
      });

      // Refresh properties to reflect the change
      fetchProperties();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Agent assigned to property!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error assigning agent: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assign Agents to Properties')),
      body: ListView.builder(
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];

          return ListTile(
            title: Text(property['propertyType']),
            subtitle: Text('Price: \$${property['propertyPrice']}'),
            trailing: DropdownButton<Map<String, dynamic>>(
              hint: Text('Select Agent'),
              onChanged: (Map<String, dynamic>? agent) {
                if (agent != null) {
                  assignAgent(property['id'], agent);
                }
              },
              items: agents.map((agent) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: agent,
                  child: Text(agent['name']),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
