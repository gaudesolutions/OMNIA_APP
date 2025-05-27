// lib/data/repositories/auth_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medical_app/constants.dart';
import 'package:medical_app/data/models/user.dart';
import 'package:medical_app/data/models/role.dart';
import 'package:medical_app/data/repositories/token_repository.dart';

class AuthRepository {
 

  Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/api/accounts/login/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': email,
          'password': password,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        print('Login successful: ${response.body}');
        final data = json.decode(response.body);
        final userData = data['user'];
        final token = data['token'];
      await TokenRepository().saveToken(token);

        // Convert the API's user_type to your UserRole enum
        UserRole role;
        switch (userData['user_type']) {
          case 'doctor':
            role = UserRole.doctor;
            break;
          case 'reception':
            role = UserRole.reception;
            break;
          case 'nurse':
            role = UserRole.nurse;
            break;
          case 'admin':
            role = UserRole.admin;
            break;
          case 'super_admin':
            role = UserRole.super_admin;
            break;
          default:
            role = UserRole.patient;
        }

        // Save token somewhere (shared preferences or secure storage)
        // final token = data['token'];
        // TODO: Save token using your preferred storage method

        return User(
          id: userData['id'].toString(),
          name: '${userData['first_name']} ${userData['last_name']}',
          email: userData['email'],
          role: role,
          // Add any other fields you need
        );
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }



Future<User?> register({
  required String name,
  required String email,
  required String username,
  required String password,
  required UserRole role,
  String? phoneNumber,
  String? clinic,
}) async {
  try {
    // Split name into first_name and last_name
    final nameParts = name.split(' ');
    final firstName = nameParts.first;
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    // Create request body with all required fields
    final Map requestBody = {
      'username': username,
      'email': email,
      'password': password,
      'first_name': firstName,
      'last_name': lastName,
      'user_type': role.toString().split('.').last,
    };
    
    // Add optional fields if provided
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      requestBody['phone_number'] = phoneNumber;
    }
    
    if (clinic != null && clinic.isNotEmpty) {
      requestBody['clinic'] = clinic;
    }
    
    print('Registration request: $requestBody');
    
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/api/accounts/register/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );
    
    print('Registration status code: ${response.statusCode}');
    print('Registration response: ${response.body}');
    
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final userData = data['user']; // Extract the user object from response
      final token = data['token'];
      await TokenRepository().saveToken(token);
      
      // Convert the API's user_type to your UserRole enum
      UserRole responseRole;
      switch (userData['user_type']) { // Access user_type within the userData object
        case 'doctor':
          responseRole = UserRole.doctor;
          break;
        case 'reception':
          responseRole = UserRole.reception;
          break;
        case 'nurse':
          responseRole = UserRole.nurse;
          break;
        case 'admin':
          responseRole = UserRole.admin;
          break;
        case 'super_admin':
          responseRole = UserRole.super_admin;
          break;
        default:
          responseRole = UserRole.patient;
      }
      
      return User(
        id: userData['id'].toString(), // Access id from userData
        name: '$firstName $lastName',
        email: email,
        username: username,
        role: responseRole,  // Using the converted role from response
        phoneNumber: phoneNumber,
        clinicName: clinic,
      );
    } else {
      // Parse and print error for debugging
      print('Registration failed: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Registration error: $e');
    return null;
  }
}
  Future<void> logout() async {
    try {
      final token = await TokenRepository().getToken();
      // Get token from storage
      // final token = ''; // TODO: Get token from your storage

      await http.post(
        Uri.parse('${AppConstants.baseUrl}/accounts/logout/'),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
      );
  await TokenRepository().deleteToken();
      // Clear local token storage
      // TODO: Clear token from your storage

      return;
    } catch (e) {
      print('Logout error: $e');
    }
  }
}
