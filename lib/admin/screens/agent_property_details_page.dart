import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgentPropertyDetailsPage extends StatelessWidget {
  final String propertyId;
  final String agentId;

  const AgentPropertyDetailsPage({
    required this.propertyId,
    required this.agentId,
    Key? key,
  }) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchPropertyCustomerInteractions() async {
    // Query to fetch customer interactions for the specific property and agent
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collectionGroup('customer_interactions')
        .where('propertyId', isEqualTo: propertyId)
        .where('agentId', isEqualTo: agentId)
        .get();

    // Map Firestore documents to a list of maps
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Property Details")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPropertyCustomerInteractions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final interactions = snapshot.data ?? [];
          if (interactions.isEmpty) {
            return const Center(child: Text("No customer interactions available."));
          }
          return ListView.builder(
            itemCount: interactions.length,
            itemBuilder: (context, index) {
              final interaction = interactions[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interaction['customerName'] ?? 'Unknown Customer',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text("Phone: ${interaction['phoneNo'] ?? 'N/A'}"),
                      Text("Offer Price: ${interaction['offerPrice'] ?? 'N/A'}"),
                      Text("Opinion: ${interaction['opinion'] ?? 'N/A'}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
