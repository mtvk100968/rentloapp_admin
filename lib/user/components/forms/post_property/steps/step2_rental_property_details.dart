import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../../common/providers_user/property_provider.dart';
import '../../../../../utils/validators.dart'; // For number formatting

class Step2PropertyDetails extends StatefulWidget {
  final GlobalKey<FormState> formKey;

  const Step2PropertyDetails({Key? key, required this.formKey})
      : super(key: key);

  @override
  _Step2PropertyDetailsState createState() => _Step2PropertyDetailsState();
}

class _Step2PropertyDetailsState extends State<Step2PropertyDetails> {
  late TextEditingController _rentPerMonthController;
  late TextEditingController _advanceMonthsController;
  late TextEditingController _advanceRentController;

  // Controllers
  final TextEditingController _buildingNameController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _builtUpAreaController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  // ... add more as needed

  final indianFormat = NumberFormat.decimalPattern('en_IN');
  late final PropertyProvider _provider; // store reference here

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<PropertyProvider>(context, listen: false);

    _rentPerMonthController = TextEditingController(
      text: _provider.rentPerMonth > 0 ? indianFormat.format(_provider.rentPerMonth) : '',
    );
    _advanceMonthsController = TextEditingController(
      text: _provider.advanceRentMonths > 0 ? _provider.advanceRentMonths.toString() : '',
    );
    _advanceRentController = TextEditingController(
      text: _provider.advanceRent > 0 ? indianFormat.format(_provider.advanceRent) : '',
    );

