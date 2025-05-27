// lib/data/models/user.dart
import 'role.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? username; // Added username field
  final UserRole role;
  final String? clinicName;
  final String? phoneNumber;
  final String? profileImage;
  
  User({
    required this.id,
    required this.name,
    required this.email,
     this.username, // Added to constructor
    required this.role,
    this.clinicName,
    this.phoneNumber,
    this.profileImage,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username, // Added to JSON serialization
      'role': role.value, // Using the extension method
      'clinicName': clinicName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
    };
  }
 
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'],
      email: json['email'],
      username: json['username'], // Added to deserialization
      role: UserRoleExtension.fromString(json['role']),
      clinicName: json['clinicName'],
      phoneNumber: json['phoneNumber'],
      profileImage: json['profileImage'],
    );
  }
}
// lib/data/models/role.dart
enum UserRole {
  super_admin,
  doctor,
  patient,
  nurse,
  reception,
  admin,

}

// Extension to help with string conversion
extension UserRoleExtension on UserRole {
  String get value {
    return toString().split('.').last;
  }
  
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.patient, // Default role
    );
  }
}

