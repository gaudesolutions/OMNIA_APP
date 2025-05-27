import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/blocs/auth/auth_bloc.dart';
import 'package:medical_app/blocs/auth/auth_state.dart';
import 'package:medical_app/data/models/role.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
           print(state.user.role);
          // Navigate based on user role
          switch (state.user.role) {
            
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
              Navigator.of(context).pushReplacementNamed('/admin-dashboard');
              break;
            case UserRole.super_admin:
              Navigator.of(context).pushReplacementNamed('/super-admin-dashboard');
              break;
            default:
              Navigator.of(context).pushReplacementNamed('/home');
          }
        } else if (state is AuthUnauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logo.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text(
                'Medical Services App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}