class Clinic {
  final int id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String phone;
  final String email;
  final String website;
  final bool active;
  final int staffCount;

  Clinic({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.phone,
    required this.email,
    required this.website,
    required this.active,
    required this.staffCount,
  });

  factory Clinic.fromJson(Map<String, dynamic> json) {
    return Clinic(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      active: json['active'],
      staffCount: json['staff_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id != 0 ? id : null, // Don't include ID for new clinics
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'phone': phone,
      'email': email,
      'website': website,
      'active': active,
    };
  }
}

class ClinicStatistics {
  final int totalClinics;
  final int activeClinics;
  final Map<String, int> clinicsByState;

  ClinicStatistics({
    required this.totalClinics,
    required this.activeClinics,
    required this.clinicsByState,
  });

  factory ClinicStatistics.fromJson(Map<String, dynamic> json) {
    return ClinicStatistics(
      totalClinics: json['total_clinics'],
      activeClinics: json['active_clinics'],
      clinicsByState: Map<String, int>.from(json['clinics_by_state']),
    );
  }
}