import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/blocs/auth/auth_bloc.dart';
import 'package:medical_app/blocs/auth/auth_event.dart';
import 'package:medical_app/blocs/auth/auth_state.dart';
import 'package:medical_app/data/models/role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // App theme constants
  static const Color primaryColor = Color(0xFF00A79D);
  static const Color backgroundColor = Colors.white;
  static const Color textSecondaryColor = Color(0xFF757575);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

 void _onLoginPressed() {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });
    
    // Get the username and password from controllers
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    
    // Dispatch login event to AuthBloc
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        username: username,
        password: password,
      ),
    );
    
    // Listen for state changes to handle UI updates
    // This can be moved to initState if you want to listen throughout the widget lifecycle
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
  // Navigate to role-specific dashboard after successful login
  final user = state.user;
   print(user.role);
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
    Navigator.of(context).pushReplacementNamed('/admin-dashboard');
      break;
    case UserRole.super_admin:
      Navigator.of(context).pushReplacementNamed('/super-admin-dashboard');
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
        _buildTopSection(width, height * 0.4),
        _buildBottomSection(width, height * 0.6),
      ],
    );
  }

  Widget _buildLandscapeLayout(double width, double height) {
    return Row(
      children: [
        SizedBox(
          width: width * 0.4,
          child: _buildTopSection(width * 0.4, height),
        ),
        SizedBox(
          width: width * 0.6,
          child: _buildBottomSection(width * 0.6, height),
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
        borderRadius: 
          const BorderRadius.only(
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
                 bottomLeft: Radius.circular(30),
                // bottomRight: Radius.circular(30),
              )
          
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
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
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
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
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
      padding: EdgeInsets.symmetric(horizontal: paddingVal, vertical: height * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Healthcare Solution",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryColor,
              fontSize: 24 * fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: height * 0.01),
          Text(
            "Early protection for lovely health family",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSecondaryColor,
              fontSize: 14 * fontSize,
            ),
          ),
          SizedBox(height: height * 0.04),
          Expanded(
            child: _buildLoginForm(width, height),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(double width, double height) {
    final fontSize = MediaQuery.of(context).textScaleFactor;
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _usernameController,
            hintText: "username",
            prefixIcon: Icons.person_outline,
            
          ),
          SizedBox(height: height * 0.02),
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
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          SizedBox(height: height * 0.01),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                padding: EdgeInsets.zero,
                minimumSize: Size(50, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12 * fontSize,
                ),
              ),
            ),
          ),
          SizedBox(height: height * 0.03),
          _buildLoginButton(height),
          SizedBox(height: height * 0.02),
          _buildSignUpOption(fontSize),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final fontSize = MediaQuery.of(context).textScaleFactor;
    
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: TextStyle(fontSize: 14 * fontSize),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textSecondaryColor, fontSize: 14 * fontSize),
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

  Widget _buildLoginButton(double height) {
    final buttonHeight = height * 0.08;
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
        onPressed: _isLoading ? null : _onLoginPressed,
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
                "Login",
                style: TextStyle(
                  fontSize: 16 * fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSignUpOption(double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(
            color: textSecondaryColor,
            fontSize: 12 * fontSize,
          ),
        ),
        TextButton(
          onPressed: () {
                      Navigator.of(context).pushNamed('/register');

          },
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            minimumSize: const Size(50, 30),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            "Sign up",
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