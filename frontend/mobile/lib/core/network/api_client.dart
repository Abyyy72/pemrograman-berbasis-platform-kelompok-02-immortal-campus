import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Use 10.0.2.2 for Android emulator, localhost for iOS or real IP
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  static const String webBaseUrl = 'http://localhost:3000/api/v1';

  static String get effectiveBaseUrl {
    // Default to localhost for testing/desktop/web
    return webBaseUrl;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('$effectiveBaseUrl$endpoint');
    final headers = await _headers();
    return http.get(uri, headers: headers);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$effectiveBaseUrl$endpoint');
    final headers = await _headers();
    return http.post(uri, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$effectiveBaseUrl$endpoint');
    final headers = await _headers();
    return http.patch(uri, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$effectiveBaseUrl$endpoint');
    final headers = await _headers();
    return http.delete(uri, headers: headers);
  }
}
