import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String role; // 'manager' or 'agent'
  final String email; // Admin email or agent email

  User({
    required this.userId,
    required this.role,
    required this.email,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      userId: doc.id,
      role: data['role'] ?? 'agent', // Default to 'agent' if role is missing
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'role': role,
      'email': email,
    };
  }
}
