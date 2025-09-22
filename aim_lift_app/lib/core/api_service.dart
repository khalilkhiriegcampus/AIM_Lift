import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.137.1:8000";
  // ⚠️ Replace with your backend IP/host

  /// Save access token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", token);
  }

  /// Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access_token");
  }

  /// Login API
  static Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/login/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveToken(data["access"]);
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Login error: $e");
      return false;
    }
  }

  /// Get user profile (role + name)
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("access_token");

      if (accessToken == null) {
        print("⚠️ No access token found in storage.");
        return null;
      }

      final url = "$baseUrl/api/auth/profile/"; // ✅ Correct endpoint
      print("🌍 Fetching profile from $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );

      print("✅ Profile Status Code: ${response.statusCode}");
      print("✅ Profile Body: ${response.body}");

      if (response.statusCode == 200) {
        final profile = json.decode(response.body);
        return {
          "role": profile["role"] ?? "Client",
          "name": profile["name"] ?? "User",
        };
      }
      return null;
    } catch (e) {
      print("❌ Error fetching profile: $e");
      return null;
    }
  }

  /// Logout user (clear token)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
  }
}
