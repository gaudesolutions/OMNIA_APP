// lib/presentation/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/blocs/auth/auth_bloc.dart';
import 'package:medical_app/blocs/auth/auth_event.dart';
import 'package:medical_app/blocs/auth/auth_state.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AuthBloc>().state;
    final user = userState is AuthAuthenticated ? userState.user : null;
    final isSuperAdmin = user?.role.toString().contains('super_admin') ?? false;
    
    // App theme constants
    const Color primaryColor = Color(0xFF00A79D);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(isSuperAdmin ? 'Super Admin Dashboard' : 'Admin Dashboard'),
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
                        const SizedBox(height: 8),
                        Text('Role: ${isSuperAdmin ? 'Super Admin' : 'Admin'}'),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDashboardCard(
                  context,
                  title: 'User Management',
                  count: '48',
                  icon: Icons.people_alt,
                  color: Colors.blue,
                  onTap: () {},
                ),
                _buildDashboardCard(
                  context,
                  title: 'Clinic Management',
                  count: '3',
                  icon: Icons.local_hospital,
                  color: Colors.green,
                  onTap: () {},
                ),
                _buildDashboardCard(
                  context,
                  title: 'Reports & Analytics',
                  count: '15',
                  icon: Icons.analytics,
                  color: Colors.amber,
                  onTap: () {},
                ),
                _buildDashboardCard(
                  context,
                  title: 'System Settings',
                  count: '6',
                  icon: Icons.settings,
                  color: Colors.red,
                  onTap: () {},
                ),
                if (isSuperAdmin)
                  _buildDashboardCard(
                    context,
                    title: 'Admin Management',
                    count: '4',
                    icon: Icons.admin_panel_settings,
                    color: Colors.deepPurple,
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
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
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
        subtitle: Text('Total: $count'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}