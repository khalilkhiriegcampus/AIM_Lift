import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aim_lift_app/core/api_service.dart';

class DashboardPage extends StatefulWidget {
  final String role;
  const DashboardPage({super.key, required this.role});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List incidents = [];
  bool isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchIncidents();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _fetchIncidents();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchIncidents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");

      final response = await http.get(
        Uri.parse("${ApiService.baseUrl}/api/incidents/active/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          incidents = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("⚠️ Failed to load incidents: ${response.statusCode}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("❌ Error fetching incidents: $e");
    }
  }

  Future<void> _updateIncidentStatus(int id, String action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("access_token");

      final response = await http.post(
        Uri.parse("${ApiService.baseUrl}/api/incidents/$id/$action/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        _fetchIncidents();
      } else {
        print("⚠️ Failed to $action incident $id: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error updating incident: $e");
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case "critical":
        return Colors.red;
      case "warning":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _getSeverityLabel(String severity) {
    switch (severity.toLowerCase()) {
      case "critical":
        return "Critical";
      case "warning":
        return "Warning";
      default:
        return "Normal";
    }
  }

  Future<void> _logout(BuildContext context) async {
    await ApiService.logout();
    Navigator.pushReplacementNamed(context, "/login");
  }

  // 🔹 KPI Card Helper
  Widget _buildKpiCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final criticalCount = incidents
        .where((i) => i["severity"] == "critical")
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text("🚨 Alert Dashboard - ${widget.role}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: "Logout",
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 🔹 KPI Summary Row
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      _buildKpiCard(
                        "Active",
                        incidents.length.toString(),
                        Colors.blue,
                      ),
                      _buildKpiCard(
                        "Critical",
                        criticalCount.toString(),
                        Colors.red,
                      ),
                      _buildKpiCard("Avg Resp.", "3m", Colors.orange),
                      _buildKpiCard("SLA", "92%", Colors.green),
                    ],
                  ),
                ),

                // 🔹 Incident Grid or Empty State
                Expanded(
                  child: incidents.isEmpty
                      ? const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_box,
                                color: Colors.green,
                                size: 28,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "No active incidents",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2 cards per row
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1, // square-ish
                              ),
                          itemCount: incidents.length,
                          itemBuilder: (context, index) {
                            final incident = incidents[index];
                            final severity = incident["severity"] ?? "normal";

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: _getSeverityColor(severity),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            incident["type"] ?? "Unknown",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "📍 ${incident["location"]}",
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      "⏰ ${incident["timestamp"]}",
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Spacer(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.done,
                                            color: Colors.blue,
                                          ),
                                          onPressed: () =>
                                              _updateIncidentStatus(
                                                incident["id"],
                                                "acknowledge",
                                              ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                          ),
                                          onPressed: () =>
                                              _updateIncidentStatus(
                                                incident["id"],
                                                "resolve",
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
