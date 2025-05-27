// lib/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/blocs/auth/auth_bloc.dart';
import 'package:medical_app/blocs/auth/auth_event.dart';
import 'package:medical_app/blocs/auth/auth_state.dart';
import 'package:medical_app/data/models/role.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<AuthBloc>().state;
    final user = userState is AuthAuthenticated ? userState.user : null;
    
    // Check user role and redirect to appropriate dashboard
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        switch (user.role) {
          case UserRole.patient:
            Navigator.of(context).pushReplacementNamed('/patient-dashboard');
            break;
          case UserRole.doctor:
            Navigator.of(context).pushReplacementNamed('/doctor-dashboard');
            break;
          case UserRole.nurse:
            Navigator.of(context).pushReplacementNamed('/nurse-dashboard');
            break;
          case UserRole.reception:
            Navigator.of(context).pushReplacementNamed('/reception-dashboard');
            break;
          case UserRole.admin:
          case UserRole.super_admin:
            Navigator.of(context).pushReplacementNamed('/admin-dashboard');
            break;
          default:
            // Stay on this generic home screen
            break;
        }
      });
    }
    
    // App theme constants
    const Color primaryColor = Color(0xFF00A79D);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Medical App'),
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
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your profile...'),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: primaryColor, size: 80),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome, ${user.name}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text('Redirecting to your dashboard...'),
                ],
              ),
            ),
    );
  }
}