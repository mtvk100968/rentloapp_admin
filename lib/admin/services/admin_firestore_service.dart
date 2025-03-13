import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AdminFirestoreService {
  static FirebaseFirestore _firestoreInstance =
      FirebaseFirestore.instance;

  // Fetch agents collection
  static Future<void> fetchAgents() async {
    try {
      final snapshot = await _firestoreInstance.collection('agents').get();
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          print('Agent: ${doc.data()}');
        }
      } else {
        print('No agents found.');
      }
    } catch (e) {
      print('Error fetching agents: $e');
    }
  }

  // Sync properties from rentloapp to rentloapp-admin
  static Future<void> syncProperties() async {
    try {
      final v2Firestore = FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp'));
      final adminFirestore = FirebaseFirestore.instanceFor(app: Firebase.app('rentloapp-admin'));

      final v2Properties = await v2Firestore.collection('properties').get();

      for (var doc in v2Properties.docs) {
        await adminFirestore.collection('properties').doc(doc.id).set(doc.data());
        print('Synced property: ${doc.id}');
      }
      print('All properties synced successfully!');
    } catch (e) {
      print('Error syncing properties: $e');
    }
  }
}
