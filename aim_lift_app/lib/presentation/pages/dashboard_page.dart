import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aim_lift_app/core/api_service.dart';
import 'complaint_dashboard.dart';

class DashboardPage extends StatefulWidget {
  final String role;
  final String name;

  const DashboardPage({super.key, required this.role, required this.name});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0; // 0 = Alerts, 1 = Complaints

  // ==== ALERT DASHBOARD STATE ====
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
      }
    } catch (e) {
      setState(() => isLoading = false);
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

  Future<void> _logout(BuildContext context) async {
    await ApiService.logout();
    Navigator.pushReplacementNamed(context, "/login");
  }

  // ==== ALERT DASHBOARD VIEW ====
  Widget _buildAlertDashboard() {
    final activeCount = incidents.length;
    final criticalCount = incidents
        .where((i) => i["severity"] == "critical")
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text(
            "Hello, ${widget.name}!",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // KPI Cards
          Row(
            children: [
              _buildStatCard("Active Alerts", "$activeCount", Colors.blue),
              const SizedBox(width: 12),
              _buildStatCard("Critical", "$criticalCount", Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard("Avg Response", "3m", Colors.orange),
              const SizedBox(width: 12),
              _buildStatCard("SLA", "92%", Colors.green),
            ],
          ),
          const SizedBox(height: 24),

          // SLA Progress
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SLA Compliance",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: 0.92, // example
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.green,
                    minHeight: 12,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "92% vs Target 90%",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Incident Feed
          const Text(
            "Recent Incidents",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (incidents.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text("No active incidents right now"),
                ],
              ),
            )
          else
            Column(
              children: incidents.map((incident) {
                final severity = incident["severity"] ?? "normal";
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: _getSeverityColor(severity),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                incident["type"] ?? "Unknown Incident",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("📍 ${incident["location"] ?? "Unknown"}"),
                        Text("⏰ ${incident["timestamp"] ?? ""}"),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => _updateIncidentStatus(
                                incident["id"],
                                "acknowledge",
                              ),
                              child: const Text("Acknowledge"),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () => _updateIncidentStatus(
                                incident["id"],
                                "resolve",
                              ),
                              child: const Text("Resolve"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  // ==== KPI Helper ====
  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      _buildAlertDashboard(),
      ComplaintDashboard(role: widget.role, name: widget.name),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _selectedIndex == 0 ? "🚨 Alert Dashboard" : "📝 Complaint Dashboard",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.warning), label: "Alerts"),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Complaints",
          ),
        ],
      ),
    );
  }
}
