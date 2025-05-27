import 'package:flutter/foundation.dart';
import 'package:medical_app/data/models/clinic.dart';

enum ClinicStatus { initial, loading, success, failure }

class ClinicState {
  final List<Clinic> clinics;
  final ClinicStatus status;
  final String? errorMessage;
  final ClinicStatistics? statistics;

  const ClinicState({
    this.clinics = const [],
    this.status = ClinicStatus.initial,
    this.errorMessage,
    this.statistics,
  });
// In ClinicState class
ClinicState copyWith({
  ClinicStatus? status,
  List<Clinic>? clinics, 
  String? errorMessage,
  ClinicStatistics? statistics,
}) {
  return ClinicState(
    status: status ?? this.status,
    clinics: clinics ?? List.from(this.clinics), // Create a new list reference
    errorMessage: errorMessage,
    statistics: statistics ?? this.statistics,
  );
}
  
// In ClinicState class
@override
bool operator ==(Object other) {
  if (identical(this, other)) return true;
  return other is ClinicState &&
      other.status == status &&
      listEquals(other.clinics, clinics) && // Use Flutter's listEquals
      other.errorMessage == errorMessage;
}

@override
int get hashCode => Object.hash(status, Object.hashAll(clinics), errorMessage);
}