import 'package:dio/dio.dart';

class ApiService {
  final String baseUrl = "http://localhost:3000";
  final Dio _dio = Dio();

  // Ensure karein ki ye function ka naam exactly yahi ho
  Future<void> testConnection() async {
    try {
      print("Connecting to: $baseUrl");
      final response = await _dio.get(baseUrl);
      print("Backend Response: ${response.data}");
    } catch (e) {
      print("Connection Error: $e");
    }
  }

  // Aur ye wala bhi
  Future<void> loginUser(String phone) async {
    try {
      final response = await _dio.post(
        "$baseUrl/api/login",
        data: {"phoneNumber": phone},
      );
      print("Login Response: ${response.data}");
    } catch (e) {
      print("Login Error: $e");
    }
  }
}