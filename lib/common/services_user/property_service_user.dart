import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models_user/property_model.dart';
import 'google_maps_search_service.dart';
import 'user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PropertyServiceUser {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final UserService _userService = UserService();
  static const String collectionPath = 'properties';

  // New: Instance of GoogleMapsSearchService for free-text location searches.
  final GoogleMapsSearchService _googleMapsSearchService =
  GoogleMapsSearchService();

  /// Adds a new property to Firestore along with uploading its images, videos, and documents.
  Future<String> addPropertyByUser(
      Property property,
      List<File> images, {
        List<File>? videos,
        List<File>? documents,
      }) async {
    try {
      if (property.district == null || property.taluqMandal == null) {
        throw ArgumentError("District and Mandal are required fields.");
      }
      String propertyId =
      await _generatePropertyId(property.district!, property.taluqMandal!);

      List<String> imageUrls =
      await _uploadMediaFiles(propertyId, images, 'property_images', 'img');

      List<String> videoUrls = [];
      if (videos != null && videos.isNotEmpty) {
        videoUrls = await _uploadMediaFiles(
            propertyId, videos, 'property_videos', 'vid');
      }

      List<String> documentUrls = [];
      if (documents != null && documents.isNotEmpty) {
        documentUrls = await _uploadMediaFiles(
            propertyId, documents, 'property_documents', 'doc');
      }

      DateTime nowUtc = DateTime.now().toUtc();
      DateTime nowIst = nowUtc.add(Duration(hours: 5, minutes: 30));
      Timestamp createdAt = Timestamp.fromDate(nowIst);

      Property propertyWithMedia = Property(
        propertyId: propertyId,
        userId: property.userId,
        bedRooms: property.bedRooms,
        bathRooms: property.bathRooms,
        mobileNo: property.mobileNo,
        propertyType: property.propertyType,
        areaInSqft: property.areaInSqft,
        rentPrice: property.rentPrice,
        houseNo: property.houseNo,
        latitude: property.latitude,
        longitude: property.longitude,
        pincode: property.pincode,
        taluqMandal: property.taluqMandal,
        district: property.district,
        colonyName: property.colonyName,
        state: property.state,
        images: imageUrls,
        videos: videoUrls,
        documents: documentUrls,
        parkingSpots: property.parkingSpots,
        city: property.city,
        address: property.address,
        // boreWater: property.boreWater, // ✅ Add this
        // gas: property.gas, // ✅ Add this
        // ghmcWater: property.ghmcWater, // ✅ Add this
        carpetArea: property.carpetArea, // ✅ Add this
        iconPath: property.iconPath, // ✅ Add this
        status: property.status, // ✅ Add this
        createdAt: createdAt.toDate(), // Convert Timestamp to DateTime
      );

      await _firestore
          .collection(collectionPath)
          .doc(propertyId)
          .set(propertyWithMedia.toMap());
      await _userService.addPropertyToUser(property.userId, propertyId);
      return propertyId;
    } catch (e, stacktrace) {
      print('Error adding property: $e');
      print(stacktrace);
      Error.throwWithStackTrace(
          Exception('Failed to add property'), stacktrace);
    }
  }

  /// Fetches a property from Firestore by its ID.
  Future<Property?> getPropertyById(String propertyId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
      await _firestore.collection(collectionPath).doc(propertyId).get();
      if (doc.exists) {
        return Property.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e, stacktrace) {
      print('Error fetching property: $e');
      print(stacktrace);
      Error.throwWithStackTrace(Exception('Failed to fetch property'), stacktrace);
    }
  }

  /// Fetch properties by a list of IDs.
  Future<List<Property>> getPropertiesByIds(List<String> propertyIds) async {
    if (propertyIds.isEmpty) return [];
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(collectionPath)
          .where(FieldPath.documentId, whereIn: propertyIds)
          .get();
      return snapshot.docs.map((doc) => Property.fromDocument(doc)).toList();
    } catch (e, stacktrace) {
      print('Error fetching properties by IDs: $e');
      print(stacktrace);
      Error.throwWithStackTrace(
          Exception('Failed to fetch properties by IDs'), stacktrace);
    }
  }

  /// Updates an existing property in Firestore.
  Future<void> updateProperty(
      Property property, {
        List<File>? newImages,
        List<File>? newVideos,
        List<File>? newDocuments,
      }) async {
    try {
      List<String> updatedImageUrls = List.from(property.images);
      List<String> updatedVideoUrls = List.from(property.videos);
      List<String> updatedDocumentUrls = List.from(property.documents);

      if (property.propertyId.isEmpty) {
        throw ArgumentError("Property ID is required to update a property.");
      }

      if (newImages != null && newImages.isNotEmpty) {
        List<String> newImageUrls = await _uploadMediaFiles(
            property.propertyId, newImages, 'property_images', 'img');
        updatedImageUrls.addAll(newImageUrls);
      }
      if (newVideos != null && newVideos.isNotEmpty) {
        List<String> newVideoUrls = await _uploadMediaFiles(
            property.propertyId, newVideos, 'property_videos', 'vid');
        updatedVideoUrls.addAll(newVideoUrls);
      }
      if (newDocuments != null && newDocuments.isNotEmpty) {
        List<String> newDocumentUrls = await _uploadMediaFiles(
            property.propertyId, newDocuments, 'property_documents', 'doc');
        updatedDocumentUrls.addAll(newDocumentUrls);
      }

      Map<String, dynamic> updatedData = property.toMap();
      updatedData['images'] = updatedImageUrls;
      updatedData['videos'] = updatedVideoUrls;
      updatedData['documents'] = updatedDocumentUrls;

      await _firestore
          .collection(collectionPath)
          .doc(property.propertyId)
          .update(updatedData);
    } catch (e, stacktrace) {
      print('Error updating property: $e');
      print(stacktrace);
      Error.throwWithStackTrace(
          Exception('Failed to update property'), stacktrace);
    }
  }

  /// Deletes a property from Firestore and removes its media files from Firebase Storage.
  Future<void> deleteProperty(
      String propertyId,
      List<String> imageUrls, {
        List<String>? videoUrls,
        List<String>? documentUrls,
        String? userId,
      }) async {
    try {
      if (imageUrls.isNotEmpty) {
        await _deleteFiles(imageUrls);
      }
      if (videoUrls != null && videoUrls.isNotEmpty) {
        await _deleteFiles(videoUrls);
      }
      if (documentUrls != null && documentUrls.isNotEmpty) {
        await _deleteFiles(documentUrls);
      }
      await _firestore.collection(collectionPath).doc(propertyId).delete();
      if (userId != null && userId.isNotEmpty) {
        await _firestore.collection('users').doc(userId).update({
          'postedPropertyIds': FieldValue.arrayRemove([propertyId])
        });
      }
    } catch (e, stacktrace) {
      print('Error deleting property: $e');
      print(stacktrace);
      Error.throwWithStackTrace(
          Exception('Failed to delete property'), stacktrace);
    }
  }

  /// New: Searches properties using a free-text query.
  /// This function leverages the Google Maps API to convert a query (which can be a street,
  /// colony, landmark, apartment name, etc.) into a geographic bounding box and then returns
  /// properties within that area.
  Future<List<Property>> searchProperties(String query) async {
    // Attempt to get location details (including viewport if available) from Google Maps.
    final locationResult = await _googleMapsSearchService.searchPlace(query);
    List<Property> results = [];

    if (locationResult != null) {
      double minLat, maxLat, minLng, maxLng;

      if (locationResult.containsKey('viewport')) {
        // Use viewport bounds from geocode result for a precise area search
        final viewport = locationResult['viewport'] as Map<String, dynamic>;
        final northeast = viewport['northeast'] as Map<String, dynamic>;
        final southwest = viewport['southwest'] as Map<String, dynamic>;
        minLat = southwest['lat'];
        maxLat = northeast['lat'];
        minLng = southwest['lng'];
        maxLng = northeast['lng'];
      } else {
        // Fallback: use the center point with a fixed radius (10 km)
        final centerLat = locationResult['lat'];
        final centerLng = locationResult['lng'];
        const radiusInKm = 10.0;
        final latDelta = radiusInKm / 111;
        minLat = centerLat - latDelta;
        maxLat = centerLat + latDelta;
        final lngDelta =
            radiusInKm / (111 * math.cos(centerLat * math.pi / 180));
        minLng = centerLng - lngDelta;
        maxLng = centerLng + lngDelta;
      }

      // Query Firestore for properties within the computed latitude range.
      final snapshot = await _firestore
          .collection(collectionPath)
          .where('latitude', isGreaterThanOrEqualTo: minLat)
          .where('latitude', isLessThanOrEqualTo: maxLat)
          .get();

      // Further filter for longitude bounds.
      results = snapshot.docs
          .map((doc) => Property.fromDocument(doc))
          .where((property) =>
      property.longitude >= minLng && property.longitude <= maxLng)
          .toList();

      // Optionally, refine results by checking if the query text appears in key address fields.
      final lowerQuery = query.toLowerCase();
      results = results.where((property) {
        final combinedAddress = [
          property.address,
          property.city,
          property.district,
          property.taluqMandal,
          property.colonyName
        ].where((element) => element != null).join(' ').toLowerCase();
        return combinedAddress.contains(lowerQuery);
      }).toList();

      return results;
    } else {
      // Fallback: if Google Maps doesn't return a location, perform a basic text search.
      final snapshot = await _firestore.collection(collectionPath).get();
      final lowerQuery = query.toLowerCase();
      results = snapshot.docs
          .map((doc) => Property.fromDocument(doc))
          .where((property) {
        final combinedAddress = [
          property.address,
          property.city,
          property.district,
          property.taluqMandal,
          property.colonyName
        ].where((element) => element != null).join(' ').toLowerCase();
        return combinedAddress.contains(lowerQuery);
      }).toList();
      return results;
    }
  }

  /// Fetches properties based on various filters.
  /// Supports both administrative area searches and landmark searches.
  /// If a [place] is provided, its geometry is used to compute a bounding box.
  Future<List<Property>> getPropertiesWithFilters({
    List<String>? propertyTypes,
    double? minPricePerUnit,
    double? maxPricePerUnit,
    double? minLandArea,
    double? maxLandArea,
    // Geolocation filtering:
    Map<String, dynamic>? place,
    double? latitude,
    double? longitude,
    double? searchRadiusKm,
    // Explicit bounding box parameters:
    double? minLat,
    double? maxLat,
    double? minLon,
    double? maxLon,
    // Administrative filters:
    String? city,
    String? district,
    String? pincode,
    String? searchQuery,
  }) async {
    print('getPropertiesWithFilters called with:');
    print('propertyTypes: $propertyTypes');
    print('minPricePerUnit: $minPricePerUnit');
    print('maxPricePerUnit: $maxPricePerUnit');
    print('minLandArea: $minLandArea');
    print('maxLandArea: $maxLandArea');
    print('latitude: $latitude');
    print('longitude: $longitude');
    print('searchRadiusKm: $searchRadiusKm');
    print('minLat: $minLat');
    print('maxLat: $maxLat');
    print('minLon: $minLon');
    print('maxLon: $maxLon');
    print('city: $city');
    print('district: $district');
    print('pincode: $pincode');
    print('searchQuery: $searchQuery');
    print('place: $place');

    // Use local variables to hold computed bounding box values.
    double? computedMinLat = minLat;
    double? computedMaxLat = maxLat;
    double? computedMinLon = minLon;
    double? computedMaxLon = maxLon;

    if (place != null && place['geometry'] != null) {
      double defaultSearchRadiusKm = searchRadiusKm ?? 10;
      double radiusInDegrees = defaultSearchRadiusKm / 111;
      if (place['geometry'].containsKey('viewport')) {
        var viewport = place['geometry']['viewport'];
        double swLat = viewport['southwest']['lat'];
        double swLng = viewport['southwest']['lng'];
        double neLat = viewport['northeast']['lat'];
        double neLng = viewport['northeast']['lng'];
        double viewportHeight = neLat - swLat;
        double viewportWidth = neLng - swLng;
        if (viewportHeight < 0.005 || viewportWidth < 0.005) {
          double lat = place['geometry']['location']['lat'];
          double lon = place['geometry']['location']['lng'];
          computedMinLat = lat - radiusInDegrees;
          computedMaxLat = lat + radiusInDegrees;
          computedMinLon = lon - radiusInDegrees;
          computedMaxLon = lon + radiusInDegrees;
        } else {
          computedMinLat = swLat - radiusInDegrees;
          computedMaxLat = neLat + radiusInDegrees;
          computedMinLon = swLng - radiusInDegrees;
          computedMaxLon = neLng + radiusInDegrees;
        }
      } else {
        double lat = place['geometry']['location']['lat'];
        double lon = place['geometry']['location']['lng'];
        computedMinLat = lat - radiusInDegrees;
        computedMaxLat = lat + radiusInDegrees;
        computedMinLon = lon - radiusInDegrees;
        computedMaxLon = lon + radiusInDegrees;
      }
    }

    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

    if (propertyTypes != null && propertyTypes.isNotEmpty) {
      query = query.where('propertyType', whereIn: propertyTypes);
    }
    if (city != null && city.isNotEmpty) {
      query = query.where('city', isEqualTo: city);
    }
    if (district != null && district.isNotEmpty) {
      query = query.where('district', isEqualTo: district);
    }
    if (pincode != null && pincode.isNotEmpty) {
      query = query.where('pincode', isEqualTo: pincode);
    }
    if (minPricePerUnit != null || maxPricePerUnit != null) {
      if (minPricePerUnit != null && maxPricePerUnit != null) {
        query = query.where('pricePerUnit',
            isGreaterThanOrEqualTo: minPricePerUnit,
            isLessThanOrEqualTo: maxPricePerUnit);
      } else if (minPricePerUnit != null) {
        query = query.where('pricePerUnit',
            isGreaterThanOrEqualTo: minPricePerUnit);
      } else if (maxPricePerUnit != null) {
        query =
            query.where('pricePerUnit', isLessThanOrEqualTo: maxPricePerUnit);
      }
    }

    QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    print(
        'Number of properties fetched from Firestore: ${snapshot.docs.length}');
    List<Property> properties = snapshot.docs
        .map((doc) => Property.fromMap(doc.id, doc.data()))
        .toList();

    if (minLandArea != null || maxLandArea != null) {
      properties = properties.where((property) {
        bool matches = true;
        if (minLandArea != null) {
          matches = matches && property.areaInSqft >= minLandArea;
        }
        if (maxLandArea != null) {
          matches = matches && property.areaInSqft <= maxLandArea;
        }
        return matches;
      }).toList();
      print('Properties after land area filter: ${properties.length}');
    }

    if (computedMinLat != null &&
        computedMaxLat != null &&
        computedMinLon != null &&
        computedMaxLon != null) {
      properties = properties.where((property) {
        return property.latitude >= computedMinLat! &&
            property.latitude <= computedMaxLat! &&
            property.longitude >= computedMinLon! &&
            property.longitude <= computedMaxLon!;
      }).toList();
      print('Properties after bounding box filter: ${properties.length}');
    } else if (latitude != null &&
        longitude != null &&
        searchRadiusKm != null) {
      double radiusInDegrees = searchRadiusKm / 111;
      double _minLat = latitude - radiusInDegrees;
      double _maxLat = latitude + radiusInDegrees;
      double _minLon = longitude - radiusInDegrees;
      double _maxLon = longitude + radiusInDegrees;
      properties = properties.where((property) {
        return property.latitude >= _minLat &&
            property.latitude <= _maxLat &&
            property.longitude >= _minLon &&
            property.longitude <= _maxLon;
      }).toList();
      print('Properties after radius filter: ${properties.length}');
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      properties = properties.where((property) {
        return property.propertyType.toLowerCase().contains(queryLower) ||
            property.address!.toLowerCase().contains(queryLower) ||
            property.city!.toLowerCase().contains(queryLower) ||
            property.district!.toLowerCase().contains(queryLower);
      }).toList();
      print('Properties after searchQuery filter: ${properties.length}');
    }

    return properties;
  }

  Future<List<Property>> getAllProperties() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('properties').get();

    return snapshot.docs
        .map((doc) => Property.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();
  }

  Future<void> addProposedPrice(
      String propertyId, double price, String remark) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception("User must be logged in to propose a price.");
      }
      final proposal = {
        'userId': userId,
        'price': price,
        'remark': remark,
        'timestamp': Timestamp.now(),
      };
      await _firestore.collection(collectionPath).doc(propertyId).update({
        'proposedPrices': FieldValue.arrayUnion([proposal]),
      });
    } catch (e, stacktrace) {
      print('Error adding proposed price: $e');
      print(stacktrace);
      Error.throwWithStackTrace(
          Exception('Failed to add proposed price'), stacktrace);
    }
  }

  Future<List<Map<String, dynamic>>> getProposedPrices(
      String propertyId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc =
      await _firestore.collection(collectionPath).doc(propertyId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('proposedPrices')) {
          return List<Map<String, dynamic>>.from(data['proposedPrices']);
        }
      }
      return [];
    } catch (e, stacktrace) {
      print('Error fetching proposed prices: $e');
      print(stacktrace);
      Error.throwWithStackTrace(
          Exception('Failed to fetch proposed prices'), stacktrace);
    }
  }

  Future<List<String>> _uploadMediaFiles(String propertyId, List<File> files,
      String folder, String mediaType) async {
    List<String> downloadUrls = [];
    int index = 1;
    for (File file in files) {
      try {
        String fileName =
            '${propertyId}_$mediaType$index${_getFileExtension(file.path)}';
        final String userId =
            FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
        Reference ref = _storage.ref().child('$folder/$userId').child(fileName);
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
        index++;
      } catch (e, stacktrace) {
        print('Error uploading $mediaType file: $e');
        print(stacktrace);
      }
    }
    return downloadUrls;
  }

  Future<void> _deleteFiles(List<String> fileUrls) async {
    for (String url in fileUrls) {
      try {
        Reference ref = _storage.refFromURL(url);
        await ref.delete();
      } catch (e, stacktrace) {
        print('Error deleting file $url: $e');
        print(stacktrace);
      }
    }
  }

  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final rand = DateTime.now().millisecondsSinceEpoch;
    return List.generate(
        length, (index) => chars[(rand + index) % chars.length]).join();
  }

  String _getFileExtension(String path) {
    return path.substring(path.lastIndexOf('.'));
  }

  Future<String> _generatePropertyId(String district, String mandal) async {
    String districtCode =
    district.length >= 2 ? district.substring(0, 2).toUpperCase() : 'XX';
    String mandalCode =
    mandal.length >= 2 ? mandal.substring(0, 2).toUpperCase() : 'YY';
    String prefix = '$districtCode$mandalCode';
    return await _firestore.runTransaction<String>((transaction) async {
      DocumentReference counterRef = _firestore
          .collection('property_counters')
          .doc('$districtCode$mandalCode');
      DocumentSnapshot counterSnapshot = await transaction.get(counterRef);
      int currentCount = 0;
      if (counterSnapshot.exists) {
        currentCount = counterSnapshot.get('count') ?? 0;
      }
      int newCount = currentCount + 1;
      transaction.set(counterRef, {'count': newCount}, SetOptions(merge: true));
      String serialNumber = newCount.toString().padLeft(4, '0');
      String propertyId = '$prefix$serialNumber';
      return propertyId;
    });
  }
}
