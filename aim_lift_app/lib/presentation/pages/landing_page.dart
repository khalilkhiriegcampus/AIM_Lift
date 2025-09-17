import 'package:flutter/material.dart';
import 'login_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/landing.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Dark overlay
          Container(color: Colors.black.withOpacity(0.5)),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ✅ AIM + JKR Logos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logo.png", // AIM logo
                          height: 80,
                        ),
                        const SizedBox(width: 20),
                        Image.asset(
                          "assets/images/jkr_logo.png", // JKR logo
                          height: 80,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // ✅ Title
                    const Text(
                      "Monitoring Lifts\nNot Just Machines",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),

                    // ✅ Description
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        "Real-time monitoring, alerts, and predictive analysis "
                        "to keep lifts safe and reliable for everyone.",
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ✅ Login button (full width)
                    SizedBox(
                      width: 220, // fixed button width (adjust as needed)
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text("Login"),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ✅ Sign Up button (full width)
                    SizedBox(
                      width: 220, // fixed button width (adjust as needed)
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Sign Up clicked")),
                          );
                        },
                        icon: const Icon(Icons.app_registration),
                        label: const Text("Sign Up"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
