import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/data/models/clinic.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_event.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_state.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic/clinicservice.dart';
class ClinicBloc extends Bloc<ClinicEvent, ClinicState> {
  final ClinicService clinicService;

  ClinicBloc(this.clinicService) : super(const ClinicState()) {
    on<FetchClinicsEvent>(_onFetchClinics);
    on<AddClinicEvent>(_onAddClinic);
    on<UpdateClinicEvent>(_onUpdateClinic);
    on<DeleteClinicEvent>(_onDeleteClinic);
  }

  Future<void> _onFetchClinics(
    FetchClinicsEvent event,
    Emitter<ClinicState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ClinicStatus.loading));
      // Note the use of fetchClinics() to match your service
      final clinics = await clinicService.fetchClinics();
      emit(state.copyWith(
        status: ClinicStatus.success,
        clinics: clinics,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ClinicStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddClinic(
    AddClinicEvent event,
    Emitter<ClinicState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ClinicStatus.loading));
      // Note the use of createClinic() to match your service
      final newClinic = await clinicService.createClinic(event.clinic);
      final updatedClinics = List<Clinic>.from(state.clinics)..add(newClinic);
      emit(state.copyWith(
        status: ClinicStatus.success,
        clinics: updatedClinics,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ClinicStatus.failure,
        errorMessage: 'Failed to add clinic: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateClinic(
    UpdateClinicEvent event,
    Emitter<ClinicState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ClinicStatus.loading));
      final updatedClinic = await clinicService.updateClinic(event.clinic);
      final updatedClinics = state.clinics.map((clinic) {
        return clinic.id == updatedClinic.id ? updatedClinic : clinic;
      }).toList();
      emit(state.copyWith(
        status: ClinicStatus.success,
        clinics: updatedClinics,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ClinicStatus.failure,
        errorMessage: 'Failed to update clinic: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteClinic(
    DeleteClinicEvent event,
    Emitter<ClinicState> emit,
  ) async {
    try {
      emit(state.copyWith(status: ClinicStatus.loading));
      // Use your deleteClinic method
      await clinicService.deleteClinic(event.clinicId);
      
      // Update the list after successful deletion
      final updatedClinics = state.clinics
          .where((clinic) => clinic.id != event.clinicId)
          .toList();
      
      emit(state.copyWith(
        status: ClinicStatus.success,
        clinics: updatedClinics,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ClinicStatus.failure,
        errorMessage: 'Failed to delete clinic: ${e.toString()}',
      ));
    }
  }
}