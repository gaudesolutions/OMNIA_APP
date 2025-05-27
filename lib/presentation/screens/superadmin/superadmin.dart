import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/blocs/auth/auth_bloc.dart';
import 'package:medical_app/blocs/auth/auth_event.dart';
import 'package:medical_app/blocs/auth/auth_state.dart';
import 'package:medical_app/constants.dart';
import 'package:medical_app/data/repositories/auth_repository.dart';
import 'package:medical_app/data/repositories/token_repository.dart';
import 'package:medical_app/data/repositories/user_repository.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic/clinicservice.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic/manageclinic.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_event.dart';
import 'package:medical_app/presentation/screens/superadmin/clinic_management_bloc/clinic_management_state.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_event.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_state.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_management_screen.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_stats_view.dart';

class SuperAdminHomeScreen extends StatefulWidget {
  const SuperAdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<SuperAdminHomeScreen> createState() => _SuperAdminHomeScreenState();
}

class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen> {
  // App theme constants
  static const Color primaryColor = Color(0xFF00A79D);
  static const Color backgroundColor = Colors.white;
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color cardColor = Colors.white;

  late String _username;
  late UserBloc _userBloc;
  late ClinicBloc _clinicBloc;

  @override
  void initState() {
    super.initState();
    // Get user info from AuthBloc
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated && authState.user.name != null) {
      _username =
          authState.user.name.isNotEmpty ? authState.user.name : "Admin";
      print("Username set to: $_username"); // Add debug logging
    } else {
      _username = "Admin";
      print("Using default username: Admin"); // Add debug logging
    }
    
