import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/data/models/clinic.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_event.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic/clinicformpage.dart';

class ClinicCard extends StatelessWidget {
  final Clinic clinic;

  const ClinicCard({Key? key, required this.clinic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    clinic.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: clinic.active
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    clinic.active ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: clinic.active
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on,
                '${clinic.city}, ${clinic.state} ${clinic.postalCode}'),
            _buildInfoRow(Icons.phone, clinic.phone),
            _buildInfoRow(Icons.email, clinic.email),
            _buildInfoRow(Icons.language, clinic.website),
            _buildInfoRow(Icons.people,
                '${clinic.staffCount} Staff Members'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                          value: BlocProvider.of<ClinicBloc>(context),
                          child: ClinicFormPage(clinic: clinic),
                        ),
                      ),
                    );
                    if (result == true) {
                      context.read<ClinicBloc>().add(FetchClinicsEvent());
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmation(context, clinic);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Clinic clinic) {
    showDialog(
      context: context,
      builder: (dialogContext) {
    return BlocProvider.value(
      value: context.read<ClinicBloc>(),
      child: AlertDialog(
        title: Text('Delete Clinic'),
        content: Text('Are you sure you want to delete ${clinic.name}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              context
                  .read<ClinicBloc>()
                  .add(DeleteClinicEvent(clinicId: clinic.id));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${clinic.name} deleted')),
              );
            },
          ),
        ],
      ),
    );
      },
    );
  }
}

class ClinicTable extends StatelessWidget {
  final List<Clinic> clinics;

  const ClinicTable({Key? key, required this.clinics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DataTable(
        columnSpacing: 20,
        horizontalMargin: 20,
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('City')),
          DataColumn(label: Text('State')),
          DataColumn(label: Text('Phone')),
          DataColumn(label: Text('Staff Count')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: clinics.map((clinic) {
          return DataRow(
            cells: [
              DataCell(Text(clinic.name)),
              DataCell(Text(clinic.city)),
              DataCell(Text(clinic.state)),
              DataCell(Text(clinic.phone)),
              DataCell(Text(clinic.staffCount.toString())),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: clinic.active
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    clinic.active ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: clinic.active
                          ? Colors.green.shade800
                          : Colors.red.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: BlocProvider.of<ClinicBloc>(context),
                              child: ClinicFormPage(clinic: clinic),
                            ),
                          ),
                        );
                        if (result == true) {
                          context.read<ClinicBloc>().add(FetchClinicsEvent());
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        _showDeleteConfirmation(context, clinic);
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Clinic clinic) {
    showDialog(
  context: context,
  builder: (dialogContext) {
    return BlocProvider.value(
      value: context.read<ClinicBloc>(),
      child: AlertDialog(
        title: Text('Delete Clinic'),
        content: Text('Are you sure you want to delete ${clinic.name}?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              // Use the parent context or dialogContext (if properly wrapped)
              context.read<ClinicBloc>().add(DeleteClinicEvent(clinicId: clinic.id));
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${clinic.name} deleted')),
              );
            },
          ),
        ],
      ),
    );
  },
);

  }




}