import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://192.168.137.1:8000";

  /// Login with username + password
  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    final url = Uri.parse("$baseUrl/api/auth/login/");
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save tokens
        final prefs = await SharedPreferences.getInstance();
        if (data["access"] != null) {
          await prefs.setString("access_token", data["access"]);
        }
        if (data["refresh"] != null) {
          await prefs.setString("refresh_token", data["refresh"]);
        }

        return data;
      } else {
        print("❌ Login failed: ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Login error: $e");
      return null;
    }
  }

  /// Refresh the access token using refresh token
  static Future<String?> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString("refresh_token");

      if (refreshToken == null) {
        print("⚠️ No refresh token found");
        return null;
      }

      final url = Uri.parse("$baseUrl/api/auth/refresh/");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refresh": refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["access"] != null) {
          await prefs.setString("access_token", data["access"]);
          print("🔄 Token refreshed successfully");
          return data["access"];
        }
      } else {
        print("❌ Refresh failed: ${response.body}");
      }
      return null;
    } catch (e) {
      print("❌ Refresh error: $e");
      return null;
    }
  }

  /// Get user profile (with auto-refresh on expired token)
  static Future<Map<String, dynamic>?> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("access_token");

    if (accessToken == null) {
      print("⚠️ No access token in storage");
      return null;
    }

    final url = Uri.parse("$baseUrl/api/auth/profile/");
    var response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );

    // If token expired, try refreshing
    if (response.statusCode == 401) {
      print("⚠️ Access token expired. Refreshing...");
      accessToken = await _refreshToken();

      if (accessToken == null) return null;

      // Retry the profile request with new token
      response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );
    }

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Failed to fetch profile: ${response.body}");
      return null;
    }
  }

  /// Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access_token");
    await prefs.remove("refresh_token");
    print("👋 Logged out. Tokens cleared.");
  }
}
