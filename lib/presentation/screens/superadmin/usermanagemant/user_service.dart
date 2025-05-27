import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medical_app/data/models/user.dart';


class UserService {
  final String baseUrl;
  final String token;
  
  UserService({required this.baseUrl, required this.token});
  
  Map<String, String> get headers => {
    'Authorization': 'Token 931eeee02c0575dbdecd33c879b1c8911127df7c',
    'Content-Type': 'application/json',
  };

  Future<List<User1>> fetchUsers({String? search}) async {
    final uri = Uri.parse('$baseUrl/api/accounts/admin/users/').replace(
      queryParameters: search != null ? {'search': search} : null,
    );
    
    final response = await http.get(uri, headers: headers);
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => User1.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users: ${response.body}');
    }
  }

  Future<User1> createUser(User1 user, String password) async {
    final userData = user.toJson();
    userData['password'] = password;
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/accounts/admin/users/'),
      headers: headers,
      body: json.encode(userData),
    );
    
    if (response.statusCode == 201) {
      return User1.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  Future<User1> updateUser(User1 user, {String? password}) async {
    final userData = user.toJson();
    if (password != null && password.isNotEmpty) {
      userData['password'] = password;
    }
    
    final response = await http.put(
      Uri.parse('$baseUrl/api/accounts/admin/users/${user.id}/'),
      headers: headers,
      body: json.encode(userData),
    );
    
    if (response.statusCode == 200) {
      return User1.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  Future<void> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/accounts/admin/users/$userId/'),
      headers: headers,
    );
    
    if (response.statusCode != 204) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }
  
  Future<UserStatistics> getUserStatistics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/accounts/admin/users/by_role/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return UserStatistics.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user statistics: ${response.body}');
    }
  }
  
  Future<List<ClinicUserCount>> getUsersByClinic() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/accounts/admin/users/by_clinic/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ClinicUserCount.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users by clinic: ${response.body}');
    }
  }
}