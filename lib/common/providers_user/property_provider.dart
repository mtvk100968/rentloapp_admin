import 'package:flutter/material.dart';
import 'dart:io';
import '../../common/models_user/property_model.dart';
import '../../user/data/districts_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyProvider with ChangeNotifier {
  Timestamp getCurrentTimestampInIST() {
    DateTime nowUtc = DateTime.now().toUtc();
    DateTime nowIst = nowUtc.add(const Duration(hours: 5, minutes: 30));
    return Timestamp.fromDate(nowIst);
  }

  String _phoneNumber = '';
  String _email = '';
  String _name = '';
  String _propertyOwnerName = '';
  String _propertyType = 'Apartment';
  String _userType = 'Owner';
  double _rentPerMonth = 0.0;
  double _areaInSqft = 0.0;
  double _carpetArea = 0.0;
  double _advanceRent = 0.0;
  int _advanceRentMonths = 0;
  String? _bedRooms;
  String? _bathRooms;
  String? _parkingSpots;
  String? _district;
  String? _mandal;
  String? _village;
  String _pincode = '';
  String _state = '';
  String _city = '';
  String _colonyName = '';
  String _houseNo = '';
  String _propertyName = '';
  String _taluqMandal = '';
  String? _address;
  double _latitude = 17.385044;
  double _longitude = 78.486671;
  String _roadAccess = '';
  String _roadType = '';
  double _roadWidth = 0.0;
  String _landFacing = '';
  String? _ventureName;
  final List<File> _imageFiles = [];
  final List<File> _videoFiles = [];
  final List<File> _documentFiles = [];
  bool _isGeocoding = false;
  bool get isGeocoding => _isGeocoding;
  final String _apiKey = "YOUR_API_KEY";
  List<Map<String, dynamic>> _proposedPrices = [];
  List<Map<String, dynamic>> get proposedPrices => _proposedPrices;

  void setProposedPrices(List<Map<String, dynamic>> prices) {
    _proposedPrices = prices;
    notifyListeners();
  }

  Future<void> submitProposedPrice(
      String propertyId, double price, String remark) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User must be logged in to submit a price proposal.");
      }
      final proposal = {
        'userId': user.uid,
        'price': price,
        'remark': remark,
        'timestamp': getCurrentTimestampInIST(),
      };
      await FirebaseFirestore.instance
          .collection('properties')
          .doc(propertyId)
          .update({
        'proposedPrices': FieldValue.arrayUnion([proposal]),
      });
      _proposedPrices.add(proposal);
      notifyListeners();
    } catch (e) {
      developer.log("Error submitting proposed price: $e");
      throw Exception("Failed to submit proposed price.");
    }
  }

  Future<void> fetchProposedPrices(String propertyId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
          .instance
          .collection('properties')
          .doc(propertyId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('proposedPrices')) {
          _proposedPrices =
          List<Map<String, dynamic>>.from(data['proposedPrices'] ?? []);
          notifyListeners();
        }
      }
    } catch (e) {
      developer.log("Error fetching proposed prices: $e");
      throw Exception("Failed to fetch proposed prices.");
    }
  }

  String get email => _email;
  double get rentPerMonth => _rentPerMonth;
  int get advanceRentMonths => _advanceRentMonths;
  double get advanceRent => _advanceRent;


  String get phoneNumber => _phoneNumber;
  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  String get name => _name;
  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  String get colonyName => _colonyName;
  void setColonyName(String value) {
    _colonyName = value;
    notifyListeners();
  }

  String get houseNo => _houseNo;
  void setHouseNo(String value) {
    _houseNo = value;
    notifyListeners();
  }

  String get taluqMandal => _taluqMandal;
  void setTaluqMandal(String value) {
    _taluqMandal = value;
    notifyListeners();
  }

  String get propertyOwnerName => _propertyOwnerName;
  void setPropertyOwnerName(String value) {
    _propertyOwnerName = value;
    notifyListeners();
  }

  String get propertyType => _propertyType;
  void setPropertyType(String value) {
    _propertyType = value;
    notifyListeners();
  }

  String get userType => _userType;
  void setUserType(String value) {
    if (value != _userType) {
      _userType = value;
      notifyListeners();
    }
  }

  double get areaInSqft => _areaInSqft;
  void setAreaInSqft(double value) {
    _areaInSqft = value;
    notifyListeners();
  }

  double get carpetArea => _carpetArea;
  void setCarpetArea(double value) {
    _carpetArea = value;
    notifyListeners();
  }

  // 1. BHK
  String? get bedRooms => _bedRooms;
  void setBedRooms(String? value) {
    _bedRooms = value;
    notifyListeners();
  }

  // 2. BATH
  String? get bathRooms => _bathRooms;
  void setBathRooms(String? value) {
    _bathRooms = value;
    notifyListeners();
  }

  // 3. PKS
  String? get parkingSpots => _parkingSpots;
  void setParkingSpots(String? value) {
    _parkingSpots = value;
    notifyListeners();
  }

