import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/blocs/auth/auth_bloc.dart';
import 'package:medical_app/blocs/auth/auth_event.dart';
import 'package:medical_app/blocs/auth/auth_state.dart';
import 'package:medical_app/data/models/role.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController(); // Added email controller
  final _passwordController = TextEditingController();
  final _phoneNumberController =
      TextEditingController(); // Added phone controller
  final _clinicController = TextEditingController(); // Added clinic controller

  UserRole _selectedRole = UserRole.patient; // Default value
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // App theme constants
  static const Color primaryColor = Color(0xFF00A79D);
  static const Color backgroundColor = Colors.white;
  static const Color textSecondaryColor = Color(0xFF757575);

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    _clinicController.dispose();
    super.dispose();
  }

  void _onSignupPressed() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Get values from controllers
      final name = _nameController.text.trim();
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final phoneNumber = _phoneNumberController.text.trim();
      final clinic = _clinicController.text.trim();

      // Dispatch register event to AuthBloc
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              name: name,
              username: username,
              email: email,
              password: password,
              role: _selectedRole,
              phoneNumber: phoneNumber.isNotEmpty ? phoneNumber : null,
              clinic: clinic.isNotEmpty ? clinic : null,
            ),
          );

      // Listen for state changes to handle UI updates
      context.read<AuthBloc>().stream.listen((state) {
        if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });

          if (state is AuthAuthenticated) {
            // Navigate to role-specific dashboard after successful signup

            final user = state.user;
            print(user.role);
            switch (user.role) {
              case UserRole.patient:
                Navigator.of(context)
                    .pushReplacementNamed('/patient-dashboard');
                break;
              case UserRole.doctor:
                Navigator.of(context).pushReplacementNamed('/doctor-dashboard');
                break;
              case UserRole.nurse:
                Navigator.of(context).pushReplacementNamed('/nurse-dashboard');
                break;
              case UserRole.reception:
                Navigator.of(context)
                    .pushReplacementNamed('/reception-dashboard');
                break;
              case UserRole.admin:
                Navigator.of(context).pushReplacementNamed('/admin-dashboard');
                break;
              case UserRole.super_admin:
                Navigator.of(context)
                    .pushReplacementNamed('/super-admin-dashboard');
                break;
              default:
                Navigator.of(context).pushReplacementNamed('/home');
            }
          } else if (state is AuthFailure) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;
    final isLandscape = screenWidth > screenHeight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: screenHeight),
          child: isLandscape
              ? _buildLandscapeLayout(screenWidth, screenHeight)
              : _buildPortraitLayout(screenWidth, screenHeight),
        ),
      ),
    );
  }

  Widget _buildPortraitLayout(double width, double height) {
    return Column(
      children: [
        _buildTopSection(width,
            height * 0.25), // Make top section smaller to fit more fields
        _buildBottomSection(width, height * 0.75), // More space for form fields
      ],
    );
  }

  Widget _buildLandscapeLayout(double width, double height) {
    return Row(
      children: [
        SizedBox(
          width: width * 0.35, // Smaller left section
          child: _buildTopSection(width * 0.35, height),
        ),
        SizedBox(
          width: width * 0.65, // Larger right section for form
          child: _buildBottomSection(width * 0.65, height),
        ),
      ],
    );
  }

  Widget _buildTopSection(double width, double height) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor,
            primaryColor,
            primaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
          bottomLeft: Radius.circular(30),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative white circles
          _buildDecorativeElements(),

          // Doctor image
          Positioned(
            bottom: -20,
            left: 0,
            right: 0,
            child: Container(
              height: height * 0.85,
              child: Image.asset(
                'assets/images/doctor1.png',
                fit: BoxFit.fitHeight,
              ),
            ),
          ),

          // Small white circle behind doctor
          Positioned(
            bottom: height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                height: width * 0.2,
                width: width * 0.2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeElements() {
    return Stack(
      children: [
        Positioned(
          top: 40,
          left: 30,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 90,
          right: 40,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: 120,
          left: 60,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            ),
          ),
        ),
        Positioned(
          bottom: 80,
          left: -40,
          child: Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.15), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(double width, double height) {
    final fontSize = MediaQuery.of(context).textScaleFactor;
    final paddingVal = width * 0.075;

    return Container(
      height: height,
      padding:
          EdgeInsets.symmetric(horizontal: paddingVal, vertical: height * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Create Account",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryColor,
              fontSize: 24 * fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: height * 0.01),
          Text(
            "Join our healthcare solution today",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 14 * fontSize,
            ),
          ),
          SizedBox(height: height * 0.02),
          Expanded(
            child: _buildSignupForm(width, height),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm(double width, double height) {
    final fontSize = MediaQuery.of(context).textScaleFactor;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Full Name
            _buildTextField(
              controller: _nameController,
              hintText: "Full Name",
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            SizedBox(height: height * 0.015),

            // Username
            _buildTextField(
              controller: _usernameController,
              hintText: "Username",
              prefixIcon: Icons.account_circle_outlined,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a username';
                }
                return null;
              },
            ),
            SizedBox(height: height * 0.015),

            // Email
            _buildTextField(
              controller: _emailController,
              hintText: "Email Address",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                // Basic email validation
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: height * 0.015),

            // Phone number
            _buildTextField(
              controller: _phoneNumberController,
              hintText: "Phone Number (Optional)",
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: height * 0.015),

            // Password
            _buildTextField(
              controller: _passwordController,
              hintText: "Password",
              prefixIcon: Icons.lock_outline,
              obscureText: !_isPasswordVisible,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20 * fontSize,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                if (value.length < 8) {
                  return 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            SizedBox(height: height * 0.015),

            // User Role Dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<UserRole>(
                  isExpanded: true,
                  value: _selectedRole,
                  icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14 * fontSize,
                  ),
                  hint: Text(
                    "Select Role",
                    style: TextStyle(
                        color: textSecondaryColor, fontSize: 14 * fontSize),
                  ),
                  onChanged: (UserRole? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                  items: UserRole.values
                      .map<DropdownMenuItem<UserRole>>((UserRole role) {
                    return DropdownMenuItem<UserRole>(
                      value: role,
                      child: Row(
                        children: [
                          Icon(
                            _getRoleIcon(role),
                            color: primaryColor,
                            size: 20 * fontSize,
                          ),
                          SizedBox(width: 10),
                          Text(
                            _getRoleName(role),
                            style: TextStyle(fontSize: 14 * fontSize),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: height * 0.015),

            // Clinic field (show for doctors, nurses, reception)
            if (_selectedRole == UserRole.doctor ||
                _selectedRole == UserRole.nurse ||
                _selectedRole == UserRole.reception)
              Column(
                children: [
                  _buildTextField(
                    controller: _clinicController,
                    hintText: "Clinic/Hospital Name",
                    prefixIcon: Icons.local_hospital_outlined,
                    validator: (value) {
                      if (_selectedRole == UserRole.doctor &&
                          (value == null || value.isEmpty)) {
                        return 'Please enter clinic name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: height * 0.015),
                ],
              ),

            SizedBox(height: height * 0.025),
            _buildSignupButton(height),
            SizedBox(height: height * 0.02),
            _buildLoginOption(fontSize),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.patient:
        return Icons.person;
      case UserRole.doctor:
        return Icons.medical_services;
      case UserRole.nurse:
        return Icons.health_and_safety;
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.reception:
        return Icons.contact_phone;
      case UserRole.super_admin:
        return Icons.security;
      default:
        return Icons.person;
    }
  }

  String _getRoleName(UserRole role) {
    return role.toString().split('.').last.capitalize();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final fontSize = MediaQuery.of(context).textScaleFactor;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 14 * fontSize),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle:
            TextStyle(color: textSecondaryColor, fontSize: 14 * fontSize),
        prefixIcon: Icon(prefixIcon, color: primaryColor, size: 20 * fontSize),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        errorStyle: TextStyle(fontSize: 12 * fontSize),
      ),
    );
  }

  Widget _buildSignupButton(double height) {
    final buttonHeight = height * 0.06;
    final fontSize = MediaQuery.of(context).textScaleFactor;

    return Container(
      height: buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onSignupPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: buttonHeight * 0.4,
                width: buttonHeight * 0.4,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 16 * fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginOption(double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: TextStyle(
            color: textSecondaryColor,
            fontSize: 12 * fontSize,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('/login');
          },
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Login",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12 * fontSize,
            ),
          ),
        ),
      ],
    );
  }
}

// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
