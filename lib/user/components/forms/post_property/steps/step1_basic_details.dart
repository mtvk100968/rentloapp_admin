import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../common/models_user/user_model.dart';
import '../../../../../common/providers_user/property_provider.dart';
import '../../../../../utils/format.dart';
import '../../../../../utils/validators.dart';

class Step1BasicDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const Step1BasicDetails({Key? key, required this.formKey}) : super(key: key);

  @override
  _Step1BasicDetailsState createState() => _Step1BasicDetailsState();
}

class _Step1BasicDetailsState extends State<Step1BasicDetails> {
  String? selectedValue; // Ensure it starts as null
  final List<String> propertyTypes = [
    "Apartment",
    "House",
    "Villa",
    "Plot",
    "Commercial Space",
  ]; // Add your property types here

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();

  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Attempt to fetch phone number from Firebase Auth
      _phoneController.text = user.phoneNumber ?? '';

      try {
        // Fetch additional details from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          setState(() {
            currentUser = AppUser.fromDocument(doc.data()!);
            _emailController.text = currentUser?.email ?? '';
            _phoneController.text = currentUser?.phoneNumber ??
                user.phoneNumber ??
                ''; // Use Firestore as fallback
            _nameController.text = currentUser?.name ?? '';
          });
        }
      } catch (e) {
        print("Error fetching Firestore user data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phone Number Field
            TextFormField(
              decoration: const InputDecoration(labelText: 'Your Phone Number'),
              keyboardType: TextInputType.phone,
              initialValue: propertyProvider.phoneNumber.isNotEmpty
                  ? propertyProvider.phoneNumber
                  : '+91',
              validator: Validators.phoneValidator,
              onChanged: (value) => propertyProvider.setPhoneNumber(value),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\+?[0-9]*$')),
                LengthLimitingTextInputFormatter(13),
              ],
            ),
            const SizedBox(height: 20),

            // Email ID Field (NEW)
            TextFormField(
              decoration: const InputDecoration(labelText: 'Your Email'),
              keyboardType: TextInputType.emailAddress,
              initialValue: propertyProvider.email,
              validator: Validators.emailValidator,
              onChanged: (value) => propertyProvider.setEmail(value),
            ),
            const SizedBox(height: 20),

            // Name Field
            TextFormField(
              decoration: const InputDecoration(labelText: 'Your Name'),
              initialValue: propertyProvider.name,
              validator: Validators.requiredValidator,
              onChanged: (value) => propertyProvider.setName(value),
              inputFormatters: [
                capitalizeWordsInputFormatter(),
              ],
            ),
            const SizedBox(height: 20),

            // Property Owner Name Field
            TextFormField(
              decoration:
              const InputDecoration(labelText: 'Property Owner Name'),
              initialValue: propertyProvider.propertyOwnerName,
              validator: Validators.requiredValidator,
              onChanged: (value) =>
                  propertyProvider.setPropertyOwnerName(value),
              inputFormatters:[
                capitalizeWordsInputFormatter(),
              ],
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
