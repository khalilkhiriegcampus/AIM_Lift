import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aim_lift_app/core/api_service.dart';
// import;

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    final profile = await ApiService.getProfile();
    if (profile != null) {
      Navigator.pushReplacementNamed(
        context,
        "/dashboard",
        arguments: {
          "role": profile["role"] ?? "Client",
          "name": profile["name"] ?? "User",
        },
      );
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 simple loader like old version
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
