import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/data/models/clinic.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_event.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_state.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic/clinicformpage.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic/clinicservice.dart';
import 'package:medical_app/presentation/screens/superadmin/components/cartlistview.dart';

class ClinicsManagementPage extends StatelessWidget {
  final ClinicService clinicService;

  const ClinicsManagementPage({Key? key, required this.clinicService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ClinicBloc(clinicService)..add(FetchClinicsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Clinics Management'),
          backgroundColor: const Color(0xFF00BFA5),
        ),
        drawer: ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: Drawer(
            backgroundColor: const Color(0xFF00BFA5),
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                children: [
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 25,
                          child: Icon(Icons.person,
                              color: Color(0xFF00BFA5), size: 30),
                        ),
                        SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alpha',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Super Admin',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDrawerItem(Icons.dashboard, 'Dashboard'),
                  _buildDrawerItem(Icons.local_hospital, 'Clinics',
                      isSelected: true),
                  _buildDrawerItem(Icons.people, 'Users'),
                  _buildDrawerItem(Icons.analytics, 'Analytics'),
                ],
              ),
            ),
          ),
        ),
        body: const ClinicListView(), 
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF00BFA5),
          child: const Icon(Icons.add),
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
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title,
      {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        selectedTileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: () {},
      ),
    );
  }
}
