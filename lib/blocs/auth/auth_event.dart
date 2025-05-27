// lib/blocs/auth/auth_event.dart
import 'package:medical_app/data/models/role.dart';

abstract class AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String username;
  final String password;

  AuthLoginRequested({required this.username, required this.password});
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String username; // Keep as separate field
  final String email;    // Add email as a separate field
  final String password;
  final UserRole role;
  final String? phoneNumber;
  final String? clinic;

  AuthRegisterRequested({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    this.phoneNumber,
    this.clinic,
  });
}

class AuthLogoutRequested extends AuthEvent {}