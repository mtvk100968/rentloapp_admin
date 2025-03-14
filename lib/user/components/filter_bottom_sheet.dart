import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PropertyType { Apartment, IndependetHouse, Villa, CommercialSpace }

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? currentFilters;

  const FilterBottomSheet({Key? key, this.currentFilters}) : super(key: key);

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Existing fields
  PropertyType? selectedPropertyType;
  String rentPrice = '';
  String areaInSqft = '';
  double minRentPrice = 0.0;
  double maxRentPrice = 0.0;
  double minAreaInSqft = 0.0;
  double maxAreaInSqft = 0.0;
  RangeValues selectedRentPriceRange = const RangeValues(0, 0);
  RangeValues selectedAreaRange = const RangeValues(0, 0);
  bool isLoading = false;

  // NEW FIELDS: location (city) and bedrooms
  final TextEditingController _locationController = TextEditingController();
  int? _selectedBedrooms; // 1..4 => 4+ is “5”

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  // Convert string to enum
  PropertyType? _propertyTypeFromString(String typeString) {
    switch (typeString) {
      case 'Apartment':
        return PropertyType.Apartment;
      case 'IndependetHouse':
        return PropertyType.IndependetHouse;
      case 'Villa':
        return PropertyType.Villa;
      case 'CommercialSpace':
        return PropertyType.CommercialSpace;
      default:
        return null;
    }
  }

  // Convert enum to string
  String _propertyTypeToString(PropertyType type) {
    switch (type) {
      case PropertyType.Apartment:
        return 'Apartment';
      case PropertyType.IndependetHouse:
        return 'IndependetHouse';
      case PropertyType.Villa:
        return 'Villa';
      case PropertyType.CommercialSpace:
        return 'CommercialSpace';
    }
  }

  Future<void> _loadFilters() async {
    final prefs = await SharedPreferences.getInstance();

    // Load property type
    final List<String> propertyTypes =
        prefs.getStringList('selectedPropertyTypes') ?? [];
    if (propertyTypes.isNotEmpty) {
      selectedPropertyType = _propertyTypeFromString(propertyTypes.first);
    }

    // Setup min/max defaults
    if (selectedPropertyType == PropertyType.Apartment) {
      minRentPrice = 5000;
      maxRentPrice = 500000;
      minAreaInSqft = 500;
      maxAreaInSqft = 10000;
    } else if (selectedPropertyType == PropertyType.IndependetHouse ||
        selectedPropertyType == PropertyType.Villa) {
      minRentPrice = 5000;
      maxRentPrice = 500000;
      minAreaInSqft = 500;
      maxAreaInSqft = 10000;
    } else {
      minRentPrice = 5000;
      maxRentPrice = 500000;
      minAreaInSqft = 500;
      maxAreaInSqft = 10000;
    }

    // Load last chosen range
    double loadedMinRent = prefs.getDouble('minRentPrice') ?? minRentPrice;
    double loadedMaxRent = prefs.getDouble('maxRentPrice') ?? maxRentPrice;
    double loadedMinArea = prefs.getDouble('minAreaInSqft') ?? minAreaInSqft;
    double loadedMaxArea = prefs.getDouble('maxAreaInSqft') ?? maxAreaInSqft;

    // Clamp them
    loadedMinRent = loadedMinRent.clamp(minRentPrice, maxRentPrice);
    loadedMaxRent = loadedMaxRent.clamp(minRentPrice, maxRentPrice);
    if (loadedMinRent > loadedMaxRent) {
      loadedMinRent = minRentPrice;
      loadedMaxRent = maxRentPrice;
    }

    loadedMinArea = loadedMinArea.clamp(minAreaInSqft, maxAreaInSqft);
    loadedMaxArea = loadedMaxArea.clamp(minAreaInSqft, maxAreaInSqft);
    if (loadedMinArea > loadedMaxArea) {
      loadedMinArea = minAreaInSqft;
      loadedMaxArea = maxAreaInSqft;
    }

    // Set your RangeValues
    setState(() {
      selectedRentPriceRange = RangeValues(loadedMinRent, loadedMaxRent);
      selectedAreaRange = RangeValues(loadedMinArea, loadedMaxArea);
    });

    // NEW: load location and bedrooms
    _locationController.text = prefs.getString('location') ?? '';
    _selectedBedrooms = prefs.getInt('bedrooms'); // might be null
  }

  Future<void> _saveFilters() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> propertyTypes = selectedPropertyType != null
        ? [_propertyTypeToString(selectedPropertyType!)]
        : [];

    await prefs.setStringList('selectedPropertyTypes', propertyTypes);
    // Save range
    await prefs.setDouble('minRentPrice', selectedRentPriceRange.start);
    await prefs.setDouble('maxRentPrice', selectedRentPriceRange.end);
    await prefs.setDouble('minAreaInSqft', selectedAreaRange.start);
    await prefs.setDouble('maxAreaInSqft', selectedAreaRange.end);

    // Save rentPrice / areaInSqft strings
    await prefs.setString('pricePerUnitUnit', rentPrice);
    await prefs.setString('landAreaUnit', areaInSqft);

    // NEW: save location and bedrooms
    await prefs.setString('location', _locationController.text);
    if (_selectedBedrooms != null) {
      await prefs.setInt('bedrooms', _selectedBedrooms!);
    } else {
      // or remove the key if null
      prefs.remove('bedrooms');
    }
  }

  void togglePropertyType(PropertyType type) {
    setState(() {
      if (selectedPropertyType == type) {
        selectedPropertyType = null;
        resetFilters();
      } else {
        selectedPropertyType = type;
        if (selectedPropertyType == PropertyType.Apartment) {
          rentPrice = 'rentPrice';
          areaInSqft = 'sqft';
          minRentPrice = 5000;
          maxRentPrice = 500000;
          minAreaInSqft = 100;
          maxAreaInSqft = 10000;
          selectedRentPriceRange = RangeValues(minRentPrice, maxRentPrice);
          selectedAreaRange = RangeValues(minAreaInSqft, minAreaInSqft);
        } else if (selectedPropertyType == PropertyType.IndependetHouse ||
            selectedPropertyType == PropertyType.Villa) {
          rentPrice = 'rentPrice';
          areaInSqft = 'sqft';
          minRentPrice = 5000;
          maxRentPrice = 500000;
          minAreaInSqft = 100;
          maxAreaInSqft = 10000;
          selectedRentPriceRange = RangeValues(minRentPrice, maxRentPrice);
          selectedAreaRange = RangeValues(minAreaInSqft, minAreaInSqft);
        }
      }
    });
  }

  void resetFilters() {
    setState(() {
      selectedPropertyType = null;
      rentPrice = 'rentPrice';
      areaInSqft = 'sqft';
      minRentPrice = 5000;
      maxRentPrice = 500000;
      minAreaInSqft = 500;
      maxAreaInSqft = 10000;
      selectedRentPriceRange = RangeValues(minRentPrice, maxRentPrice);
      selectedAreaRange = RangeValues(minAreaInSqft, maxAreaInSqft);

      // Reset location and bedrooms
      _locationController.clear();
      _selectedBedrooms = null;
    });
  }

  String formatPrice(double value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(1)}C';
    } else if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  void applyFilters() async {
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    await _saveFilters();

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filters Applied')),
    );

    List<String> selectedPropertyTypesList = selectedPropertyType != null
        ? [_propertyTypeToString(selectedPropertyType!)]
        : [];

    Navigator.pop(context, {
      'selectedPropertyTypes': selectedPropertyTypesList,
      'selectedRentPriceRange': selectedRentPriceRange,
      'selectedAreaRange': selectedAreaRange,
      'areaInSqft': areaInSqft,
      // NEW: pass location and bedrooms
      'location': _locationController.text,
      'bedrooms': _selectedBedrooms,
    });
  }

  Widget buildPropertyTypeRadio(PropertyType type, String label) {
    return RadioListTile<PropertyType>(
      title: Text(label, style: const TextStyle(fontSize: 16)),
      value: type,
      groupValue: selectedPropertyType,
      onChanged: (PropertyType? value) {
        togglePropertyType(type);
      },
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  // NEW: bedroom radio row
  Widget buildBedroomOptions() {
    // We want 1,2,3,4+ as possible values => store 5 to represent “4+”
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Bedrooms',
          style: TextStyle(fontSize: 18),
        ),
        Row(
          children: [
            // Radio for 1 bedroom
            Radio<int>(
              value: 1,
              groupValue: _selectedBedrooms,
              onChanged: (val) => setState(() => _selectedBedrooms = val),
            ),
            const Text('1'),

            Radio<int>(
              value: 2,
              groupValue: _selectedBedrooms,
              onChanged: (val) => setState(() => _selectedBedrooms = val),
            ),
            const Text('2'),

            Radio<int>(
              value: 3,
              groupValue: _selectedBedrooms,
              onChanged: (val) => setState(() => _selectedBedrooms = val),
            ),
            const Text('3'),

            Radio<int>(
              value: 5, // 5 means 4+
              groupValue: _selectedBedrooms,
              onChanged: (val) => setState(() => _selectedBedrooms = val),
            ),
            const Text('4+'),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight = screenHeight * 0.7;
    if (screenHeight < 600) {
      containerHeight = screenHeight * 0.9;
    }

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.lightGreen,
          onPrimary: Colors.white,
          secondary: Colors.greenAccent,
        ),
      ),
      child: Container(
        height: containerHeight,
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Properties',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Property Type
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Property Type',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              buildPropertyTypeRadio(PropertyType.Apartment, 'Apartment'),
              buildPropertyTypeRadio(PropertyType.Villa, 'Villa'),
              buildPropertyTypeRadio(PropertyType.IndependetHouse, 'IndependetHouse'),
              buildPropertyTypeRadio(PropertyType.CommercialSpace, 'CommercialSpace'),

              const SizedBox(height: 16),

              // NEW: location text field
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Location/Place',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: 'Enter city or location',
                ),
              ),

              const SizedBox(height: 16),

              // NEW: bedroom options
              buildBedroomOptions(),

              const SizedBox(height: 16),

              // Rent Price
              if (rentPrice.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rent Price ($rentPrice): '
                          '${formatPrice(selectedRentPriceRange.start)}'
                          ' - '
                          '${formatPrice(selectedRentPriceRange.end)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    RangeSlider(
                      values: selectedRentPriceRange,
                      min: minRentPrice,
                      max: maxRentPrice,
                      divisions: 10,
                      activeColor: Colors.green,
                      inactiveColor: Colors.grey[300],
                      labels: RangeLabels(
                        formatPrice(selectedRentPriceRange.start),
                        formatPrice(selectedRentPriceRange.end),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          selectedRentPriceRange = values;
                        });
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Area in Sqft
              if (areaInSqft.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Area ($areaInSqft): '
                          '${selectedAreaRange.start.toStringAsFixed(0)}'
                          ' - '
                          '${selectedAreaRange.end.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    RangeSlider(
                      values: selectedAreaRange,
                      min: minAreaInSqft,
                      max: maxAreaInSqft,
                      divisions: 10,
                      activeColor: Colors.green,
                      inactiveColor: Colors.grey[300],
                      labels: RangeLabels(
                        selectedAreaRange.start.toStringAsFixed(1),
                        selectedAreaRange.end.toStringAsFixed(1),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          selectedAreaRange = values;
                        });
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 5),

              // Bottom row: reset + apply
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: resetFilters,
                    child: const Text(
                      'Reset Filters',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : applyFilters,
                    child: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Apply Filters',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
