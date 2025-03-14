//
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../../common/providers_user/property_provider.dart';
import '../../../../../common/services_user/geocodeing_service.dart';
import '../../../../../utils/validators.dart';

class Step3AddressDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const Step3AddressDetails({Key? key, required this.formKey}) : super(key: key);

  @override
  _Step3AddressDetailsState createState() => _Step3AddressDetailsState();
}

class _Step3AddressDetailsState extends State<Step3AddressDetails> {
  late TextEditingController _pincodeController;
  late TextEditingController _houseNoController;
  late TextEditingController _propertyNameController;
  late TextEditingController _colonyNameController;
  late TextEditingController _addressController;
  late TextEditingController _taluqMandalController;
  late TextEditingController _districtController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _villageController;

  late final VoidCallback _listener;
  late final PropertyProvider _propertyProvider;

  @override
  void initState() {
    super.initState();
    _propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
    _listener = () => _updateControllers(_propertyProvider);
    _propertyProvider.addListener(_listener);

    // Initialize controllers from provider...
    _pincodeController = TextEditingController(text: _propertyProvider.pincode);
    _houseNoController = TextEditingController(text: _propertyProvider.houseNo);
    _propertyNameController = TextEditingController(text: _propertyProvider.propertyName);
    _colonyNameController = TextEditingController(text: _propertyProvider.colonyName);
    _addressController = TextEditingController(text: _propertyProvider.address ?? '');
    _districtController = TextEditingController(text: _propertyProvider.district ?? '');
    _cityController = TextEditingController(text: _propertyProvider.city);
    _taluqMandalController = TextEditingController(text: _propertyProvider.taluqMandal);
    _stateController = TextEditingController(text: _propertyProvider.state);
    _villageController = TextEditingController(text: _propertyProvider.village ?? '');
  }

  void _updateControllers(PropertyProvider provider) {
    if (!mounted) return;
    if (_pincodeController.text != provider.pincode) {
      _pincodeController.text = provider.pincode;
    }
    if (_cityController.text != provider.city) {
      _cityController.text = provider.city;
    }
    if (_districtController.text != (provider.district ?? '')) {
      _districtController.text = provider.district ?? '';
    }
    if (_stateController.text != provider.state) {
      _stateController.text = provider.state;
    }
    if (_villageController.text != (provider.village ?? '')) {
      _villageController.text = provider.village ?? '';
    }
    setState(() {});
  }

  // /// Fetch city/district/state from pincode
  // Future<void> _fetchLocationFromPincode() async {
  //   final propertyProvider = Provider.of<PropertyProvider>(context, listen: false);
  //   String pincode = _pincodeController.text.trim();
  //
  //   if (pincode.length == 6) {
  //     try {
  //       Map<String, String>? locationData =
  //       await GeocodingService.getLocationFromPincode(pincode);
  //       if (locationData != null) {
  //         propertyProvider.setPincode(pincode);
  //         propertyProvider.setCity(locationData["city"] ?? '');
  //         propertyProvider.setDistrict(locationData["district"] ?? '');
  //         propertyProvider.setStateField(locationData["state"] ?? '');
  //
  //         setState(() {
  //           _cityController.text = propertyProvider.city;
  //           _districtController.text = propertyProvider.district ?? '';
  //           _stateController.text = propertyProvider.state;
  //         });
  //       }
  //     } catch (e) {
  //       print("Error fetching location: $e");
  //     }
  //   }
  // }

  Future<void> _fetchLocationFromPincode() async {
    String pincode = _pincodeController.text.trim();

    if (pincode.length == 6) {
      try {
        final locationData = await GeocodingService.getLocationFromPincode(pincode);
        if (locationData != null) {
          // Use your stored provider reference.
          _propertyProvider.setPincode(pincode);
          _propertyProvider.setCity(locationData["city"] ?? '');
          _propertyProvider.setDistrict(locationData["district"] ?? '');
          _propertyProvider.setStateField(locationData["state"] ?? '');

          if (mounted) {
            setState(() {
              _cityController.text = _propertyProvider.city;
              _districtController.text = _propertyProvider.district ?? '';
              _stateController.text = _propertyProvider.state;
            });
          }
        }
      } catch (e) {
        print("Error fetching location: $e");
      }
    }
  }

  @override
  void dispose() {
    _propertyProvider.removeListener(_listener);
    _pincodeController.dispose();
    _houseNoController.dispose();
    _propertyNameController.dispose();
    _colonyNameController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _villageController.dispose();
    _taluqMandalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return Form(
      key: widget.formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Pincode
              TextFormField(
                controller: _pincodeController,
                decoration: const InputDecoration(labelText: 'Pincode'),
                keyboardType: TextInputType.number,
                validator: Validators.pincodeValidator,
                onFieldSubmitted: (_) => _fetchLocationFromPincode(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (val) => propertyProvider.setPincode(val),
              ),
              const SizedBox(height: 20),

              // House No
              TextFormField(
                controller: _houseNoController,
                decoration: const InputDecoration(labelText: 'House No'),
                validator: Validators.requiredValidator,
                onChanged: (value) => propertyProvider.setHouseNo(value),
              ),
              const SizedBox(height: 20),

              // Property Name
              // 2) Building/Project/Society Name
              TextFormField(
                controller: _propertyNameController,
                decoration: const InputDecoration(
                  labelText: 'Building / Project / Society (Name)',
                ),
                validator: Validators.requiredValidator,
                onChanged: (value) {
                  // e.g. propertyProvider.setPropertyName(value);
                },
              ),
              const SizedBox(height: 20),

              // Colony Name
              TextFormField(
                controller: _colonyNameController,
                decoration: const InputDecoration(labelText: 'Colony Name'),
                validator: Validators.requiredValidator,
                onChanged: (value) => propertyProvider.setColonyName(value),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _villageController,
                decoration: const InputDecoration(labelText: 'Village'),
                validator: Validators.requiredValidator,
                onChanged: (value) => propertyProvider.setVillage(value),
              ),
              const SizedBox(height: 20),

              // Taluq / Mandal
              TextFormField(
                controller: _taluqMandalController,
                decoration: const InputDecoration(labelText: 'Taluq / Mandal'),
                validator: Validators.requiredValidator,
                onChanged: (value) => propertyProvider.setTaluqMandal(value),
              ),
              const SizedBox(height: 20),

              // City (read-only)
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'City'),
                readOnly: true,
              ),
              const SizedBox(height: 20),

              // District (read-only)
              TextFormField(
                controller: _districtController,
                decoration: const InputDecoration(labelText: 'District'),
                readOnly: true,
              ),
              const SizedBox(height: 20),

              // State (read-only)
              TextFormField(
                controller: _stateController,
                decoration: const InputDecoration(labelText: 'State'),
                readOnly: true,
              ),
              const SizedBox(height: 20),

              // Next, Add Price Details button

              // SizedBox(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       // Validate
              //       if (widget.formKey.currentState!.validate()) {
              //         // If valid, proceed to next step
              //         // e.g., Navigator.push(...) or propertyProvider.saveStep3();
              //         print("Step 3 is valid. Move to next step or show Step 4.");
              //       }
              //     },
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.green,
              //       foregroundColor: Colors.white,
              //     ),
              //     child: const Text('Next, Add Price Details'),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}