import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PropertyAssignmentPanel extends StatelessWidget {
  final List<Map<String, dynamic>> properties;
  final Function(String) onAssignAgent;

  const PropertyAssignmentPanel({
    Key? key,
    required this.properties,
    required this.onAssignAgent,
  }) : super(key: key);

  void _showAgentAssignmentModal(BuildContext context, String propertyId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Assign Agent for Property #$propertyId',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with the actual list length of agents
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Agent ${index + 1}'),
                    subtitle: Text('Experience: ${5 + index} years'), // Sample data
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Code to assign the selected agent to the property with propertyId
                        Navigator.pop(context);
                      },
                      child: Text('Assign'),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: properties.map((property) {
        String agentName = property['agentName'] ?? 'None';
        String agentId = property['agentId'] ?? 'None';

        return ListTile(
          title: Text('Property ID: ${property['id']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Address: ${property['address'] ?? 'N/A'}'),
              Text('Agent: $agentName (ID: $agentId)'), // Display assigned agent info
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () {
              // Call the modal method here
              _showAgentAssignmentModal(context, property['id']);
            },
            child: const Text('Assign Agent'),
          ),
        );
      }).toList(),
    );
  }
}
