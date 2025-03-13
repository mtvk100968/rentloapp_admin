import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http; // Add this line

class PropertyService {
  // Define FirebaseFirestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch properties from 'rentloapp'
  // Future<List<Map<String, dynamic>>> fetchPropertiesFromV2() async {
  //   List<Map<String, dynamic>> properties = [];
  //   try {
  //     FirebaseFirestore firestoreV2 =
  //         FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp'));
  //     QuerySnapshot propertiesSnapshot =
  //         await firestoreV2.collection('properties').get();
  //     properties = propertiesSnapshot.docs
  //         .map((doc) => doc.data() as Map<String, dynamic>)
  //         .toList();
  //   } catch (e) {
  //     print("Error fetching properties from rentloapp: $e");
  //   }
  //   return properties;
  // }

  Future<List<Map<String, dynamic>>> fetchPropertiesFromV2() async {
    List<Map<String, dynamic>> properties = [];
    try {
      FirebaseFirestore firestoreV2 = FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp'));
      QuerySnapshot propertiesSnapshot = await firestoreV2.collection('properties').get();

      // Process the documents and convert them into a List of Maps
      properties = propertiesSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print("Error fetching properties from rentloapp: $e");
    }
    return properties;
  }


  Future<void> debugFetchPropertiesFromV2() async {
    try {
      final v2Firestore = FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp'));
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await v2Firestore.collection('properties').get();

      print('Fetched ${querySnapshot.docs.length} properties from rentloapp');

      if (querySnapshot.docs.isEmpty) {
        print('No documents found in the properties collection');
      } else {
        querySnapshot.docs.forEach((doc) {
          print('Property ID: ${doc.id}, Data: ${doc.data()}');
        });
      }
    } catch (e) {
      print("Error fetching properties from rentloapp: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchAgents() async {
    List<Map<String, dynamic>> agents = [];
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('agents')
          .get();

      agents = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          "id": doc.id,
          "name": data["name"] ?? "Unknown",
          "area": data["area"] ?? "N/A",
          "pincode": data["pincode"] ?? "N/A",
        };
      }).toList();
    } catch (e) {
      print("Error fetching agents: $e");
    }
    return agents;
  }

  // // Combined addAgent method to add a new agent to Firestore with optional fields
  // Future<void> addAgent(Map<String, dynamic> agentData) async {
  //   try {
  //     // Use the agent ID as the document ID
  //     await _firestore.collection('agents').doc(agentData['id']).set(agentData);
  //     print("Agent added successfully.");
  //   } catch (e) {
  //     print("Failed to add agent: $e");
  //     throw e;
  //   }
  // }

  Future<void> addAgent(Map<String, dynamic> agentData) async {
    try {
      await _firestore.collection('agents').doc(agentData['id']).set(agentData);
      print("Agent added: ${agentData['name']}");
    } catch (e) {
      print("Error adding agent: $e");
      throw e;
    }
  }

  // // Add a new agent to Firestore
  // Future<void> addAgent(Map<String, dynamic> agentData) async {
  //   await FirebaseFirestore.instance
  //       .collection('agents')
  //       .doc(agentData['id'])
  //       .set(agentData);
  // }

  Future<void> removeAgent(String agentId) async {
    try {
      FirebaseFirestore firestoreAdmin =
      FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp-admin'));
      await firestoreAdmin.collection('agents').doc(agentId).delete();
      print("Agent removed successfully.");
    } catch (e) {
      print("Error removing agent: $e");
    }
  }

  Future<void> assignAgentToProperty(String propertyId, String agentId, String agentName) async {
    try {
      DocumentReference propertyRef =
      FirebaseFirestore.instance.collection('properties').doc(propertyId);

      // Add the agent to the 'agents' array
      await propertyRef.update({
        'agents': FieldValue.arrayUnion([
          {'id': agentId, 'name': agentName}
        ]),
      });

      print("Agent $agentName assigned successfully to property $propertyId.");
    } catch (e) {
      print("Error assigning agent to property: $e");
      throw Exception("Failed to assign agent.");
    }
  }

  // Sync properties from 'rentloapp' to 'rentloapp-admin'
  Future<void> syncPropertiesToAdmin() async {
    try {
      // Step 1: Fetch properties from rentloapp
      List<Map<String, dynamic>> properties = await fetchPropertiesFromV2();
      print("Fetched ${properties.length} properties from rentloapp");

      // Step 2: Get an instance of rentloapp-admin
      FirebaseFirestore firestoreAdmin = FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp-admin'));

      // Step 3: Sync each property to rentloapp-admin
      for (var property in properties) {
        String propertyId = property['id'];
        print("Syncing property ID: $propertyId to rentloapp-admin");

        await firestoreAdmin.collection('properties').doc(propertyId).set(
          property,
          SetOptions(merge: true),
        );
        print("Property ID: $propertyId synced successfully.");
      }

      print("All properties synced to rentloapp-admin successfully.");
    } catch (e) {
      print("Error syncing properties to rentloapp-admin: $e");
    }
  }

  Future<Map<String, String>> fetchLocationDetailsByPincode(
      String pincode) async {
    final url = 'https://api.postalpincode.in/pincode/$pincode';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data[0]['Status'] == 'Success') {
          final postOffice = data[0]['PostOffice'][0];
          return {
            'district': postOffice['District'],
            'state': postOffice['State'],
            'city': postOffice[
            'Division'], // Adjust if you need a different key for city
          };
        }
      }
      return {};
    } catch (e) {
      print('Error fetching location data: $e');
      return {};
    }
  }

  Future<void> removeAgentFromProperty(
      String propertyId, String agentId, String agentName) async {
    try {
      FirebaseFirestore firestoreAdmin =
      FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp-admin'));

      DocumentReference propertyRef =
      firestoreAdmin.collection('properties').doc(propertyId);

      // Fetch the property document
      DocumentSnapshot propertySnapshot = await propertyRef.get();
      if (!propertySnapshot.exists) {
        throw Exception("Property with ID $propertyId not found.");
      }

      // Retrieve the existing agents list
      List<dynamic> agents = propertySnapshot.get('agents') ?? [];

      // Filter out the agent with the specified agentId
      agents = agents.where((agent) => agent['id'] != agentId).toList();

      // Update the agents array in Firestore
      await propertyRef.update({'agents': agents});

      print("Agent removed successfully from property.");
    } catch (e) {
      print("Error removing agent from property: $e");
    }
  }

  Future<void> addCustomerReviewToProperty(String propertyId, Map<String, dynamic> reviewData) async {
    try {
      FirebaseFirestore firestoreAdmin = FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp-admin'));

      await firestoreAdmin.collection('properties')
          .doc(propertyId)
          .collection('customer_reviews')
          .add(reviewData);
      print("Customer review added successfully to property.");
    } catch (e) {
      print("Error adding customer review: $e");
    }
  }

  // Real-time listener for agents updates
  void listenToAgentsUpdates(Function(List<Map<String, dynamic>>) onAgentsUpdated) {
    FirebaseFirestore.instance
        .collection('agents')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      List<Map<String, dynamic>> agents = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      onAgentsUpdated(agents);
      print("Agents updated in real-time: $agents");
    });
  }

  // Real-time listener for customer reviews updates
  void listenToCustomerReviewsUpdates(String propertyId, Function(List<Map<String, dynamic>>) onReviewsUpdated) {
    FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyId)
        .collection('customer_reviews')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      List<Map<String, dynamic>> reviews = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      onReviewsUpdated(reviews);
      print("Customer reviews updated in real-time for property $propertyId: $reviews");
    });
  }

  Future<void> transferProperties() async {
    // Initialize Firebase for both projects
    final Rentloapp = FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp'));
    final RentloappAdmin = FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp-admin'));

    try {
      // Fetch properties from rentloapp
      QuerySnapshot<Map<String, dynamic>> snapshot = await Rentloapp.collection('properties').get();

      // Transfer properties to rentloapp-admin
      for (var doc in snapshot.docs) {
        final propertyData = doc.data();
        await RentloappAdmin
            .collection('properties')
            .doc(doc.id)
            .set(propertyData, SetOptions(merge: true));
      }

      print('Properties transferred successfully!');
    } catch (e) {
      print('Error transferring properties: $e');
    }
  }

  // Future<void> syncPropertiesToAdmin() async {
  //   try {
  //     final v2Firestore = FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp'));
  //     final adminFirestore = FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp-admin'));
  //
  //     // Set up the query with a limit for pagination
  //     Query<Map<String, dynamic>> query = v2Firestore.collection('properties').limit(50);
  //     QuerySnapshot<Map<String, dynamic>> snapshot;
  //
  //     do {
  //       // Fetch the current batch of documents
  //       snapshot = await query.get();
  //
  //       for (var doc in snapshot.docs) {
  //         try {
  //           final propertyData = doc.data();
  //           // Write the document to the admin Firestore
  //           await adminFirestore
  //               .collection('properties')
  //               .doc(doc.id)
  //               .set(propertyData, SetOptions(merge: true));
  //           print('Property ${doc.id} synced successfully.');
  //         } catch (e) {
  //           // Handle errors for individual document sync
  //           print('Error syncing property ${doc.id}: $e');
  //         }
  //       }
  //
  //       // Prepare the query for the next batch if there are more documents
  //       if (snapshot.docs.isNotEmpty) {
  //         query = v2Firestore
  //             .collection('properties')
  //             .startAfterDocument(snapshot.docs.last)
  //             .limit(50);
  //       }
  //     } while (snapshot.docs.isNotEmpty); // Continue until no more documents
  //
  //     print('All properties synced successfully.');
  //   } catch (e) {
  //     // Catch and rethrow any errors during the entire process
  //     print('Error syncing properties: $e');
  //     throw e;
  //   }
  // }

  Future<void> saveAgent(Map<String, dynamic> agentData) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      await firestore.collection('agents').doc(agentData['id']).set(agentData);
      print("Agent saved successfully.");
    } catch (e) {
      print("Error saving agent: $e");
      throw Exception("Failed to save agent.");
    }
  }

  Future<void> saveCustomerReview(String propertyId, Map<String, dynamic> reviewData) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final reviewsCollection = firestore
          .collection('properties')
          .doc(propertyId)
          .collection('customer_reviews');
      await reviewsCollection.add(reviewData);
      print("Customer review saved successfully.");
    } catch (e) {
      print("Error saving customer review: $e");
      throw Exception("Failed to save customer review.");
    }
  }

  Future<void> addCustomerToProperty(String propertyId, Map<String, dynamic> customerData) async {
    try {
      FirebaseFirestore firestoreAdmin = FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp-admin'));
      DocumentReference propertyRef = firestoreAdmin.collection('properties').doc(propertyId);

      await propertyRef.update({
        'customers': FieldValue.arrayUnion([customerData]),
      });
      print("Customer added successfully to property.");
    } catch (e) {
      print("Error adding customer to property: $e");
    }
  }
}
