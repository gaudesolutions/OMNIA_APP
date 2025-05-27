
// lib/data/models/user.dart
class User1 {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String userType;
  final int? clinicId;
  final String? clinicName;
  final bool isActive;
  final String? phoneNumber;
  final String? profileImage;

  User1({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userType,
    this.clinicId,
    this.clinicName,
    required this.isActive,
    this.phoneNumber,
    this.profileImage,
  });

  factory User1.fromJson(Map<String, dynamic> json) {
    return User1(
      id: json['id'],
      username: json['username'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      userType: json['user_type'],
      clinicId: json['clinic'],
      clinicName: json['clinic_name'],
      isActive: json['is_active'] ?? true,
      phoneNumber: json['phone_number'],
      profileImage: json['profile_image'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'user_type': userType,
      'is_active': isActive,
      'phone_number': phoneNumber,
    };

    if (id != 0) {
      data['id'] = id;
    }
    
    if (clinicId != null) {
      data['clinic'] = clinicId;
    }

    return data;
  }

  User1 copyWith({
    int? id,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? userType,
    int? clinicId,
    String? clinicName,
    bool? isActive,
    String? phoneNumber,
    String? profileImage,
  }) {
    return User1(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      userType: userType ?? this.userType,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      isActive: isActive ?? this.isActive,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}

// lib/data/models/user_stats.dart
class UserStatistics {
  final int superAdmin;
  final int admin;
  final int doctor;
  final int nurse;
  final int reception;

  UserStatistics({
    required this.superAdmin,
    required this.admin,
    required this.doctor,
    required this.nurse,
    required this.reception,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      superAdmin: json['super_admin'] ?? 0,
      admin: json['admin'] ?? 0,
      doctor: json['doctor'] ?? 0,
      nurse: json['nurse'] ?? 0,
      reception: json['reception'] ?? 0,
    );
  }
}

class ClinicUserCount {
  final String clinicName;
  final int userCount;

  ClinicUserCount({
    required this.clinicName,
    required this.userCount,
  });

  factory ClinicUserCount.fromJson(Map<String, dynamic> json) {
    return ClinicUserCount(
      clinicName: json['clinic__name'] ?? 'Unknown',
      userCount: json['user_count'] ?? 0,
    );
  }
}