    // Add a listener that checks for mounted before calling setState
    _provider.addListener(_updateAdvanceRent);
  }

  /// Build a row of ChoiceChips for "Property Type"
  Widget _buildPropertyTypeSelection() {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final propertyTypeOptions = [
      "Apartment",
      "Independent Floor",
      "Independent House",
      "Villa",
      "Commercial"
    ];

    return Wrap(
      spacing: 8.0,
      children: propertyTypeOptions.map((option) {
        final isSelected = (propertyProvider.propertyType == option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              propertyProvider.setPropertyType(option);
            }
          },
        );
      }).toList(),
    );
  }


  /// Build a row of ChoiceChips for BHK selection
  Widget _buildBhkSelection() {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final bhkOptions = ["1 BHK", "2 BHK", "3 BHK", "4 BHK", "5 BHK", "6 BHK", "7 BHK", "8 BHK"];

    return Wrap(
      spacing: 8.0,
      children: bhkOptions.map((option) {
        final isSelected = (propertyProvider.bedRooms == option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              propertyProvider.setBedRooms(option);
            } else {
              propertyProvider.setBedRooms(null);
            }
          },
        );
      }).toList(),
    );
  }

  Widget _buildBathSelection() {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final bathOptions = ["1 Bath", "2 Bath", "3 Bath", "4+ Bath"];

    return Wrap(
      spacing: 8.0,
      children: bathOptions.map((option) {
        final isSelected = (propertyProvider.bathRooms == option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              propertyProvider.setBathRooms(option);
            } else {
              propertyProvider.setBathRooms(null);
            }
          },
        );
      }).toList(),
    );
  }


  /// Build a row of ChoiceChips for ParkingSpots selection
  Widget _buildParkingSpotsSelection() {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final pksOptions = ["1 PKS", "2 PKS", "3 PKS"];

    return Wrap(
      spacing: 8.0,
      children: pksOptions.map((option) {
        final isSelected = (propertyProvider.parkingSpots == option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              propertyProvider.setParkingSpots(option);
            } else {
              propertyProvider.setParkingSpots(null);
            }
          },
        );
      }).toList(),
    );
  }


  /// Build a row of ChoiceChips for Furnish Type
  Widget _buildFurnishSelection() {
    final propertyProvider = Provider.of<PropertyProvider>(context);
    final furnishingOptions = ["Fully Furnished", "Semi Furnished", "Unfurnished"];

    return Wrap(
      spacing: 8.0,
      children: furnishingOptions.map((option) {
        final isSelected = (propertyProvider.furnishType == option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              propertyProvider.setFurnishType(option);
            } else {
              propertyProvider.setFurnishType(null);
            }
          },
        );
      }).toList(),
    );
  }


  // void _updateAdvanceRent() {
  //   final provider = Provider.of<PropertyProvider>(context, listen: false);
  //   double advanceRent = provider.rentPerMonth * provider.advanceRentMonths;
  //
  //   setState(() {
  //     _advanceRentController.text = advanceRent > 0
  //         ? indianFormat.format(advanceRent)
  //         : '';
  //   });
  //
  //   provider.setAdvanceRent(advanceRent);
  // }

  void _updateAdvanceRent() {
    if (!mounted) return; // Prevent calling setState after dispose

    double advanceRent = _provider.rentPerMonth * _provider.advanceRentMonths;

    setState(() {
      _advanceRentController.text = advanceRent > 0 ? indianFormat.format(advanceRent) : '';
    });

    _provider.setAdvanceRent(advanceRent);
  }

  @override
  void dispose() {
    _provider.removeListener(_updateAdvanceRent);
    _rentPerMonthController.dispose();
    _advanceMonthsController.dispose();
    _advanceRentController.dispose();
    _buildingNameController.dispose();
    _localityController.dispose();
    _builtUpAreaController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  String _formatToIndianSystem(String value) {
    if (value.isEmpty) return '';
    double? parsedValue = double.tryParse(value.replaceAll(',', ''));
    return parsedValue != null ? indianFormat.format(parsedValue) : value;
  }

  @override
  Widget build(BuildContext context) {
    final propertyProvider = Provider.of<PropertyProvider>(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 16.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
        ),
        child: Form(
          key: widget.formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rent per Month Field

                // 1) Property Type row
                const Text("Property Type", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildPropertyTypeSelection(),
                const SizedBox(height: 20),

                // 4) Bedrooms row
                const Text("Bedrooms", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildBhkSelection(),
                const SizedBox(height: 20),

                // 5) Bathrooms row
                const Text("Bathrooms", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildBathSelection(),
                const SizedBox(height: 20),


                // 6) Furnish Type
                const Text("Furnish Type", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildFurnishSelection(),
                const SizedBox(height: 20),

                // 4) ParkingSpots row
                const Text("ParkingSpots", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildParkingSpotsSelection(),
                const SizedBox(height: 20),

                // 5) Built-Up Area
                TextFormField(
                  controller: _builtUpAreaController,
                  decoration: const InputDecoration(
                    labelText: 'Built Up Area',
                    suffixText: 'Sq. ft.',
                  ),
                  keyboardType: TextInputType.number,
                  validator: Validators.requiredValidator,
                  onChanged: (value) {
                    // e.g. propertyProvider.setBuiltUpArea(double.tryParse(value) ?? 0);
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _rentPerMonthController,
                  decoration: const InputDecoration(labelText: 'Rent per Month'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: Validators.priceValidator,
                  onChanged: (value) {
                    String formattedValue = value.isNotEmpty
                        ? indianFormat.format(double.tryParse(value.replaceAll(',', '')) ?? 0.0)
                        : '';
                    _rentPerMonthController.value = TextEditingValue(
                      text: formattedValue,
                      selection: TextSelection.collapsed(offset: formattedValue.length),
                    );
                    double? parsedValue = double.tryParse(value.replaceAll(',', ''));
                    propertyProvider.setRentPerMonth(parsedValue ?? 0.0);
                  },
                ),
                const SizedBox(height: 20),

                // Advance Rent Months Field
                TextFormField(
                  controller: _advanceMonthsController,
                  decoration: const InputDecoration(
                    labelText: 'Advance Rent Months',
                  ),
                  keyboardType: TextInputType.number,
                  validator: Validators.requiredValidator,
                  onChanged: (value) {
                    int? months = int.tryParse(value);
                    propertyProvider.setAdvanceRentMonths(months ?? 0);
                    _updateAdvanceRent();
                  },
                ),
                const SizedBox(height: 20),

                // Advance Rent (Auto-calculated)
                TextFormField(
                  controller: _advanceRentController,
                  decoration: const InputDecoration(
                    labelText: 'Advance Rent (auto-calculated)',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  enabled: false, // Auto-calculated
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}