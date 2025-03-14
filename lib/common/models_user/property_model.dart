import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Property {
  final String propertyId;
  final String propertyType;
  final String mobileNo;
  final double latitude;
  final double longitude;
  final double areaInSqft;
  final double carpetArea;
  final double rentPrice;
  final int bedRooms;
  final int bathRooms;
  final int parkingSpots;
  final String houseNo;
  final String colonyName;
  final String city;
  final String taluqMandal;
  final String district;
  final String state;
  final String pincode;
  final String? iconPath;
  final List<String> images;
  final List<String> videos;
  final List<String> documents;
  final String userId;
  final String? address;
  final String status;
  final Map<String, dynamic>? additionalDetails;
  final DateTime createdAt;
  // final bool gas;
  // final bool ghmcWater;
  // final bool boreWater;

  Property({
    required this.propertyId,
    required this.propertyType,
    required this.latitude,
    required this.longitude,
    required this.areaInSqft,
    required this.rentPrice,
    required this.bedRooms,
    required this.bathRooms,
    required this.parkingSpots,
    required this.mobileNo,
    required this.city,
    required this.colonyName,
    required this.houseNo,
    required this.taluqMandal,
    required this.district,
    required this.state,
    required this.pincode,
    required this.iconPath,
    required this.images,
    required this.videos,
    required this.documents,
    required this.userId,
    required this.address,
    required this.status,
    this.additionalDetails,
    required this.carpetArea,
    required this.createdAt,
    // required this.gas,
    // required this.ghmcWater,
    // required this.boreWater,
  });

  Property copyWith({
    String? propertyId,
    String? mobileNo,
    String? propertyType,
    double? latitude,
    double? longitude,
    String? iconPath,
    String? userId,
    double? rentPrice,
    List<String>? imageUrls,
    List<String>? videoUrls,
    int? bedRooms,
    int? bathRooms,
    double? areaInSqft,
    int? parkingSpots,
    String? houseNo,
    String? colonyName,
    String? city,
    String? taluqMandal,
    String? district,
    String? state,
    String? pincode,
  }) {
    return Property(
      propertyId: propertyId ?? this.propertyId,
      mobileNo: mobileNo ?? this.mobileNo,
      propertyType: propertyType ?? this.propertyType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      iconPath: iconPath ?? this.iconPath,
      userId: userId ?? this.userId,
      rentPrice: rentPrice ?? this.rentPrice,
      areaInSqft: areaInSqft ?? this.areaInSqft,
      carpetArea: carpetArea ?? carpetArea,
      images: imageUrls ?? images,
      videos: videoUrls ?? videos,
      documents: videoUrls ?? documents,
      bedRooms: bedRooms ?? this.bedRooms,
      bathRooms: bathRooms ?? this.bathRooms,
      parkingSpots: parkingSpots ?? this.parkingSpots,
      houseNo: houseNo ?? this.houseNo,
      colonyName: colonyName ?? this.colonyName,
      city: city ?? this.city,
      taluqMandal: taluqMandal ?? this.taluqMandal,
      district: district ?? this.district,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      address: address ?? address,
      status: status,
      createdAt: createdAt, // ✅ No need for default value
      // gas: gas,                  // ✅ No need for default value
      // ghmcWater: ghmcWater, // ✅ No need for default value
      // boreWater: boreWater, // ✅ No need for default value
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'propertyId': propertyId,
      'mobileNo': mobileNo,
      'propertyType': propertyType,
      'latitude': latitude,
      'longitude': longitude,
      'iconPath': iconPath,
      'rentPrice': rentPrice,
      'userId': userId,
      'images': images,
      'videos': videos,
      'documents': documents,
      'bedRooms': bedRooms,
      'bathRooms': bathRooms,
      'areaInSqft': areaInSqft,
      'parkingSpots': parkingSpots,
      'houseNo': houseNo,
      'colonyName': colonyName,
      'city': city,
      'taluqMandal': taluqMandal,
      'district': district,
      'state': state,
      'pincode': pincode,
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> data) {
    return Property(
      propertyId: id,

      // Numeric fields:
      rentPrice: (data['rentPrice'] as num?)?.toDouble() ?? 0.0,
      bedRooms: (data['bedRooms'] as num?)?.toInt() ?? 0,
      bathRooms: (data['bathRooms'] as num?)?.toInt() ?? 0,
      areaInSqft: (data['areaInSqft'] as num?)?.toDouble() ?? 0.0,
      carpetArea: (data['carpetArea'] as num?)?.toDouble() ?? 0.0,
      parkingSpots: (data['parkingSpots'] as num?)?.toInt() ?? 0,

      // Coordinates (also parsed as double):
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,

      // Strings (fallback to empty string if missing):
      userId: data['userId'] as String? ?? '',
      mobileNo: data['mobileNo'] as String? ?? '',
      propertyType: data['propertyType'] as String? ?? '',
      houseNo: data['houseNo'] as String? ?? '',
      pincode: data['pincode'] as String? ?? '',
      taluqMandal: data['taluqMandal'] as String? ?? '',
      district: data['district'] as String? ?? '',
      colonyName: data['colonyName'] as String? ?? '',
      state: data['state'] as String? ?? '',
      city: data['city'] as String? ?? '',
      address: data['address'] as String? ?? '',
      iconPath: data['iconPath'] as String? ?? '',
      status: data['status'] as String? ?? '',

      // Lists (fallback to empty lists if missing):
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      documents: List<String>.from(data['documents'] ?? []),

      // Timestamp → DateTime
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'propertyType': propertyType,
      'latitude': latitude,
      'longitude': longitude,
      'areaInSqft': areaInSqft,
      'rentPrice': rentPrice,
      'bedRooms': bedRooms,
      'bathRooms': bathRooms,
      'parkingSpots': parkingSpots,
      'mobileNo': mobileNo,
      'city': city,
      'colonyName': colonyName,
      'houseNo': houseNo,
      'taluqMandal': taluqMandal,
      'district': district,
      'state': state,
      'pincode': pincode,
      'iconPath': iconPath,
      'images': images,
      'videos': videos,
      'documents': documents,
      'userId': userId,
      'address': address,
      'status': status,
      'additionalDetails': additionalDetails,
      'carpetArea': carpetArea,
    };
  }

  // Factory constructor to create a Property instance from a Firestore document
  factory Property.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Document data is null for ${doc.id}");
    }

    return Property(
      propertyId: doc.id,
      propertyType: data['propertyType'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      rentPrice: (data['rentPrice'] as num?)?.toDouble() ?? 0.0,
      areaInSqft: (data['areaInSqft'] as num?)?.toDouble() ?? 0.0,
      bedRooms: (data['bedRooms'] as num?)?.toInt() ?? 0,
      bathRooms: (data['bathRooms'] as num?)?.toInt() ?? 0,
      parkingSpots: (data['parkingSpots'] as num?)?.toInt() ?? 0,
      mobileNo: data['mobileNo'] ?? '',
      city: data['city'] ?? '',
      colonyName: data['colonyName'] ?? '',
      houseNo: data['houseNo'] ?? '',
      taluqMandal: data['taluqMandal'] ?? '',
      district: data['district'] ?? '',
      state: data['state'] ?? '',
      pincode: data['pincode'] ?? '',
      iconPath: data['iconPath'] ?? 'default_icon_path',
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      documents: List<String>.from(data['documents'] ?? []),
      userId: data['userId'] ?? '',
      address: data['address'] ?? '',
      status: data['status'] ?? '',
      additionalDetails: data['additionalDetails'] as Map<String, dynamic>? ?? {},
      carpetArea: (data['carpetArea'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // gas: data['gas'] as bool? ?? false,
      // ghmcWater: data['ghmcWater'] as bool? ?? false,
      // boreWater: data['boreWater'] as bool? ?? false,
    );
  }

  static Future<Property> fetchPropertyDetails(String propertyId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('properties')
        .doc(propertyId)
        .get();

    if (!doc.exists) {
      throw Exception('Property not found');
    }
    return Property.fromFirestore(doc);
  }

  factory Property.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;

    return Property(
      propertyId: snapshot.id,
      propertyType: data['propertyType'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      areaInSqft: (data['areaInSqft'] as num?)?.toDouble() ?? 0.0,
      rentPrice: (data['rentPrice'] as num?)?.toDouble() ?? 0,
      bedRooms: (data['bedRooms'] as num?)?.toInt() ?? 0,
      bathRooms: (data['bathRooms'] as num?)?.toInt() ?? 0,
      parkingSpots: (data['parkingSpots'] as num?)?.toInt() ?? 0,
      mobileNo: data['mobileNo']?.toString() ?? '',
      city: data['city'] ?? '',
      colonyName: data['colonyName'] ?? '',
      houseNo: data['houseNo'] ?? '',
      taluqMandal: data['taluqMandal'] ?? '',
      district: data['district'] ?? '',
      state: data['state'] ?? '',
      pincode: data['pincode']?.toString() ?? '',
      iconPath: data['iconPath'] ?? 'default_icon_path',
      images: List<String>.from(data['images'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
      documents: List<String>.from(data['documents'] ?? []),
      userId: data['userId'] ?? '',
      address: data['address'] ?? '',
      status: data['status'] ?? '',
      additionalDetails: data['additionalDetails'] as Map<String, dynamic>? ?? {},
      carpetArea: (data['carpetArea'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // gas: data['gas'] as bool? ?? false,
      // ghmcWater: data['ghmcWater'] as bool? ?? false,
      // boreWater: data['boreWater'] as bool? ?? false,
    );
  }


  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      propertyId: json['propertyId'],
      mobileNo: json['mobileNo'],
      propertyType: json['propertyType'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      iconPath: json['iconPath'] ?? '',
      rentPrice: (json['rentPrice'] as num?)?.toDouble() ?? 0,
      userId: json['userId'],
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      documents: List<String>.from(json['documents'] ?? []),
      bedRooms: (json['bedRooms'] as num?)?.toInt() ?? 0,
      bathRooms: (json['bathRooms'] as num?)?.toInt() ?? 0,
      areaInSqft: (json['areaInSqft'] as num?)?.toDouble() ?? 0.0,
      carpetArea: (json['carpetArea'] as num?)?.toDouble() ?? 0.0,
      parkingSpots: (json['parkingSpots'] as num?)?.toInt() ?? 0,
      houseNo: json['houseNo'] as String? ?? 'No address provided',
      colonyName: json['colonyName'] as String? ?? 'No address provided',
      city: json['city'] as String? ?? 'No address provided',
      taluqMandal: json['taluqMandal'] as String? ?? 'No address provided',
      district: json['district'] as String? ?? 'No address provided',
      state: json['state'] as String? ?? 'No address provided',
      pincode: json['pincode'] as String? ?? '',
      address: json['address'] as String? ?? '',
      status: json['status'] as String? ?? '',
      additionalDetails: json['additionalDetails'] as Map<String, dynamic>? ?? {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      // gas: json['gas'] as bool? ?? false,
      // ghmcWater: json['ghmcWater'] as bool? ?? false,
      // boreWater: json['boreWater'] as bool? ?? false,
    );
  }

  Future<Marker> toMarker() async {
    return Marker(
      markerId: MarkerId(propertyId),
      position: LatLng(latitude, longitude),
      icon: await BitmapDescriptor.asset(
          const ImageConfiguration(), iconPath!),
      infoWindow: InfoWindow(
        title: propertyType,
        snippet: 'Price: ₹${rentPrice.toDouble().toStringAsFixed(2)}',
      ),
    );
  }

  static Future<List<Marker>> createMarkersFromProperties(
      List<Property> properties) async {
    return await Future.wait(
        properties.map((property) => property.toMarker()).toList());
  }

  factory Property.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Document data is null for ${doc.id}");
    }

    return Property(
      propertyId: doc.id,
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      rentPrice: (data['rentPrice'] as num?)?.toDouble() ?? 0,
      propertyType: data['propertyType'] ?? '',
      areaInSqft: (data['areaInSqft'] as num?)?.toDouble() ?? 0.0,
      bedRooms: (data['bedRooms'] as num?)?.toInt() ?? 0,
      bathRooms: (data['bathRooms'] as num?)?.toInt() ?? 0,
      parkingSpots: (data['parkingSpots'] as num?)?.toInt() ?? 0,
      mobileNo: data['mobileNo']?.toString() ?? '',
      colonyName: data['colonyName'] ?? '',
      houseNo: data['houseNo'] ?? '',
      taluqMandal: data['taluqMandal'] ?? '',
      city: data['city'] ?? '',
      district: data['district'] ?? '',
      state: data['state'] ?? '',
      pincode: data['pincode']?.toString() ?? '',
      iconPath: data['iconPath'] ?? 'default_icon_path',
      images: List<String>.from(data['images'] ?? []),
      videos: data['videos'] != null ? List<String>.from(data['videos']) : [],
      documents: data['documents'] != null ? List<String>.from(data['documents']) : [],
      userId: data['userId'] ?? '',
      address: data['address'] ?? '',
      status: data['status'] ?? '',
      additionalDetails: data['additionalDetails'] as Map<String, dynamic>? ?? {},
      carpetArea: (data['carpetArea'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // gas: data['gas'] as bool? ?? false,
      // ghmcWater: data['ghmcWater'] as bool? ?? false,
      // boreWater: data['boreWater'] as bool? ?? false,
    );
  }

  LatLng get location => LatLng(latitude, longitude);
}
