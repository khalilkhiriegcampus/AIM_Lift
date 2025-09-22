import 'package:flutter/material.dart';

class ComplaintDashboard extends StatefulWidget {
  final String role; // "JKR", "Contractor", "Client"
  final String name;

  const ComplaintDashboard({super.key, required this.role, required this.name});

  @override
  State<ComplaintDashboard> createState() => _ComplaintDashboardState();
}

class _ComplaintDashboardState extends State<ComplaintDashboard> {
  // Dummy complaint data (replace with API integration later)
  List<Map<String, dynamic>> complaints = [
    {
      "id": 1,
      "location": "Block A - Lift 2",
      "timestamp": "2025-09-19 14:20",
      "status": "Pending",
      "client": "ABC Mall",
      "contractor": "LiftCo",
    },
    {
      "id": 2,
      "location": "Block B - Lift 1",
      "timestamp": "2025-09-18 09:50",
      "status": "In Progress",
      "client": "XYZ Tower",
      "contractor": "LiftFix",
    },
    {
      "id": 3,
      "location": "Block C - Lift 3",
      "timestamp": "2025-09-17 10:15",
      "status": "Resolved",
      "client": "JKR HQ",
      "contractor": "LiftCo",
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "In Progress":
        return Colors.blue;
      case "Resolved":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = complaints
        .where((c) => c["status"] == "Pending")
        .length;
    final inProgressCount = complaints
        .where((c) => c["status"] == "In Progress")
        .length;
    final resolvedCount = complaints
        .where((c) => c["status"] == "Resolved")
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "📝 Complaint Dashboard - ${widget.role}",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
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

            // KPI cards
            Row(
              children: [
                _buildStatusCard(
                  "Pending",
                  pendingCount.toString(),
                  Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildStatusCard(
                  "In Progress",
                  inProgressCount.toString(),
                  Colors.blue,
                ),
                const SizedBox(width: 12),
                _buildStatusCard(
                  "Resolved",
                  resolvedCount.toString(),
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // New complaint (client only)
            if (widget.role == "Client")
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: InkWell(
                  onTap: () {
                    // TODO: Navigate to complaint form
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: const [
                        Icon(Icons.add_alert, size: 32, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          "Report Lift Problem",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (widget.role == "Client") const SizedBox(height: 24),

            // Complaint List
            const Text(
              "Complaints",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Column(
              children: complaints.map((complaint) {
                final status = complaint["status"];
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
                        Text(
                          complaint["location"],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "⏰ ${complaint["timestamp"]}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          "👤 Client: ${complaint["client"]}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        Text(
                          "🔧 Contractor: ${complaint["contractor"]}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Role-based actions
                        if (widget.role == "Contractor" && status != "Resolved")
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  // TODO: API to mark In Progress
                                },
                                child: const Text("Start Work"),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: API to mark Resolved
                                },
                                child: const Text("Mark Resolved"),
                              ),
                            ],
                          ),

                        if (widget.role == "JKR")
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  // TODO: API escalate/reassign
                                },
                                child: const Text("Reassign Contractor"),
                              ),
                              TextButton(
                                onPressed: () {
                                  // TODO: API SLA follow-up
                                },
                                child: const Text("Escalate"),
                              ),
                            ],
                          ),

                        if (widget.role == "Client" && status == "Resolved")
                          Row(
                            children: [
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.thumb_up,
                                  color: Colors.green,
                                ),
                                label: const Text("Satisfied"),
                                onPressed: () {
                                  // TODO: API feedback
                                },
                              ),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.thumb_down,
                                  color: Colors.red,
                                ),
                                label: const Text("Not Satisfied"),
                                onPressed: () {
                                  // TODO: API feedback
                                },
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
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, Color color) {
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
}