    // Initialize blocs
    _initializeBlocs();
  }
  
  Future<void> _initializeBlocs() async {
    final token = await TokenRepository().getToken() as String;
    if (token.isNotEmpty) {
      final userService = UserService(
        baseUrl: AppConstants.baseUrl,
        token: token,
      );
      
      final clinicService = ClinicService(
        baseUrl: AppConstants.baseUrl,
        token: token,
      );
      
      _userBloc = UserBloc(userService)..add(FetchUserStatsEvent());
      _clinicBloc = ClinicBloc(clinicService)..add(FetchClinicsEvent());
      
      if (mounted) {
        setState(() {});
      }
    }
  }

  // Function to handle logout
  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ?? false;

    if (shouldLogout) {
      // Clear tokens and user data
      await TokenRepository().deleteToken();
      await UserRepository().deleteUser();
      
      // Dispatch logout event to AuthBloc
   context.read<AuthBloc>().add(AuthLogoutRequested());
      
      // Navigate to login screen and clear the navigation stack
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', 
        (route) => false
      );
    }
  }

  @override
  void dispose() {
    // Don't close the blocs here if they're provided at a higher level
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isLandscape = screenWidth > screenHeight;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _userBloc),
        BlocProvider.value(value: _clinicBloc),
      ],
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight),
            child: isLandscape
                ? _buildLandscapeLayout(screenWidth, screenHeight)
                : _buildPortraitLayout(screenWidth, screenHeight),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(double width, double height) {
    return Column(
      children: [
        _buildCombinedHeaderSection(width, height * 0.25),
        _buildBottomSection(width, height * 0.75),
      ],
    );
  }

  Widget _buildLandscapeLayout(double width, double height) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width * 0.4,
          child: _buildCombinedHeaderSection(width * 0.4, height),
        ),
        SizedBox(
          width: width * 0.6,
          child: _buildBottomSection(width * 0.6, height),
        ),
      ],
    );
  }

  Widget _buildCombinedHeaderSection(double width, double height) {
    return Container(
      width: width,
      constraints: BoxConstraints(minHeight: height),
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Bar Equivalent
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Super Admin Dashboard",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              // Profile Avatar with Logout functionality
              GestureDetector(
                onTap: _handleLogout,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 18,
                  child: Text(
                    _getInitials(_username),
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          // Content Section
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: primaryColor,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Super Admin",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Welcome,",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _capitalizeName(_username),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Stats Container - Now using BlocBuilder for dynamic updates
          BlocBuilder<UserBloc, UserState>(
            buildWhen: (previous, current) {
              return previous.statistics != current.statistics;
            },
            builder: (context, userState) {
              return BlocBuilder<ClinicBloc, ClinicState>(
                buildWhen: (previous, current) {
                  return previous.clinics.length != current.clinics.length;
                },
                builder: (context, clinicState) {
                  final clinicsCount = clinicState.clinics.length.toString();
                  
                  // Extract user statistics
                  int totalUsers = 0;
                  int doctorsCount = 0;
                  
                  if (userState.statistics != null) {
                    final stats = userState.statistics!;
                    totalUsers = stats.superAdmin + stats.admin + stats.doctor + stats.nurse + stats.reception;
                    doctorsCount = stats.doctor;
                  }
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickStat(
                          title: "Clinics",
                          value: clinicsCount,
                          icon: Icons.local_hospital_rounded,
                          color: const Color(0xFF4A90E2),
                          isLoading: clinicState.status == ClinicStatus.loading,
                        ),
                        Container(
                          height: 35,
                          width: 1,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        _buildQuickStat(
                          title: "Users",
                          value: totalUsers.toString(),
                          icon: Icons.people_rounded,
                          color: const Color(0xFF9B51E0),
                          isLoading: userState.status == UserStatus.loading,
                        ),
                        Container(
                          height: 35,
                          width: 1,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        _buildQuickStat(
                          title: "Doctors",
                          value: doctorsCount.toString(),
                          icon: Icons.medical_services_rounded,
                          color: const Color(0xFFE67E22),
                          isLoading: userState.status == UserStatus.loading,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isLoading = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 18,
        ),
        const SizedBox(height: 6),
        isLoading 
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            : Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF333333),
                ),
              ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            color: textSecondaryColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(double width, double height) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Quick Actions",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          // Manage Clinics
          Builder(
            builder: (context) => _buildActionCard(
              icon: Icons.local_hospital_rounded,
              title: "Manage Clinics",
              description:
                  "Add, edit, or remove clinics from the system. Update clinic details and services.",
              color: const Color(0xFF4A90E2),
              onTap: () async {
                // Push to clinics management and refresh stats upon return
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: _clinicBloc,
                      child: ClinicsManagementPage(
                        clinicService: _clinicBloc.clinicService,
                      ),
                    ),
                  ),
                );
                
                // Refresh stats when returning to this screen
                _userBloc.add(FetchUserStatsEvent());
                _clinicBloc.add(FetchClinicsEvent());
              },
            ),
          ),
          const SizedBox(height: 16),
          // Manage Users
          Builder(
            builder: (context) => _buildActionCard(
              icon: Icons.people_rounded,
              title: "Manage Users",
              description:
                  "Add new users, edit permissions, manage roles and access control for all users.",
              color: const Color(0xFF9B51E0),
              onTap: () async {
                // Push to user management and refresh stats upon return
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: _userBloc,
                      child: UserManagementScreen(),
                    ),
                  ),
                );
                
                // Refresh stats when returning to this screen
                _userBloc.add(FetchUserStatsEvent());
              },
            ),
          ),
          const SizedBox(height: 16),
          // System Analytics
          Builder(
            builder: (context) => _buildActionCard(
              icon: Icons.insert_chart_rounded,
              title: "System Analytics",
              description:
                  "View detailed statistics and analytics about system usage, appointments, and more.",
              color: const Color(0xFFE67E22),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Scaffold(
                      appBar: AppBar(
                        title: const Text('System Analytics'),
                        backgroundColor: const Color(0xFF00A79D),
                        elevation: 0,
                      ),
                      backgroundColor: Colors.white,
                      body: SafeArea(
                        child: BlocProvider.value(
                          value: _userBloc..add(FetchUserStatsEvent())..add(FetchUsersByClinicEvent()),
                          child: const UserStatsView(),
                        ),
                      ),
                    ),
                  ),
                );
                
                // Refresh stats when returning to this screen
                _userBloc.add(FetchUserStatsEvent());
                _clinicBloc.add(FetchClinicsEvent());
              },
            ),
          ),
          const SizedBox(height: 16),
          // Logout Option
          Builder(
            builder: (context) => _buildActionCard(
              icon: Icons.logout,
              title: "Logout",
              description:
                  "Log out from your account and return to the login screen.",
              color: const Color(0xFFE53E3E),
              onTap: _handleLogout,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.01),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 12,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _capitalizeName(String? name) {
    if (name == null || name.isEmpty) return '';

    List<String> nameParts = name.split(' ');
    List<String> capitalizedParts = [];

    for (var part in nameParts) {
      if (part.isNotEmpty) {
        capitalizedParts.add(part[0].toUpperCase() + part.substring(1));
      }
    }

    return capitalizedParts.join(' ');
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '';

    List<String> nameParts =
        name.split(' ').where((part) => part.isNotEmpty).toList();

    if (nameParts.isEmpty) return '';

    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }

    return (nameParts[0][0] + nameParts[1][0]).toUpperCase();
  }
}