// lib/presentation/screens/patient/patient_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/blocs/auth/auth_bloc.dart';
import 'package:medical_app/blocs/auth/auth_event.dart';
import 'package:medical_app/blocs/auth/auth_state.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AuthBloc>().state;
    final user = userState is AuthAuthenticated ? userState.user : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${user.name}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text('Email: ${user.email}'),
                        const SizedBox(height: 16),
                        const Text(
                          'Patient Dashboard',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDashboardCard(
                  context,
                  title: 'Book Appointment',
                  icon: Icons.calendar_today,
                  color: Colors.blue,
                  description: 'Schedule a new appointment with a doctor',
                ),
                _buildDashboardCard(
                  context,
                  title: 'My Appointments',
                  icon: Icons.access_time,
                  color: Colors.green,
                  description: 'View and manage your upcoming appointments',
                ),
                _buildDashboardCard(
                  context,
                  title: 'Medical History',
                  icon: Icons.history,
                  color: Colors.purple,
                  description: 'Access your complete medical records',
                ),
                _buildDashboardCard(
                  context,
                  title: 'Prescriptions',
                  icon: Icons.medication,
                  color: Colors.orange,
                  description: 'View your current prescriptions',
                ),
                _buildDashboardCard(
                  context,
                  title: 'Find Doctor',
                  icon: Icons.search,
                  color: Colors.teal,
                  description: 'Search and connect with healthcare providers',
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          radius: 25,
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to specific section
        },
      ),
    );
  }
}
