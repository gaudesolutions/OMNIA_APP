import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medical_app/data/models/clinic.dart';
// import 'package:medical_app/data/models/clinic_statistics.dart';

class ClinicService {
  final String baseUrl;
  final String token;
  
  ClinicService({required this.baseUrl, required this.token});
  
  Map<String, String> get headers => {
    'Authorization': 'Token $token',
    'Content-Type': 'application/json',
  };

  Future<List<Clinic>> fetchClinics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/clinics/clinics/'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Clinic.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clinics: ${response.body}');
    }
  }

  Future<Clinic> createClinic(Clinic clinic) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/clinics/clinics/'),
      headers: headers,
      body: json.encode(clinic.toJson()),
    );
    print(response.body);
    print('sssssssssssssssssssssssssss');
    print(token);
    if (response.statusCode == 201) {
      return Clinic.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create clinic: ${response.body}');
    }
  }

  Future<Clinic> updateClinic(Clinic clinic) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/clinics/clinics/${clinic.id}/'),
      headers: headers,
      body: json.encode(clinic.toJson()),
    );
    print(headers);
    print('eeeeeeeeeeeeeeeeeeeeeeee');
    if (response.statusCode == 200) {
      return Clinic.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update clinic: ${response.body}');
    }
  }

  Future<void> deleteClinic(int clinicId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/clinics/clinics/$clinicId/'),
      headers: headers,
    );
     print(headers);
    print('eeeeeeeeeeeeeeeeeeeeeeee');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete clinic: ${response.body}');
    }
  }

  Future<ClinicStatistics> getClinicStatistics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/clinics/clinics/statistics/'),
      headers: headers,
    );
     print(headers);
    print('eeeeeeeeeeeeeeeeeeeeeeee');
    if (response.statusCode == 200) {
      return ClinicStatistics.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load clinic statistics: ${response.body}');
    }
  }
}