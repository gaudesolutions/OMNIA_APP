import 'package:medical_app/data/models/clinic.dart';

abstract class ClinicEvent {}

class FetchClinicsEvent extends ClinicEvent {}

class AddClinicEvent extends ClinicEvent {
  final Clinic clinic;
  
  AddClinicEvent({required this.clinic});
}

class UpdateClinicEvent extends ClinicEvent {
  final Clinic clinic;
  
  UpdateClinicEvent({required this.clinic});
}

class DeleteClinicEvent extends ClinicEvent {
  final int clinicId;
  
  DeleteClinicEvent({required this.clinicId});
}

class FetchClinicStatisticsEvent extends ClinicEvent {}