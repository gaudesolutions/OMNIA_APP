// lib/presentation/screens/reception/reception_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/blocs/auth/auth_bloc.dart';
import 'package:medical_app/blocs/auth/auth_event.dart';
import 'package:medical_app/blocs/auth/auth_state.dart';

class ReceptionHomeScreen extends StatelessWidget {
  const ReceptionHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AuthBloc>().state;
    final user = userState is AuthAuthenticated ? userState.user : null;
    
    // App theme constants
    const Color primaryColor = Color(0xFF00A79D);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Reception Dashboard'),
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
                  elevation: 2,
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
                        if (user.clinicName != null)
                          Text('Clinic: ${user.clinicName}'),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDashboardCard(
                  context,
                  title: 'Appointment Bookings',
                  count: '12',
                  icon: Icons.calendar_today,
                  color: Colors.indigo,
                  onTap: () {},
                ),
                _buildDashboardCard(
                  context,
                  title: 'Patient Check-ins',
                  count: '7',
                  icon: Icons.how_to_reg,
                  color: Colors.teal,
                  onTap: () {},
                ),
                _buildDashboardCard(
                  context,
                  title: 'Doctor Schedules',
                  count: '5',
                  icon: Icons.schedule,
                  color: Colors.deepOrange,
                  onTap: () {},
                ),
                _buildDashboardCard(
                  context,
                  title: 'Billing',
                  count: '9',
                  icon: Icons.receipt_long,
                  color: Colors.purple,
                  onTap: () {},
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Patients',
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
    required String count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          radius: 25,
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Today: $count'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}