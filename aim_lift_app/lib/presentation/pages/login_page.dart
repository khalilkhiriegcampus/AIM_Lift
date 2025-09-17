import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme.dart';
import '../../core/api_service.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    print("📌 Username entered: $username");
    print(
      "📌 Password entered: $password",
    ); // ⚠️ Only for debugging, remove later!

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter username and password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final url = Uri.parse("http://192.168.137.46:8000/api/auth/login/");
    // ⚠️ Replace with your laptop's hotspot/LAN IP

    try {
      print("🌍 Sending POST to $url");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "username":
              username, // Django expects "username" (not email by default)
          "password": password,
        }),
      );

      print("✅ Status Code: ${response.statusCode}");
      print("✅ Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken = data["access"];
        final refreshToken = data["refresh"];

        print("🔑 Access Token: $accessToken");
        print("🔄 Refresh Token: $refreshToken");

        // Save tokens locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("access_token", accessToken);
        await prefs.setString("refresh_token", refreshToken);

        // Get user profile
        final profile = await ApiService.getProfile();
        print("👤 Profile: $profile");

        if (profile != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Welcome ${profile['username']}")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => DashboardPage(profile: profile)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to load profile")),
          );
        }
      } else {
        print("❌ Login failed: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid username or password")),
        );
      }
    } catch (e) {
      print("⚠️ Exception: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),

              // AIM Logo
              Center(child: Image.asset("assets/images/logo.png", height: 100)),

              const SizedBox(height: 20),

              // Title
              const Text(
                "Login to AIM-Lift",
                textAlign: TextAlign.center,
                style: AppTextStyles.heading,
              ),

              const SizedBox(height: 40),

              // Username field
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 16),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Login button
              _isLoading
                  ? const Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text("Logging in..."),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

              const SizedBox(height: 12),

              // Forgot password
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Forgot Password clicked")),
                  );
                },
                child: const Text("Forgot Password?"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ Dashboard Page shows profile data
class DashboardPage extends StatelessWidget {
  final Map<String, dynamic>? profile;
  const DashboardPage({super.key, this.profile});

  @override
  Widget build(BuildContext context) {
    final username = profile?["username"] ?? "Guest";
    final email = profile?["email"] ?? "unknown";

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Welcome, $username!",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Email: $email"),
          ],
        ),
      ),
    );
  }
}
