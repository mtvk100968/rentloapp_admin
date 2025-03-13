import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerInteractionScreen extends StatefulWidget {
  final String propertyId;
  final String agentId;
  final String agentName;

  const CustomerInteractionScreen({
    Key? key,
    required this.propertyId,
    required this.agentId,
    required this.agentName,
  }) : super(key: key);

  @override
  _CustomerInteractionScreenState createState() => _CustomerInteractionScreenState();
}

class _CustomerInteractionScreenState extends State<CustomerInteractionScreen> {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // final TextEditingController _otpController = TextEditingController();
  final TextEditingController _priceOfferedController = TextEditingController();
  final TextEditingController _opinionController = TextEditingController();

  // bool isOTPSent = false;
  // String? generatedOTP;

  Future<List<Map<String, dynamic>>> _fetchCustomerInteractions() async {
    final interactionsSnapshot = await FirebaseFirestore.instance
        .collection('properties')
        .doc(widget.propertyId)
        .collection('customer_interactions')
        .where('agentId', isEqualTo: widget.agentId)
        .get();

    return interactionsSnapshot.docs.map((doc) => doc.data()).toList();
  }

  // Method to add customer interaction
  Future<void> addCustomerInteraction(Map<String, dynamic> interactionData) async {
    await ensureAuthenticated(); // Ensures user is signed in
    await FirebaseFirestore.instance
        .collection('properties')
        .doc(widget.propertyId) // Use widget.propertyId instead of propertyId
        .collection('customer_interactions')
        .add(interactionData);
  }

  Future<void> ensureAuthenticated() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  // void _sendOTP() {
  //   // Generate a simple OTP (for demonstration purposes, ideally use a more secure method).
  //   generatedOTP = (1000 + (9000 * (new DateTime.now().millisecond % 1000)).toInt()).toString();
  //   setState(() {
  //     isOTPSent = true;
  //   });
  //   // You would send this OTP to the customer via an SMS API in a real application.
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text("OTP sent: $generatedOTP")), // Display OTP for demo (Remove in production).
  //   );
  // }

  Future<void> _addCustomerInteraction() async {
    // if (_otpController.text != generatedOTP) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text("Invalid OTP. Please try again.")),
    //   );
    //   return;
    // }

    final customerName = _customerNameController.text.trim();
    final phoneNumber = _phoneController.text.trim();

    if (customerName.isEmpty || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields.")),
      );
      return;
    }

    final interactionsRef = FirebaseFirestore.instance
        .collection('properties')
        .doc(widget.propertyId)
        .collection('customer_interactions');

    try {
      // Check if the customer already exists
      QuerySnapshot existingCustomer = await interactionsRef
          .where('agentId', isEqualTo: widget.agentId)
          .where('customerName', isEqualTo: customerName)
          .where('phoneNo', isEqualTo: phoneNumber)
          .get();

      if (existingCustomer.docs.isNotEmpty) {
        // Customer exists, update their interaction
        DocumentSnapshot existingDoc = existingCustomer.docs.first;
        await existingDoc.reference.update({
          'visitCount': FieldValue.increment(1),
          // Increment visit count
          'visitTimestamps': FieldValue.arrayUnion([Timestamp.now()]),
          // Add new timestamp
          'priceOffered': int.tryParse(_priceOfferedController.text) ?? 0,
          // Update price offered
          'opinion': _opinionController.text,
          // Update opinion
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Customer interaction updated successfully.")),
        );
      } else {
        // Add a new customer interaction
        final newInteraction = {
          'agentId': widget.agentId,
          'customerName': customerName,
          'phoneNo': phoneNumber,
          'priceOffered': int.tryParse(_priceOfferedController.text) ?? 0,
          'opinion': _opinionController.text,
          'visitCount': 1, // First visit
          'visitTimestamps': [Timestamp.now()], // Log first visit timestamp
        };

        await interactionsRef.add(newInteraction);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Customer interaction added successfully.")),
        );
      }

      // Clear the form
      _customerNameController.clear();
      _phoneController.clear();
      _priceOfferedController.clear();
      _opinionController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add interaction: $e")),
      );
    }
  }

  Future<void> saveCustomerInteraction(String propertyId, String agentId, String customerName, String phoneNo, int offerPrice, String opinion) async {
    await FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyId)
        .collection('customer_interactions')
        .add({
      'agentId': agentId,
      'customerName': customerName,
      'phoneNo': phoneNo,
      'offerPrice': offerPrice,
      'opinion': opinion,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Customers adding by ${widget.agentName}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Form for adding a new customer interaction
            TextField(
              controller: _customerNameController,
              decoration: const InputDecoration(labelText: "Customer Name"),
            ),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone Number"),
            ),
            // if (!isOTPSent)
            //   ElevatedButton(
            //     onPressed: _sendOTP,
            //     child: const Text("Send OTP"),
            //   ),
            // if (isOTPSent) ...[
            // TextField(
            //   controller: _otpController,
            //   keyboardType: TextInputType.number,
            //   decoration: const InputDecoration(labelText: "Enter OTP"),
            // ),
            TextField(
              controller: _priceOfferedController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price Offered"),
            ),
            TextField(
              controller: _opinionController,
              decoration: const InputDecoration(labelText: "Opinion"),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                // Prepare the data to be saved
                Map<String, dynamic> interactionData = {
                  'customerName': _customerNameController.text,
                  'phoneNo': _phoneController.text,
                  'offerPrice': _priceOfferedController.text,
                  'opinion': _opinionController.text,
                  'agentId': widget.agentId, // Use widget.agentId here
                };

                // Call the method to save data to Firestore
                await addCustomerInteraction(interactionData);

                // Show confirmation and go back
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Customer interaction added successfully!")),
                );

                Navigator.pop(context);
              },
              child: Text("Add Customer Interaction"),
            ),
          ],
        ),
      ),
    );
  }
}