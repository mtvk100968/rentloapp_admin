// lib/models/user_model.dart

class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? phoneNumber;
  final List<String> postedPropertyIds;
  final List<String> favoritedPropertyIds;
  final List<String> inTalksPropertyIds;
  final List<String> rentedPropertyIds;

  AppUser({
    required this.uid,
    this.name,
    this.email,
    this.phoneNumber,
    List<String>? postedPropertyIds,
    List<String>? favoritedPropertyIds,
    List<String>? inTalksPropertyIds,
    List<String>? rentedPropertyIds,
  })  : postedPropertyIds = postedPropertyIds ?? [],
        favoritedPropertyIds = favoritedPropertyIds ?? [],
        inTalksPropertyIds = inTalksPropertyIds ?? [],
        rentedPropertyIds = rentedPropertyIds ?? [];

  // Convert AppUser object to a Map for Firestore
  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
    if (postedPropertyIds.isNotEmpty) {
      data['postedPropertyIds'] = postedPropertyIds;
    }
    if (favoritedPropertyIds.isNotEmpty) {
      data['favoritedPropertyIds'] = favoritedPropertyIds;
    }
    if (inTalksPropertyIds.isNotEmpty) {
      data['inTalksPropertyIds'] = inTalksPropertyIds;
    }
    if (rentedPropertyIds.isNotEmpty) {
      data['rentedPropertyIds'] = rentedPropertyIds;
    }
    return data;
  }

  // Create AppUser object from a Firestore DocumentSnapshot
  factory AppUser.fromDocument(Map<String, dynamic> doc) {
    return AppUser(
      uid: doc['uid'] ?? '',
      name: doc['name'],
      email: doc['email'],
      phoneNumber: doc['phoneNumber'],
      postedPropertyIds: List<String>.from(doc['postedPropertyIds'] ?? []),
      favoritedPropertyIds:
      List<String>.from(doc['favoritedPropertyIds'] ?? []),
      inTalksPropertyIds: List<String>.from(doc['inTalksPropertyIds'] ?? []),
      rentedPropertyIds: List<String>.from(doc['rentedPropertyIds'] ?? []),
    );
  }
}
