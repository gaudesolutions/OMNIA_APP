// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/blocs/auth/auth_bloc.dart';
import 'package:medical_app/blocs/auth/auth_event.dart';
import 'package:medical_app/data/repositories/auth_repository.dart';
import 'package:medical_app/data/repositories/user_repository.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_bloc.dart';
import 'package:medical_app/routes/app_router.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic/clinicservice.dart';
import 'package:medical_app/constants.dart';
import 'package:medical_app/data/repositories/token_repository.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthRepository authRepository = AuthRepository();
  final UserRepository userRepository = UserRepository();
  final TokenRepository tokenRepository = TokenRepository();
  final AppRouter appRouter = AppRouter();
  ClinicBloc? clinicBloc;
  UserBloc? userBloc; // Add this line
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeBlocs();
  }

  Future<void> _initializeBlocs() async {
    final token = await tokenRepository.getToken() ?? '';
    final clinicService = ClinicService(
      baseUrl: AppConstants.baseUrl,
      token: token,
    );
    
    // Create UserService with the same token
    final userService = UserService( // You'll need to create this service
      baseUrl: AppConstants.baseUrl,
      token: token,
    );
    
    setState(() {
      clinicBloc = ClinicBloc(clinicService);
      userBloc = UserBloc(userService); // Add this line
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

return MultiRepositoryProvider(
  providers: [
    RepositoryProvider.value(value: authRepository),
    RepositoryProvider.value(value: userRepository),
    RepositoryProvider.value(value: tokenRepository),
  ],
  child: MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => AuthBloc(
          authRepository: authRepository,
          userRepository: userRepository,
        )..add(AuthCheckStatus()),
      ),
      BlocProvider.value(
        value: clinicBloc!,
      ),
      BlocProvider.value( // Add this block
        value: userBloc!,
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medical Services App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      onGenerateRoute: appRouter.onGenerateRoute,
      initialRoute: '/',
    ),
  ),
);
  }
}