from django.views.generic import TemplateView

class LandingView(TemplateView):
    template_name = "dashboard/landing.html"


class DashboardView(TemplateView):
    template_name = "dashboard/dashboard.html"

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)

        # 🔹 Dummy Active Incidents
        context["incidents"] = [
            {"time": "2025-09-22 10:15", "premise": "Menara JKR", "type": "Mantrap", "status": "Detected"},
            {"time": "2025-09-22 09:50", "premise": "Hospital KL", "type": "Power Failure", "status": "Acknowledged"},
        ]

        # 🔹 Dummy Premises (with lat/lng)
        context["premises"] = [
            {"name": "Menara JKR", "lat": 3.1569, "lng": 101.7123, "status": "Alert"},
            {"name": "Hospital KL", "lat": 3.1715, "lng": 101.6958, "status": "Normal"},
            {"name": "KLCC Tower", "lat": 3.1579, "lng": 101.7118, "status": "Normal"},
        ]

        # 🔹 Dummy SLA compliance data
        context["sla_labels"] = ["JKR", "Contractor A", "Contractor B"]
        context["sla_values"] = [92, 85, 78]

        # 🔹 User info
        context["user"] = {"username": "JKR Supervisor"}

        return context
