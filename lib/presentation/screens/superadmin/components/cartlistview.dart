
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_event.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_state.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic/clinicformpage.dart';
import 'package:medical_app/presentation/screens/superadmin/components/cardtable.dart';

class ClinicListView extends StatelessWidget {
  const ClinicListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClinicBloc, ClinicState>(
      listener: (context, state) {
        if (state.status == ClinicStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      child: BlocBuilder<ClinicBloc, ClinicState>(
        buildWhen: (previous, current) {
          final clinicsChanged = previous.clinics != current.clinics;
          final statusChanged = previous.status != current.status;
          print(
              'Clinics changed: $clinicsChanged, Status changed: $statusChanged');
          print(
              'Previous clinics count: ${previous.clinics.length}, Current: ${current.clinics.length}');
          return clinicsChanged || statusChanged;
        },
        builder: (context, state) {
          if (state.status == ClinicStatus.initial ||
              (state.status == ClinicStatus.loading && state.clinics.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.status == ClinicStatus.failure &&
              state.clinics.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.errorMessage ?? 'Failed to load clinics'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ClinicBloc>().add(FetchClinicsEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        bool isMobile = constraints.maxWidth < 768;
                        if (isMobile) {
                          return RefreshIndicator(
                            onRefresh: () async {
                              context
                                  .read<ClinicBloc>()
                                  .add(FetchClinicsEvent());
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.clinics.length,
                              itemBuilder: (context, index) {
                                return ClinicCard(
                                    clinic: state.clinics[index]);
                              },
                            ),
                          );
                        } else {
                          return RefreshIndicator(
                            onRefresh: () async {
                              context
                                  .read<ClinicBloc>()
                                  .add(FetchClinicsEvent());
                            },
                            child: SingleChildScrollView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              child: ClinicTable(clinics: state.clinics),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (state.status == ClinicStatus.loading &&
                  state.clinics.isNotEmpty)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Clinics Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add New Clinic'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<ClinicBloc>(),
                    child: ClinicFormPage(),
                  ),
                ),
              );
              if (result == true) {
                context.read<ClinicBloc>().add(FetchClinicsEvent());
              }
            },
          ),
        ],
      ),
    );
  }
}


