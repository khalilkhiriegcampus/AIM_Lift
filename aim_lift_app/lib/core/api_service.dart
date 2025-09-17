import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.137.1:8000";
  // ⚠️ Replace with your laptop hotspot/LAN IP if it changes

  /// Get user profile using stored access token
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("access_token");

      if (accessToken == null) {
        print("⚠️ No access token found in storage.");
        return null;
      }

      final url = "$baseUrl/api/auth/login/"; // keep as String
      print("🌍 Fetching profile from $url with token $accessToken");

      final response = await http.get(
        Uri.parse(url), // ✅ convert String → Uri
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );

      print("✅ Profile Status Code: ${response.statusCode}");
      print("✅ Profile Body: ${response.body}");

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        print("❌ Unauthorized — maybe token expired.");
        return null;
      } else {
        print("❌ Failed to fetch profile: ${response.body}");
        return null;
      }
    } catch (e) {
      print("⚠️ Exception in getProfile: $e");
      return null;
    }
  }
}
