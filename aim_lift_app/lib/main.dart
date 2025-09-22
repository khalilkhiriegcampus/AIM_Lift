import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'presentation/pages/landing_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/dashboard_page.dart';

void main() {
  runApp(const AimLiftApp());
}

class AimLiftApp extends StatelessWidget {
  const AimLiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIM-Lift',
      debugShowCheckedModeBanner: false,
      theme: appTheme,

      // 👇 Initial screen
      home: const LandingPage(),

      // 👇 Route definitions
      routes: {
        "/login": (context) => const LoginPage(),
        "/dashboard": (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;

          final role = args["role"] as String? ?? "Client";
          final name = args["name"] as String? ?? "User";

          return DashboardPage(role: role, name: name);
        },
      },
    );
  }
}
