import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'presentation/pages/landing_page.dart';

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
      home: const LandingPage(), // ✅ now it exists
    );
  }
}
