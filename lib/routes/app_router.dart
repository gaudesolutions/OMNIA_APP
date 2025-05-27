// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/constants.dart';
import 'package:medical_app/data/repositories/token_repository.dart';
import 'package:medical_app/presentation/screens/admin/admin_home_screen.dart';
import 'package:medical_app/presentation/screens/nurse/nurse.dart';
import 'package:medical_app/presentation/screens/reception/reception_home_screen.dart';
import 'package:medical_app/presentation/screens/splash_screen.dart';
import 'package:medical_app/presentation/screens/login_screen.dart';
import 'package:medical_app/presentation/screens/registration_screen.dart';
import 'package:medical_app/presentation/screens/doctor/doctor_home_screen.dart';
import 'package:medical_app/presentation/screens/patient/patient_home_screen.dart';
import 'package:medical_app/presentation/screens/superadmin/superadmin.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic/manageclinic.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic/clinicservice.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_bloc.dart';
// import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_management_page.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_management_screen.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service.dart'; // Added import for UserService

class AppRouter {
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      // Doctor routes
      case '/doctor-dashboard':
        return MaterialPageRoute(builder: (_) => const DoctorHomeScreen());

      // Patient routes
      case '/patient-dashboard':
        return MaterialPageRoute(builder: (_) => const PatientHomeScreen());
      
      case '/users':
        return MaterialPageRoute(
          builder: (context) => FutureBuilder<String?>(
            future: TokenRepository().getToken(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final token = snapshot.data ?? '';
                
                // Create the UserService with the token
                final userService = UserService(
                  baseUrl: AppConstants.baseUrl,
                  token: token,
                );
                
                return BlocProvider<UserBloc>(
                  create: (context) => UserBloc(userService),
                  child: const UserManagementScreen(),
                );
              } else {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        );

      // Add other role dashboards
      case '/nurse-dashboard':
        return MaterialPageRoute(builder: (_) => const NurseHomeScreen());
      case '/reception-dashboard':
        return MaterialPageRoute(builder: (_) => const ReceptionHomeScreen());
      case '/admin-dashboard':
        return MaterialPageRoute(builder: (_) => const AdminHomeScreen());
      case '/super-admin-dashboard':
        return MaterialPageRoute(builder: (_) => const SuperAdminHomeScreen());

      // Clinic management route
      case '/clinics':
        return MaterialPageRoute(
          builder: (context) {
            // Get token first
            return FutureBuilder<String?>(
              future: TokenRepository().getToken(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final token = snapshot.data ?? '';
                  
                  final clinicService = ClinicService(
                    baseUrl: AppConstants.baseUrl,
                    token: token,
                  );
                  
                  return BlocProvider<ClinicBloc>(
                    create: (context) => ClinicBloc(clinicService),
                    child: ClinicsManagementPage(
                      clinicService: clinicService,
                    ),
                  );
                } else {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            );
          },
        );

      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}