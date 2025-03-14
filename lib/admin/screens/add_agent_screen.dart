// File: screens/add_agent_screen.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../common/services_admin/property_service.dart';

class AddAgentScreen extends StatefulWidget {
  const AddAgentScreen({Key? key}) : super(key: key);

  @override
  _AddAgentScreenState createState() => _AddAgentScreenState();
}

class _AddAgentScreenState extends State<AddAgentScreen> {
  final PropertyService propertyService = PropertyService();
  final TextEditingController _agentNameController = TextEditingController();
  final TextEditingController _agentIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _tahsilController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  String? _selectedGender; // Store the selected gender
  bool _isLoading = false;
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final fileName = 'agents/${_phoneController.text}.png';
      final ref = FirebaseStorage.instance.ref().child(fileName);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<String> _uploadDefaultPlaceholder(String assetPath, String gender) async {
    try {
      final fileName = 'agents/placeholders/$gender.png';
      final ref = FirebaseStorage.instance.ref().child(fileName);

      // Load the asset bytes
      final bytes = await DefaultAssetBundle.of(context).load(assetPath);

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$fileName');

      // Write the bytes to the temporary file
      await tempFile.writeAsBytes(bytes.buffer.asUint8List());

      // Upload the file to Firebase Storage
      await ref.putFile(tempFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading default placeholder: $e");
      return 'assets/images/$gender.png'; // Fallback to local asset path
    }
  }

  @override
  void initState() {
    super.initState();

    // Listener for the pincode field to automatically fetch location details
    _pincodeController.addListener(() async {
      if (_pincodeController.text.length == 6) {
        // Check if pincode is complete (6 digits)
        final locationDetails = await propertyService
            .fetchLocationDetailsByPincode(_pincodeController.text);
        if (locationDetails.isNotEmpty) {
          _districtController.text = locationDetails['district'] ?? '';
          _stateController.text = locationDetails['state'] ?? '';
          _cityController.text = locationDetails['city'] ?? '';
          setState(() {}); // Update the UI with new values
        }
      }
    });

    // Listener to copy phone number to agent ID
    _phoneController.addListener(() {
      _agentIdController.text = _phoneController.text;
    });
  }

  Future<void> _addAgent() async {
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a gender.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? imageUrl;

    // Upload image if selected, else set default based on gender
    try {
      // Check if an image is selected
      if (_selectedImage != null) {
        // Upload selected image
        imageUrl = await _uploadImage(_selectedImage!); // Upload and get URL
      }

      // If no image is uploaded, use default placeholder based on gender
      imageUrl ??= _selectedGender == 'Male'
          ? await _uploadDefaultPlaceholder('assets/images/businessman.png', 'Male')
          : await _uploadDefaultPlaceholder('assets/images/businesswoman.png', 'Female');


      final agentData = {
        'id': _agentIdController.text,
        'name': _agentNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'city': _cityController.text,
        'district': _districtController.text,
        'state': _stateController.text,
        'tahsil': _tahsilController.text,
        'pincode': _pincodeController.text,
        'gender': _selectedGender, // Add gender to agent data
        'imageUrl': imageUrl, // Save image URL
        'assignedProperties': '0', // Convert to String
        'dealsClosed': '0', // Convert to String
      };

      // Add agent to Firestore
      await propertyService.addAgent(agentData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Agent added successfully!")),
      );

      _resetForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to add agent: $e")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Clear input fields after successful addition
  void _resetForm() {
    _agentIdController.clear();
    _agentNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _addressController.clear();
    _cityController.clear();
    _districtController.clear();
    _stateController.clear();
    _tahsilController.clear();
    _pincodeController.clear();
    setState(() {
      _selectedGender = null;
      _selectedImage = null;
    });
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera),
            title: const Text('Camera'),
            onTap: () {
              Navigator.of(context).pop(); // Close the bottom sheet
              _pickImage(ImageSource.camera); // Use camera
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.of(context).pop(); // Close the bottom sheet
              _pickImage(ImageSource.gallery); // Use gallery
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Agent'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _agentNameController,
                decoration: const InputDecoration(labelText: 'Agent Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _agentIdController,
                decoration: const InputDecoration(
                  labelText: 'Agent ID (Phone Number)',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Street and city'),
                keyboardType: TextInputType.streetAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tahsilController,
                decoration: const InputDecoration(labelText: 'Tahsil/Mandal'),
                readOnly: false,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: 'District'),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
                readOnly: true,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _selectedImage != null
                      ? Image.file(
                    _selectedImage!,
                    height: 50,
                    width: 50,
                  )
                      : const Text("No image selected."),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () => _showImageSourceBottomSheet(),
                    child: const Text("Pick Image"),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _addAgent,
                child: const Text('Add Agent'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _agentNameController.dispose();
    _agentIdController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _tahsilController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }
}
