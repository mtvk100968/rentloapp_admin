import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerVisitPropertyPage extends StatefulWidget {
  final String propertyId;
  final String agentId;

  CustomerVisitPropertyPage({required this.propertyId, required this.agentId});

  @override
  _CustomerVisitPropertyPageState createState() => _CustomerVisitPropertyPageState();
}

class _CustomerVisitPropertyPageState extends State<CustomerVisitPropertyPage> {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController willingPriceController = TextEditingController();

  void logCustomerVisit() {
    String customerName = customerNameController.text;
    double willingPrice = double.tryParse(willingPriceController.text) ?? 0.0;

    if (customerName.isNotEmpty && willingPrice > 0) {
      FirebaseFirestore.instance.collection('properties').doc(widget.propertyId).collection('visits').add({
        'customerName': customerName,
        'willingPrice': willingPrice,
        'agentId': widget.agentId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Customer visit logged!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please enter valid details.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Log Customer Visit')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: customerNameController,
              decoration: InputDecoration(labelText: 'Customer Name'),
            ),
            TextField(
              controller: willingPriceController,
              decoration: InputDecoration(labelText: 'Willing Price'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: logCustomerVisit,
              child: Text('Log Visit'),
            ),
          ],
        ),
      ),
    );
  }
}