// 2. FurnishType
  String? _furnishType;
  String? get furnishType => _furnishType;
  void setFurnishType(String? value) {
    _furnishType = value;
    notifyListeners();
  }

// 3. Share With Agents
  bool _shareWithAgents = false;
  bool get shareWithAgents => _shareWithAgents;
  void setShareWithAgents(bool value) {
    _shareWithAgents = value;
    notifyListeners();
  }


  // ✅ Add Setters
  void setRentPerMonth(double value) {
    if (_rentPerMonth != value) {
      _rentPerMonth = value;
      _calculateAdvanceRent();
      notifyListeners();
    }
  }

  void setAdvanceRentMonths(int value) {
    if (_advanceRentMonths != value) {
      _advanceRentMonths = value;
      _calculateAdvanceRent();
      notifyListeners();
    }
  }

  void setAdvanceRent(double value) {
    if (_advanceRent != value) {
      _advanceRent = value;
      notifyListeners();
    }
  }

  // ✅ Auto-calculate Advance Rent
  void _calculateAdvanceRent() {
    _advanceRent = _rentPerMonth * _advanceRentMonths;
  }

  // ✅ Getter for propertyName
  String get propertyName => _propertyName;

  // ✅ Setter for propertyName
  void setPropertyName(String value) {
    if (_propertyName != value) {
      _propertyName = value;
      notifyListeners();
    }
  }

  int parseBedrooms(String? bedroomsString) {
    // e.g. "2 BHK" => 2
    // If user never chose, return 0
    if (bedroomsString == null || bedroomsString.isEmpty) return 0;

    // If your strings are like "1 BHK", "2 BHK", "3 BHK"...
    // split on space:
    final parts = bedroomsString.split(' '); // ["2", "BHK"]
    return int.tryParse(parts.first) ?? 0;
  }

  int parseBath(String? bathString) {
    // e.g. "2 Bath" => 2, or "4+ Bath" => 4
    if (bathString == null || bathString.isEmpty) return 0;

    // If your strings are "1 Bath", "2 Bath", "3 Bath", "4+ Bath"
    // you can handle "4+" specifically:
    if (bathString.startsWith('4+')) {
      return 4; // or 5, depending on how you want to store
    }

    final parts = bathString.split(' '); // ["2", "Bath"]
    return int.tryParse(parts.first) ?? 0;
  }

  int parseParking(String? parkingString) {
    // e.g. "2 PKS" => 2
    if (parkingString == null || parkingString.isEmpty) return 0;

    final parts = parkingString.split(' '); // ["2", "PKS"]
    return int.tryParse(parts.first) ?? 0;
  }

  String? get district => _district;
  void setDistrict(String value) {
    if (value == _district) {
      developer.log('District unchanged: $value');
      return;
    }
    developer.log('Setting new district: $value');
    _district = value;
    _mandal = null;
    notifyListeners();
  }

  String? get mandal => _mandal;
  void setMandal(String value) {
    if (value == _mandal) {
      developer.log('Mandal unchanged: $value');
      return;
    }
    developer.log('Setting new mandal: $value');
    _mandal = value;
    notifyListeners();
  }

  String? get village => _village;
  void setVillage(String value) {
    if (value != _village) {
      _village = value;
      notifyListeners();
    }
  }

  String get city => _city;
  void setCity(String value) {
    _city = value;
    notifyListeners();
  }

  String get pincode => _pincode;
  Future<void> setPincode(String value) async {
    if (value == _pincode) {
      developer.log('Pincode unchanged: $value');
      return;
    }
    developer.log('Setting new pincode: $value');
    _pincode = value;
    notifyListeners();
    if (_pincode.length == 6) {
      try {
        await geocodePincode(_pincode);
      } catch (e) {
        developer.log('Geocoding failed: $e');
      }
    }
  }

  String get state => _state;

  void setStateField(String value) {  // ✅ Renamed to avoid conflict
    if (_state != value) {
      _state = value;
      notifyListeners();
    }
  }

  String? get address => _address;
  void setAddress(String value) {
    _address = value;
    notifyListeners();
  }

  double get latitude => _latitude;
  void setLatitude(double value) {
    _latitude = value;
    notifyListeners();
  }

  double get longitude => _longitude;
  void setLongitude(double value) {
    _longitude = value;
    notifyListeners();
  }

  String get roadAccess => _roadAccess;
  void setRoadAccess(String value) {
    _roadAccess = value;
    notifyListeners();
  }

  String get roadType => _roadType;
  void setRoadType(String value) {
    _roadType = value;
    notifyListeners();
  }

  double get roadWidth => _roadWidth;
  void setRoadWidth(double value) {
    if (value < 0) throw ArgumentError('Road width cannot be negative');
    _roadWidth = value;
    notifyListeners();
  }

  String get landFacing => _landFacing;
  void setLandFacing(String value) {
    _landFacing = value;
    notifyListeners();
  }

  List<File> get imageFiles => _imageFiles;
  void addImageFile(File file) {
    if (!_imageFiles.contains(file)) {
      _imageFiles.add(file);
      notifyListeners();
    }
  }

  void removeImageFile(File file) {
    _imageFiles.remove(file);
    notifyListeners();
  }

  List<File> get videoFiles => _videoFiles;
  void addVideoFile(File file) {
    if (!_videoFiles.contains(file)) {
      _videoFiles.add(file);
      notifyListeners();
    }
  }

  void removeVideoFile(File file) {
    _videoFiles.remove(file);
    notifyListeners();
  }

  List<File> get documentFiles => _documentFiles;
  void addDocumentFile(File file) {
    if (!_documentFiles.contains(file)) {
      _documentFiles.add(file);
      notifyListeners();
    }
  }

  void removeDocumentFile(File file) {
    _documentFiles.remove(file);
    notifyListeners();
  }

  List<String> get districtList => districtData.keys.toList();

  List<String> get mandalList {
    if (_district != null && districtData.containsKey(_district!)) {
      return districtData[_district!]!.toSet().toList();
    }
    return [];
  }

  Future<void> geocodePincode(String pincode) async {
    _isGeocoding = true;
    notifyListeners();

    try {
      final Uri uri = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$pincode&components=country:IN&key=$_apiKey'
      );
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          String city = '';
          String district = '';
          String state = '';
          String village = '';

          List<dynamic> results = data['results'];
          if (results.isNotEmpty) {
            List<dynamic> addressComponents = results[0]['address_components'];
            print('Full address components: $addressComponents'); // Debug log

            for (var component in addressComponents) {
              print('Component: ${component['long_name']} with types: ${component['types']}');
              List<dynamic> types = component['types'];
              if (types.contains('locality')) {
                city = component['long_name'];
              } else if (types.contains('administrative_area_level_2') ||
                  types.contains('administrative_area_level_3')) {
                district = component['long_name'];
              } else if (types.contains('administrative_area_level_1')) {
                state = component['long_name'];
              } else if (types.contains('sublocality_level_1') ||
                  types.contains('neighborhood')) {
                village = component['long_name'];
              }
            }

            // Update provider values
            setCity(city);
            setDistrict(district);
            setStateField(state);
            if (village.isNotEmpty) {
              setVillage(village);
            }
            if (results[0]['geometry'] != null &&
                results[0]['geometry']['location'] != null) {
              double lat = results[0]['geometry']['location']['lat'];
              double lng = results[0]['geometry']['location']['lng'];
              setLatitude(lat);
              setLongitude(lng);
            }
          } else {
            throw Exception('No results found for the provided pincode.');
          }
        } else {
          throw Exception('Geocoding API error: ${data['status']}');
        }
      } else {
        throw Exception('Failed to fetch location details.');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isGeocoding = false;
      notifyListeners();
    }
  }


  Property toProperty() {
    return Property(
      propertyId: '', // Assign appropriate propertyId
      propertyType: propertyType,
      latitude: latitude,
      longitude: longitude,
      rentPrice: rentPerMonth,         // Use your provider’s rent
      areaInSqft: areaInSqft,
      carpetArea: carpetArea, // Assign actual value
      bedRooms: parseBedrooms(_bedRooms), // Assign actual value
      bathRooms: parseBath(_bathRooms),
      parkingSpots: parseParking(_parkingSpots),
      mobileNo: phoneNumber,
      city: city,
      colonyName: colonyName, // Fixing undefined field
      houseNo: houseNo, // Fixing undefined field
      taluqMandal: taluqMandal, // Fixing undefined field
      district: district ?? '',
      state: state,
      pincode: pincode,
      iconPath: null,
      images: [],
      videos: [],
      documents: [],
      userId: FirebaseAuth.instance.currentUser?.uid ?? 'unknown',
      address: address,
      status: 'active', // Default status
      additionalDetails: {}, // Empty map as default
      createdAt: DateTime.now(), // ✅ Fix: Add required field
      // gas: false, // ✅ Fix: Default value
      // ghmcWater: false, // ✅ Fix: Default value
      // boreWater: false, // ✅ Fix: Default value
    );
  }

  void resetForm() {
    _phoneNumber = '';
    _name = '';
    _propertyOwnerName = '';
    _propertyType = 'Plot';
    _userType = 'Owner';
    _ventureName = null;
    _district = null;
    _mandal = null;
    _village = null;
    _city = '';
    _pincode = '';
    _state = '';
    _latitude = 17.385044;
    _longitude = 78.486671;
    _roadAccess = '';
    _roadType = '';
    _roadWidth = 0.0;
    _landFacing = '';
    _imageFiles.clear();
    _videoFiles.clear();
    _documentFiles.clear();
    _address = '';
    _proposedPrices.clear();
    notifyListeners();
  }
}
